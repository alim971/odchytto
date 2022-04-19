import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/ads/AdState.dart';
import 'package:watcher/common/ads/widgets.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/utils.dart';
import 'package:watcher/common/widgets/future.dart';
import 'package:watcher/regio/data/api.dart' as api;
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/routes/routesDetails.dart';
import 'package:watcher/regio/theme.dart';

import '../../common/utils/shared.dart';
import '../../common/widgets/widgets.dart';

class WatchedRoutes extends StatelessWidget {
  WatchedRoutes({this.routeId, this.delay, Key? key}) : super(key: key);
  final String? routeId;
  final int? delay;
  final List<RouteTransport> futureRoutes = [];
  final List<WatchedEntity> ongoing = [];

  String getType(JourneyNotifier notifier, String id) {
    return notifier.allLocations!
        .firstWhere((element) => element.id == id)
        .type;
  }

  Future<bool> init(JourneyNotifier notifier) async {
    if (notifier.allLocations == null) {
      await JourneyNotifier.init();
    }
    final _prefs = SharedPreferencesWrapper();
    final watched = await _prefs.getAll();
    for (var route in watched) {
      var entityId = await _prefs.get(route);
      WatchedEntity? entity = await api.getEntity(entityId);
      if (entity == null) {
        continue;
      }
      if (entity.departureTime.isBefore(DateTime.now())) {
        ongoing.add(entity);
        continue;
      }
      try {
        Connection connection = await api.getConnection(
            ['REGULAR'],
            route,
            entity.toStationId,
            entity.fromStationId,
            notifier.language,
            notifier.currency);
        futureRoutes.add(RouteTransport.fromConnection(connection));
      } catch (x) {
        try {
          final List<RouteTransport> routes = await api.getRoutes(
              entity.tariffs,
              getType(notifier, entity.toStationId),
              entity.toStationId,
              getType(notifier, entity.fromStationId),
              entity.fromStationId,
              prettyDate(entity.departureTime),
              notifier.language,
              notifier.currency);
          bool added = false;
          for (var route in routes) {
            if (route.id == entity.routeId) {
              futureRoutes.add(route);
              added = true;
              break;
            }
          }
          if (!added) {
            ongoing.add(entity);
          }
        } catch (y) {
          ongoing.add(entity);
        }
      }
      //   try {
      //     connection = await api.getConnection(
      //         entity.tariffs,
      //         route,
      //         entity.toStationId,
      //         entity.fromStationId,
      //         notifier.language,
      //         notifier.currency);
      //     // Connection tmp = await api.getConnection(entity.tariffs, route, entity.toStationId, entity.fromStationId);
      //     futureRoutes.add(RouteTransport.fromConnection(connection));
      //   } catch (e) {
      //     try {
      // connection = await api.getConnection(
      //     ['REGULAR'],
      //     route,
      //     entity.toStationId,
      //     entity.fromStationId,
      //     notifier.language,
      //     notifier.currency);
      // futureRoutes.add(RouteTransport.fromConnection(connection));
    }
    //     } catch (x) {
    //       try {
    //         final List<RouteTransport> routes = await api.getRoutes(
    //             entity.tariffs,
    //             getType(notifier, entity.toStationId),
    //             entity.toStationId,
    //             getType(notifier, entity.fromStationId),
    //             entity.fromStationId,
    //             prettyDate(entity.departureTime),
    //             notifier.language,
    //             notifier.currency);
    //         bool added = false;
    //         for (var route in routes) {
    //           if (route.id == entity.routeId) {
    //             futureRoutes.add(route);
    //             added = true;
    //             break;
    //           }
    //         }
    //         if (!added) {
    //           ongoing.add(entity);
    //         }
    //       } catch (y) {
    //         ongoing.add(entity);
    //       }
    //     }
    //   }
    // }
    futureRoutes.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    ongoing.sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return futureRoutes.isNotEmpty || ongoing.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final notifierJourney =
        Provider.of<JourneyNotifier>(context, listen: false);
    final adState = Provider.of<AdState>(context);
    final BannerAd banner = BannerAd(
      adUnitId: adState.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
    return Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => OverrideLocalization(
            locale: notifier.locale,
            child: FutureBuilder(
                future: init(notifierJourney),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    if (!snapshot.data!) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PlaceName(AppLocalizations.of(context).noWatched),
                          if (AdState.SHOULD_SHOW_ADS)
                            AdOrSpaceWidget(banner: banner),
                        ],
                      );
                    }
                    return Column(children: [
                      if (ongoing.isNotEmpty)
                        Ongoing(
                            routes: ongoing, routeId: routeId, delay: delay),
                      if (futureRoutes.isNotEmpty)
                        Expanded(
                            child: FutureRoutes(
                                routes: futureRoutes, routeId: routeId)),
                      if (AdState.SHOULD_SHOW_ADS)
                        AdOrSpaceWidget(banner: banner),
                    ]);
                  } else {
                    return BuilderNoData(snapshot);
                  }
                })));
  }

  // @override
  // Widget build(BuildContext context) {
  //   final notifier = Provider.of<JourneyNotifier>(context, listen: false);
  //   return WillPopScope(
  //       onWillPop: () async {
  //         notifier.refresh(shouldDelete: true);
  //         return true;
  //       },
  //       child: Scaffold(
  //           backgroundColor: berlinBrightYellow,
  //           appBar: AppBar(
  //             title: Text(AppLocalizations.of(context).title),
  //             actions: [
  //               Builder(
  //                 builder: (context) => IconButton(
  //                   icon: Icon(Icons.settings),
  //                   onPressed: () => showPreferences(context),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           body: FutureBuilder(
  //               future: init(),
  //               builder: (context, AsyncSnapshot<bool> snapshot) {
  //                 if (snapshot.hasData) {
  //                   if (!snapshot.data!) {
  //                     return Center(
  //                       child: PlaceName('Ziadne sledovane spoje'),
  //                     ); //TODO add translation
  //                   }
  //                   return Column(children: [
  //                     Ongoing(routes: ongoing),
  //                     Expanded(child: FutureRoutes(routes: futureRoutes))
  //                   ]);
  //                 } else {
  //                   return BuilderNoData(snapshot);
  //                 }
  //               })));
  // }
}

