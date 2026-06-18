import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_grid.dart';

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
      final response = await ref.read(
        anchorListProvider(page: _currentPage + 1).future,
      );
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

    return Scaffold(
      appBar: AppBar(title: Text('anchor.list.title'.tr())),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: firstPageAsync.when(
              skipLoadingOnRefresh: false,
              loading: () => HomeAnchorLiveGrid(padding: EdgeInsets.all(16)),
              error: (err, stack) => Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .7,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
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
              data: (page) {
                if (!_initialized) {
                  _initialized = true;
                  _anchors
                    ..clear()
                    ..addAll(page.data);
                  _lastPage = page.lastPage;
                }

                return Column(
                  children: [
                    HomeAnchorLiveGrid(
                      anchors: _anchors,
                      padding: const EdgeInsets.all(16),
                    ),
                    if (_isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      )
                    else
                      const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
