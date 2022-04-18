import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/widgets/future.dart';
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/data/models.dart';
import 'package:watcher/regio/theme.dart';

class TariffSelector extends StatefulWidget {
  const TariffSelector({Key? key}) : super(key: key);

  @override
  State<TariffSelector> createState() => _TariffSelectorState();
}

class _TariffSelectorState extends State<TariffSelector> {
  late TariffWithCounter dropdownValue;
  int _peopleCount = 1;

  int get peopleCount => _peopleCount;

  set peopleCount(int peopleCount) {
    if (peopleCount >= 0) {
      _peopleCount = peopleCount;
    }
  }

  void addPeople() {
    setState(() {
      _peopleCount += 1;
    });
  }

  void removePeople() {
    setState(() {
      if (peopleCount > 1) {
        _peopleCount -= 1;
      }
    });
  }

  bool onlyOnePerson() {
    return peopleCount == 1;
  }

  bool initialized = false;
  late HashMap<String, TariffWithCounter> tariffs =
      HashMap<String, TariffWithCounter>();

  HashMap<String, TariffWithCounter> mapTariffs(List<Tariff> list) {
    TariffWithCounter update(TariffWithCounter value, Tariff updated) {
      value.tariff = updated;
      return value;
    }

    for (Tariff tariff in list) {
      if (tariffs.containsKey(tariff.key)) {
        tariffs.update(tariff.key, (value) => update(value, tariff));
      } else {
        tariffs.putIfAbsent(
            tariff.key,
            () => TariffWithCounter(
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
    final notifierJourney = Provider.of<JourneyNotifier>(context);
    return Consumer<PrefsNotifier>(
        builder: (context, notifier, _) => FutureBuilder(
            future: notifierJourney.getTariffs(), //TODO remove and move to init
            builder: (context, AsyncSnapshot<List<Tariff>?> snapshot) {
              if (snapshot.hasData) {
                mapTariffs(snapshot.data!);
                if (!initialized) {
                  dropdownValue = tariffs['REGULAR']!;
                  initialized = true;
                }
                return Container(
                  color: brightRegioYellow,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: const Color(0xFFFFBF00),
                    ),
                    child: DropdownButton<TariffWithCounter>(
                      selectedItemBuilder: (_) {
                        return tariffs.keys.map<Widget>((String item) {
                          return Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(peopleCount.toString() +
                                  AppLocalizations.of(context).passenger +
                                  (peopleCount == 1
                                      ? ''
                                      : peopleCount > 3
                                          ? AppLocalizations.of(context)
                                              .multiplePassengers
                                          : AppLocalizations.of(context)
                                              .passengers)),
                              const Icon(Icons.person),
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
                      onChanged: (TariffWithCounter? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: tariffs.values
                          .map<DropdownMenuItem<TariffWithCounter>>(
                              (TariffWithCounter value) {
                        return DropdownMenuItem<TariffWithCounter>(
                          value: value,
                          child: TariffsCounter(value, addPeople,
                              removePeople), //TODO ADD default for user to select in setting
                        );
                      }).toList(),
                    ),
                  ),
                );
              } else {
                return BuilderNoData(snapshot);
              }
            }));
  }
}

class TariffsCounter extends StatefulWidget {
  const TariffsCounter(this.tariff, this.add, this.remove, {Key? key})
      : super(key: key);
  final TariffWithCounter tariff;
  final dynamic add;
  final dynamic remove;

  @override
  _TariffsCounterState createState() => _TariffsCounterState();
}

class _TariffsCounterState extends State<TariffsCounter> {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(widget.tariff.description, style: const TextStyle(fontSize: 13)),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            OutlinedButton(
              child: const Icon(Icons.remove),
              onPressed: () => setState(() {
                if (notifier.tariffs.length > 1 && widget.tariff.count > 0) {
                  widget.tariff.count -= 1;
                  notifier.tariffs.remove(widget.tariff.tariff);
                  notifier.refresh();
                  widget.remove();
                }
              }),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width:
                        widget.tariff.count > 0 && notifier.tariffs.length > 1
                            ? 2.0
                            : 0.0,
                    color: Colors.blue),
                shape: const CircleBorder(),
              ),
            ),
            Text(widget.tariff.count.toString()),
            OutlinedButton(
              child: const Icon(Icons.add),
              onPressed: () => setState(() {
                if (notifier.tariffs.length < 6) {
                  widget.tariff.count += 1;
                  notifier.tariffs.add(widget.tariff.tariff);
                  notifier.refresh();
                  widget.add();
                }
              }),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: notifier.tariffs.length < 6 ? 2.0 : 0.0,
                    color: Colors.blue),
                shape: const CircleBorder(),
              ),
            ),
          ]),
        ]);
  }
}
