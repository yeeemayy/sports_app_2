import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/community/presentation/providers/community_auth_providers.dart';
import '../../routes/app_routes.dart';

/// Guards a Community action that requires a signed-in account.
///
/// Returns `true` and lets the caller proceed when someone is logged in.
/// Otherwise pushes the app's shared login screen (carrying [returnPath] so
/// login can return the user to where they were) and returns `false`.
bool ensureCommunityLoggedIn(BuildContext context, WidgetRef ref, {String? returnPath}) {
  if (ref.read(isCommunityLoggedInProvider)) return true;
  final path = returnPath ?? GoRouterState.of(context).uri.toString();
  context.push('${AppRoutes.login}?returnPath=${Uri.encodeComponent(path)}');
  return false;
}
