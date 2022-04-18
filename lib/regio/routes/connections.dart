import 'package:flutter/material.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/utils.dart';
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/theme.dart';

class ConnectionWidget extends StatelessWidget {
  const ConnectionWidget(this.sectionFirst, this.transfer, {Key? key})
      : super(key: key);
  final Section sectionFirst;
  final Transfer transfer;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SectionWidget(sectionFirst, false),
      const SizedBox(height: 15),
      TransferWidget(transfer),
      const SizedBox(height: 15),
    ]);
  }
}

class TransferWidget extends StatelessWidget {
  const TransferWidget(this.transfer, {Key? key}) : super(key: key);
  final Transfer transfer;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      const SizedBox(width: 52),
      const Icon(Icons.access_time),
      const SizedBox(width: 10),
      Text(AppLocalizations.of(context).wait + format(transfer.time),
          style: const TextStyle(color: grey, fontSize: 15))
    ]);
  }
}

class SectionWidget extends StatelessWidget {
  const SectionWidget(this.section, this.isDestination, {Key? key})
      : super(key: key);
  final Section section;
  final bool isDestination;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(prettyTime(section.departureTime)),
          const SizedBox(width: 10),
          if (section.getType().contains('train')) const Icon(Icons.train),
          if (section.getType().contains('bus'))
            const Icon(Icons.directions_bus),
          const SizedBox(width: 10),
          Text(section.departureName)
        ]),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(section.travelTime,
              style: const TextStyle(color: grey, fontSize: 11.5)),
          const SizedBox(width: 10),
          const Icon(Icons.south_sharp),
          const SizedBox(width: 10),
          Text(
              section.line.getLine() +
                  " " +
                  section.line.from +
                  " - " +
                  section.line.to +
                  (section.line.code != ""
                      ? " (" + section.line.code + ")"
                      : ""),
              style: const TextStyle(color: grey, fontSize: 15)),
        ]),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(prettyTime(section.arrivalTime)),
          const SizedBox(width: 10),
          if (!isDestination) const Icon(Icons.circle_rounded),
          if (isDestination) const Icon(Icons.place),
          const SizedBox(width: 10),
          Text(section.arrivalName)
        ]),
      ],
    );
  }
}
