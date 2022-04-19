import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/ads/AdState.dart';
import 'package:watcher/common/ads/widgets.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/utils.dart';
import 'package:watcher/common/widgets/other.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/routes/routesDetails.dart';
import 'package:watcher/regio/theme.dart';
import 'package:watcher/regio/widgets/other.dart';

class RoutesPanel extends StatelessWidget {
  const RoutesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adState = Provider.of<AdState>(context);
    final BannerAd banner = BannerAd(
      adUnitId: adState.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
    return Consumer<JourneyNotifier>(
      builder: (context, notifier, _) => notifier.isError
          ? ErrorMessage(
              errorMessage:
                  AppLocalizations.of(context).error) //notifier.error)
          : notifier.isLoading
              ? Column(
                  children: [
                    const Expanded(child: LoadingCircle()),
                    if (AdState.SHOULD_SHOW_ADS)
                      AdOrSpaceWidget(banner: banner),
                  ],
                )
              : notifier.routes != null && notifier.routes!.isEmpty
                  ? ContainerWithIconNoRoutes(banner: banner)
                  : notifier.routes != null && notifier.routes!.isNotEmpty
                      ? RoutesList(notifier.routes!)
                      : ContainerWithIcon(banner: banner),
    );
  }
}

class RoutesList extends StatefulWidget {
  const RoutesList(this.routes, {Key? key})
      : super(key: key); //TODO maybe add banner from previous page?
  final List<RouteTransport> routes;
  @override
  _RoutesListState createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  static const adPerRoutes = 3;

  bool isAd(int index) {
    return AdState.SHOULD_SHOW_ADS && index % (adPerRoutes + 1) == adPerRoutes;
  }

  List<ExpansionPanel> getListWithAds() {
    final adState = Provider.of<AdState>(context);
    final routes = widget.routes.map<ExpansionPanel>((RouteTransport route) {
      return ExpansionPanel(
        backgroundColor: brightRegioYellow,
        canTapOnHeader: true,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return RouteHeader(route);
        },
        body: RouteConnectionDetails(route),
        isExpanded: route.isExpanded,
      );
    }).toList();
    if (!AdState.SHOULD_SHOW_ADS) {
      return routes;
    }
    final List<ExpansionPanel> routesWithAds = [];
    for (var i = 0; i < routes.length; i++) {
      if (isAd(routesWithAds.length)) {
        final BannerAd myBanner = BannerAd(
          adUnitId: adState.bannerId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: const BannerAdListener(),
        )..load();
        routesWithAds.add(ExpansionPanel(
          backgroundColor: brightRegioYellow,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
              child: Container(height: 50, child: AdWidget(ad: myBanner)),
            );
          },
          body: Container(),
          isExpanded: false,
        ));
      }
      routesWithAds.add(routes[i]);
    }
    return routesWithAds;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return RefreshIndicator(
        onRefresh: () async {
          notifier.refresh(shouldDelete: true, forceRefresh: true);
        },
        child: SingleChildScrollView(
            child: Column(
          children: [
            if (prettyDate(widget.routes[0].arrivalTime) !=
                prettyDate(notifier.date))
              Center(
                child: PlaceName(AppLocalizations.of(context).noRoutes),
              ),
            ExpansionPanelList(
              // expandedHeaderPadding: EdgeInsets.all(0),
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  if (isAd(index)) {
                    return;
                  }
                  final int routeIndex = index -
                      (AdState.SHOULD_SHOW_ADS
                          ? index ~/ (adPerRoutes + 1)
                          : 0);
                  widget.routes[routeIndex].isExpanded = !isExpanded;
                });
              },
              children: getListWithAds(),
            ),
          ],
        )));
  }
}
