import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_graphics.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

InputDecoration registrationDecoration({String? hint}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.authField),
    borderSide: const BorderSide(color: AppColors.authFieldBorder, width: .5),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.authPlaceholder,
    filled: true,
    fillColor: AppColors.authField,
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.authPrimary),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
    constraints: const BoxConstraints(minHeight: 50),
    isDense: true,
    errorMaxLines: 3,
  );
}

class RegistrationLabel extends StatelessWidget {
  const RegistrationLabel({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: AppTypography.authLabel),
      const SizedBox(height: AppSpacing.page),
      Semantics(label: label, child: child),
    ],
  );
}

class LinkedEmail extends StatelessWidget {
  const LinkedEmail({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.authConnected,
        borderRadius: BorderRadius.circular(AppRadius.authField),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: AppTypography.authDescription.copyWith(
                      color: AppColors.authConnectedText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.authEmailLinked,
                    style: AppTypography.authCaption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const AuthIcon(AuthAssets.connected),
          ],
        ),
      ),
    );
  }
}

class RegistrationBirthDate extends StatelessWidget {
  const RegistrationBirthDate({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return FormField<DateTime>(
      builder: (field) {
        final date = field.value;
        return InkWell(
          borderRadius: BorderRadius.circular(AppRadius.authField),
          onTap: () async {
            FocusScope.of(context).unfocus();
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1),
              lastDate: DateUtils.dateOnly(DateTime.now()),
              helpText: strings.authBirthDate,
              builder: (context, child) => Theme(
                data: AppTheme.authentication(Theme.of(context)),
                child: child!,
              ),
            );
            if (field.mounted && picked != null) field.didChange(picked);
          },
          child: InputDecorator(
            decoration: registrationDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date == null
                        ? strings.authDateHint
                        : DateFormat('dd/MM/yyyy', 'id').format(date),
                    style: date == null
                        ? AppTypography.authPlaceholder
                        : AppTypography.authInput,
                  ),
                ),
                const AuthIcon(AuthAssets.calendar),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RegistrationConsent extends StatelessWidget {
  const RegistrationConsent({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return FormField<bool>(
      initialValue: false,
      validator: (checked) =>
          checked == true ? null : strings.authConsentRequired,
      builder: (field) {
        final checked = field.value == true;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              checked: checked,
              child: InkWell(
                onTap: () => field.didChange(!checked),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (checked)
                      const AuthIcon(AuthAssets.checked)
                    else
                      SizedBox.square(
                        dimension: 24,
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.authSecondary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        strings.authConsent,
                        style: AppTypography.authCaption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (field.errorText case final error?)
              Padding(
                padding: const EdgeInsets.only(left: 30, top: 4),
                child: Text(
                  error,
                  style: AppTypography.authCaption.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
