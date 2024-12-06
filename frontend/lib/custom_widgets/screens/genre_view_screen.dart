import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/console.dart';
import 'package:sonata/custom_widgets/stacked_screen_appbar.dart';
import 'package:sonata/custom_widgets/tiles/song_tile.dart';

class GenreViewScreen extends StatelessWidget {
  final int genre_id;
  final String genre_name;
  const GenreViewScreen({super.key, required this.genre_id, required this.genre_name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StackedScreenAppbar(genre_name),
      body: FutureBuilder(
        future: DbHelper.instance.getSongIdsOfGenre(genre_id),
        builder: (context, snapshot) {
          return (!snapshot.hasData)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => SongTile(snapshot.data![index]),
                );
        },
      ),
      bottomNavigationBar: const Console(),
    );
  }
}
