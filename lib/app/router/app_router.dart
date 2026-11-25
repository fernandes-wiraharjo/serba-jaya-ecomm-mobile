import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/app/shell/main_shell.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/auth_onboarding_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/registration_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/login_required_dialog.dart';
import 'package:serba_jaya_mobile/features/home/presentation/home_placeholder.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/widgets/feedback_panel.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_mobile.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_page_title.dart';

const _sessionCheck = '/session';
const _login = '/login';
const _register = '/login/register';
const _authPaths = {_login, _register};
final Set<NavigatorState> _activeLoginDialogs = {};

final appRouterProvider = Provider<GoRouter>((ref) {
  final isDevelopment =
      ref.watch(appConfigProvider).environment == AppEnvironment.dev;
  final refresh = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refresh,
    redirect: (_, state) => sessionRedirect(
      state.uri,
      ref.read(sessionProvider),
      now: ref.read(sessionClockProvider)(),
    ),
    errorBuilder: (context, _) => Scaffold(
      body: FeedbackPanel(message: AppLocalizations.of(context).notFound),
    ),
    routes: [
      GoRoute(
        path: _sessionCheck,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AuthOnboardingPage(),
        ),
      ),
      ..._authenticationRoutes(rootNavigatorKey),
      ShellRoute(
        builder: (context, state, child) {
          final routeDestination = AppDestination.fromPath(state.uri.path);
          return MainShell(
            destination:
                AppDestination.navigationTabs.contains(routeDestination)
                ? routeDestination
                : null,
            headerSurfaceColor: routeDestination == AppDestination.home
                ? AppColors.headerHomeSurface
                : AppColors.headerSurface,
            headerBuilder: (context, destination, badgeCounts) {
              if (destination == null) return null;
              if (destination == AppDestination.home) {
                return HeaderMobileActions(
                  cartCount: badgeCounts[AppDestination.cart] ?? 0,
                  notificationCount:
                      badgeCounts[AppDestination.notifications] ?? 0,
                  onCartTap: () => _requestDestination(
                    context,
                    AppDestination.cart,
                    ref.read(sessionProvider),
                    ref.read(sessionClockProvider)(),
                  ),
                  onNotificationsTap: () => _requestDestination(
                    context,
                    AppDestination.notifications,
                    ref.read(sessionProvider),
                    ref.read(sessionClockProvider)(),
                  ),
                );
              }

              return HeaderPageTitle(
                title: destination.label(AppLocalizations.of(context)),
                onBack: () => context.go(AppDestination.home.path),
                cartCount: badgeCounts[AppDestination.cart] ?? 0,
                onCartTap: destination == AppDestination.cart
                    ? null
                    : () => _requestDestination(
                        context,
                        AppDestination.cart,
                        ref.read(sessionProvider),
                        ref.read(sessionClockProvider)(),
                      ),
              );
            },
            onDestinationSelected: (destination) => _requestDestination(
              context,
              destination,
              ref.read(sessionProvider),
              ref.read(sessionClockProvider)(),
            ),
            child: child,
          );
        },
        routes: [
          for (final destination in AppDestination.values)
            GoRoute(
              path: destination.path,
              builder: (context, _) => isDevelopment
                  ? _placeholder(
                      context,
                      destination,
                      onNotificationsRequested: () => _requestDestination(
                        context,
                        AppDestination.notifications,
                        ref.read(sessionProvider),
                        ref.read(sessionClockProvider)(),
                      ),
                    )
                  : FeedbackPanel(
                      message: AppLocalizations.of(context).unavailable,
                    ),
            ),
        ],
      ),
    ],
  );
  ref.onDispose(refresh.dispose);
  ref.onDispose(router.dispose);
  return router;
});

List<RouteBase> _authenticationRoutes(GlobalKey<NavigatorState> root) => [
  GoRoute(
    path: '/login',
    parentNavigatorKey: root,
    builder: (context, state) => LoginPage(
      onClose: () => context.go(AppDestination.home.path),
      onRegister: () => context.go(
        _authLocation(
          _register,
          _protectedPath(state.uri.queryParameters['from']),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: 'register',
        parentNavigatorKey: root,
        builder: (context, state) => RegistrationPage(
          onCancel: () => context.go(
            _authLocation(
              _login,
              _protectedPath(state.uri.queryParameters['from']),
            ),
          ),
        ),
      ),
    ],
  ),
];

String? _protectedPath(String? path) {
  final destination = path == null ? null : AppDestination.fromPath(path);
  return destination?.protected == true ? destination?.path : null;
}

String _authLocation(String path, String? from, {String? next}) {
  final query = {'from': ?from, 'next': ?next};
  return Uri(
    path: path,
    queryParameters: query.isEmpty ? null : query,
  ).toString();
}

void _requestDestination(
  BuildContext context,
  AppDestination destination,
  SessionState session,
  DateTime now,
) {
  final redirect = sessionRedirect(
    Uri.parse(destination.path),
    session,
    now: now,
  );
  if (redirect == null) {
    context.go(destination.path);
    return;
  }

  final target = Uri.parse(redirect);
  if (target.path == _sessionCheck || !destination.protected) {
    context.go(redirect);
    return;
  }

  final navigator = Navigator.of(context, rootNavigator: true);
  if (!_activeLoginDialogs.add(navigator)) return;
  unawaited(
    showLoginRequiredDialog(context).then((loginRequested) {
      _activeLoginDialogs.remove(navigator);
      if (loginRequested == true && context.mounted) {
        context.go(_authLocation(_login, destination.path));
      }
    }),
  );
}

/// Resume only registered routes. Incoming URLs do not become redirect targets.
String? sessionRedirect(
  Uri uri,
  SessionState session, {
  required DateTime now,
}) {
  final path = uri.path;
  final isAuth = _authPaths.contains(path);
  final checking = path == _sessionCheck;
  final from = _protectedPath(
    isAuth || checking ? uri.queryParameters['from'] : path,
  );

  if (session is SessionInitializing) {
    if (checking || (!isAuth && from == null)) return null;
    return _authLocation(_sessionCheck, from, next: isAuth ? path : null);
  }

  final signedIn =
      session is SessionAuthenticated && session.session.isUsableAt(now);
  if (signedIn) {
    return isAuth || checking ? from ?? AppDestination.home.path : null;
  }
  if (checking) {
    final next = uri.queryParameters['next'];
    if (next != null && _authPaths.contains(next)) {
      return _authLocation(next, from);
    }
    return AppDestination.home.path;
  }
  return !isAuth && from != null ? AppDestination.home.path : null;
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
    AppDestination.profile => Consumer(
      builder: (context, ref, _) => SafeArea(
        child: Center(
          child: TextButton(
            onPressed: () {
              final controller = ref.read(sessionProvider.notifier);
              context.go(AppDestination.home.path);
              controller.logout();
            },
            child: Text(strings.logout),
          ),
        ),
      ),
    ),
    _ => FeedbackPanel(message: strings.placeholder),
  };
}
