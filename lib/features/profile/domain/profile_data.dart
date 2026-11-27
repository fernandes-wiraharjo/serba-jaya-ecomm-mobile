enum ProfileGender { male, female }

final class ProfileData {
  const ProfileData({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.gender,
  });

  final String name;
  final String email;
  final String phone;
  final ProfileGender? gender;
}
