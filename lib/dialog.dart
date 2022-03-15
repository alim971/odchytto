import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/models.dart';

showWatchedDialog(context, routeId, condition, option1, option2) {
  final notifier = Provider.of<JourneyNotifier>(context, listen: false);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Already watched'),
      content: const Text(
          'This route is already watched. Do you want to unwatch it, or edit it?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (await notifier.deleteWatched(routeId)) {
              Navigator.pop(context);
              await showMessage(context, 'Deleted successfully',
                  'This route is no longer watched');
            } else {
              await showMessage(
                  context, 'Deletion failed', 'Deletion of watcher failed.');
            }
            notifier.refresh();
          },
          child: const Text('Unwatch'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => condition ? option1 : option2));
          },
          child: const Text('Edit'),
        ),
      ],
    ),
  );
}

showMessage(context, title, message) {
  final notifier = Provider.of<JourneyNotifier>(context, listen: false);

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            notifier.refresh();
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
