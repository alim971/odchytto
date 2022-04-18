import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Consumer<JourneyNotifier>(
      builder: (context, notifier, _) => notifier.isError
          ? ErrorMessage(
              errorMessage:
                  AppLocalizations.of(context).error) //notifier.error)
          : notifier.isLoading
              ? const LoadingCircle()
              : notifier.routes != null && notifier.routes!.isEmpty
                  ? const ContainerWithIconNoRoutes()
                  : notifier.routes != null && notifier.routes!.isNotEmpty
                      ? RoutesList(notifier.routes!)
                      : const ContainerWithIcon(),
    );
  }
}

class RoutesList extends StatefulWidget {
  const RoutesList(this.routes, {Key? key}) : super(key: key);
  final List<RouteTransport> routes;
  @override
  _RoutesListState createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
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
                  widget.routes[index].isExpanded = !isExpanded;
                });
              },
              children:
                  widget.routes.map<ExpansionPanel>((RouteTransport route) {
                return ExpansionPanel(
                  backgroundColor: brightRegioYellow,
                  canTapOnHeader: true,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return RouteHeader(route);
                  },
                  body: RouteConnectionDetails(route),
                  isExpanded: route.isExpanded,
                );
              }).toList(),
            ),
          ],
        )));
  }
}
