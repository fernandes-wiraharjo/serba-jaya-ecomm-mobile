import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class DevShell extends StatelessWidget {
  const DevShell({super.key, required this.destination, required this.child});

  final AppDestination destination;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(destination.label(strings))),
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (final item in AppDestination.values)
              if (item != AppDestination.notifications)
                Semantics(
                  selected: item == destination,
                  child: TextButton(
                    onPressed: () => context.go(item.path),
                    child: Text(item.label(strings)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
