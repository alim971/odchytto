// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/dialog.dart';
import 'package:watcher/common/widgets/animations.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brightRegioYellow,
      body: Column(
        children: [
          const Flexible(
            flex: 8,
            child: TransportAnimation(
              type: TransportAnimationType.bus, // TODO random
              fit: BoxFit.contain,
            ),
          ),
          Flexible(
            flex: 2,
            child: Consumer<AppStateNotifier>(
              builder: (context, notifier, _) => RaisedButton(
                color: darkRegioYellow,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: Text(
                  AppLocalizations.of(context).tapContinue,
                  style: const TextStyle(color: Colors.black54),
                ),
                onPressed: () async {
                  if (await (Connectivity().checkConnectivity()) ==
                      ConnectivityResult.none) {
                    showMessage(
                        context,
                        AppLocalizations.of(context).noInternetTitle,
                        AppLocalizations.of(context).noInternet);
                  } else {
                    notifier.hideSplash();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
