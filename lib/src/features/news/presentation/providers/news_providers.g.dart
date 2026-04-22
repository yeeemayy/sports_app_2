// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newsFirstPageHash() => r'153fba687ed4d63a80607da97e3a348feaaf7bdc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [newsFirstPage].
@ProviderFor(newsFirstPage)
const newsFirstPageProvider = NewsFirstPageFamily();

/// See also [newsFirstPage].
class NewsFirstPageFamily extends Family<AsyncValue<List<NewsArticle>>> {
  /// See also [newsFirstPage].
  const NewsFirstPageFamily();

  /// See also [newsFirstPage].
  NewsFirstPageProvider call(String locale) {
    return NewsFirstPageProvider(locale);
  }

  @override
  NewsFirstPageProvider getProviderOverride(
    covariant NewsFirstPageProvider provider,
  ) {
    return call(provider.locale);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'newsFirstPageProvider';
}

/// See also [newsFirstPage].
class NewsFirstPageProvider
    extends AutoDisposeFutureProvider<List<NewsArticle>> {
  /// See also [newsFirstPage].
  NewsFirstPageProvider(String locale)
    : this._internal(
        (ref) => newsFirstPage(ref as NewsFirstPageRef, locale),
        from: newsFirstPageProvider,
        name: r'newsFirstPageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$newsFirstPageHash,
        dependencies: NewsFirstPageFamily._dependencies,
        allTransitiveDependencies:
            NewsFirstPageFamily._allTransitiveDependencies,
        locale: locale,
      );

  NewsFirstPageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.locale,
  }) : super.internal();

  final String locale;

  @override
  Override overrideWith(
    FutureOr<List<NewsArticle>> Function(NewsFirstPageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NewsFirstPageProvider._internal(
        (ref) => create(ref as NewsFirstPageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        locale: locale,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<NewsArticle>> createElement() {
    return _NewsFirstPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NewsFirstPageProvider && other.locale == locale;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, locale.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NewsFirstPageRef on AutoDisposeFutureProviderRef<List<NewsArticle>> {
  /// The parameter `locale` of this provider.
  String get locale;
}

class _NewsFirstPageProviderElement
    extends AutoDisposeFutureProviderElement<List<NewsArticle>>
    with NewsFirstPageRef {
  _NewsFirstPageProviderElement(super.provider);

  @override
  String get locale => (origin as NewsFirstPageProvider).locale;
}

String _$newsDetailHash() => r'a00ea56817e9fb54ec6ac6aabcb03f80920f3ed2';

/// See also [newsDetail].
@ProviderFor(newsDetail)
const newsDetailProvider = NewsDetailFamily();

/// See also [newsDetail].
class NewsDetailFamily extends Family<AsyncValue<NewsDetail>> {
  /// See also [newsDetail].
  const NewsDetailFamily();

  /// See also [newsDetail].
  NewsDetailProvider call(int id, String locale) {
    return NewsDetailProvider(id, locale);
  }

  @override
  NewsDetailProvider getProviderOverride(
    covariant NewsDetailProvider provider,
  ) {
    return call(provider.id, provider.locale);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'newsDetailProvider';
}

/// See also [newsDetail].
class NewsDetailProvider extends AutoDisposeFutureProvider<NewsDetail> {
  /// See also [newsDetail].
  NewsDetailProvider(int id, String locale)
    : this._internal(
        (ref) => newsDetail(ref as NewsDetailRef, id, locale),
        from: newsDetailProvider,
        name: r'newsDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$newsDetailHash,
        dependencies: NewsDetailFamily._dependencies,
        allTransitiveDependencies: NewsDetailFamily._allTransitiveDependencies,
        id: id,
        locale: locale,
      );

  NewsDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
    required this.locale,
  }) : super.internal();

  final int id;
  final String locale;

  @override
  Override overrideWith(
    FutureOr<NewsDetail> Function(NewsDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NewsDetailProvider._internal(
        (ref) => create(ref as NewsDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
        locale: locale,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<NewsDetail> createElement() {
    return _NewsDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NewsDetailProvider &&
        other.id == id &&
        other.locale == locale;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);
    hash = _SystemHash.combine(hash, locale.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NewsDetailRef on AutoDisposeFutureProviderRef<NewsDetail> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `locale` of this provider.
  String get locale;
}

class _NewsDetailProviderElement
    extends AutoDisposeFutureProviderElement<NewsDetail>
    with NewsDetailRef {
  _NewsDetailProviderElement(super.provider);

  @override
  int get id => (origin as NewsDetailProvider).id;
  @override
  String get locale => (origin as NewsDetailProvider).locale;
}

String _$newsPaginatedHash() => r'3e9dca484905d79c5fa352c033ba0a6f9cc32f41';

/// See also [NewsPaginated].
@ProviderFor(NewsPaginated)
final newsPaginatedProvider =
    AutoDisposeNotifierProvider<NewsPaginated, NewsPaginatedState>.internal(
      NewsPaginated.new,
      name: r'newsPaginatedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newsPaginatedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewsPaginated = AutoDisposeNotifier<NewsPaginatedState>;
String _$newsSearchHash() => r'd85d48b4dfbf7f5d1a89eaa48e461e793aa9d269';

/// See also [NewsSearch].
@ProviderFor(NewsSearch)
final newsSearchProvider =
    AutoDisposeNotifierProvider<NewsSearch, NewsPaginatedState>.internal(
      NewsSearch.new,
      name: r'newsSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newsSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewsSearch = AutoDisposeNotifier<NewsPaginatedState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
