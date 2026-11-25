import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/sign_in_action.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_graphics.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, required this.onClose, required this.onRegister});

  final VoidCallback onClose;
  final VoidCallback onRegister;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  AuthSignInMethod? _pending;
  String? _notice;

  Future<void> _requestSignIn(AuthSignInMethod method) async {
    if (_pending != null) return;
    final strings = AppLocalizations.of(context);
    final action = ref.read(signInActionProvider);
    if (action == null) {
      setState(() => _notice = strings.authProviderUnavailable);
      return;
    }

    setState(() {
      _pending = method;
      _notice = null;
    });
    try {
      await action(method);
    } on Exception {
      if (mounted) setState(() => _notice = strings.authProviderFailed);
    } finally {
      if (mounted) setState(() => _pending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Theme(
      data: AppTheme.authentication(Theme.of(context)),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.authLoginInset,
                ),
                child: LayoutBuilder(
                  builder: (context, viewport) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewport.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 11),
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Transform.translate(
                                  offset: const Offset(8, 0),
                                  child: IconButton(
                                    onPressed: widget.onClose,
                                    tooltip: strings.authClose,
                                    icon: const AuthIcon(AuthAssets.close),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.authLoginInset,
                                ),
                                child: Center(child: _content(strings)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 23,
                              ),
                              child: Text(
                                strings.authVersion(
                                  const String.fromEnvironment(
                                    'APP_DISPLAY_VERSION',
                                    defaultValue: '0.1.0',
                                  ),
                                ),
                                style: AppTypography.authCaption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(AppLocalizations strings) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AuthLogo(size: const Size(197, 200), label: strings.authBrand),
      const SizedBox(height: AppSpacing.authLogoGap),
      SizedBox(
        height: 1,
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.fill,
          child: SvgPicture.asset(
            AuthAssets.divider,
            width: 346,
            height: 1,
            excludeFromSemantics: true,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.authLogoGap - 1),
      Text(
        strings.authWelcome,
        style: AppTypography.authTitle,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.small),
      Text(
        strings.authDescription,
        style: AppTypography.authDescription,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.authSectionGap),
      AuthActionButton(
        label: strings.authApple,
        onPressed: _pending == null
            ? () => _requestSignIn(AuthSignInMethod.apple)
            : null,
        radius: AppRadius.control,
        trailing: const AuthIcon(AuthAssets.apple),
        loadingLabel: _pending == AuthSignInMethod.apple
            ? strings.authPreparing
            : null,
      ),
      const SizedBox(height: AppSpacing.authControlGap),
      AuthActionButton(
        label: strings.authGoogle,
        onPressed: _pending == null
            ? () => _requestSignIn(AuthSignInMethod.google)
            : null,
        filled: false,
        radius: AppRadius.control,
        outline: AppColors.authPrimary,
        trailing: Image.asset(
          AuthAssets.google,
          width: 23,
          height: 24,
          excludeFromSemantics: true,
        ),
        loadingLabel: _pending == AuthSignInMethod.google
            ? strings.authPreparing
            : null,
      ),
      if (_notice case final notice?) ...[
        const SizedBox(height: AppSpacing.authControlGap),
        Semantics(
          liveRegion: true,
          child: Text(
            notice,
            textAlign: TextAlign.center,
            style: AppTypography.authCaption.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.authSectionGap - 10),
      TextButton(
        onPressed: _pending == null ? widget.onRegister : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          foregroundColor: AppColors.authPrimary,
        ),
        child: Text.rich(
          TextSpan(
            style: AppTypography.authDescription,
            children: [
              TextSpan(text: strings.authNoAccount),
              TextSpan(
                text: strings.authRegister,
                style: const TextStyle(
                  color: AppColors.authPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}
