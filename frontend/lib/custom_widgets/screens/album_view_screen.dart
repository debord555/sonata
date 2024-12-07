import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/console.dart';
import 'package:sonata/custom_widgets/custom_text.dart';
import 'package:sonata/custom_widgets/tiles/album_song_tile.dart';
import 'package:sonata/custom_widgets/stacked_screen_appbar.dart';
import 'package:sonata/misc/constants.dart';
import 'package:provider/provider.dart';

class AlbumViewScreen extends StatefulWidget {
  final int album_id;

  const AlbumViewScreen(this.album_id, {super.key});

  @override
  State<AlbumViewScreen> createState() => _AlbumViewScreenState();
}

class _AlbumViewScreenState extends State<AlbumViewScreen> {
  late Future<List<Map<String, dynamic>>> future_album_song_data;

  @override
  void initState() {
    future_album_song_data = DbHelper.instance.getAlbumSongData(widget.album_id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future_album_song_data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print("x");
          return Scaffold(
            appBar: StackedScreenAppbar(snapshot.data![0]["album"]),
            body: ListView(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: SizedBox.square(
                        dimension: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image(
                            image: snapshot.data![0]["album_art"],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            snapshot.data![0]["album"],
                            style: HugeAlbumTitle,
                          ),
                          Text(snapshot.data![0]["album_artist"], style: AlbumNameInAlbumTile),
                          const SizedBox.square(dimension: 20),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (snapshot.data![0]["id"] != -1) {
                                    List<int> toAdd = [];
                                    for (var item in snapshot.data!) {
                                      toAdd.add(item["id"] as int);
                                    }
                                    Provider.of<Data>(context, listen: false).addSongsToQueueAndPlay(toAdd);
                                  }
                                },
                                icon: const Icon(Icons.play_arrow),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (snapshot.data![0]["id"] != -1) {
                                    List<int> toAdd = [];
                                    for (var item in snapshot.data!) {
                                      toAdd.add(item["id"] as int);
                                    }
                                    Provider.of<Data>(context, listen: false).addSongsToQueueShuffledAndPlay(toAdd);
                                  }
                                },
                                icon: const Icon(Icons.shuffle),
                              ),
                              PopupMenuButton(
                                onSelected: (value) {
                                  switch (value) {
                                    case 0:
                                      if (snapshot.data![0]["id"] != -1) {
                                        List<int> toAdd = [];
                                        for (var item in snapshot.data!) {
                                          toAdd.add(item["id"] as int);
                                        }
                                        Provider.of<Data>(context, listen: false).addSongsToQueue(toAdd);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added ${toAdd.length} songs to queue."),));
                                      }
                                      break;
                                    case 1:
                                      if (snapshot.data![0]["id"] != -1) {
                                        List<int> toAdd = [];
                                        for (var item in snapshot.data!) {
                                          toAdd.add(item["id"] as int);
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added ${toAdd.length} songs to queue."),));
                                        Provider.of<Data>(context, listen: false).addSongsToQueueShuffled(toAdd);
                                      }
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 0,
                                    child: Text("Add to Queue"),
                                  ),
                                  const PopupMenuItem(
                                    value: 1,
                                    child: Text("Add to Queue Shuffled"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                for (var item in snapshot.data!)
                  AlbumSongTile(
                    song_id: item["id"],
                    disc_number: item["disc_number"],
                    track_number: item["track_number"],
                    song_name: item["title"],
                    contributing_artists: item["contributing_artists"],
                  )
              ],
            ),
            bottomNavigationBar: const Console(),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
