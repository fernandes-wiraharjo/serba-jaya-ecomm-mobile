import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

enum AppDestination {
  home('/'),
  cart('/cart', protected: true),
  chat('/chat'),
  orders('/orders', protected: true),
  profile('/profile', protected: true),
  notifications('/notifications', protected: true);

  const AppDestination(this.path, {this.protected = false});

  final String path;
  final bool protected;

  String label(AppLocalizations strings) => switch (this) {
    home => strings.home,
    cart => strings.cart,
    chat => strings.chat,
    orders => strings.orders,
    profile => strings.profile,
    notifications => strings.notifications,
  };

  static AppDestination? fromPath(String path) {
    for (final destination in values) {
      if (destination.path == path) return destination;
    }
    return null;
  }
}
