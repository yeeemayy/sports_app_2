// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$footballRealtimeHash() => r'52b3f79ebf6a20f1e55f0817b248ac3a022aafcb';

/// See also [FootballRealtime].
@ProviderFor(FootballRealtime)
final footballRealtimeProvider =
    AutoDisposeNotifierProvider<
      FootballRealtime,
      Map<String, MatchRealtimeData>
    >.internal(
      FootballRealtime.new,
      name: r'footballRealtimeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$footballRealtimeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FootballRealtime =
    AutoDisposeNotifier<Map<String, MatchRealtimeData>>;
String _$basketballRealtimeHash() =>
    r'771ce2407a4799e3a2ebd12310b5a552c2aa913a';

/// See also [BasketballRealtime].
@ProviderFor(BasketballRealtime)
final basketballRealtimeProvider =
    AutoDisposeNotifierProvider<
      BasketballRealtime,
      Map<String, BasketballRealtimeData>
    >.internal(
      BasketballRealtime.new,
      name: r'basketballRealtimeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$basketballRealtimeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BasketballRealtime =
    AutoDisposeNotifier<Map<String, BasketballRealtimeData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
