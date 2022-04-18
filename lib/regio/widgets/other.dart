import 'package:flutter/material.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/theme.dart';

class ContainerWithIcon extends StatelessWidget {
  const ContainerWithIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: brightRegioYellow,
        child: const Center(
            child: Opacity(
          opacity: 0.2,
          child: Icon(
            Icons.directions_subway,
            size: 200,
          ),
        )));
  }
}

class ContainerWithIconNoRoutes extends StatelessWidget {
  const ContainerWithIconNoRoutes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: brightRegioYellow,
        child: Center(
            child: Column(
          children: [
            PlaceName(AppLocalizations.of(context).noRoutesFound),
            const Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.directions_subway,
                size: 200,
              ),
            ),
          ],
        )));
  }
}
