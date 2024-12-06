import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/tiles/song_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Welcome back!",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox.square(
          dimension: 40,
        ),
        FutureBuilder(
          future: DbHelper.instance.getTopSongs(10),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
                    child: Text(
                      (snapshot.data!.isNotEmpty) ? "Most Played Songs" : "",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  for (int i = 0; i < snapshot.data!.length; i++) SongTile(snapshot.data![i]),
                ],
              );
            }
          },
        )
      ],
    );
  }
}
