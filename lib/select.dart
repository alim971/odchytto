import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/data/data.dart' as data;
import 'package:watcher/data/localization.dart';
import 'package:watcher/theme.dart';
import 'package:watcher/utils.dart';
import 'package:watcher/watch.dart';
import 'package:watcher/widgets/prefs.dart';

import 'data/data.dart';
import 'data/models.dart';

class SelectConnection extends StatelessWidget {
  const SelectConnection({required this.route});
  final data.Route route;

  @override
  Widget build(BuildContext context) {
    openOptions(String seatClass) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Watcher(route: route, seatClass: seatClass)));
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
        body: route.freeSeats == 0
            ? NotAvailableRouteDetails(route: route, callback: openOptions)
            : AvailableRouteDetails(route: route, callback: openOptions),
      ),
    );
  }
}

class NotAvailableRouteDetails extends StatelessWidget {
  const NotAvailableRouteDetails({required this.route, required this.callback});
  final data.Route route;
  final dynamic callback;
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    final seats = notifier.seats;
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      RouteInfo(
          departureName: notifier.allLocations!
              .firstWhere((element) => element.id == route.departureStation)
              .name
              .replaceAll(' - ', ','),
          arrivalName: notifier.allLocations!
              .firstWhere((element) => element.id == route.arrivalStation)
              .name
              .replaceAll(' - ', ','),
          departureTime: route.departureTime,
          arrivalTime: route.arrivalTime),
      Expanded(
        child: PriceClasses(
            launch: null, priceClasses: [], seats: seats!, callback: callback),
      )
    ]);
  }
}

class AvailableRouteDetails extends StatelessWidget {
  const AvailableRouteDetails({required this.route, required this.callback});
  final data.Route route;
  final dynamic callback;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    launch(String seatClass) => launchURLApp(
          route.id,
          route.departureStation,
          route.arrivalStation,
          notifier.tariffs.map((e) => e.key),
          seatClass,
        );
    final seats = notifier.seats;
    return FutureBuilder(
        future: notifier.getConnection(route),
        builder: (context, AsyncSnapshot<data.Connection?> snapshot) {
          if (snapshot.hasData) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RouteInfo(
                      departureName: snapshot.data!.departureName,
                      arrivalName: snapshot.data!.arrivalName,
                      departureTime: route.departureTime,
                      arrivalTime: route.arrivalTime),
                  Expanded(
                    child: PriceClasses(
                      launch: launch,
                      priceClasses: snapshot.data!.priceClasses,
                      seats: seats!,
                      callback: callback,
                    ),
                  )
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

class PriceClasses extends StatelessWidget {
  const PriceClasses(
      {required this.launch,
      required this.priceClasses,
      required this.seats,
      required this.callback});
  final dynamic launch;
  final List<data.PriceClass> priceClasses;
  final Map<String, SeatClass> seats;
  final dynamic callback;

  @override
  Widget build(BuildContext context) {
    final priceClassesMap = {for (var v in priceClasses) v.id: v};
    final diff = seats.keys.toSet().difference(priceClassesMap.keys.toSet());

    return ListView(children: [
      ...priceClassesMap.keys.map<StatelessWidget>((key) => JourneyAvailable(
          launch, priceClassesMap[key]!, seats[key]!, callback)),
      ...diff.map((e) => JourneyNotAvailable(seats[e]!, callback)),
    ]);
  }
}

class JourneyAvailable extends StatelessWidget {
  const JourneyAvailable(this.launch, this.priceClass, this.seat, this.callback,
      {Key? key})
      : super(key: key);
  final data.PriceClass priceClass;
  final data.SeatClass seat;
  final dynamic launch;
  final dynamic callback;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
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
              PlaceName(seat.title, size: 0.5),
              Column(
                children: [
                  PlaceName(priceClass.freeSeats.toString() + " volnych mist",
                      highlight: false, size: 0.3),
                  notifier.tariffs.length <= priceClass.freeSeats
                      ? ElevatedButton(
                          onPressed: () {
                            launch(seat.key);
                          },
                          child: Text(priceClass.price.toString() +
                              " KC")) //TODO add currency
                      : ElevatedButton(
                          onPressed: () {
                            callback(seat.key);
                          },
                          child: Text("Sledovat")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class JourneyNotAvailable extends StatelessWidget {
  const JourneyNotAvailable(this.seat, this.callback, {Key? key})
      : super(key: key);
  final data.SeatClass seat;
  final dynamic callback;

  @override
  Widget build(BuildContext context) {
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
              PlaceName(seat.title, size: 0.5),
              Column(
                children: [
                  PlaceName("0 volnych mist", highlight: false, size: 0.3),
                  ElevatedButton(
                      onPressed: () {
                        callback(seat.key);
                      },
                      child: Text("Sledovat")),
                ],
              ) //TODO add translation
            ],
          ),
        ),
      ),
    );
  }
}
