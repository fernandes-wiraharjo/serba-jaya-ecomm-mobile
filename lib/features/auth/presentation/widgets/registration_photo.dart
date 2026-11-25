import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_graphics.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class RegistrationPhoto extends StatefulWidget {
  const RegistrationPhoto({super.key});

  @override
  State<RegistrationPhoto> createState() => _RegistrationPhotoState();
}

class _RegistrationPhotoState extends State<RegistrationPhoto> {
  Uint8List? _preview;
  String? _fileName;
  bool _picking = false;

  Future<void> _pick() async {
    if (_picking) return;
    FocusScope.of(context).unfocus();
    setState(() => _picking = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );
      if (file == null || !mounted) return;
      final preview = await file.readAsBytes();
      if (mounted) {
        setState(() {
          _preview = preview;
          _fileName = file.name;
        });
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).authPhotoFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final image = _preview;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.page),
      decoration: BoxDecoration(
        color: AppColors.authField,
        borderRadius: BorderRadius.circular(AppRadius.authField),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.authFieldBorder, width: .5),
            ),
            child: image == null
                ? const Center(child: AuthIcon(AuthAssets.photo, size: 40))
                : Image.memory(
                    image,
                    fit: BoxFit.cover,
                    semanticLabel: strings.authPhoto,
                    errorBuilder: (_, _, _) => const Center(
                      child: AuthIcon(AuthAssets.photo, size: 40),
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.authControlGap),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 183),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.authPhoto,
                      style: AppTypography.authDescription.copyWith(
                        color: AppColors.authText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fileName ?? strings.authNoPhoto,
                      style: AppTypography.authDescription.copyWith(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AuthActionButton(
                      label: strings.authPickPhoto,
                      filled: false,
                      onPressed: _picking ? null : _pick,
                      loadingLabel: _picking ? strings.authPreparing : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
