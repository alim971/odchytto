import 'package:flutter/material.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/widgets/other.dart';

class BuilderNoData extends StatelessWidget {
  const BuilderNoData(this.snapshot, {Key? key}) : super(key: key);
  final snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return ErrorMessage(
          errorMessage:
              AppLocalizations.of(context).error); //snapshot.error.toString());
    } else {
      return const LoadingCircle();
    }
  }
}
