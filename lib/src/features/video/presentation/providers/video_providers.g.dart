// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoListHash() => r'97e127f7fdc8225be260da6afc6c48460fac8403';

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

/// See also [videoList].
@ProviderFor(videoList)
const videoListProvider = VideoListFamily();

/// See also [videoList].
class VideoListFamily extends Family<AsyncValue<VideoListResponse>> {
  /// See also [videoList].
  const VideoListFamily();

  /// See also [videoList].
  VideoListProvider call({required String locale, int page = 1}) {
    return VideoListProvider(locale: locale, page: page);
  }

  @override
  VideoListProvider getProviderOverride(covariant VideoListProvider provider) {
    return call(locale: provider.locale, page: provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoListProvider';
}

/// See also [videoList].
class VideoListProvider extends AutoDisposeFutureProvider<VideoListResponse> {
  /// See also [videoList].
  VideoListProvider({required String locale, int page = 1})
    : this._internal(
        (ref) => videoList(ref as VideoListRef, locale: locale, page: page),
        from: videoListProvider,
        name: r'videoListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$videoListHash,
        dependencies: VideoListFamily._dependencies,
        allTransitiveDependencies: VideoListFamily._allTransitiveDependencies,
        locale: locale,
        page: page,
      );

  VideoListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.locale,
    required this.page,
  }) : super.internal();

  final String locale;
  final int page;

  @override
  Override overrideWith(
    FutureOr<VideoListResponse> Function(VideoListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VideoListProvider._internal(
        (ref) => create(ref as VideoListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        locale: locale,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<VideoListResponse> createElement() {
    return _VideoListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoListProvider &&
        other.locale == locale &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, locale.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoListRef on AutoDisposeFutureProviderRef<VideoListResponse> {
  /// The parameter `locale` of this provider.
  String get locale;

  /// The parameter `page` of this provider.
  int get page;
}

class _VideoListProviderElement
    extends AutoDisposeFutureProviderElement<VideoListResponse>
    with VideoListRef {
  _VideoListProviderElement(super.provider);

  @override
  String get locale => (origin as VideoListProvider).locale;
  @override
  int get page => (origin as VideoListProvider).page;
}

String _$videoDetailHash() => r'2aebdabc8acf96a68a21fd4d5bcc61383a2e3fff';

/// See also [videoDetail].
@ProviderFor(videoDetail)
const videoDetailProvider = VideoDetailFamily();

/// See also [videoDetail].
class VideoDetailFamily extends Family<AsyncValue<VideoDetail>> {
  /// See also [videoDetail].
  const VideoDetailFamily();

  /// See also [videoDetail].
  VideoDetailProvider call(int id, String locale) {
    return VideoDetailProvider(id, locale);
  }

  @override
  VideoDetailProvider getProviderOverride(
    covariant VideoDetailProvider provider,
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
  String? get name => r'videoDetailProvider';
}

/// See also [videoDetail].
class VideoDetailProvider extends AutoDisposeFutureProvider<VideoDetail> {
  /// See also [videoDetail].
  VideoDetailProvider(int id, String locale)
    : this._internal(
        (ref) => videoDetail(ref as VideoDetailRef, id, locale),
        from: videoDetailProvider,
        name: r'videoDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$videoDetailHash,
        dependencies: VideoDetailFamily._dependencies,
        allTransitiveDependencies: VideoDetailFamily._allTransitiveDependencies,
        id: id,
        locale: locale,
      );

  VideoDetailProvider._internal(
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
    FutureOr<VideoDetail> Function(VideoDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VideoDetailProvider._internal(
        (ref) => create(ref as VideoDetailRef),
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
  AutoDisposeFutureProviderElement<VideoDetail> createElement() {
    return _VideoDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoDetailProvider &&
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
mixin VideoDetailRef on AutoDisposeFutureProviderRef<VideoDetail> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `locale` of this provider.
  String get locale;
}

class _VideoDetailProviderElement
    extends AutoDisposeFutureProviderElement<VideoDetail>
    with VideoDetailRef {
  _VideoDetailProviderElement(super.provider);

  @override
  int get id => (origin as VideoDetailProvider).id;
  @override
  String get locale => (origin as VideoDetailProvider).locale;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
