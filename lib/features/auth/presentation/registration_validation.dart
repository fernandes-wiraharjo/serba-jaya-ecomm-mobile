import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final _phonePattern = RegExp(r'^[0-9]{1,13}$');

String? validateRegistrationName(String? value, AppLocalizations strings) =>
    (value?.trim().isEmpty ?? true) ? strings.authNameRequired : null;

String? validateRegistrationPhone(String? value, AppLocalizations strings) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) return strings.authPhoneRequired;
  final nationalNumber = input.startsWith('0') ? input.substring(1) : input;
  return _phonePattern.hasMatch(nationalNumber)
      ? null
      : strings.authPhoneInvalid;
}

String? validateRegistrationEmail(String? value, AppLocalizations strings) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) return strings.authEmailRequired;
  return _emailPattern.hasMatch(input) ? null : strings.authEmailInvalid;
}
