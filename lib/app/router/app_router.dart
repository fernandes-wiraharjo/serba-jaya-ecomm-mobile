import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/app/router/dev_shell.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/login_gate.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/home/presentation/home_placeholder.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/widgets/feedback_panel.dart';

const _sessionCheck = '/session';
const _login = '/login';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isDevelopment =
      ref.watch(appConfigProvider).environment == AppEnvironment.dev;
  final refresh = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  final router = GoRouter(
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
      GoRoute(path: _login, builder: (_, _) => const LoginGate()),
      GoRoute(
        path: _sessionCheck,
        builder: (_, _) => const Scaffold(body: FeedbackPanel(loading: true)),
      ),
      ShellRoute(
        builder: (_, state, child) {
          if (!isDevelopment) return Scaffold(body: child);
          return DevShell(
            destination:
                AppDestination.fromPath(state.uri.path) ?? AppDestination.home,
            child: child,
          );
        },
        routes: [
          for (final destination in AppDestination.values)
            GoRoute(
              path: destination.path,
              builder: (context, _) => isDevelopment
                  ? _placeholder(context, destination)
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

/// Retain only a known protected path. Query strings and external URIs
/// never become post-login redirect destinations.
String? sessionRedirect(
  Uri uri,
  SessionState session, {
  required DateTime now,
}) {
  final path = uri.path;
  final resuming = path == _login || path == _sessionCheck;
  final target = resuming ? uri.queryParameters['from'] : path;
  final destination = target == null ? null : AppDestination.fromPath(target);
  final protectedPath = destination?.protected == true
      ? destination?.path
      : null;

  String gate(String route) => Uri(
    path: route,
    queryParameters: protectedPath == null ? null : {'from': protectedPath},
  ).toString();

  if (path == _sessionCheck && session is SessionInitializing) return null;
  if ((protectedPath != null || path == _login) &&
      session is SessionInitializing) {
    return gate(_sessionCheck);
  }
  final signedIn =
      session is SessionAuthenticated && session.session.isUsableAt(now);

  if (resuming) {
    if (signedIn) return protectedPath ?? AppDestination.home.path;
    return path == _login ? null : gate(_login);
  }
  return protectedPath != null && !signedIn ? gate(_login) : null;
}

Widget _placeholder(BuildContext context, AppDestination destination) {
  final strings = AppLocalizations.of(context);
  return switch (destination) {
    AppDestination.home => const HomePlaceholder(),
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
