import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart' hide GoogleIdentity;
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/domain/google_identity.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/app_header.dart';

class GoogleAccountPreviewPage extends StatelessWidget {
  const GoogleAccountPreviewPage({super.key, required this.identity});

  final GoogleIdentity identity;

  static const path = '/dev/google-account-preview';
  static const _unavailable = 'Tidak tersedia';

  @override
  Widget build(BuildContext context) {
    final data = identity.registrationData;
    return Scaffold(
      backgroundColor: AppColors.headerSurface,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Google Account Preview',
                    style: AppTypography.authHeading,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                primary: false,
                padding: const EdgeInsets.all(AppSpacing.page),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundImage: data.photoUrl == null
                                ? null
                                : NetworkImage(data.photoUrl!),
                            onBackgroundImageError: data.photoUrl == null
                                ? null
                                : (_, _) {},
                            child: data.photoUrl == null
                                ? const Icon(Icons.person, size: 42)
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            'Google Sign-In berhasil',
                            style: AppTypography.authTitle,
                          ),
                          const Text(
                            'Data profil dan token belum diverifikasi backend.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  _section('Informasi Akun', [
                    _field('Google User ID', data.googleUserId),
                    _field('Nama lengkap', data.displayName),
                    _field('Nama depan', data.givenName),
                    _field('Nama belakang', data.familyName),
                    _field('Email', data.email),
                    _field(
                      'Email terverifikasi',
                      data.emailVerified?.toString(),
                    ),
                    _field('Profile Photo URL', data.photoUrl),
                    _field(
                      'ID Token tersedia',
                      identity.idToken?.isNotEmpty == true ? 'Ya' : 'Tidak',
                    ),
                    for (final entry in data.unverifiedClaims.entries)
                      _field(
                        '${entry.key} (belum diverifikasi)',
                        entry.value?.toString(),
                      ),
                  ]),
                  const SizedBox(height: AppSpacing.page),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Kembali'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await GoogleSignIn.instance.signOut();
                      if (context.mounted) context.pop();
                    },
                    child: const Text('Masuk dengan Akun Lain'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await GoogleSignIn.instance.signOut();
                      if (context.mounted) context.go('/');
                    },
                    child: const Text('Keluar dari Google'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _section(String title, List<Widget> fields) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.authHeading),
          const SizedBox(height: AppSpacing.small),
          ...fields,
        ],
      ),
    ),
  );

  static Widget _field(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: AppTypography.authCaption)),
        Expanded(
          flex: 3,
          child: SelectableText(
            value?.isNotEmpty == true ? value! : _unavailable,
          ),
        ),
      ],
    ),
  );
}
