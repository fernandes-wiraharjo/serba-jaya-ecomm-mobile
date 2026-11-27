import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/core/location/app_location_picker.dart';
import 'package:serba_jaya_mobile/core/location/location_models.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/app/router/auth_routes.dart';
import 'package:serba_jaya_mobile/app/shell/main_shell.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/auth_onboarding_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/login_required_dialog.dart';
import 'package:serba_jaya_mobile/features/home/presentation/home_placeholder.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_page.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_address_page.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_edit_page.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_secondary_pages.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/motion/app_page_transitions.dart';
import 'package:serba_jaya_mobile/shared/motion/app_tab_transition.dart';
import 'package:serba_jaya_mobile/shared/widgets/feedback_panel.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_mobile.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_page_title.dart';

export 'auth_routes.dart' show sessionRedirect;

final appRouterProvider = Provider<GoRouter>((ref) {
  final isDevelopment =
      ref.watch(appConfigProvider).environment == AppEnvironment.dev;
  final refresh = ValueNotifier(0);
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final requests = _ShellNavigation(ref, rootNavigatorKey);
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refresh,
    redirect: (_, state) => sessionRedirect(
      state.uri,
      ref.read(sessionProvider),
      now: ref.read(sessionClockProvider)(),
    ),
    errorPageBuilder: (context, state) => AppTransitionPage<void>(
      key: state.pageKey,
      child: Scaffold(
        body: FeedbackPanel(message: AppLocalizations.of(context).notFound),
      ),
    ),
    routes: [
      GoRoute(
        path: authSessionPath,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AuthOnboardingPage(),
        ),
      ),
      ...authenticationRoutes(rootNavigatorKey, isDevelopment: isDevelopment),
      _mainShellRoute(requests, isDevelopment),
    ],
  );
  ref.listen(sessionProvider, (_, session) {
    // GoRouter refreshes the base URI of an imperative stack. Check the
    // visible auth page first so a validated session still resumes its target.
    if (router.routerDelegate.currentConfiguration.isNotEmpty) {
      final uri = router.state.uri;
      if (authPagePaths.contains(uri.path) && session is SessionAuthenticated) {
        final target = sessionRedirect(
          uri,
          session,
          now: ref.read(sessionClockProvider)(),
        );
        if (target != null) {
          router.go(target);
          return;
        }
      }
    }
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellRoute _mainShellRoute(
  _ShellNavigation requests,
  bool isDevelopment,
) => StatefulShellRoute(
  navigatorContainerBuilder: (_, shell, children) => Consumer(
    builder: (context, ref, _) => _ShellSessionAccess(
      allowed: hasActiveSession(
        ref.watch(sessionProvider),
        ref.read(sessionClockProvider)(),
      ),
      child: AppTabTransition(index: shell.currentIndex, children: children),
    ),
  ),
  pageBuilder: (_, state, shell) => AppTransitionPage<void>(
    key: state.pageKey,
    child: Builder(
      builder: (context) {
        final destination = AppDestination.fromPath(state.uri.path);
        void open(AppDestination target) =>
            requests.open(context, shell, target, current: destination);

        return MainShell(
          destination: AppDestination.navigationTabs.contains(destination)
              ? destination
              : null,
          headerSurfaceColor: destination == AppDestination.home
              ? AppColors.headerHomeSurface
              : AppColors.headerSurface,
          headerBuilder: (context, destination, badgeCounts) {
            if (destination == null || destination == AppDestination.profile) {
              return null;
            }
            if (destination == AppDestination.home) {
              return HeaderMobileActions(
                cartCount: badgeCounts[AppDestination.cart] ?? 0,
                notificationCount:
                    badgeCounts[AppDestination.notifications] ?? 0,
                onCartTap: () => open(AppDestination.cart),
                onNotificationsTap: () => open(AppDestination.notifications),
              );
            }
            return HeaderPageTitle(
              title: destination.label(AppLocalizations.of(context)),
              onBack: () => context.go(AppDestination.home.path),
              cartCount: badgeCounts[AppDestination.cart] ?? 0,
              onCartTap: destination == AppDestination.cart
                  ? null
                  : () => open(AppDestination.cart),
            );
          },
          onDestinationSelected: open,
          child: shell,
        );
      },
    ),
  ),
  branches: [
    for (final destination in AppDestination.navigationTabs)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: destination.path,
            pageBuilder: (_, state) =>
                _destinationPage(state, destination, requests, isDevelopment),
            routes: [
              if (destination == AppDestination.profile)
                ..._profileRoutes(requests._root),
              if (destination == AppDestination.home)
                GoRoute(
                  path: 'notifications',
                  pageBuilder: (_, state) => _destinationPage(
                    state,
                    AppDestination.notifications,
                    requests,
                    isDevelopment,
                  ),
                ),
            ],
          ),
        ],
      ),
  ],
);