class FutureRoutes extends StatefulWidget {
  const FutureRoutes({required this.routes, this.routeId, Key? key})
      : super(key: key);
  final String? routeId;
  final List<RouteTransport> routes;
  @override
  State<FutureRoutes> createState() => _FutureRoutesState();
}

class _FutureRoutesState extends State<FutureRoutes> {
  void remove(String routeId) {
    setState(() {
      widget.routes.removeWhere((element) => element.id == routeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        PlaceName(AppLocalizations.of(context).routesAvailable),
        ExpansionPanelList(
          // expandedHeaderPadding: EdgeInsets.all(0),
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              widget.routes[index].isExpanded = !isExpanded;
            });
          },
          children: widget.routes.map<ExpansionPanel>((RouteTransport route) {
            return ExpansionPanel(
              //todo add opened when opened from notification
              backgroundColor: brightRegioYellow,
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return RouteHeader(route, remove: remove);
              },
              body: RouteConnectionDetails(route),
              isExpanded: widget.routeId == null || widget.routeId != route.id
                  ? route.isExpanded
                  : true,
            );
          }).toList(),
        ),
      ],
    ));
  }
}

class Ongoing extends StatefulWidget {
  const Ongoing({required this.routes, this.routeId, this.delay, Key? key})
      : super(key: key);
  final List<WatchedEntity> routes;
  final String? routeId;
  final int? delay;

  @override
  State<Ongoing> createState() => _OngoingState();
}

class _OngoingState extends State<Ongoing> {
  void remove(String entityId) {
    setState(() {
      widget.routes.removeWhere((element) => element.id == entityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        PlaceName(AppLocalizations.of(context).routesFull),
        ExpansionPanelList(
          // expandedHeaderPadding: EdgeInsets.all(0),
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              widget.routes[index].isExpanded = !isExpanded;
            });
          },
          children: widget.routes.map<ExpansionPanel>((WatchedEntity route) {
            return ExpansionPanel(
              backgroundColor: brightRegioYellow,
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return RouteOngoingHeader(route);
              },
              body: RouteOngoingDetails(route, remove,
                  delay: widget.routeId == null ||
                          widget.routeId != route.routeId ||
                          widget.delay == null
                      ? 0
                      : widget.delay!),
              isExpanded:
                  widget.routeId == null || widget.routeId != route.routeId
                      ? route.isExpanded
                      : true,
            );
          }).toList(),
        ),
      ],
    ));
  }
}
// class _OngoingState extends State<Ongoing> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         PlaceName(AppLocalizations.of(context).routesFull),
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.2,
//           child: ListView(
//             children: widget.routes
//                 .map((route) => OngoingTile(route: route))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class OngoingTile extends StatelessWidget {
//   const OngoingTile({required this.route, Key? key}) : super(key: key);
//   final WatchedEntity route;
//   @override
//   Widget build(BuildContext context) {
//     final notifier = Provider.of<JourneyNotifier>(context, listen: false);
//     final departureName = notifier.allLocations!
//         .firstWhere((element) => element.id == route.fromStationId)
//         .name
//         .replaceAll(' - ', ',');
//     final arrivalName = notifier.allLocations!
//         .firstWhere((element) => element.id == route.toStationId)
//         .name
//         .replaceAll(' - ', ',');
//     return ListTile(
//       // tileColor: berlinDarkYellow,
//       title: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             PlaceName(departureName, size: 0.3),
//             Text(prettyDate(route.arrivalTime.toLocal())),
//             PlaceName(arrivalName, size: 0.3),
//           ]),
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Text(prettyTime(route.arrivalTime.toLocal()) +
//                 '-' +
//                 prettyTime(route.arrivalTime.toLocal())), //todo add departure
//             Text('Delay: ' + ' minutes'),
//             ButtonOngoing(routeId: route.id!),
//           ]),
//           Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [Text('Delay: ' + ' minutes')])
//         ],
//       ),
//     );
//
//     // return RouteInfo(
//     //     departureName: notifier.allLocations!
//     //         .firstWhere((element) => element.id == route.fromStationId)
//     //         .name
//     //         .replaceAll(' - ', ','),
//     //     arrivalName: notifier.allLocations!
//     //         .firstWhere((element) => element.id == route.toStationId)
//     //         .name
//     //         .replaceAll(' - ', ','),
//     //     departureTime: route.arrivalTime, //TODO add departureTime
//     //     arrivalTime: route.arrivalTime);
//   }
// }
