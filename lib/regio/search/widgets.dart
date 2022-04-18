import 'package:flutter/material.dart';
import 'package:watcher/common/utils/utils.dart';
import 'package:watcher/regio/data/data.dart';

class CityTile extends StatelessWidget {
  const CityTile({Key? key, required this.city, required this.onTap})
      : super(key: key);
  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(city.name + ', ' + city.country),
      minLeadingWidth: 20,
      leading: const Icon(Icons.location_pin),
      // subtitle: Text('aaa'),
      onTap: onTap,
    );
  }
}

class StationTile extends StatelessWidget {
  const StationTile({Key? key, required this.station, required this.onTap})
      : super(key: key);
  final Station station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(station.fullName),
      leading: SizedBox(
        width: 70,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: getIcons(station)),
        ),
      ),
      // subtitle: Text('aaa'),
      onTap: onTap,
    );
  }
}
