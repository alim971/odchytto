import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/widgets/future.dart';
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/search/widgets.dart';
import 'package:watcher/regio/theme.dart' as theme;
import 'package:watcher/regio/widgets/other.dart';

class PlacesSearchDelegate extends SearchDelegate<Location> {
  PlacesSearchDelegate(this.context);
  final BuildContext context;

  @override
  String get searchFieldLabel => AppLocalizations.of(context).search;

  @override
  ThemeData appBarTheme(BuildContext context) => theme.appTheme;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        notifier.refresh(shouldDelete: true);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return FutureBuilder(
        future: notifier.locationSearchPlaces(query),
        builder: (context, AsyncSnapshot<List<Location>?> snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: theme.brightRegioYellow,
              child: ListView(
                children: snapshot.data!
                    .map(
                      (el) => (el is Station)
                          ? StationTile(
                              station: el,
                              onTap: () => close(context, el),
                            )
                          : CityTile(
                              city: el as City,
                              onTap: () => close(context, el),
                            ),
                    )
                    .toList(),
              ),
            );
          } else {
            return BuilderNoData(snapshot);
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return FutureBuilder(
        future: notifier.locationSearchPlaces(query),
        builder: (context, AsyncSnapshot<List<Location>?> snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: theme.brightRegioYellow,
              child: ListView(
                children: snapshot.data!
                    .map(
                      (el) => (el is Station)
                          ? StationTile(
                              station: el,
                              onTap: () => close(context, el),
                            )
                          : CityTile(
                              city: el as City,
                              onTap: () => close(context, el),
                            ),
                    )
                    .toList(),
              ),
            );
          } else if ((snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError)) {
            return const ContainerWithIcon();
          } else {
            return BuilderNoData(snapshot);
          }
        });
  }
}
