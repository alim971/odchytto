import 'package:flutter/material.dart';
import 'package:watcher/common/widgets/prefs.dart';

class AppBarBuilder extends StatelessWidget {
  const AppBarBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Row(
        children: [
          IconButton(
            icon: const Icon(Icons.catching_pokemon_sharp),
            onPressed: () => showRegioWatched(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showPreferences(context),
          ),
        ],
      ),
    );
  }
}
