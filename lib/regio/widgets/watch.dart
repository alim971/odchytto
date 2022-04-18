import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/dialog.dart';
import 'package:watcher/common/widgets/builder.dart';
import 'package:watcher/common/widgets/future.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/routes/routesDetails.dart';
import 'package:watcher/regio/theme.dart';
import 'package:watcher/regio/utils/utils.dart';

class WatcherOptionsMap {
  final Map<String, bool> _options = {};

  Map<String, bool> get options => _options;

  get optionsAsList =>
      _options.keys.where((key) => _options[key]! == true).toList();
}

class Watcher extends StatelessWidget {
  const Watcher({required this.route, required this.seatClass});
  final RouteTransport route;
  final String seatClass;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        notifier.refresh(shouldDelete: true);
        return true;
      },
      child: Scaffold(
          backgroundColor: brightRegioYellow,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).title),
            actions: [
              const AppBarBuilder(),
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
      {Key? key,
      required this.route,
      required this.seatClass,
      required this.options})
      : super(key: key);
  final RouteTransport route;
  final String seatClass;
  final List<WatchType> options;
  final WatcherOptionsMap map = WatcherOptionsMap();

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);

    return FutureBuilder(
        future: notifier.getWatched(route.id),
        builder: (context, AsyncSnapshot<WatchedEntity?> snapshot) {
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
                      for (var type in options)
                        WatchOption(type, map, snapshot.data, seatClass),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (map.optionsAsList.length == 0) {
                                await showMessage(
                                    context,
                                    AppLocalizations.of(context)
                                        .selectTypeTitle,
                                    AppLocalizations.of(context).selectType);
                                return;
                              }
                              if (snapshot.hasData) {
                                snapshot.data!.type = map.optionsAsList.reduce(
                                    (String value, String element) =>
                                        value + element);
                                snapshot.data!.tariffs = notifier.tariffs
                                    .map<String>((e) => e.key)
                                    .toList();
                                snapshot.data!.tickets =
                                    snapshot.data!.tariffs.length;
                                snapshot.data!.seatClasses =
                                    seatClass == '' ? [] : [seatClass];
                                snapshot.data!.url = getRegioShopUrl(
                                    snapshot.data!.routeId,
                                    snapshot.data!.fromStationId,
                                    snapshot.data!.toStationId,
                                    snapshot.data!.tariffs);
                                notifier.postWhole(snapshot.data!);
                              } else {
                                notifier.post(
                                    route.id,
                                    route.departureStation,
                                    route.arrivalStation,
                                    seatClass,
                                    route.arrivalTime,
                                    route.departureTime,
                                    map.optionsAsList);
                              }
                              await showMessage(
                                  context,
                                  AppLocalizations.of(context)
                                      .watchedRouteTitle,
                                  AppLocalizations.of(context).watchedRoute);
                              Navigator.popUntil(
                                  context,
                                  (Route<dynamic> predicate) =>
                                      predicate.isFirst);
                            },
                            icon: const Icon(Icons.catching_pokemon),
                            label: Text(AppLocalizations.of(context).title),
                          ),
                        ),
                      )
                    ],
                  )),
                ]);
          } else {
            return BuilderNoData(snapshot);
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
  const WatchOption(this.type, this.map, this.entity, this.seatClass,
      {Key? key})
      : super(key: key);
  final WatchType type;
  final WatcherOptionsMap map;
  final WatchedEntity? entity;
  final String seatClass;

  String get typeAsString =>
      type.toString().replaceAll(r'WatchType.', '').toLowerCase();

  @override
  State<WatchOption> createState() => _WatchOptionState(
      isSwitched: entity != null &&
          entity!.type.contains(typeAsString) &&
          ((entity!.seatClasses.length == 0 && seatClass == "") ||
              (entity!.seatClasses.contains(seatClass) && seatClass != "")));
}

class _WatchOptionState extends State<WatchOption> {
  _WatchOptionState({this.isSwitched = false});
  bool isSwitched;

  get text {
    switch (widget.typeAsString) {
      case 'tickets':
        return AppLocalizations.of(context).tickets;
      case 'delays':
        return AppLocalizations.of(context).delays;
      case 'cancelled':
        return AppLocalizations.of(context).cancelation;
      default:
        return "Invalid choice";
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.map.options.update(widget.typeAsString, (previous) => isSwitched,
        ifAbsent: () => isSwitched);
    // isSwitched = widget.entity == null ? false : widget.entity!.type.contains(widget.type);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        color: brightRegioYellow,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PlaceName(text, size: 0.3),
              Center(
                child: Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                      widget.map.options.update(
                          widget.typeAsString, (previous) => value,
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
