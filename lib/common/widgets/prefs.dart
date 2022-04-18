// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Preferences widget
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/dialog.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/theme.dart';
import 'package:watcher/regio/widgets/watched.dart';

void showPreferences(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: brightRegioYellow,
    builder: (context) => const Preferences(),
  );
}

void showRegioWatched(BuildContext context, {String? routeId, int? delay}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: brightRegioYellow,
    builder: (context) => routeId == null
        ? WatchedRoutes()
        : WatchedRoutes(routeId: routeId, delay: delay),
  );
  // Navigator.push(
  //     context, MaterialPageRoute(builder: (context) => WatchedRoutes()));
}

class Preferences extends StatelessWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefsNotifier>(
      builder: (context, notifier, _) => OverrideLocalization(
        locale: notifier.locale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(25),
              child: Builder(
                builder: (context) => Text(
                  AppLocalizations.of(context).preferences,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const LocalePref(),
            const CurrencyPref(),
            const VersionPref(),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Text(
            //       notifier.version,
            //       style: const TextStyle(color: grey, fontSize: 11.5),
            //     )
            //   ],
            // ),
            // SplashPref(),
          ],
        ),
      ),
    );
  }
}

class LocalePref extends StatelessWidget {
  const LocalePref({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifierJourney =
        Provider.of<JourneyNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => Row(
          children: [
            Expanded(child: Text(AppLocalizations.of(context).language)),
            Radio(
              value: 0,
              groupValue: notifier.localeSelector,
              onChanged: (val) =>
                  notifier.setLocaleSelector(0, notifierJourney),
            ),
            Text(AppLocalizations.of(context).czech),
            Radio(
              value: 1,
              groupValue: notifier.localeSelector,
              onChanged: (val) =>
                  notifier.setLocaleSelector(1, notifierJourney),
            ),
            Text(AppLocalizations.of(context).slovak),
            Radio(
              value: 2,
              groupValue: notifier.localeSelector,
              onChanged: (val) =>
                  notifier.setLocaleSelector(2, notifierJourney),
            ),
            Text(AppLocalizations.of(context).english),
          ],
        ),
      ),
    );
  }
}

class CurrencyPref extends StatelessWidget {
  const CurrencyPref({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifierJourney =
        Provider.of<JourneyNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => Row(
          children: [
            Expanded(child: Text(AppLocalizations.of(context).currency)),
            Radio(
              value: 0,
              groupValue: notifier.currencySelector,
              onChanged: (val) => notifier.setCurrency(0, notifierJourney),
            ),
            Text(AppLocalizations.of(context).czk),
            Radio(
              value: 1,
              groupValue: notifier.currencySelector,
              onChanged: (val) => notifier.setCurrency(1, notifierJourney),
            ),
            Text(AppLocalizations.of(context).eur),
          ],
        ),
      ),
    );
  }
}

class VersionPref extends StatelessWidget {
  const VersionPref({Key? key}) : super(key: key);

  Widget getMessage(context, PrefsNotifier notifier) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(
        children: [
          Expanded(child: Text(AppLocalizations.of(context).appName)),
          Text(notifier.appName),
        ],
      ),
      Row(
        children: [
          Expanded(child: Text(AppLocalizations.of(context).package)),
          Text(notifier.packageName),
        ],
      ),
      Row(
        children: [
          Expanded(child: Text(AppLocalizations.of(context).version)),
          Text(notifier.version),
        ],
      ),
      Row(
        children: [
          Expanded(child: Text(AppLocalizations.of(context).buildNumber)),
          Text(notifier.buildNumber),
        ],
      ),
      Row(
        children: [
          Expanded(child: Text(AppLocalizations.of(context).fullVersion)),
          Text(notifier.version + '+' + notifier.buildNumber),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => Row(
          children: [
            Expanded(child: Text(AppLocalizations.of(context).version)),
            TextButton(
                onPressed: () async {
                  await showWidgetMessage(
                      context,
                      AppLocalizations.of(context).details,
                      getMessage(context, notifier));
                },
                child: Text(notifier.version)),
          ],
        ),
      ),
    );
  }
}

class SplashPref extends StatelessWidget {
  const SplashPref({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Consumer<AppStateNotifier>(
            builder: (context, notifier, _) => IconButton(
              icon: const Icon(Icons.restore, size: 15, color: Colors.grey),
              onPressed: () => notifier.resetSplash(),
            ),
          )
        ],
      ),
    );
  }
}
