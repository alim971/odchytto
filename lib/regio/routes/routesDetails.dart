import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/utils.dart';
import 'package:watcher/common/widgets/future.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/routes/connections.dart';
import 'package:watcher/regio/theme.dart';
import 'package:watcher/regio/widgets/buttons.dart';

class RouteHeader extends StatelessWidget {
  const RouteHeader(this.route, {this.remove, Key? key}) : super(key: key);
  final RouteTransport route;
  final dynamic remove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // tileColor: berlinDarkYellow,
      title: DefaultTextStyle(
        style: TextStyle(color: route.freeSeats == 0 ? grey : Colors.black),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RouteTimeDetails(route, remove),
            RouteDetail(route),
          ],
        ),
      ),
    );
  }
}

class RouteFutureHeader extends StatelessWidget {
  const RouteFutureHeader(this.route, {this.remove, Key? key})
      : super(key: key);
  final RouteTransport route;
  final dynamic remove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // tileColor: berlinDarkYellow,
      title: DefaultTextStyle(
        style: TextStyle(color: route.freeSeats == 0 ? grey : Colors.black),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RouteTimeDetails(route, remove),
            RouteDetail(route),
          ],
        ),
      ),
    );
  }
}

class RouteOngoingHeader extends StatelessWidget {
  const RouteOngoingHeader(this.route, {Key? key}) : super(key: key);
  final WatchedEntity route;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    final departureName = notifier.allLocations!
        .firstWhere((element) => element.id == route.fromStationId)
        .name
        .replaceAll(' - ', ',');
    final arrivalName = notifier.allLocations!
        .firstWhere((element) => element.id == route.toStationId)
        .name
        .replaceAll(' - ', ',');
    return ListTile(
      // tileColor: berlinDarkYellow,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        PlaceName(departureName, size: 0.23),
        Text(prettyTime(route.departureTime)),
        const Text("-"),
        Text(prettyTime(route.arrivalTime)),
        PlaceName(arrivalName, size: 0.23),
      ]),
    );
  }
}

class RouteOngoingDetails extends StatelessWidget {
  const RouteOngoingDetails(this.route, this.remove, {this.delay = 0, Key? key})
      : super(key: key);
  final WatchedEntity route;
  final dynamic remove;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        PlaceName(prettyDate(route.departureTime), size: 0.25),
        if (delay > 0)
          PlaceName(
              AppLocalizations.of(context).delay +
                  ": $delay" +
                  (delay > 4
                      ? AppLocalizations.of(context).minutes
                      : AppLocalizations.of(context).minutesLess),
              size: 0.3,
              color: Colors.red),
        ButtonOngoing(
            entityId: route.id!, routeId: route.routeId, remove: remove),
      ]),
    );
  }
}

class RouteTimeDetails extends StatelessWidget {
  const RouteTimeDetails(this.route, this.remove, {Key? key}) : super(key: key);
  final RouteTransport route;
  final dynamic remove;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(prettyTime(route.departureTime) +
            ' - ' +
            prettyTime(route.arrivalTime)),
        Text(prettyDate(route.departureTime)),
        FutureBuilder(
            future: notifier.isWatched(route.id),
            builder: (context, AsyncSnapshot<bool?> snapshot) {
              if (snapshot.hasData) {
                return route.freeSeats != 0 &&
                        route.freeSeats >= notifier.tariffs.length
                    ? ButtonWithPrice(route, snapshot.data!, remove)
                    : ButtonWhenSoldOut(route, snapshot.data!, remove);
              } else {
                return BuilderNoData(snapshot);
              }
            }),
      ],
    );
  }
}

class RouteDetail extends StatelessWidget {
  const RouteDetail(this.route, {Key? key}) : super(key: key);

  final RouteTransport route;

  Color getColor(int seats, tickets) {
    if (seats == 0 || seats < tickets) return Colors.redAccent;
    if (seats < 10 || seats == tickets) return Colors.deepOrangeAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);

    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Text(route.travelTime),
        // SizedBox(width: 5),
        ...getIcons(route),
        Text(route.transfers == 0
            ? AppLocalizations.of(context).direct
            : (route.transfers.toString() +
                (route.transfers == 1
                    ? AppLocalizations.of(context).transfer
                    : AppLocalizations.of(context).transfers))),
        SizedBox(width: route.types.length == 1 ? 10 : 18),
        if (route.delay.isNotEmpty) ...[
          Text(AppLocalizations.of(context).delay + ": " + route.delay,
              style: const TextStyle(color: Colors.red)),
          const SizedBox(width: 5)
        ],
        const Icon(Icons.person),
        Text(
            route.freeSeats == 0
                ? AppLocalizations.of(context).sold
                : route.freeSeats.toString() +
                    AppLocalizations.of(context).seats,
            style: TextStyle(
                color: getColor(route.freeSeats, notifier.tariffs.length)))
      ],
    );
  }
}

class RouteConnectionDetails extends StatelessWidget {
  const RouteConnectionDetails(this.route, {Key? key}) : super(key: key);
  final RouteTransport route;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);

    if (route.freeSeats == 0) {
      return ListTile(
          title: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(prettyTime(route.departureTime)),
                  const SizedBox(width: 10),
                  if (route.typesAsStrings.contains('train'))
                    const Icon(Icons.train),
                  if (route.typesAsStrings.contains('bus'))
                    const Icon(Icons.directions_bus),
                  const SizedBox(width: 10),
                  Text(notifier.allLocations!
                      .firstWhere(
                          (element) => element.id == route.departureStation)
                      .name
                      .replaceAll(' - ', ','))
                ]),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(prettyTime(route.arrivalTime)),
                  const SizedBox(width: 10),
                  const Icon(Icons.place),
                  const SizedBox(width: 10),
                  Text(notifier.allLocations!
                      .firstWhere(
                          (element) => element.id == route.arrivalStation)
                      .name
                      .replaceAll(' - ', ','))
                ]),
              ]),
          // subtitle: const Text(
          //     'To delete this panel, tap the trash can icon'),
          // trailing: const Icon(Icons.shopping_cart),
          onTap: () {
            // setState(() {
            // });
          });
    }

    return FutureBuilder(
        future: notifier.getConnection(route),
        builder: (context, AsyncSnapshot<Connection?> snapshot) {
          if (snapshot.hasData) {
            int length = snapshot.data!.sections.length;
            return ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < length; i++)
                      route.transfers > i
                          ? ConnectionWidget(
                              //todo check null value used
                              snapshot.data!.sections[i],
                              snapshot.data!.transfersInfo!.transfers[i])
                          : SectionWidget(snapshot.data!.sections[i], true),
                  ],
                ),
                // subtitle: const Text(
                //     'To delete this panel, tap the trash can icon'),
                // trailing: const Icon(Icons.shopping_cart),
                onTap: () {
                  // setState(() {
                  // });
                });
          } else {
            return BuilderNoData(snapshot);
          }
        });
  }
}

class RouteInfo extends StatelessWidget {
  const RouteInfo(
      {Key? key,
      required this.departureName,
      required this.arrivalName,
      required this.departureTime,
      required this.arrivalTime})
      : super(key: key);

  final String departureName;
  final String arrivalName;
  final DateTime departureTime;
  final DateTime arrivalTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            PlaceName(departureName, size: 0.3),
            PlaceName(arrivalName, size: 0.3),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            PlaceName(prettyDateTime(departureTime),
                highlight: false, size: 0.3),
            PlaceName(prettyDateTime(arrivalTime), highlight: false, size: 0.3),
          ]),
        ),
      ],
    );
  }
}
