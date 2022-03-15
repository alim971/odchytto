// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:watcher/data/data.dart' as data;
import 'package:watcher/data/localization.dart';
import 'package:watcher/data/models.dart';
import 'package:watcher/select.dart';
import 'package:watcher/theme.dart';
import 'package:watcher/utils.dart';
import 'package:watcher/watch.dart';
import 'package:watcher/widgets/prefs.dart';
import 'package:watcher/widgets/search.dart';
import 'package:watcher/widgets/splash.dart';
import 'package:watcher/widgets/widgets.dart';

import 'dialog.dart';

void main() => runApp(BerlinTransportApp());

class BerlinTransportApp extends StatelessWidget {
  const BerlinTransportApp({Key? key}) : super(key: key);

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
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).title,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('de'),
        ],
        theme: appTheme,
        home: Consumer<PrefsNotifier>(
          builder: (context, notifier, _) => OverrideLocalization(
            locale: notifier.locale ?? Locale('en'),
            child: Consumer<AppStateNotifier>(
              builder: (context, notifier, _) =>
                  notifier.showSplash ? SplashScreen() : BerlinTransportPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class BerlinTransportPage extends StatelessWidget {
  const BerlinTransportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        notifier.refresh();
        return true;
      },
      child: Scaffold(
        backgroundColor: berlinBrightYellow,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).title),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => showPreferences(context),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 5),
            Origin(),
            SizedBox(height: 15),
            Destination(),
            SizedBox(height: 15),
            TarrifSelector(),
            SizedBox(height: 15),
            DateSelector(),
            SizedBox(height: 15),
            RefreshButton(),
            SizedBox(height: 15),
            Expanded(
              child: JourneyPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

class RefreshButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    return ElevatedButton.icon(
      onPressed: () {
        notifier.refresh();
      },
      icon: Icon(Icons.refresh),
      label: Text("Refresh"), //TODO Add translation
    );
  }
}

class DateSelector extends StatefulWidget {
  const DateSelector({Key? key}) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime? selectedDate;

  _selectDate(BuildContext context) async {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.yellow, // header background color
              onPrimary: Colors.black, // header text color
              onSurface: Colors.black26, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
      notifier.date = selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton.icon(
            onPressed: () {
              _selectDate(context);
            },
            icon: Icon(Icons.date_range),
            label: Text(selectedDate == null
                ? "Choose Date"
                : "${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}"),
          ),
          // Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}")
        ],
      ),
    );
  }
}

class TarrifSelector extends StatefulWidget {
  const TarrifSelector({Key? key}) : super(key: key);

  @override
  State<TarrifSelector> createState() => _TarrifSelectorState();
}

class _TarrifSelectorState extends State<TarrifSelector> {
  late Tariff2 dropdownValue;
  int _peopleCount = 1;

  int get peopleCount => _peopleCount;

  set peopleCount(int peopleCount) {
    if (peopleCount >= 0) {
      _peopleCount = peopleCount;
    }
  }

  void setTariffs(notifier) {
    List<data.Tariff> result = [];
    for (Tariff2 tariff in tariffs.values) {
      for (int i = 0; i < tariff.count; i++) {
        result.add(tariff.tariff);
      }
    }
    notifier.tariffs = result;
  }

  void addPeople(notifier) {
    setState(() {
      _peopleCount += 1;
    });
    setTariffs(notifier);
  }

  void removePeople(notifier) {
    setState(() {
      if (peopleCount > 1) {
        _peopleCount -= 1;
      }
    });
    setTariffs(notifier);
  }

  bool onlyOnePerson() {
    return peopleCount == 1;
  }

  bool initialized = false;
  late HashMap<String, Tariff2> tariffs = HashMap<String, Tariff2>();

