import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/registration_validation.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_graphics.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/registration_controls.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/registration_photo.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

enum _Gender { unspecified, male, female }

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    super.key,
    required this.onCancel,
    this.providerEmail,
  });

  final VoidCallback onCancel;

  /// Supplied by a trusted provider flow when one becomes available.
  final String? providerEmail;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _form = GlobalKey<FormState>();
  bool _validSubmission = false;

  void _submit() {
    FocusScope.of(context).unfocus();
    final valid = _form.currentState?.validate() ?? false;
    if (_validSubmission != valid) setState(() => _validSubmission = valid);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Theme(
      data: AppTheme.authentication(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 12)],
            ),
          ),
          toolbarHeight: 55,
          leadingWidth: 44,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: widget.onCancel,
            tooltip: strings.authBack,
            icon: Transform.translate(
              offset: const Offset(6, 0),
              child: const RotatedBox(
                quarterTurns: 2,
                child: AuthIcon(AuthAssets.back),
              ),
            ),
          ),
          title: Text(
            strings.authRegistrationTitle,
            style: AppTypography.authHeading,
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.authFormInset,
              AppSpacing.authFormInset,
              AppSpacing.authFormInset,
              AppSpacing.large,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _form,
                  onChanged: () {
                    if (_validSubmission) {
                      setState(() => _validSubmission = false);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.page,
                    children: [
                      Text(
                        strings.authRequiredLegend,
                        style: AppTypography.authCaption,
                      ),
                      const RegistrationPhoto(),
                      RegistrationLabel(
                        label: strings.authName,
                        child: TextFormField(
                          key: const ValueKey('registration-name'),
                          decoration: registrationDecoration(
                            hint: strings.authNameHint,
                          ),
                          style: AppTypography.authInput,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          validator: (value) =>
                              validateRegistrationName(value, strings),
                        ),
                      ),
                      _phone(strings),
                      _email(strings),
                      RegistrationLabel(
                        label: strings.authBirthDate,
                        child: const RegistrationBirthDate(),
                      ),
                      RegistrationLabel(
                        label: strings.authGender,
                        child: _gender(strings),
                      ),
                      RegistrationLabel(
                        label: strings.authReferral,
                        child: TextFormField(
                          decoration: registrationDecoration(
                            hint: strings.authReferralHint,
                          ),
                          style: AppTypography.authInput,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const RegistrationConsent(),
                      AuthActionButton(
                        label: strings.authCreateAccount,
                        onPressed: _submit,
                      ),
                      if (_validSubmission)
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            strings.authRegistrationUnavailable,
                            style: AppTypography.authDescription,
                          ),
                        ),
                      AuthActionButton(
                        label: strings.authCancel,
                        filled: false,
                        onPressed: widget.onCancel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phone(AppLocalizations strings) => RegistrationLabel(
    label: strings.authPhone,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          child: Row(
            children: [
              const AuthIcon(AuthAssets.flag),
              const SizedBox(width: 9),
              SizedBox(
                width: 31,
                child: Text(
                  strings.authPhonePrefix,
                  style: AppTypography.authLabel,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TextFormField(
            key: const ValueKey('registration-phone'),
            decoration: registrationDecoration(hint: strings.authPhoneHint),
            style: AppTypography.authInput,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) => validateRegistrationPhone(value, strings),
          ),
        ),
      ],
    ),
  );

  Widget _email(AppLocalizations strings) {
    final email = widget.providerEmail?.trim() ?? '';
    if (email.isNotEmpty) {
      return RegistrationLabel(
        label: strings.authEmailFromProvider,
        child: LinkedEmail(email: email),
      );
    }
    return RegistrationLabel(
      label: strings.authEmail,
      child: TextFormField(
        key: const ValueKey('registration-email'),
        decoration: registrationDecoration(hint: strings.authEmailHint),
        style: AppTypography.authInput,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
        validator: (value) => validateRegistrationEmail(value, strings),
      ),
    );
  }

  Widget _gender(AppLocalizations strings) => DropdownButtonFormField<_Gender>(
    isExpanded: true,
    decoration: registrationDecoration(),
    hint: Text(strings.authGenderHint, style: AppTypography.authPlaceholder),
    style: AppTypography.authInput.copyWith(color: AppColors.authText),
    icon: const RotatedBox(
      quarterTurns: 1,
      child: AuthIcon(AuthAssets.dropdown),
    ),
    items: [
      DropdownMenuItem(
        value: _Gender.unspecified,
        child: Text(strings.authGenderUnspecified),
      ),
      DropdownMenuItem(
        value: _Gender.male,
        child: Text(strings.authGenderMale),
      ),
      DropdownMenuItem(
        value: _Gender.female,
        child: Text(strings.authGenderFemale),
      ),
    ],
    onChanged: (_) {},
  );
}
