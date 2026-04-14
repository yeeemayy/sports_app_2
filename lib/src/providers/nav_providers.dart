import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected bottom navigation index.
/// Updated by [AppWrapper] on every tab change.
final currentNavIndexProvider = StateProvider<int>((ref) => 0);