  HashMap<String, Tariff2> mapTariffs(List<data.Tariff> list) {
    Tariff2 update(Tariff2 value, data.Tariff updated) {
      value.tariff = updated;
      return value;
    }

    for (data.Tariff tariff in list) {
      if (tariffs.containsKey(tariff.key)) {
        tariffs.update(tariff.key, (value) => update(value, tariff));
      } else {
        tariffs.putIfAbsent(
            tariff.key,
            () => Tariff2(
                tariff,
                tariff.key == 'REGULAR'
                    ? 1
                    : 0)); //TODO add default in settings
      }
    }
    return tariffs;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return FutureBuilder(
        future: notifier.getTariffs(),
        builder: (context, AsyncSnapshot<List<data.Tariff>?> snapshot) {
          if (snapshot.hasData) {
            if (!initialized) {
              dropdownValue = mapTariffs(snapshot.data!)['REGULAR']!;
              initialized = true;
            }
            return Container(
              color: berlinBrightYellow,
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Color(0xFFFFBF00),
                ),
                child: DropdownButton<Tariff2>(
                  selectedItemBuilder: (_) {
                    return tariffs.keys.map<Widget>((String item) {
                      return Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(peopleCount.toString() +
                              ' cestujuci' +
                              (peopleCount == 0
                                  ? 'ch'
                                  : '')), //TODO add translation
                          Icon(Icons.person),
                        ],
                      ));
                    }).toList();
                  },
                  isExpanded: true,
                  value: dropdownValue,
                  icon: null,
                  elevation: 16,
                  underline: Container(
                    height: 3,
                    color: Colors.black26,
                  ),
                  onChanged: (Tariff2? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  items: tariffs.values
                      .map<DropdownMenuItem<Tariff2>>((Tariff2 value) {
                    return DropdownMenuItem<Tariff2>(
                      value: value,
                      child: TariffCountss(
                          value,
                          addPeople,
                          removePeople,
                          onlyOnePerson,
                          notifier), //TODO ADD default for user to select in setting
                    );
                  }).toList(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            dropdownValue =
                Tariff2(data.Tariff(key: 'no', description: 'tariff'), 0);
            return Container(
              color: berlinBrightYellow,
              child: Center(
                child: Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            dropdownValue =
                Tariff2(data.Tariff(key: 'no', description: 'tariff'), 0);
            return Container(
              color: berlinBrightYellow,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}

class Tariff2 {
  Tariff2(this.tariff, this._count);
  data.Tariff tariff;
  int _count;

  int get count => _count;

  String get description => tariff.description;
  String get key => tariff.key;

  set count(int count) {
    if (count >= 0) _count = count;
  }

  @override
  bool operator ==(Object other) => other is Tariff2 && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

class TariffCountss extends StatefulWidget {
  const TariffCountss(
      this.tariff, this.add, this.remove, this.onlyOne, this.notifier,
      {Key? key})
      : super(key: key);
  final Tariff2 tariff;
  final dynamic add;
  final dynamic remove;
  final dynamic onlyOne;
  final dynamic notifier;

  @override
  _TariffCountssState createState() => _TariffCountssState();
}

class _TariffCountssState extends State<TariffCountss> {
  @override
  Widget build(BuildContext context) {
    // count = widget.tariff.count;
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(widget.tariff.description, style: TextStyle(fontSize: 13)),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            OutlinedButton(
              child: Icon(Icons.remove),
              onPressed: () => setState(() {
                if (!widget.onlyOne() && widget.tariff.count > 0) {
                  widget.tariff.count -= 1;
                  widget.remove(widget.notifier);
                }
              }),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: widget.tariff.count > 0 && !widget.onlyOne()
                        ? 2.0
                        : 0.0,
                    color: Colors.blue),
                shape: CircleBorder(),
              ),
            ),
            Text(widget.tariff.count.toString()),
            OutlinedButton(
              child: Icon(Icons.add),
              onPressed: () => setState(() {
                widget.tariff.count += 1;
                widget.add(widget.notifier);
              }),
              style: OutlinedButton.styleFrom(
                side: BorderSide(width: 2.0, color: Colors.blue),
                shape: CircleBorder(),
              ),
            ),
          ]),
        ]);
  }
}

class Origin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return GestureDetector(
        child: notifier.departure != null
            ? EmbossedText(notifier.departure!.name)
            : EmbossedText(AppLocalizations.of(context).origin),
        onTap: () {
          notifier.searchType = SearchType.origin;
          showPlacesSearch(context).then(
              (place) => notifier.departure = place ?? notifier.departure);
        });
  }
}

