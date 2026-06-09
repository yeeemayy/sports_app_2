class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.isLoading = true,
    this.error,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool isLoading;
  final Object? error;

  bool get hasMore => currentPage < lastPage;

  PaginatedState<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
