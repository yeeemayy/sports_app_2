import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'package:shenghaotiyu/src/core/services/rongcloud_service.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/providers/auth_notifier.dart';

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
    // Force fresh RongCloud credentials every time this tab is entered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(rongCloudCredentialsProvider(widget.anchorId));
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
    ref.invalidate(rongCloudCredentialsProvider(widget.anchorId));
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

  Future<void> _initChat(({String rcKey, String rcToken}) creds) async {
    if (_engine != null || _connecting) return;
    if (mounted) setState(() => _connecting = true);

    // One chatroom per anchor; RongCloud resolves the connecting user's id
    // from the token itself (see `onConnected`'s `userId` below).
    _roomCid = widget.anchorId.toString();
    final authUser = ref.read(authNotifierProvider).valueOrNull?.user;
    _myName = authUser?.nickname ?? '';

    // rc_token is shaped `<connectToken>@<naviServer>;<statServer>` for this
    // private RongCloud deployment — passed to connect() as-is below; the
    // SDK parses the combined form itself and routes to the embedded
    // nav/stat servers, so there's no need to split it or set
    // [RCIMIWEngineOptions.naviServer]/[statisticServer] explicitly.
    final connectToken = creds.rcToken;

    final options = RCIMIWEngineOptions.create();
    _engine = await RCIMIWEngine.create(creds.rcKey, options);

    _engine!.onRemoteMessageRecalled = (RCIMIWMessage? recalled) {
      if (!mounted || recalled?.messageUId == null) return;
      setState(() {
        _messages.removeWhere((m) => m.messageUId == recalled!.messageUId);
        _bufferedMessages.removeWhere((m) => m.messageUId == recalled!.messageUId);
      });
    };

    _engine!.onMessageReceived =
        (RCIMIWMessage? message, int? left, bool? offline, bool? hasPackage) {
          if (!mounted || message == null) return;
          if (message.targetId != _roomCid) return;
          if (message is! RCIMIWTextMessage) return;

          final senderName =
              message.userInfo?.name ?? message.senderUserId ?? '';
          final text = message.text ?? '';
          if (text.isEmpty) return;

          final chatMsg = _ChatMessage(
            senderName: senderName,
            senderId: message.senderUserId ?? '',
            text: text,
            messageUId: message.messageUId,
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
                ref.read(authNotifierProvider).valueOrNull?.isAuthenticated ??
                false;
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
      } else if (code == 34001 &&
          mounted &&
          _engine != null &&
          !_didRetry34001) {
        // 34001: server still has a previous session active — wait briefly and retry once.
        _didRetry34001 = true;
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted || _engine == null) return;
        await _engine!.connect(
          connectToken,
          30,
          callback: RCIMIWConnectCallback(
            onConnected: (int? retryCode, String? userId) async {
              _myId = userId;
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
      connectToken,
      30,
      callback: RCIMIWConnectCallback(
        onConnected: (int? code, String? userId) async {
          _myId = userId;
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
    final credsAsync = ref.read(rongCloudCredentialsProvider(widget.anchorId));
    credsAsync.whenData((creds) {
      if (creds != null) _initChat(creds);
    });
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
      final chatMsg = _ChatMessage(
        senderName: name,
        senderId: _myId ?? '',
        text: text,
        isOwn: true,
      );
      await _engine!.sendMessage(
        msg,
        callback: RCIMIWSendMessageCallback(
          onMessageSent: (int? code, RCIMIWMessage? sent) {
            if (mounted && code == 0 && sent?.messageUId != null) {
              setState(() => chatMsg.messageUId = sent!.messageUId);
            }
          },
        ),
      );

      if (mounted) {
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
    if (text.isEmpty || _engine == null || !_connected || _roomCid == null)
      return;
    _inputController.clear();

    final msg = await _engine!.createTextMessage(
      RCIMIWConversationType.chatroom,
      _roomCid!,
      null,
      text,
    );
    if (msg != null) {
      final chatMsg = _ChatMessage(
        senderName: _myName ?? _myId ?? '',
        senderId: _myId ?? '',
        text: text,
        isOwn: true,
      );
      setState(() => _messages.add(chatMsg));
      _scrollToBottom();

      final userInfo = RCIMIWUserInfo.create();
      userInfo.userId = _myId ?? '';
      userInfo.name = _myName ?? '';
      msg.userInfo = userInfo;
      await _engine!.sendMessage(
        msg,
        callback: RCIMIWSendMessageCallback(
          onMessageSent: (int? code, RCIMIWMessage? sent) {
            if (mounted && code == 0 && sent?.messageUId != null) {
              setState(() => chatMsg.messageUId = sent!.messageUId);
            }
          },
        ),
      );
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
    final isLoggedIn =
        ref.watch(authNotifierProvider).valueOrNull?.isAuthenticated ?? false;

    ref.listen(authNotifierProvider, (prev, next) {
      final prevAuth = prev?.valueOrNull;
      final nextAuth = next.valueOrNull;
      // Skip transitions while either state is still loading — otherwise the
      // loading→data transition looks like a login/logout and triggers a
      // spurious _reinitChat on every app start.
      if (prevAuth == null || nextAuth == null) return;
      if (prevAuth.isAuthenticated != nextAuth.isAuthenticated) _reinitChat();
    });

    ref.listen(rongCloudCredentialsProvider(widget.anchorId), (_, next) {
      next.whenData((creds) {
        if (creds != null) _initChat(creds);
      });
      if (next.hasError && mounted) {
        setState(() {
          _connecting = false;
          _connectError = true;
        });
      }
    });

    return Column(
      children: [
        _ChatStatusBanner(
          connecting: _connecting,
          initialSyncDone: _initialSyncDone,
          connectError: _connectError,
          onRetry: _retryConnect,
        ),
        Expanded(
          child: _ChatMessageList(
            scrollController: _scrollController,
            messages: _messages,
            initialSyncDone: _initialSyncDone,
            connected: _connected,
          ),
        ),
        _ChatInputBar(
          isLoggedIn: isLoggedIn,
          connected: _connected,
          inputController: _inputController,
          onSend: _sendMessage,
          loginPath:
              '${AppRoutes.login}?returnPath=${Uri.encodeComponent(AppRoutes.anchorPath(widget.anchorId))}',
        ),
      ],
    );
  }
}

class _ChatStatusBanner extends StatelessWidget {
  const _ChatStatusBanner({
    required this.connecting,
    required this.initialSyncDone,
    required this.connectError,
    required this.onRetry,
  });

  final bool connecting;
  final bool initialSyncDone;
  final bool connectError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (connectError) {
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
              onPressed: onRetry,
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
    if (connecting || !initialSyncDone) {
      return Container(
        width: double.infinity,
        color: context.appColors.lineStrong,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'anchor.detail.chats.connecting'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: context.appColors.text2),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ChatMessageList extends StatelessWidget {
  const _ChatMessageList({
    required this.scrollController,
    required this.messages,
    required this.initialSyncDone,
    required this.connected,
  });

  final ScrollController scrollController;
  final List<_ChatMessage> messages;
  final bool initialSyncDone;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    if (initialSyncDone && messages.isEmpty && connected) {
      return Center(
        child: Text(
          'anchor.detail.chats.empty'.tr(),
          style: TextStyle(color: context.appColors.text2, fontSize: 13),
        ),
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) => _ChatMessageTile(message: messages[index]),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  const _ChatMessageTile({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13),
          children: [
            TextSpan(
              text: '${message.senderName}: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: message.isOwn ? context.appColors.accent : Colors.green,
              ),
            ),
            TextSpan(text: message.text),
          ],
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.isLoggedIn,
    required this.connected,
    required this.inputController,
    required this.onSend,
    required this.loginPath,
  });

  final bool isLoggedIn;
  final bool connected;
  final TextEditingController inputController;
  final VoidCallback onSend;
  final String loginPath;

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.appColors.lineStrong)),
        ),
        child: TextButton.icon(
          onPressed: () => context.push(loginPath),
          icon: const Icon(Icons.lock_outline, size: 16),
          label: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'anchor.detail.chats.login_to_chat_action'.tr(),
                  style: TextStyle(color: context.appColors.accent),
                ),
                TextSpan(text: 'anchor.detail.chats.login_to_chat_suffix'.tr()),
              ],
            ),
          ),
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            foregroundColor: context.appColors.text,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.appColors.lineStrong)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: inputController,
              enabled: connected,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'anchor.detail.chats.input.hint'.tr(),
                hintStyle: const TextStyle(fontSize: 13),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: context.appColors.lineStrong),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: context.appColors.lineStrong),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: context.appColors.accent),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: connected ? onSend : null,
            style: TextButton.styleFrom(
              backgroundColor: context.appColors.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: context.appColors.shimmerBase,
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
  _ChatMessage({
    required this.senderName,
    required this.senderId,
    required this.text,
    this.messageUId,
    this.isOwn = false,
  });

  final String senderName;
  final String senderId;
  final String text;
  String? messageUId;
  final bool isOwn;
}
