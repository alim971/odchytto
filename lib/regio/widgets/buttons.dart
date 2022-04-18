import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/dialog.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/utils/utils.dart';
import 'package:watcher/regio/widgets/select.dart';
import 'package:watcher/regio/widgets/watch.dart';

class ButtonWatchDelay extends StatelessWidget {
  const ButtonWatchDelay(
      {required this.route, required this.isWatched, Key? key})
      : super(key: key);
  final RouteTransport route;
  final bool isWatched;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return ElevatedButton(
      onPressed: () async {
        notifier.post(route.id, route.departureStation, route.arrivalStation,
            '', route.arrivalTime, route.departureTime, ['delays']);
        await showMessage(
            context,
            AppLocalizations.of(context).watchedRouteTitle,
            AppLocalizations.of(context).watchedRoute);
        Navigator.popUntil(
            context, (Route<dynamic> predicate) => predicate.isFirst);
      },
      child: TextIsWatched(isWatched),
    );
  }
}

class SwapButton extends StatelessWidget {
  const SwapButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: IconButton(
        icon: const Icon(Icons.swap_vert_outlined),
        tooltip: AppLocalizations.of(context).swap,
        onPressed: () {
          notifier.swap();
        },
      ),
    );
  }
}

class RefreshButton extends StatelessWidget {
  const RefreshButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return ElevatedButton.icon(
      onPressed: () {
        notifier.refresh(shouldDelete: true, forceRefresh: true);
      },
      icon: const Icon(Icons.refresh),
      label: Text(AppLocalizations.of(context).refresh),
    );
  }
}

class ButtonUnwatch extends StatelessWidget {
  const ButtonUnwatch(
      {required this.entityId, required this.routeId, this.remove, Key? key})
      : super(key: key);
  final String entityId;
  final String routeId;
  //whether any action shoud be taken when we unwatch route
  final dynamic remove;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);

    return TextButton(
      onPressed: () async {
        if (entityId != ''
            ? await notifier.deleteWatchedEntity(entityId, routeId)
            : await notifier.deleteWatched(routeId)) {
          if (remove != null) {
            remove(routeId);
          }
          Navigator.pop(context);
          notifier.refresh();
          await showMessage(
              context,
              AppLocalizations.of(context).deletionSuccess,
              AppLocalizations.of(context).noLonger);
        } else {
          await showMessage(
              context,
              AppLocalizations.of(context).deletionFailTitle,
              AppLocalizations.of(context).deletionFail);
        }
        // notifier.refresh();
      },
      child: Text(AppLocalizations.of(context).unwatchButton),
    );
  }
}

class ButtonOngoing extends StatelessWidget {
  const ButtonOngoing(
      {required this.entityId, required this.routeId, this.remove, Key? key})
      : super(key: key);
  final String entityId;
  final String routeId;
  final dynamic remove;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () =>
            showUnwatchDialogRegio(context, entityId, routeId, remove),
        child: const TextIsWatched(true));
  }
}

class ButtonWhenSoldOut extends StatelessWidget {
  const ButtonWhenSoldOut(this.route, this.isWatched, this.remove, {Key? key})
      : super(key: key);
  final RouteTransport route;
  final bool isWatched;
  final dynamic remove;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          if (isWatched) {
            showWatchedDialog(
                context,
                route.id,
                (route.typesAsStrings.contains('bus') &&
                    route.types.length == 1),
                Watcher(route: route, seatClass: "NO"),
                SelectConnection(route: route),
                remove);
          } else {
            if (route.typesAsStrings.contains('bus') &&
                route.types.length == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Consumer<PrefsNotifier>(
                          builder: (context, notifier, _) =>
                              OverrideLocalization(
                                  locale: notifier.locale,
                                  child: Watcher(
                                      route: route, seatClass: "NO")))));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Consumer<PrefsNotifier>(
                          builder: (context, notifier, _) =>
                              OverrideLocalization(
                                  locale: notifier.locale,
                                  child: SelectConnection(route: route)))));
            }
          }
        },
        child: TextIsWatched(isWatched));
  }
}

class TextIsWatched extends StatelessWidget {
  const TextIsWatched(this.isWatched, {Key? key}) : super(key: key);
  final bool isWatched;

  @override
  Widget build(BuildContext context) {
    return Text(isWatched
        ? AppLocalizations.of(context).watched
        : AppLocalizations.of(context).watch);
  }
}

class ButtonWithPrice extends StatelessWidget {
  const ButtonWithPrice(this.route, this.isWatched, this.remove, {Key? key})
      : super(key: key);
  final RouteTransport route;
  final bool isWatched;
  final dynamic remove;

  @override
  Widget build(BuildContext context) {
    final notifierJourney =
        Provider.of<JourneyNotifier>(context, listen: false);
    return Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => ElevatedButton(
              onPressed: () {
                if (isWatched) {
                  showWatchedDialog(
                    context,
                    route.id,
                    (!(route.typesAsStrings.contains('bus') &&
                        route.types.length == 1)),
                    SelectConnection(route: route),
                    null,
                    remove,
                  );
                } else {
                  if (route.typesAsStrings.contains('bus') &&
                      route.types.length == 1) {
                    launchShop(
                      route.id,
                      route.departureStation,
                      route.arrivalStation,
                      notifierJourney.tariffs.map((e) => e.key),
                      seatClass: "NO",
                    );
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Consumer<PrefsNotifier>(
                                builder: (context, notifier, _) =>
                                    OverrideLocalization(
                                        locale: notifier.locale,
                                        child:
                                            SelectConnection(route: route)))));
                  }
                }
              },
              child: isWatched
                  ? TextIsWatched(isWatched)
                  : Text((route.minPrice == route.maxPrice
                      ? route.maxPrice.toString() + notifier.currency.code
                      : AppLocalizations.of(context).from +
                          route.minPrice.toString() +
                          notifier.currency.code)),
            ));
  }
}
