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
import 'package:watcher/regio/widgets/buttons.dart';
import 'package:watcher/regio/widgets/watch.dart';

class SelectConnection extends StatelessWidget {
  const SelectConnection({required this.route});
  final RouteTransport route;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);

    openOptions(String seatClass) async {
      if (seatClass == 'noSeat') {
        notifier.post(route.id, route.departureStation, route.arrivalStation,
            '', route.arrivalTime, route.departureTime, ['delays']);
        await showMessage(
            context,
            AppLocalizations.of(context).watchedRouteTitle,
            AppLocalizations.of(context).watchedRoute);
        Navigator.popUntil(
            context, (Route<dynamic> predicate) => predicate.isFirst);
        return;
      } else if (seatClass == 'watchedNoSeat') {
        await showUnwatchDialogRegio(context, '', route.id, null);
        Navigator.popUntil(
            context, (Route<dynamic> predicate) => predicate.isFirst);
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Consumer<PrefsNotifier>(
                  builder: (context, notifier, _) => OverrideLocalization(
                      locale: notifier.locale,
                      child: Watcher(route: route, seatClass: seatClass)))));
    }

    return WillPopScope(
      onWillPop: () async {
        notifier.refresh(shouldDelete: true);
        return true;
      },
      child: Scaffold(
        backgroundColor: brightRegioYellow,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).title),
          actions: const [
            AppBarBuilder(),
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
  final RouteTransport route;
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
            launch: null,
            routeId: route.id,
            priceClasses: const [],
            seats: seats!,
            callback: callback,
            freeSeats: route.freeSeats),
      )
    ]);
  }
}

class AvailableRouteDetails extends StatelessWidget {
  const AvailableRouteDetails({required this.route, required this.callback});
  final RouteTransport route;
  final dynamic callback;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    launch({String seatClass = ""}) => launchShop(
          route.id,
          route.departureStation,
          route.arrivalStation,
          notifier.tariffs.map((e) => e.key),
          seatClass: seatClass,
        );
    final seats = notifier.seats;
    return FutureBuilder(
        future: notifier.getConnection(route, onlyData: true),
        builder: (context, AsyncSnapshot<Connection?> snapshot) {
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
                      routeId: route.id,
                      priceClasses: snapshot.data!.priceClasses,
                      seats: seats!,
                      callback: callback,
                      freeSeats: route.freeSeats,
                    ),
                  )
                ]);
          } else {
            return BuilderNoData(snapshot);
          }
        });
  }
}

class PriceClasses extends StatelessWidget {
  const PriceClasses(
      {required this.launch,
      required this.routeId,
      required this.priceClasses,
      required this.seats,
      required this.callback,
      required this.freeSeats});
  final dynamic launch;
  final String routeId;
  final List<PriceClass> priceClasses;
  final Map<String, SeatClass> seats;
  final dynamic callback;
  final int freeSeats;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);

    final priceClassesMap = {for (var v in priceClasses) v.id: v};
    final diff = seats.keys.toSet().difference(priceClassesMap.keys.toSet());
    final minPrice = priceClasses.isEmpty
        ? 0.0
        : priceClasses
            .reduce((curr, next) => curr.price < next.price ? curr : next)
            .price;
    final SeatClass noSeat = SeatClass(
        key: "noSeat",
        title: AppLocalizations.of(context).noSeat,
        description: "");
    final SeatClass anySeat = SeatClass(
        key: "", title: AppLocalizations.of(context).anySeat, description: "");
    final PriceClass anyPrice =
        PriceClass(id: "", price: minPrice, freeSeats: freeSeats);

    return RefreshIndicator(
        onRefresh: () async {
          notifier.refresh(shouldDelete: true, forceRefresh: true);
        },
        child: ListView(children: [
          SeatsNotAvailable(
              seat: noSeat,
              callback: callback,
              routeId: routeId,
              freeSeats: -1),
          freeSeats < notifier.tariffs.length
              ? SeatsNotAvailable(
                  seat: anySeat,
                  callback: callback,
                  routeId: routeId,
                  freeSeats: freeSeats)
              : SeatsAvailable(launch, anyPrice, anySeat, callback),
          ...priceClassesMap.keys.map<StatelessWidget>((key) => SeatsAvailable(
              launch, priceClassesMap[key]!, seats[key]!, callback)),
          ...diff.map((e) => SeatsNotAvailable(
              seat: seats[e]!, callback: callback, routeId: routeId)),
        ]));
  }
}

class SeatsAvailable extends StatelessWidget {
  const SeatsAvailable(this.launch, this.priceClass, this.seat, this.callback,
      {Key? key})
      : super(key: key);
  final PriceClass priceClass;
  final SeatClass seat;
  final dynamic launch;
  final dynamic callback;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
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
              PlaceName(seat.title, size: 0.5, center: false),
              Column(
                children: [
                  PlaceName(
                      priceClass.freeSeats.toString() +
                          AppLocalizations.of(context).seats,
                      highlight: false,
                      size: 0.3),
                  notifier.tariffs.length <= priceClass.freeSeats
                      ? ElevatedButton(
                          onPressed: () {
                            launch(seatClass: seat.key);
                          },
                          child: Consumer<PrefsNotifier>(
                              builder: (context, notifier, _) => Text(
                                  (priceClass.id == ''
                                          ? AppLocalizations.of(context).from
                                          : '') +
                                      priceClass.price.toString() +
                                      notifier.currency.code)))
                      : ElevatedButton(
                          onPressed: () {
                            callback(seat.key);
                          },
                          child: const TextIsWatched(false)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SeatsNotAvailable extends StatelessWidget {
  const SeatsNotAvailable(
      {required this.seat,
      required this.routeId,
      this.callback,
      this.freeSeats = 0,
      Key? key})
      : super(key: key);
  final SeatClass seat;
  final String routeId;
  final dynamic callback;
  final int freeSeats;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return FutureBuilder(
        future: notifier.isSeatOrTypeWatched(
            routeId, seat.key == "noSeat" ? "delays" : "tickets", seat.key),
        builder: (context, AsyncSnapshot<bool?> snapshot) {
          bool isWatched = false;
          if (snapshot.hasData) {
            isWatched = snapshot.data!;
          }
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
                    PlaceName(seat.title, size: 0.5, center: false),
                    Column(
                      children: [
                        freeSeats != -1
                            ? PlaceName(
                                freeSeats.toString() +
                                    AppLocalizations.of(context).seats,
                                highlight: false,
                                size: 0.3)
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                ),
                              ),
                        ElevatedButton(
                            onPressed: () {
                              callback(seat.key == 'noSeat' && isWatched
                                  ? "watchedNoSeat"
                                  : seat.key);
                            },
                            child: TextIsWatched(isWatched)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
