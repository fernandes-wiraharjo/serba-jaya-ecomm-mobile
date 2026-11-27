import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_graphics.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_field.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/features/profile/domain/profile_data.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_components.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_controller.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: ref.read(profileControllerProvider).name,
  );
  ProfileGender? _gender;

  @override
  void initState() {
    super.initState();
    _gender = ref.read(profileControllerProvider).gender;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final profile = ref.watch(profileControllerProvider);
    return ProfileScreen(
      title: s.profileEdit,
      children: [
        ProfileSurface(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 10,
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: profileBackground,
                child: AuthIcon(AuthAssets.photo, size: 40),
              ),
              Text(
                s.profileChangePhoto,
                style: AppTypography.authCaption.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authPrimary,
                ),
              ),
              Text(
                s.profileFeatureUnavailable,
                style: AppTypography.authCaption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              ProfileField(
                key: const ValueKey('profile-name'),
                label: s.profileFullName,
                controller: _name,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? s.profileNameRequired
                    : null,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.profileGender, style: ProfileField.labelStyle),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    children: [
                      for (final (gender, label) in [
                        (ProfileGender.male, s.profileMale),
                        (ProfileGender.female, s.profileFemale),
                      ])
                        _GenderChoice(
                          label: label,
                          selected: _gender == gender,
                          onTap: () => setState(
                            () => _gender = _gender != gender ? gender : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              ProfileField(
                label: s.profilePhone,
                initialValue: profile.phone.isEmpty
                    ? s.profileNoData
                    : profile.phone,
                enabled: false,
              ),
              ProfileField(
                label: s.profileEmail,
                initialValue: profile.email.isEmpty
                    ? s.profileNoData
                    : profile.email,
                enabled: false,
              ),
              Text(s.profileContactHint, style: AppTypography.authCaption),
              AuthActionButton(
                label: s.profileSave,
                onPressed: () {
                  if (_form.currentState?.validate() != true) return;
                  ref
                      .read(profileControllerProvider.notifier)
                      .edit(_name.text, _gender);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(s.profileLocalSaved)));
                  context.canPop() ? context.pop() : context.go('/profile');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderChoice extends StatelessWidget {
  const _GenderChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.authPrimary : AppColors.authSecondary;
    final borderRadius = BorderRadius.circular(12);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? const Color(0xFFFFF0F0) : Colors.white,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? color : Colors.transparent,
                    border: Border.all(color: color),
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.authCaption.copyWith(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
