import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/widgets/buttons.dart';

showUnwatchDialogRegio(context, entityId, routeId, remove) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => OverrideLocalization(
            locale: notifier.locale,
            child: UnwatchAlert(
                entityId: entityId, routeId: routeId, remove: remove))),
  );
}

showWatchedDialog(context, routeId, condition, option1, option2, remove,
    {entityId = ""}) {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) => Consumer<PrefsNotifier>(
          builder: (context, notifier, _) => OverrideLocalization(
                locale: notifier.locale,
                child: WatchedAlert(
                    routeId: routeId,
                    remove: remove,
                    widget: condition ? option1 : option2),
              )));
}

showMessage(context, title, message) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => OverrideLocalization(
            locale: notifier.locale,
            child: MessageAlert(title: title, message: message))),
  );
}

showWidgetMessage(context, title, child) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => OverrideLocalization(
            locale: notifier.locale,
            child: CustomMessageAlert(title: title, child: child))),
  );
}

class UnwatchAlert extends StatelessWidget {
  const UnwatchAlert({
    required this.entityId,
    required this.routeId,
    required this.remove,
    Key? key,
  }) : super(key: key);
  final String entityId;
  final String routeId;
  final dynamic remove;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).watchedRouteTitle),
      content: Text(AppLocalizations.of(context).unwatch),
      actions: <Widget>[
        ButtonUnwatch(entityId: entityId, routeId: routeId, remove: remove),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context).cancel),
        ),
      ],
    );
  }
}

class WatchedAlert extends StatelessWidget {
  const WatchedAlert({
    required this.routeId,
    required this.remove,
    required this.widget,
    Key? key,
  }) : super(key: key);
  final String routeId;
  final dynamic remove;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).alreadyWatchdedTitle),
      content: Text(AppLocalizations.of(context).alreadyWatched),
      actions: <Widget>[
        ButtonUnwatch(entityId: "", routeId: routeId, remove: remove),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Consumer<PrefsNotifier>(
                        builder: (context, notifier, _) => OverrideLocalization(
                            locale: notifier.locale, child: widget))));
          },
          child: Text(AppLocalizations.of(context).edit),
        ),
      ],
    );
  }
}

class MessageAlert extends StatelessWidget {
  const MessageAlert({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            notifier.refresh();
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context).ok),
        ),
      ],
    );
  }
}

class CustomMessageAlert extends StatelessWidget {
  const CustomMessageAlert({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return AlertDialog(
      title: Text(title),
      content: child,
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            notifier.refresh();
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context).ok),
        ),
      ],
    );
  }
}