List<RouteBase> _profileRoutes(GlobalKey<NavigatorState> root) => [
  _profileRoute(root, 'edit', 'profile-edit', (_) => const ProfileEditPage()),
  _profileRoute(
    root,
    'addresses',
    'profile-addresses',
    (_) => const ProfileAddressPage(),
    routes: [
      _profileRoute(root, 'location', 'profile-address-location', (state) {
        final selection = state.extra;
        return AppLocationPicker(
          initial: selection is LocationAddress ? selection : null,
        );
      }),
      _profileRoute(
        root,
        'new',
        'profile-address-new',
        (_) => const ProfileAddressForm(),
      ),
      _profileRoute(
        root,
        ':id/edit',
        'profile-address-edit',
        (state) => ProfileAddressForm(
          addressId: int.tryParse(state.pathParameters['id']!) ?? -1,
        ),
      ),
    ],
  ),
  _profileRoute(
    root,
    'rewards',
    'profile-rewards',
    (_) => const ProfileRewardsPage(view: ProfileRewardsView.points),
  ),
  _profileRoute(
    root,
    'vouchers',
    'profile-vouchers',
    (_) => const ProfileRewardsPage(view: ProfileRewardsView.vouchers),
  ),
  _profileRoute(
    root,
    'points-history',
    'profile-points-history',
    (_) => const ProfileRewardsPage(view: ProfileRewardsView.history),
  ),
  _profileRoute(
    root,
    'membership',
    'profile-membership',
    (_) => const ProfileMembershipPage(),
  ),
  _profileRoute(
    root,
    'delete',
    'profile-delete',
    (_) => const ProfileDeletePage(),
  ),
];

GoRoute _profileRoute(
  GlobalKey<NavigatorState> root,
  String path,
  String name,
  Widget Function(GoRouterState) build, {
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  name: name,
  parentNavigatorKey: root,
  routes: routes,
  pageBuilder: (_, state) =>
      AppTransitionPage<void>(key: state.pageKey, child: build(state)),
);

Page<void> _destinationPage(
  GoRouterState state,
  AppDestination destination,
  _ShellNavigation requests,
  bool isDevelopment,
) => AppTransitionPage<void>(
  key: state.pageKey,
  child: Builder(
    builder: (context) {
      if (destination.protected && !_ShellSessionAccess.isAllowed(context)) {
        return const SizedBox.expand();
      }
      if (destination == AppDestination.profile) return const ProfilePage();
      return isDevelopment
          ? _placeholder(
              context,
              destination,
              onNotificationsRequested: () =>
                  requests.openNotifications(context),
            )
          : FeedbackPanel(message: AppLocalizations.of(context).unavailable);
    },
  ),
);

// Riverpod pauses consumers in inactive branches. An inherited value keeps
// the access rule effective for retained screens even while their tickers stop.
class _ShellSessionAccess extends InheritedWidget {
  const _ShellSessionAccess({required this.allowed, required super.child});

  final bool allowed;

  static bool isAllowed(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_ShellSessionAccess>()
          ?.allowed ??
      false;

  @override
  bool updateShouldNotify(_ShellSessionAccess oldWidget) =>
      oldWidget.allowed != allowed;
}

class _ShellNavigation {
  _ShellNavigation(this._ref, this._root);

  final Ref _ref;
  final GlobalKey<NavigatorState> _root;
  bool _authDialogOpen = false;

  void open(
    BuildContext context,
    StatefulNavigationShell shell,
    AppDestination destination, {
    AppDestination? current,
  }) {
    if (!_canNavigate(context)) return;
    final redirect = _redirect(destination);
    if (redirect != null) {
      _handleBlocked(context, destination, redirect);
    } else if (destination == AppDestination.notifications) {
      if (current != destination) context.go(destination.path);
    } else {
      final index = AppDestination.navigationTabs.indexOf(destination);
      if (index != shell.currentIndex) {
        shell.goBranch(index);
      } else if (current == AppDestination.notifications) {
        context.pop();
      }
    }
  }

  void openNotifications(BuildContext context) {
    if (!_canNavigate(context)) return;
    const destination = AppDestination.notifications;
    final redirect = _redirect(destination);
    if (redirect == null) {
      context.go(destination.path);
    } else {
      _handleBlocked(context, destination, redirect);
    }
  }

  bool _canNavigate(BuildContext context) =>
      !_authDialogOpen &&
      !(_root.currentState?.userGestureInProgress ?? false) &&
      ModalRoute.isCurrentOf(context) == true;

  String? _redirect(AppDestination destination) => sessionRedirect(
    Uri.parse(destination.path),
    _ref.read(sessionProvider),
    now: _ref.read(sessionClockProvider)(),
  );

  void _handleBlocked(
    BuildContext context,
    AppDestination destination,
    String redirect,
  ) {
    if (Uri.parse(redirect).path == authSessionPath || !destination.protected) {
      context.go(redirect);
    } else {
      unawaited(_openAuthDialog(context, destination));
    }
  }

  Future<void> _openAuthDialog(
    BuildContext context,
    AppDestination destination,
  ) async {
    _authDialogOpen = true;
    try {
      final loginRequested = await showLoginRequiredDialog(context);
      if (loginRequested != true ||
          !context.mounted ||
          ModalRoute.isCurrentOf(context) != true) {
        return;
      }
      final redirect = _redirect(destination);
      if (redirect == null) {
        context.go(destination.path);
      } else if (Uri.parse(redirect).path == authSessionPath) {
        context.go(redirect);
      } else {
        unawaited(
          context.push<void>(authLocation(authLoginPath, destination.path)),
        );
      }
    } finally {
      _authDialogOpen = false;
    }
  }
}

Widget _placeholder(
  BuildContext context,
  AppDestination destination, {
  required VoidCallback onNotificationsRequested,
}) {
  final strings = AppLocalizations.of(context);
  return switch (destination) {
    AppDestination.home => HomePlaceholder(
      onNotificationsRequested: onNotificationsRequested,
    ),
    AppDestination.chat => FeedbackPanel(message: strings.chatPlaceholder),
    _ => FeedbackPanel(message: strings.placeholder),
  };
}
