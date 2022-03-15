// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/data/data.dart';
import 'package:watcher/data/models.dart';
import 'package:watcher/theme.dart' as theme;

import '../utils.dart';

Future<LocationS?> showPlacesSearch(BuildContext context) async =>
    await showSearch<LocationS>(
      context: context,
      delegate: PlacesSearchDelegate(),
    );

class PlacesSearchDelegate extends SearchDelegate<LocationS> {
  @override
  ThemeData appBarTheme(BuildContext context) => theme.appTheme;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);

    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        notifier.refresh();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return FutureBuilder(
        future: notifier.locationSearchPlaces(query),
        builder: (context, AsyncSnapshot<List<LocationS>?> snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: theme.berlinBrightYellow,
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
          } else if (snapshot.hasError) {
            return Container(
              color: theme.berlinBrightYellow,
              child: Center(
                child: Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return Container(
              color: theme.berlinBrightYellow,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return FutureBuilder(
        future: notifier.locationSearchPlaces(query),
        builder: (context, AsyncSnapshot<List<LocationS>?> snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: theme.berlinBrightYellow,
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
          } else if (snapshot.hasError) {
            return Container(
              color: theme.berlinBrightYellow,
              child: Center(
                child: Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return Container(
              color: theme.berlinBrightYellow,
              child: Center(
                child: Opacity(
                    opacity: 0.2,
                    child: Icon(
                      Icons.directions_railway,
                      size: 200,
                    )),
              ),
            );
          }
        });
  }
}

/// Tile depicting a place
class PlaceTile extends StatelessWidget {
  PlaceTile({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(place.name ?? ''),
      leading: Icon(Icons.home),
      onTap: onTap,
    );
  }
}

/// Tile depicting a stop
class StopTile extends StatelessWidget {
  StopTile({required this.stop, required this.onTap});
  final Stop stop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(stop.name ?? ''),
      leading: const Icon(Icons.train),
      subtitle: Text(stop.typesAsStrings.join(', ')),
      onTap: onTap,
    );
  }
}

class CityTile extends StatelessWidget {
  CityTile({required this.city, required this.onTap});
  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(city.name + ', ' + city.country),
      minLeadingWidth: 20,
      leading: Icon(Icons.location_pin),
      // subtitle: Text('aaa'),
      onTap: onTap,
    );
  }
}

class StationTile extends StatelessWidget {
  StationTile({required this.station, required this.onTap});
  final Station station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(station.fullName),
      leading: Container(
        width: 70,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: getIcons(station)),
        ),
      ),
      // subtitle: Text('aaa'),
      onTap: onTap,
    );
  }
}
