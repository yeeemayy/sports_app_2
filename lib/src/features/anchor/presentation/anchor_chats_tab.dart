import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'package:sports_app/src/features/anchor/domain/models/im_token_model.dart';
import 'package:sports_app/src/features/anchor/presentation/providers/im_token_providers.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';

class AnchorChatsTab extends ConsumerStatefulWidget {
  const AnchorChatsTab({super.key, required this.anchorId});

  final int anchorId;

  @override
  ConsumerState<AnchorChatsTab> createState() => _AnchorChatsTabState();
}

class _AnchorChatsTabState extends ConsumerState<AnchorChatsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  RCIMIWEngine? _engine;
  String? _roomCid;
  String? _myId;
  String? _myName;
  final List<_ChatMessage> _messages = [];
  final List<_ChatMessage> _bufferedMessages = [];
  // Entry message waiting to be appended after history flushes.
  _ChatMessage? _pendingEntryMsg;
  bool _initialSyncDone = false;
  bool _connecting = false;
  bool _connected = false;
  bool _connectError = false;
  bool _entryMessageSent = false;
  bool _didRetry34001 = false;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Force a fresh IM token every time this tab is entered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(imTokenProvider(widget.anchorId));
    });
  }

  @override
  void dispose() {
    if (_engine != null && _roomCid != null) {
      _engine!.leaveChatRoom(_roomCid!);
      _engine!.disconnect(false);
      _engine!.destroy();
    }
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _reinitChat() async {
    if (_engine != null && _roomCid != null) {
      _engine!.leaveChatRoom(_roomCid!);
      _engine!.disconnect(false);
      _engine!.destroy();
      _engine = null;
    }
    setState(() {
      _connecting = false;
      _connected = false;
      _connectError = false;
      _entryMessageSent = false;
      _didRetry34001 = false;
      _initialSyncDone = false;
      _pendingEntryMsg = null;
      _messages.clear();
      _bufferedMessages.clear();
      _roomCid = null;
      _myId = null;
      _myName = null;
    });
    ref.invalidate(imTokenProvider(widget.anchorId));
  }

  /// Flush buffered history messages into [_messages] and append any pending
  /// entry message at the end. Idempotent — safe to call multiple times.
  void _flushHistory() {
    if (_initialSyncDone) return;
    setState(() {
      _initialSyncDone = true;
      _messages.addAll(_bufferedMessages);
      _bufferedMessages.clear();
      if (_pendingEntryMsg != null) {
        _messages.add(_pendingEntryMsg!);
        _pendingEntryMsg = null;
      }
    });
    _scrollToBottom();
  }

  Future<void> _initChat(ImTokenModel tokenData) async {
    if (_engine != null || _connecting) return;
    if (mounted) setState(() => _connecting = true);

    _roomCid = tokenData.cid;
    _myId = tokenData.id;
    // Prefer the logged-in user's nickname from auth state over the IM token name
    final authUser = ref.read(authNotifierProvider).valueOrNull?.user;
    _myName = authUser?.nickname ?? tokenData.name;

    final options = RCIMIWEngineOptions.create();
    _engine = await RCIMIWEngine.create(tokenData.appKey, options);

    _engine!.onMessageReceived =
        (RCIMIWMessage? message, int? left, bool? offline, bool? hasPackage) {
      if (!mounted || message == null) return;
      if (message.targetId != _roomCid) return;
      if (message is! RCIMIWTextMessage) return;

      final senderName = message.userInfo?.name ?? message.senderUserId ?? '';
      final text = message.text ?? '';
      if (text.isEmpty) return;

      final chatMsg = _ChatMessage(
        senderName: senderName,
        senderId: message.senderUserId ?? '',
        text: text,
        isOwn: message.senderUserId == _myId,
      );

      if (offline == true) {
        if (_initialSyncDone) {
          // The empty-room fallback already marked sync complete before these
          // offline messages arrived — add directly so they are not lost.
          setState(() => _messages.add(chatMsg));
          _scrollToBottom();
        } else {
          // History/offline message — buffer until the last one arrives (left == 0).
          setState(() => _bufferedMessages.add(chatMsg));
          if ((left ?? 0) == 0) {
            // Last history message received — flush buffer, then show pending entry.
            _flushHistory();
          }
        }
      } else {
        // Live message. If history hasn't flushed yet, flush now so the entry
        // message (if pending) appears before any live messages.
        if (!_initialSyncDone) _flushHistory();
        setState(() => _messages.add(chatMsg));
        _scrollToBottom();
      }
    };

    Future<void> onConnectedResult(int? code) async {
      if (code == 0) {
        final joinCode = await _engine!.joinChatRoom(_roomCid!, 0, false);
        if (mounted) {
          setState(() {
            _connecting = false;
            _connected = joinCode == 0;
            _connectError = joinCode != 0;
          });
          if (joinCode == 0) {
            // Fallback: if no offline messages ever arrive (empty room or
            // non-logged-in viewer), mark sync complete after 3 s so the
            // "connecting" banner is dismissed.
            Future.delayed(const Duration(milliseconds: 3000), () {
              if (mounted && !_initialSyncDone) _flushHistory();
            });
            // Only send the entry message when the user is logged in.
            final isLoggedIn =
                ref.read(authNotifierProvider).valueOrNull?.isAuthenticated ?? false;
            if (isLoggedIn) {
              // Delay so that the chatroom's offline message batch starts
              // arriving before we send the entry message.
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted && !_entryMessageSent) {
                  _entryMessageSent = true;
                  _sendEntryMessage();
                }
              });
            }
          }
        }
      } else if (code == 34001 && mounted && _engine != null && !_didRetry34001) {
        // 34001: server still has a previous session active — wait briefly and retry once.
        _didRetry34001 = true;
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted || _engine == null) return;
        await _engine!.connect(
          tokenData.token,
          30,
          callback: RCIMIWConnectCallback(
            onConnected: (int? retryCode, String? userId) async {
              if (mounted) await onConnectedResult(retryCode);
            },
          ),
        );
      } else {
        if (mounted) {
          setState(() {
            _connecting = false;
            _connectError = true;
          });
        }
      }
    }

    await _engine!.connect(
      tokenData.token,
      30,
      callback: RCIMIWConnectCallback(
        onConnected: (int? code, String? userId) async {
          if (mounted) await onConnectedResult(code);
        },
      ),
    );
  }

  Future<void> _retryConnect() async {
    _engine?.destroy();
    _engine = null;
    setState(() {
      _connecting = false;
      _connected = false;
      _connectError = false;
      _entryMessageSent = false;
      _didRetry34001 = false;
      _initialSyncDone = false;
      _pendingEntryMsg = null;
      _messages.clear();
      _bufferedMessages.clear();
    });
    final tokenAsync = ref.read(imTokenProvider(widget.anchorId));
    tokenAsync.whenData((token) => _initChat(token));
  }

  Future<void> _sendEntryMessage() async {
    if (_engine == null || _roomCid == null) return;
    final name = _myName ?? _myId ?? '';
    final text = '来到了直播间'; //this does not need to be localized

    final msg = await _engine!.createTextMessage(
      RCIMIWConversationType.chatroom,
      _roomCid!,
      null,
      text,
    );
    if (msg != null) {
      final userInfo = RCIMIWUserInfo.create();
      userInfo.userId = _myId ?? '';
      userInfo.name = name;
      msg.userInfo = userInfo;
      await _engine!.sendMessage(msg);

      // Append locally — RongCloud does not echo messages back to sender.
      // If history is still loading, park the message in _pendingEntryMsg so
      // _flushHistory() appends it after all offline messages. Otherwise append directly.
      if (mounted) {
        final chatMsg = _ChatMessage(senderName: name, senderId: _myId ?? '', text: text, isOwn: true);
        if (_initialSyncDone) {
          setState(() => _messages.add(chatMsg));
          _scrollToBottom();
        } else {
          // History is still loading; park the entry message so _flushHistory()
          // appends it after all offline messages arrive.
          _pendingEntryMsg = chatMsg;
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _engine == null || !_connected || _roomCid == null) return;
    _inputController.clear();

    // Optimistic local append
    setState(() {
      _messages.add(
        _ChatMessage(
          senderName: _myName ?? _myId ?? '',
          senderId: _myId ?? '',
          text: text,
          isOwn: true,
        ),
      );
    });
    _scrollToBottom();

    final msg = await _engine!.createTextMessage(
      RCIMIWConversationType.chatroom,
      _roomCid!,
      null,
      text,
    );
    if (msg != null) {
      // Attach sender info so recipients can display the name.
      final userInfo = RCIMIWUserInfo.create();
      userInfo.userId = _myId ?? '';
      userInfo.name = _myName ?? '';
      msg.userInfo = userInfo;
      await _engine!.sendMessage(msg);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isLoggedIn = ref.watch(authNotifierProvider).valueOrNull?.isAuthenticated ?? false;

    ref.listen(authNotifierProvider, (prev, next) {
      final prevAuth = prev?.valueOrNull;
      final nextAuth = next.valueOrNull;
      // Skip transitions while either state is still loading — otherwise the
      // loading→data transition looks like a login/logout and triggers a
      // spurious _reinitChat on every app start.
      if (prevAuth == null || nextAuth == null) return;
      if (prevAuth.isAuthenticated != nextAuth.isAuthenticated) _reinitChat();
    });

    ref.listen(imTokenProvider(widget.anchorId), (_, next) {
      next.whenData((token) => _initChat(token));
    });

    return Column(
      children: [
        _buildStatusBanner(),
        Expanded(child: _buildMessageList()),
        _buildBottomBar(context, isLoggedIn: isLoggedIn),
      ],
    );
  }

  Widget _buildStatusBanner() {
    if (_connecting || !_initialSyncDone) {
      return Container(
        width: double.infinity,
        color: Colors.black12,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'anchor.detail.chats.connecting'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }
    if (_connectError) {
      return Container(
        width: double.infinity,
        color: Colors.red.shade50,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'anchor.detail.chats.error.connect_failed'.tr(),
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
            TextButton(
              onPressed: _retryConnect,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'anchor.detail.chats.retry'.tr(),
                style: TextStyle(fontSize: 12, color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMessageList() {
    if (_initialSyncDone && _messages.isEmpty && _connected) {
      return Center(
        child: Text(
          'anchor.detail.chats.empty'.tr(),
          style: const TextStyle(color: Colors.black38, fontSize: 13),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13),
              children: [
                TextSpan(
                  text: '${msg.senderName}: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: msg.isOwn ? Colors.pink : Colors.green,
                  ),
                ),
                TextSpan(text: msg.text),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, {required bool isLoggedIn}) {
    if (!isLoggedIn) {
      return Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: TextButton.icon(
          onPressed: () => context.push(AppRoutes.login),
          icon: const Icon(Icons.lock_outline, size: 16),
          label: Text('anchor.detail.chats.login_to_chat'.tr()),
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            foregroundColor: Colors.black38,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: _connected,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'anchor.detail.chats.input.hint'.tr(),
                hintStyle: const TextStyle(fontSize: 13),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.pink),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _connected ? _sendMessage : null,
            style: TextButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('anchor.detail.chats.send'.tr(), style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.senderName,
    required this.senderId,
    required this.text,
    this.isOwn = false,
  });

  final String senderName;
  final String senderId;
  final String text;
  final bool isOwn;
}
