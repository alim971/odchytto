import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/data/data.dart' as data;
import 'package:watcher/data/localization.dart';
import 'package:watcher/dialog.dart';
import 'package:watcher/theme.dart';
import 'package:watcher/utils.dart';
import 'package:watcher/widgets/prefs.dart';

import 'data/models.dart';

class WatcherOptionsMap {
  Map<String, bool> _options = {};

  Map<String, bool> get options => _options;

  get optionsAsList =>
      _options.keys.where((key) => _options[key]! == true).toList();
}

class Watcher extends StatelessWidget {
  const Watcher({required this.route, required this.seatClass});
  final data.Route route;
  final String seatClass;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        notifier.refresh();
        return true;
      },
      child: Scaffold(
          backgroundColor: berlinBrightYellow,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).title),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => showPreferences(context),
                ),
              ),
            ],
          ),
          body: WatchOptionsSelect(
              route: route,
              seatClass: seatClass,
              options: [WatchType.TICKETS, WatchType.DELAYS])),
    );
  }
}

class WatchOptionsSelect extends StatelessWidget {
  WatchOptionsSelect(
      {required this.route, required this.seatClass, required this.options});
  final data.Route route;
  final String seatClass;
  final List<WatchType> options;
  final WatcherOptionsMap map = WatcherOptionsMap();
  Iterable<String> get optionsAsStrings => options.map<String>(
      (t) => t.toString().replaceAll(r'WatchType.', '').toLowerCase());

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);

    return FutureBuilder(
        future: notifier.getWatched(route.id),
        builder: (context, AsyncSnapshot<data.WatchedEntity?> snapshot) {
          if (snapshot.hasData ||
              (snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError)) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RouteInfo(
                      departureName: notifier.allLocations!
                          .firstWhere(
                              (element) => element.id == route.departureStation)
                          .name
                          .replaceAll(' - ', ','),
                      arrivalName: notifier.allLocations!
                          .firstWhere(
                              (element) => element.id == route.arrivalStation)
                          .name
                          .replaceAll(' - ', ','),
                      departureTime: route.departureTime,
                      arrivalTime: route.arrivalTime),
                  Expanded(
                      child: ListView(
                    children: [
                      for (var type in optionsAsStrings)
                        WatchOption(type, map, snapshot.data),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (snapshot.hasData) {
                                snapshot.data!.type = map.optionsAsList.reduce(
                                    (String value, String element) =>
                                        value + element);
                                snapshot.data!.tariffs = notifier.tariffs
                                    .map<String>((e) => e.key)
                                    .toList();
                                snapshot.data!.tickets =
                                    snapshot.data!.tariffs.length;
                                snapshot.data!.seatClasses = [seatClass];
                                notifier.postWhole(snapshot.data!);
                              } else {
                                notifier.post(
                                    route.id,
                                    route.departureStation,
                                    route.arrivalStation,
                                    seatClass,
                                    route.arrivalTime,
                                    map.optionsAsList);
                              }
                              await showMessage(context, "Route watched",
                                  "This route is now beeing watched.");
                              Navigator.popUntil(
                                  context,
                                  (Route<dynamic> predicate) =>
                                      predicate.isFirst);
                            },
                            icon: Icon(Icons.catching_pokemon),
                            label: Text("Catch it"), //TODO Add translation
                          ),
                        ),
                      )
                    ],
                  )),
                ]);
          } else if (snapshot.hasError) {
            return Container(
              color: berlinBrightYellow,
              child: Center(
                child: Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return Container(
              color: berlinBrightYellow,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}

enum WatchType {
  TICKETS,
  DELAYS,
  CANCELLED,
}

class WatchOption extends StatefulWidget {
  const WatchOption(this.type, this.map, this.entity, {Key? key})
      : super(key: key);
  final String type;
  final WatcherOptionsMap map;
  final data.WatchedEntity? entity;

  @override
  State<WatchOption> createState() => _WatchOptionState(
      isSwitched: entity != null && entity!.type.contains(type));
}

class _WatchOptionState extends State<WatchOption> {
  _WatchOptionState({this.isSwitched = false});
  bool isSwitched;

  @override
  Widget build(BuildContext context) {
    widget.map.options.update(widget.type, (previous) => isSwitched,
        ifAbsent: () => isSwitched);
    // isSwitched = widget.entity == null ? false : widget.entity!.type.contains(widget.type);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        color: berlinBrightYellow,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PlaceName(widget.type, size: 0.3), //TODO add translation
              Center(
                child: Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                      widget.map.options.update(
                          widget.type, (previous) => value,
                          ifAbsent: () => value);
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
