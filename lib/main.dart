// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/shared.dart';
import 'package:watcher/common/widgets/builder.dart';
import 'package:watcher/common/widgets/future.dart';
import 'package:watcher/common/widgets/prefs.dart';
import 'package:watcher/common/widgets/splash.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/data/api.dart' as api;
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/regioMain.dart';
import 'package:watcher/regio/theme.dart';

import 'common/utils/dialog.dart';
import 'common/utils/utils.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  // print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //   print('User granted permission');
  // } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  //   print('User granted provisional permission');
  // } else {
  //   print('User declined or has not accepted permission');
  // }
  runApp(const CatchItApp());
}

class CatchItApp extends StatefulWidget {
  const CatchItApp({Key? key}) : super(key: key);

  @override
  State<CatchItApp> createState() => _CatchItAppState();
}

class _CatchItAppState extends State<CatchItApp> {
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    if (message.data.containsKey('url')) {
      launchUrlApp(message.data['url']);
      var entityId =
          await SharedPreferencesWrapper().get(message.data['routeId']);
      WatchedEntity? entity = await api.getEntity(entityId);
      if (entity == null) {
        return;
      }
      entity.type = entity.type.replaceFirst('tickets', '');
      await api.postEntity(entity);

      // SharedPreferencesWrapper().delete(message.data['routeId']);
    } else {
      showRegioWatched(navigatorKey.currentState!.context,
          routeId: message.data['routeId'],
          delay: int.parse(message.data['delay']));
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // print('Got a message whilst in the foreground!');
      // print('Message data: ${message.data}');
      if (message.notification != null) {
        // print(
        //     'Message also contained a notification: ${message.notification}'); //TODO add alert
        await showMessage(navigatorKey.currentState!.context,
            message.notification!.title, message.notification!.body);
      }
      _handleMessage(message);
    });
    setupInteractedMessage();
    // highlight-end
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PrefsNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => JourneyNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppStateNotifier(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).title,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('cs'),
          Locale('sk'),
          Locale('en'),
        ],
        theme: appTheme,
        home: Consumer<PrefsNotifier>(
          builder: (context, notifier, _) => FutureBuilder(
              future: notifier.init(),
              builder: (context, AsyncSnapshot<bool?> snapshot) {
                if (snapshot.hasData) {
                  return OverrideLocalization(
                    locale: notifier.locale,
                    child: Consumer<AppStateNotifier>(
                      builder: (context, notifier, _) => notifier.showSplash
                          ? const SplashScreen()
                          : const HomePage(),
                    ),
                  );
                } else {
                  return BuilderNoData(snapshot);
                }
              }),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brightRegioYellow,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).title),
        actions: const [
          AppBarBuilder(),
        ],
      ),
      body: const RegioMain(),
    );
  }
}
