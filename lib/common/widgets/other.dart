import 'package:flutter/material.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/theme.dart';

class LoadingCircle extends StatelessWidget {
  const LoadingCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: brightRegioYellow,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({required this.errorMessage, Key? key}) : super(key: key);
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: brightRegioYellow,
      child: Center(
        child: PlaceName(errorMessage),
      ),
    );
  }
}
