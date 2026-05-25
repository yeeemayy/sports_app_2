import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_card.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class AnchorListScreen extends ConsumerStatefulWidget {
  const AnchorListScreen({super.key});

  @override
  ConsumerState<AnchorListScreen> createState() => _AnchorListScreenState();
}

class _AnchorListScreenState extends ConsumerState<AnchorListScreen> {
  final _scrollController = ScrollController();
  final _anchors = <AnchorModel>[];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _initialized = false;
  bool _isLoadingMore = false;

  static double _aspectRatio(int index) => index.isEven ? 0.62 : 0.80;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(anchorListProvider());
      setState(() {
        _anchors.clear();
        _currentPage = 1;
        _lastPage = 1;
        _initialized = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _currentPage < _lastPage) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final response =
          await ref.read(anchorListProvider(page: _currentPage + 1).future);
      setState(() {
        _currentPage++;
        _lastPage = response.lastPage;
        _anchors.addAll(response.data);
      });
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _anchors.clear();
      _currentPage = 1;
      _lastPage = 1;
      _initialized = false;
    });
    ref.invalidate(anchorListProvider());
  }

  @override
  Widget build(BuildContext context) {
    final firstPageAsync = ref.watch(anchorListProvider());
    final crossAxisCount = MediaQuery.sizeOf(context).width >= 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(title: Text('anchor.list.title'.tr())),
      body: firstPageAsync.when(
        loading: () => MasonryGridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: 6,
          itemBuilder: (context, i) => AspectRatio(
            aspectRatio: _aspectRatio(i),
            child: const HomeAnchorLiveCard.loading(),
          ),
        ),
        error: (err, _) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.5,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'home.error.load_failed'.tr(),
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _refresh,
                        child: Text('common.retry'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        data: (page) {
          if (!_initialized) {
            _initialized = true;
            _anchors
              ..clear()
              ..addAll(page.data);
            _lastPage = page.lastPage;
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: MasonryGridView.count(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemCount: _anchors.length + (_isLoadingMore ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= _anchors.length) {
                  return AspectRatio(
                    aspectRatio: _aspectRatio(index),
                    child: const HomeAnchorLiveCard.loading(),
                  );
                }
                final anchor = _anchors[index];
                return AspectRatio(
                  aspectRatio: _aspectRatio(index),
                  child: HomeAnchorLiveCard(
                    anchor: anchor,
                    onTap: () => context.push(AppRoutes.anchorPath(anchor.id)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