class Destination extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return GestureDetector(
        child: notifier.arrival != null
            ? EmbossedText(notifier.arrival!.name)
            : EmbossedText(AppLocalizations.of(context).destination),
        onTap: () {
          notifier.searchType = SearchType.destination;
          showPlacesSearch(context)
              .then((place) => notifier.arrival = place ?? notifier.arrival);
        });
  }
}

class EmbossedText extends StatelessWidget {
  const EmbossedText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          color: berlinBrightYellow,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}

class JourneyPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<JourneyNotifier>(
      builder: (context, notifier, _) =>
          notifier.routes != null && notifier.routes!.length > 0
              ? RouteList(notifier.routes!)
              : Container(
                  child: Center(
                    child: Opacity(
                      opacity: 0.2,
                      child: Icon(
                        Icons.directions_subway,
                        size: 200,
                      ),
                    ),
                  ),
                ),
    );
  }
}

class ConnectionWidget extends StatelessWidget {
  ConnectionWidget(this.sectionFirst, this.transfer);
  final data.Section sectionFirst;
  final data.Transfer? transfer;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SectionWidget(sectionFirst, false),
      SizedBox(height: 15),
      TransferWidget(transfer!),
      SizedBox(height: 15),
    ]);
  }
}

class TransferWidget extends StatelessWidget {
  TransferWidget(this.transfer);
  final data.Transfer transfer;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(width: 45),
      const Icon(Icons.access_time),
      SizedBox(width: 5),
      Text("Cekani na prestup " + format(transfer.time),
          style: TextStyle(color: grey, fontSize: 15)) //TODO add translation
    ]);
  }
}

class SectionWidget extends StatelessWidget {
  SectionWidget(this.section, this.isDestination);
  final data.Section section;
  final bool isDestination;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(prettyTime(section.departureTime)),
          if (section.getType().contains('train')) const Icon(Icons.train),
          if (section.getType().contains('bus'))
            const Icon(Icons.directions_bus),
          Text(section.departureName)
        ]),
        SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(section.travelTime,
              style: TextStyle(color: grey, fontSize: 11.5)),
          SizedBox(width: 5),
          Icon(Icons.south_sharp),
          SizedBox(width: 5),
          Text(
              section.line.getLine() +
                  " " +
                  section.line.from +
                  " - " +
                  section.line.to +
                  (section.line.code != ""
                      ? " (" + section.line.code + ")"
                      : ""),
              style: TextStyle(color: grey, fontSize: 15)),
        ]),
        SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(prettyTime(section.arrivalTime)),
          SizedBox(width: 5),
          if (!isDestination) const Icon(Icons.circle_rounded),
          if (isDestination) const Icon(Icons.place),
          SizedBox(width: 5),
          Text(section.arrivalName)
        ]),
      ],
    );
  }
}

