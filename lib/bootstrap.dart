import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/app/app.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/app/config/auth_provider.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/core/storage/storage_providers.dart';
import 'package:serba_jaya_mobile/core/location/location_providers.dart';
import 'package:serba_jaya_mobile/core/ui/scroll/app_scroll_behavior.dart';
import 'package:serba_jaya_mobile/features/auth/data/secure_session_repository.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/sign_in_action.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/widgets/feedback_panel.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final config = AppConfig.fromDefines();
    runApp(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          mapConfigurationProvider.overrideWithValue(
            MapConfiguration(
              androidKey: config.googleMapsAndroidApiKey,
              iosKey: config.googleMapsIosApiKey,
              showSetupHint: config.environment == AppEnvironment.dev,
            ),
          ),
          requestGoogleIdentityProvider.overrideWith(
            (ref) => ref.watch(googleIdentityProvider),
          ),
          sessionRepositoryProvider.overrideWith(
            (ref) => SecureSessionRepository(ref.watch(secureStoreProvider)),
          ),
        ],
        child: const SerbaJayaApp(),
      ),
    );
  } on FormatException {
    runApp(
      MaterialApp(
        scrollBehavior: const AppScrollBehavior(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: FeedbackPanel(
              message: AppLocalizations.of(context).startupError,
            ),
          ),
        ),
      ),
    );
  }
}
