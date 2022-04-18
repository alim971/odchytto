import 'package:flutter/material.dart';
import 'package:watcher/common/widgets/date.dart';
import 'package:watcher/common/widgets/placeholders.dart';
import 'package:watcher/regio/routes/routes.dart';
import 'package:watcher/regio/widgets/buttons.dart';
import 'package:watcher/regio/widgets/tariffs.dart';

class RegioMain extends StatelessWidget {
  const RegioMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const spacing = 15.0;
    return Column(children: const [
      SizedBox(height: 5),
      Origin(),
      SwapButton(),
      // SizedBox(height: spacing),
      Destination(),
      SizedBox(height: spacing),
      TariffSelector(),
      SizedBox(height: spacing),
      DateSelector(),
      SizedBox(height: spacing),
      RefreshButton(),
      SizedBox(height: spacing),
      Expanded(
        child: RoutesPanel(),
      ),
    ]);
  }
}
