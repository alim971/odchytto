import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/widgets/search.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/theme.dart';

class Origin extends StatelessWidget {
  const Origin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return GestureDetector(
        child: notifier.departure != null
            ? EmbossedText(notifier.departure!.name)
            : EmbossedText(AppLocalizations.of(context).origin),
        onTap: () => showPlacesSearch(context)
            .then((place) => notifier.departure = place ?? notifier.departure));
  }
}

class Destination extends StatelessWidget {
  const Destination({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return GestureDetector(
        child: notifier.arrival != null
            ? EmbossedText(notifier.arrival!.name)
            : EmbossedText(AppLocalizations.of(context).destination),
        onTap: () => showPlacesSearch(context)
            .then((place) => notifier.arrival = place ?? notifier.arrival));
  }
}

class EmbossedText extends StatelessWidget {
  const EmbossedText(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          color: brightRegioYellow,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
