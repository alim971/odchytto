// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)
          as AppLocalizations;

  static const _localizedValues = {
    'cs': {
      'title': 'Chyť to',
      'search': 'Vyhledávání',
      'searching_message': 'vyhledávám ...',
      'origin': 'Odkud',
      'destination': 'Kam',
      'searchHintText': 'Začni psát',
      'offline': 'offline',
      'preferences': 'Nastavení',
      'language': 'Jazyk',
      'english': 'Angličtina',
      'german': 'Německy',
      'czech': 'Čeština',
      'slovak': 'Slovenština',
      'tap_continue': 'Klikni pro pokračování',
      'direct': 'Přímý',
      'seats': ' Volných míst',
      'sold': 'Vyprodáno',
      'from': 'Od ',
      'transfer': ' přestup',
      'transfers': ' přestupy',
      'wait': 'Čekání na přestup ',
      'passenger': ' cestující',
      'passengers': '',
      'multiplePassengers': 'ch',
      'refresh': 'Obnovit',
      'noWatched': 'Nejsou sledována žádná spojení',
      'czk': 'KČ',
      'eur': '€',
      'date': 'Vybrat datum',
      'watch': 'Sledovat',
      'watched': 'Sledováno',
      'routesAvailable': 'Sledována spojení',
      'routesFull': 'Práve probíhajíci spojení',
      'currency': 'Měna',
      'noRoutes':
          'Nenalezen žádný spoj na požadované datum. Zobrazuji nejbližší spoje',
      'tickets': 'Sledujte dostupnost lístků',
      'delays': 'Sledujte zpoždění',
      'cancelation': 'Sledujte, zda není spojení zrušeno',
      'watchedRoute': 'Tato trasa je nyní sledována',
      'watchedRouteTitle': 'Trasa sledována',
      'selectType': 'Musíte vybrat alespoň jednu věc, kterou budete sledovat',
      'selectTypeTitle': 'Není vybráno nic',
      'unwatch': 'Opravdu chcete přestat sledovat tuto trasu?',
      'cancel': 'Zrušit',
      'alreadyWatched':
          'Tato trasa je již sledována. Chcete ji přestat sledovat nebo upravit?',
      'alreadyWatchdedTitle': 'Sledováno',
      'edit': 'Upravit',
      'ok': 'OK',
      'deletionSuccess': 'Úspěšně smazáno',
      'deletionFailTitle': 'Smazání se nezdařilo',
      'deletionFail': 'Smazání sledovače se nezdařilo',
      'noLonger': 'Tato trasa již není sledována',
      'unwatchButton': 'Přestat sledovat',
      'swap': 'Vyměňit odkud a kam',
      'anySeat': 'Jakákoli třída sedadla',
      'noInternet': 'Žádné internetové připojení',
      'noInternetTitle':
          'Abyste mohli používat tuto aplikaci, musíte být připojeni k internetu',
      'error': 'Nastala chyba',
      'delay': 'Spoždení',
      'minutes': ' minut',
      'minutesLess': ' minuty',
      'local': 'Lokální spoj:',
      'noClass': 'Tarifní třída vlaku RegioJet podle výběru zákazníka',
      'noSeat': 'Chci jen sledovat zpoždění spoje',
      'noRoutesFound': 'Pro zvolená místa nebylo nalezeno žádné spojení',
      'version': 'Verze:',
      'details': 'Detaily aplikace',
      'package': 'Identifikátor: ',
      'appName': 'Jméno: ',
      'buildNumber': 'Číslo sestavy',
      'fullVersion': 'Plná verze: ',
    },
    'sk': {
      'title': 'Odchyť to',
      'search': 'Vyhľadávanie',
      'searching_message': 'vyhľadávam ...',
      'origin': 'Odkiaľ',
      'destination': 'Kam',
      'searchHintText': 'Začni písať',
      'offline': 'offline',
      'preferences': 'Nastavenia',
      'language': 'Jazyk',
      'english': 'Angličtina',
      'german': 'Nemčina',
      'czech': 'Čeština',
      'slovak': 'Slovenčina',
      'tap_continue': 'Klikni pre pokračovanie',
      'direct': 'Priamy spoj',
      'seats': ' Voľných miest',
      'sold': 'Vypredané',
      'from': 'Od ',
      'transfer': ' prestup',
      'transfers': ' prestupy',
      'wait': 'Čakanie na prestup ',
      'passenger': ' cestujúci',
      'passengers': '',
      'multiplePassengers': 'ch',
      'refresh': 'Obnoviť',
      'noWatched': 'Nie sú sledované žiadne spojenia',
      'czk': 'KČ',
      'eur': '€',
      'date': 'Vybrať dátum',
      'watch': 'Sledovať',
      'watched': 'Sledované',
      'routesAvailable': 'Sledované spojenia',
      'routesFull': 'Práve prebiehajúce spojenia',
      'currency': 'Mena',
      'noRoutes':
          'Nenájdený žiadny spoj na požadovaný dátum. Zobrazujem najbližšie spoje',
      'tickets': 'Sledujte dostupnosť lístkov',
      'delays': 'Sledujte meškanie',
      'cancelation': 'Sledujte, či spojenie nebolo zrušené',
      'watchedRoute': 'Táto trasa bude sledovaná',
      'watchedRouteTitle': 'Trasa sledovaná',
      'selectType': 'Musíte vybrať aspoň jednu vec, ktorú budete sledovať',
      'selectTypeTitle': 'Nie je vybrané nič',
      'unwatch': 'Naozaj chcete prestať sledovať túto trasu?',
      'cancel': 'Zrušit',
      'alreadyWatched':
          'Táto trasa je už sledovaná. Chcete ju prestať sledovať alebo ju upraviť?',
      'alreadyWatchdedTitle': 'Sledované',
      'edit': 'Upraviť',
      'ok': 'OK',
      'deletionSuccess': 'Úspešne zmazané',
      'deletionFailTitle': 'Zmazanie sa nepodarilo',
      'deletionFail': 'Zmazanie sledovača sa nepodarilo',
      'noLonger': 'Táto trasa už nie je sledovaná',
      'unwatchButton': 'Prestať sledovať',
      'swap': 'Vymeniť odkiaľ a kam',
      'anySeat': 'Akákoľvek trieda sedadla',
      'noInternet': 'Žiadne internetové pripojenie',
      'noInternetTitle':
          'Aby ste mohli používať túto aplikáciu, musíte byť pripojený k internetu',
      'error': 'Nastala chyba',
      'delay': 'Meškanie',
      'minutes': ' minút',
      'minutesLess': ' minúty',
      'local': 'Lokálny spoj:',
      'noClass': 'Tarifná trieda vlaku RegioJet podľa výberu zákazníka',
      'noSeat': 'Chcem iba sledovať meškanie spoja',
      'noRoutesFound': 'Pre zvolené miesta sa nenašlo žiadne spojenie',
      'version': 'Verzia:',
      'details': 'Detaily aplikácie',
      'package': 'Identifikátor: ',
      'appName': 'Meno: ',
      'buildNumber': 'Číslo zostavy',
      'fullVersion': 'Plná verzia: ',
    },
    'en': {
      'title': 'Catch It',
      'search': 'Search',
      'searching_message': 'searching ...',
      'origin': 'From',
      'destination': 'To',
      'searchHintText': 'Please enter a search term',
      'offline': 'offline',
      'preferences': 'Preferences',
      'language': 'Language',
      'english': 'English',
      'german': 'German',
      'czech': 'Czech',
      'slovak': 'Slovak',
      'tap_continue': 'Tap to continue',
      'direct': 'Direct',
      'seats': ' Free seats',
      'sold': 'Sold out',
      'from': 'From ',
      'transfer': ' transfer',
      'transfers': ' transfers',
      'wait': 'Waiting for transfer ',
      'passenger': ' passenger',
      'passengers': 's',
      'multiplePassengers': 's',
      'refresh': 'Refresh',
      'noWatched': 'No watched connections',
      'czk': 'CZK',
      'eur': '€',
      'date': 'Choose a date',
      'watch': 'Watch',
      'watched': 'Watched',
      'routesAvailable': 'Watched Routes',
      'routesFull': 'Routes currently ongoing',
      'currency': 'Currency',
      'noRoutes':
          'No connection found for the requested date. Showing the nearest connections',
      'tickets': 'Watch for tickets availability',
      'delays': 'Watch for delays',
      'cancelation': 'Watch if connection is cancelled',
      'watchedRoute': 'This route is now being watched',
      'watchedRouteTitle': 'Route watched',
      'selectType': 'You need to select at least one thing to watch for',
      'selectTypeTitle': 'Nothing selected',
      'unwatch': 'Are you sure you want to unwatch this route?',
      'cancel': 'Cancel',
      'alreadyWatched':
          'This route is already watched. Do you want to unwatch it, or edit it?',
      'alreadyWatchdedTitle': 'Already watched',
      'edit': 'Edit',
      'ok': 'OK',
      'deletionSuccess': 'Deleted successfully',
      'deletionFailTitle': 'Deletion failed',
      'deletionFail': 'Deletion of watcher failed',
      'noLonger': 'This route is no longer watched',
      'unwatchButton': 'Unwatch',
      'swap': 'Swap Origin and Destination',
      'anySeat': 'Any seat class',
      'noInternet': 'No internet connection',
      'noInternetTitle':
          'You must be connected to the internet to use this app',
      'error': 'There was an error',
      'delay': 'Delay',
      'minutes': ' minutes',
      'minutesLess': ' minutes',
      'local': 'Local connection:',
      'noClass':
          "Tariff class of the RegioJet train according to the customer's choice",
      'noSeat': 'I just want to watch for delays',
      'noRoutesFound': 'No connections found for the selected places',
      'version': 'Version: ',
      'details': 'App Details',
      'package': 'Package: ',
      'appName': 'App Name: ',
      'buildNumber': 'Build Number',
      'fullVersion': 'Full Version: ',
    },
    'de': {
      'hello': 'Hallo Welt',
      'title': 'Berliner Verkehrs App',
      'search': 'Suche',
      'searching_message': 'suche ...',
      'origin': 'Start',
      'destination': 'Ziel',
      'searchHintText': 'Gib einen Suchbegriff ein',
      'offline': 'offline',
      'preferences': 'Einstellungen',
      'language': 'Sprache',
      'currency': 'Currency',
      'english': 'Englisch',
      'german': 'Deutsch',
      'tap_continue': 'Zum Fortfahren Tippen',
    },
  };

  String get title => _localizedValues[locale.languageCode]!['title']!;
  String get hello => _localizedValues[locale.languageCode]!['hello']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get searchMessage =>
      _localizedValues[locale.languageCode]!['searching_message']!;
  String get origin => _localizedValues[locale.languageCode]!['origin']!;
  String get destination =>
      _localizedValues[locale.languageCode]!['destination']!;
  String get searchHintText =>
      _localizedValues[locale.languageCode]!['searchHintText']!;
  String get offline => _localizedValues[locale.languageCode]!['offline']!;
  String get preferences =>
      _localizedValues[locale.languageCode]!['preferences']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get german => _localizedValues[locale.languageCode]!['german']!;
  String get tapContinue =>
      _localizedValues[locale.languageCode]!['tap_continue']!;

  String get czech => _localizedValues[locale.languageCode]!['czech']!;
  String get slovak => _localizedValues[locale.languageCode]!['slovak']!;
  String get direct => _localizedValues[locale.languageCode]!['direct']!;
  String get seats => _localizedValues[locale.languageCode]!['seats']!;
  String get sold => _localizedValues[locale.languageCode]!['sold']!;
  String get from => _localizedValues[locale.languageCode]!['from']!;
  String get transfer => _localizedValues[locale.languageCode]!['transfer']!;
  String get transfers => _localizedValues[locale.languageCode]!['transfers']!;
  String get wait => _localizedValues[locale.languageCode]!['wait']!;
  String get passenger => _localizedValues[locale.languageCode]!['passenger']!;
  String get passengers =>
      _localizedValues[locale.languageCode]!['passengers']!;
  String get multiplePassengers =>
      _localizedValues[locale.languageCode]!['multiplePassengers']!;
  String get refresh => _localizedValues[locale.languageCode]!['refresh']!;
  String get noWatched => _localizedValues[locale.languageCode]!['noWatched']!;
  String get czk => _localizedValues[locale.languageCode]!['czk']!;
  String get eur => _localizedValues[locale.languageCode]!['eur']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get watch => _localizedValues[locale.languageCode]!['watch']!;
  String get watched => _localizedValues[locale.languageCode]!['watched']!;
  String get routesAvailable =>
      _localizedValues[locale.languageCode]!['routesAvailable']!;
  String get routesFull =>
      _localizedValues[locale.languageCode]!['routesFull']!;
  String get currency => _localizedValues[locale.languageCode]!['currency']!;
  String get noRoutes => _localizedValues[locale.languageCode]!['noRoutes']!;
  String get tickets => _localizedValues[locale.languageCode]!['tickets']!;
  String get delays => _localizedValues[locale.languageCode]!['delays']!;
  String get cancelation =>
      _localizedValues[locale.languageCode]!['cancelation']!;
  String get watchedRoute =>
      _localizedValues[locale.languageCode]!['watchedRoute']!;
  String get watchedRouteTitle =>
      _localizedValues[locale.languageCode]!['watchedRouteTitle']!;
  String get selectType =>
      _localizedValues[locale.languageCode]!['selectType']!;
  String get selectTypeTitle =>
      _localizedValues[locale.languageCode]!['selectTypeTitle']!;
  String get unwatch => _localizedValues[locale.languageCode]!['unwatch']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get alreadyWatched =>
      _localizedValues[locale.languageCode]!['alreadyWatched']!;
  String get alreadyWatchdedTitle =>
      _localizedValues[locale.languageCode]!['alreadyWatchdedTitle']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get deletionSuccess =>
      _localizedValues[locale.languageCode]!['deletionSuccess']!;
  String get deletionFailTitle =>
      _localizedValues[locale.languageCode]!['deletionFailTitle']!;
  String get deletionFail =>
      _localizedValues[locale.languageCode]!['deletionFail']!;
  String get noLonger => _localizedValues[locale.languageCode]!['noLonger']!;
  String get unwatchButton =>
      _localizedValues[locale.languageCode]!['unwatchButton']!;
  String get swap => _localizedValues[locale.languageCode]!['swap']!;
  String get anySeat => _localizedValues[locale.languageCode]!['anySeat']!;
  String get noInternet =>
      _localizedValues[locale.languageCode]!['noInternet']!;
  String get noInternetTitle =>
      _localizedValues[locale.languageCode]!['noInternetTitle']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get delay => _localizedValues[locale.languageCode]!['delay']!;
  String get minutes => _localizedValues[locale.languageCode]!['minutes']!;
  String get minutesLess =>
      _localizedValues[locale.languageCode]!['minutesLess']!;
  String get local => _localizedValues[locale.languageCode]!['local']!;
  String get noClass => _localizedValues[locale.languageCode]!['noClass']!;
  String get noSeat => _localizedValues[locale.languageCode]!['noSeat']!;
  String get noRoutesFound =>
      _localizedValues[locale.languageCode]!['noRoutesFound']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get details => _localizedValues[locale.languageCode]!['details']!;
  String get package => _localizedValues[locale.languageCode]!['package']!;
  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get buildNumber =>
      _localizedValues[locale.languageCode]!['buildNumber']!;
  String get fullVersion =>
      _localizedValues[locale.languageCode]!['fullVersion']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['cs', 'sk', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
