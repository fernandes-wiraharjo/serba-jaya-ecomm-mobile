import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/google_account_preview_page.dart';
import 'package:serba_jaya_mobile/features/auth/domain/google_identity.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/registration_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/shared/motion/app_page_transitions.dart';

const authSessionPath = '/session';
const authLoginPath = '/login';
const authRegisterPath = '/login/register';
const authPagePaths = {authLoginPath, authRegisterPath};

List<RouteBase> authenticationRoutes(
  GlobalKey<NavigatorState> root, {
  required bool isDevelopment,
}) {
  var openingRegistration = false;
  final routes = <RouteBase>[
    GoRoute(
      path: authLoginPath,
      parentNavigatorKey: root,
      pageBuilder: (_, state) => AppTransitionPage<void>(
        key: state.pageKey,
        motion: AppPageMotion.modal,
        child: Builder(
          builder: (context) => LoginPage(
            onClose: () => _closePage(context, AppDestination.home.path),
            onGoogleSuccess: (identity) {
              if (isDevelopment) {
                context.push<void>(
                  GoogleAccountPreviewPage.path,
                  extra: identity,
                );
              }
            },
            onRegister: () {
              if (openingRegistration ||
                  ModalRoute.isCurrentOf(context) != true) {
                return;
              }
              openingRegistration = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                openingRegistration = false;
              });
              unawaited(
                context.push<void>(
                  authLocation(
                    authRegisterPath,
                    _protectedPath(state.uri.queryParameters['from']),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      routes: [
        GoRoute(
          path: 'register',
          parentNavigatorKey: root,
          pageBuilder: (_, state) => AppTransitionPage<void>(
            key: state.pageKey,
            child: Builder(
              builder: (context) => RegistrationPage(
                onCancel: () => _closePage(
                  context,
                  authLocation(
                    authLoginPath,
                    _protectedPath(state.uri.queryParameters['from']),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ];
  if (isDevelopment) {
    routes.add(
      GoRoute(
        path: GoogleAccountPreviewPage.path,
        parentNavigatorKey: root,
        pageBuilder: (_, state) => AppTransitionPage<void>(
          key: state.pageKey,
          child: GoogleAccountPreviewPage(
            identity: state.extra! as GoogleIdentity,
          ),
        ),
      ),
    );
  }
  return routes;
}

void _closePage(BuildContext context, String fallback) {
  if (ModalRoute.isCurrentOf(context) != true) return;
  context.canPop() ? context.pop() : context.go(fallback);
}

String? _protectedPath(String? path) {
  final destination = path == null ? null : AppDestination.fromPath(path);
  return destination?.protected == true ? destination?.path : null;
}

String authLocation(String path, String? from, {String? next}) {
  final query = {'from': ?from, 'next': ?next};
  return Uri(
    path: path,
    queryParameters: query.isEmpty ? null : query,
  ).toString();
}

/// Resume only registered routes. Incoming URLs do not become redirect targets.
String? sessionRedirect(
  Uri uri,
  SessionState session, {
  required DateTime now,
}) {
  final path = uri.path;
  final isAuth = authPagePaths.contains(path);
  final checking = path == authSessionPath;
  final from = _protectedPath(
    isAuth || checking ? uri.queryParameters['from'] : path,
  );

  if (session is SessionInitializing) {
    if (checking || (!isAuth && from == null)) return null;
    return authLocation(authSessionPath, from, next: isAuth ? path : null);
  }

  if (hasActiveSession(session, now)) {
    return isAuth || checking ? from ?? AppDestination.home.path : null;
  }
  if (checking) {
    final next = uri.queryParameters['next'];
    if (next != null && authPagePaths.contains(next)) {
      return authLocation(next, from);
    }
    return AppDestination.home.path;
  }
  return !isAuth && from != null ? AppDestination.home.path : null;
}

bool hasActiveSession(SessionState session, DateTime now) =>
    session is SessionAuthenticated && session.session.isUsableAt(now);
