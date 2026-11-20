import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared_widgets/app_network_image.dart';
import '../../../shared_widgets/state_widgets.dart';
import 'community_header_bar.dart';
import 'community_skeletons.dart';
import 'providers/community_providers.dart';

const _kHistoryKey = 'community_search_history';
const _kMaxHistory = 10;

class CommunitySearchScreen extends ConsumerStatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  ConsumerState<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends ConsumerState<CommunitySearchScreen> {
  final _controller = TextEditingController();
  final _postsScrollController = ScrollController();
  final _usersScrollController = ScrollController();
  String? _submittedQuery;
  List<String> _history = [];
  int _tab = 0;

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => _history = prefs.getStringList(_kHistoryKey) ?? const []);
    });
    _postsScrollController.addListener(_onScrollPosts);
    _usersScrollController.addListener(_onScrollUsers);
  }

  @override
  void dispose() {
    _controller.dispose();
    _postsScrollController.dispose();
    _usersScrollController.dispose();
    super.dispose();
  }

  void _onScrollPosts() {
    final query = _submittedQuery;
    if (query == null) return;
    if (_postsScrollController.position.pixels >= _postsScrollController.position.maxScrollExtent - 300) {
      ref.read(communitySearchProvider((locale: _locale(context), query: query)).notifier).loadMore();
    }
  }

  void _onScrollUsers() {
    final query = _submittedQuery;
    if (query == null) return;
    if (_usersScrollController.position.pixels >= _usersScrollController.position.maxScrollExtent - 300) {
      ref.read(communityUserSearchProvider(query).notifier).loadMore();
    }
  }

  Future<void> _submit(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [trimmed, ..._history.where((k) => k != trimmed)].take(_kMaxHistory).toList();
    await prefs.setStringList(_kHistoryKey, updated);
    setState(() {
      _submittedQuery = trimmed;
      _history = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: communityHeaderBackButton(context),
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(hintText: 'community.search_hint'.tr(), border: InputBorder.none),
          onSubmitted: _submit,
        ),
        actions: [
          TextButton(onPressed: () => _submit(_controller.text), child: Text('community.search'.tr())),
        ],
      ),
      body: Column(
        children: [
          if (_submittedQuery != null) _TabRow(tab: _tab, onSelect: (t) => setState(() => _tab = t)),
          Expanded(
            child: _submittedQuery == null
                ? _historyView()
                : _tab == 0
                    ? _postsResultsView(_submittedQuery!)
                    : _usersResultsView(_submittedQuery!),
          ),
        ],
      ),
    );
  }

  Widget _historyView() {
    if (_history.isEmpty) return const EmptyStateWidget();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final query in _history)
            GestureDetector(
              onTap: () {
                _controller.text = query;
                _submit(query);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: ShapeDecoration(
                  color: context.appColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(query, style: AppTextStyles.body(12).copyWith(color: context.appColors.text2)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _postsResultsView(String query) {
    final state = ref.watch(communitySearchProvider((locale: _locale(context), query: query)));
    if (state.isLoading) return const CommunityAvatarRowSkeleton();
    if (state.error != null && state.posts.isEmpty) return const ErrorStateWidget();
    if (state.posts.isEmpty) return const EmptyStateWidget();
    return ListView.builder(
      controller: _postsScrollController,
      itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == state.posts.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        }
        final post = state.posts[i];
        return ListTile(
          leading: AppNetworkImage(url: post.author.avatarUrl, size: 40),
          title: Text(
            post.content,
            style: AppTextStyles.body(14).copyWith(color: context.appColors.text),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(post.author.nickname, style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
          onTap: () => context.push('/community/${post.id}'),
        );
      },
    );
  }

  Widget _usersResultsView(String query) {
    final state = ref.watch(communityUserSearchProvider(query));
    if (state.isLoading) return const CommunityAvatarRowSkeleton();
    if (state.error != null && state.users.isEmpty) return const ErrorStateWidget();
    if (state.users.isEmpty) return const EmptyStateWidget();
    return ListView.builder(
      controller: _usersScrollController,
      itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == state.users.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        }
        final user = state.users[i];
        return ListTile(
          leading: AppNetworkImage(url: user.avatarUrl, size: 40),
          title: Text(user.nickname, style: AppTextStyles.body(14).copyWith(color: context.appColors.text)),
          subtitle: user.bio != null && user.bio!.isNotEmpty
              ? Text(user.bio!, style: AppTextStyles.body(11).copyWith(color: context.appColors.text2), maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          onTap: () => context.push('/community/user/${user.id}', extra: user),
        );
      },
    );
  }
}

class _TabRow extends StatelessWidget {
  const _TabRow({required this.tab, required this.onSelect});

  final int tab;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _TabChip(label: 'community.search_tab_posts'.tr(), selected: tab == 0, onTap: () => onSelect(0)),
          const SizedBox(width: 8),
          _TabChip(label: 'community.search_tab_users'.tr(), selected: tab == 1, onTap: () => onSelect(1)),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: selected ? context.appColors.accent : context.appColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text).copyWith(color: selected ? Colors.white : context.appColors.text2),
        ),
      ),
    );
  }
}
