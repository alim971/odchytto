import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watcher/regio/data/models.dart';

class DateSelector extends StatefulWidget {
  const DateSelector({Key? key}) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime selectedDate;

  _selectDate(BuildContext context) async {
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    selectedDate = notifier.date;

    final DateTime? selected = await showDatePicker(
      locale: Locale(notifier.language),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
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
    final notifier = Provider.of<JourneyNotifier>(context, listen: false);
    selectedDate = notifier.date;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton.icon(
            onPressed: () {
              _selectDate(context);
            },
            icon: const Icon(Icons.date_range),
            label: Text(
                // selectedDate == null
                //     ? AppLocalizations.of(context).date
                //     :
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
          ),
        ],
      ),
    );
  }
}
