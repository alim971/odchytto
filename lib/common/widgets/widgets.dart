/// Widgets shared across the app
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/regio/data/models.dart';

/// Overrides the phone's locale, only if a locale is provided
class OverrideLocalization extends StatelessWidget {
  const OverrideLocalization(
      {Key? key, required this.locale, required this.child})
      : super(key: key);
  final Locale locale;
  final Widget child;

  @override
  Widget build(BuildContext context) => locale != null
      ? Localizations.override(
          context: context,
          locale: locale,
          child: child,
        )
      : child;

  Widget build2(BuildContext build) {
    return Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => locale != null
            ? Localizations.override(
                context: context,
                locale: locale,
                child: child,
              )
            : child);
  }
}

class PlaceName extends StatelessWidget {
  const PlaceName(this.name,
      {this.center = true,
      this.highlight = true,
      this.size = 1.0,
      this.color = Colors.black});
  final String name;
  final bool highlight;
  final bool center;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * size,
        child: Text(
          name,
          textAlign: center ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: highlight ? 16 : 13,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            color: color,
          ),
        ),
      ),
    );
  }
}