class RouteList extends StatefulWidget {
  RouteList(this.routes);
  final List<data.Route> routes;
  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  Color getColor(int seats) {
    if (seats == 0) return Colors.redAccent;
    if (seats < 10) return Colors.orangeAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    // List<bool> _isOpen = List<bool>.filled(widget.routes.length, false);
    final notifier = Provider.of<JourneyNotifier>(context);
    return SingleChildScrollView(
        child: Column(
      children: [
        if (prettyDate(widget.routes[0].arrivalTime) !=
            prettyDate(notifier.date!))
          Center(
            child: const PlaceName(
                "Nenalezen žádný spoj na požadované datum. Zobrazuji nejbližší spoje"),
          ), //TODO Add translation
        ExpansionPanelList(
          // expandedHeaderPadding: EdgeInsets.all(0),
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              if (widget.routes[index].freeSeats == 0) {
                isExpanded = true;
              }
              widget.routes[index].isExpanded = !isExpanded;
            });
          },
          children: widget.routes.map<ExpansionPanel>((data.Route route) {
            List<Icon> icons = getIcons(route);
            return ExpansionPanel(
              backgroundColor: berlinBrightYellow,
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  // tileColor: berlinDarkYellow,
                  title: DefaultTextStyle(
                    style: TextStyle(
                        color: route.freeSeats == 0 ? grey : Colors.black),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(prettyTime(route.departureTime) +
                                ' - ' +
                                prettyTime(route.arrivalTime)),
                            // Text(' - '),
                            // Text(prettyTime(route.arrivalTime)),
                            Text(route.travelTime),
                            FutureBuilder(
                                future: notifier.isWatched(route.id),
                                builder:
                                    (context, AsyncSnapshot<bool?> snapshot) {
                                  if (snapshot.hasData) {
                                    return route.freeSeats != 0
                                        ? ElevatedButton(
                                            onPressed: () {
                                              if (route.typesAsStrings
                                                      .contains('bus') &&
                                                  route.types.length == 1) {
                                                launchURLApp(
                                                  route.id,
                                                  route.departureStation,
                                                  route.arrivalStation,
                                                  notifier.tariffs
                                                      .map((e) => e.key),
                                                  "NO",
                                                );
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SelectConnection(
                                                                route: route)));
                                              }
                                            },
                                            child: Text(route.minPrice ==
                                                    route.maxPrice
                                                ? route.maxPrice.toString() +
                                                    'KC'
                                                : 'Od ' +
                                                    route.minPrice.toString() +
                                                    "KC"), //TODO add currency
                                          )
                                        : ElevatedButton(
                                            onPressed: () {
                                              if (snapshot.data!) {
                                                showWatchedDialog(
                                                    context,
                                                    route.id,
                                                    (route.typesAsStrings
                                                            .contains('bus') &&
                                                        route.types.length ==
                                                            1),
                                                    Watcher(
                                                        route: route,
                                                        seatClass: "NO"),
                                                    SelectConnection(
                                                        route: route));
                                              } else {
                                                if (route.typesAsStrings
                                                        .contains('bus') &&
                                                    route.types.length == 1) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Watcher(
                                                                  route: route,
                                                                  seatClass:
                                                                      "NO")));
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SelectConnection(
                                                                  route:
                                                                      route)));
                                                }
                                              }
                                            },
                                            child: Text(snapshot.data!
                                                ? "Sledovane"
                                                : "Sledovat"));
                                  } else if (snapshot.hasError) {
                                    return Container(
                                      color: berlinBrightYellow,
                                      child: Center(
                                        child: Text(
                                          '${snapshot.error}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      color: berlinBrightYellow,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                }),
                          ],
                        ),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ...getIcons(route),
                            Text(route.transfers == 0
                                ? 'Primy'
                                : (route.transfers.toString() +
                                    " prestup" +
                                    (route.transfers == 1
                                        ? ''
                                        : 'y'))), //TODO add translation
                            SizedBox(width: icons.length == 1 ? 20 : 28),
                            Icon(Icons.person),
                            Text(
                                route.freeSeats == 0
                                    ? "Vyprodano"
                                    : route.freeSeats.toString() +
                                        " volnych mist",
                                style:
                                    TextStyle(color: getColor(route.freeSeats)))
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              body: FutureBuilder(
                  future: notifier.getConnection(route),
                  builder: (context, AsyncSnapshot<data.Connection?> snapshot) {
                    if (snapshot.hasData) {
                      int length = snapshot.data!.sections.length;
                      return ListTile(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (var i = 0; i < length; i++)
                                route.transfers > i
                                    ? ConnectionWidget(
                                        snapshot.data!.sections[i],
                                        i == length - 1
                                            ? null
                                            : snapshot.data!.transfersInfo!
                                                .transfers[i])
                                    : SectionWidget(
                                        snapshot.data!.sections[i], true),
                            ],
                          ),
                          // subtitle: const Text(
                          //     'To delete this panel, tap the trash can icon'),
                          // trailing: const Icon(Icons.shopping_cart),
                          onTap: () {
                            // setState(() {
                            // });
                          });
                    } else if (snapshot.hasError) {
                      return Container(
                        color: berlinBrightYellow,
                        child: Center(
                          child: Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        color: berlinBrightYellow,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  }),
              isExpanded: route.isExpanded,
            );
          }).toList(),
        ),
      ],
    ));
  }
}
