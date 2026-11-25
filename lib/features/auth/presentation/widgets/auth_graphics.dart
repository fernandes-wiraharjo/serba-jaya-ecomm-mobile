import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class AuthAssets {
  static const logo = 'assets/auth/logo.png';
  static const alert = 'assets/auth/login_alert.png';
  static const apple = 'assets/auth/apple.svg';
  static const google = 'assets/auth/google.png';
  static const close = 'assets/auth/close.svg';
  static const divider = 'assets/auth/divider.svg';
  static const back = 'assets/auth/back.svg';
  static const photo = 'assets/auth/photo.svg';
  static const flag = 'assets/auth/flag_id.svg';
  static const connected = 'assets/auth/connected.svg';
  static const calendar = 'assets/auth/calendar.svg';
  static const dropdown = 'assets/auth/dropdown.svg';
  static const checked = 'assets/auth/checked.svg';
}

class AuthIcon extends StatelessWidget {
  const AuthIcon(this.asset, {super.key, this.size = 24});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Center(
      child: SvgPicture.asset(
        asset,
        width: switch (asset) {
          AuthAssets.apple => 19.9987,
          AuthAssets.photo => 34.8333,
          _ => size,
        },
        height: switch (asset) {
          AuthAssets.apple => 23.9992,
          AuthAssets.photo => 31.5,
          _ => size,
        },
        excludeFromSemantics: true,
      ),
    ),
  );
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, required this.size, required this.label});

  final Size size;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: label,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // The Figma image fill uses this crop in both logo viewports.
            Positioned(
              left: -size.width * .5486,
              top: -size.height * .5445,
              width: size.width * 2.1042,
              height: size.height * 2.0753,
              child: Image.asset(
                AuthAssets.logo,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
