import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/profile/domain/profile_data.dart';

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileData>(ProfileController.new);

class ProfileController extends Notifier<ProfileData> {
  @override
  ProfileData build() {
    ref.watch(sessionProvider);
    return const ProfileData();
  }

  void edit(String name, ProfileGender? gender) {
    if (name.trim().isEmpty) return;
    state = ProfileData(
      name: name.trim(),
      gender: gender,
      email: state.email,
      phone: state.phone,
    );
  }
}
