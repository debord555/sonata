import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/console.dart';
import 'package:sonata/custom_widgets/custom_text.dart';
import 'package:sonata/custom_widgets/stacked_screen_appbar.dart';
import 'package:sonata/custom_widgets/tiles/playlist_entry_tile.dart';
import 'package:sonata/misc/constants.dart';
import 'package:provider/provider.dart';

class PlaylistViewScreen extends StatefulWidget {
  final int playlist_id;
  final String playlist_name;
  final int num_songs;
  final Function updatePlaylistDetails;

  const PlaylistViewScreen({super.key, required this.playlist_id, required this.playlist_name, required this.num_songs, required this.updatePlaylistDetails});

  @override
  State<PlaylistViewScreen> createState() => _PlaylistViewScreenState();
}

class _PlaylistViewScreenState extends State<PlaylistViewScreen> {
  late Future<List<Map<String, dynamic>>> future_playlist_entries;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    future_playlist_entries = DbHelper.instance.getPlaylistEntries(widget.playlist_id);
  }

  void updatePlaylistEntries() {
    setState(() {
      future_playlist_entries = DbHelper.instance.getPlaylistEntries(widget.playlist_id);
    });
    widget.updatePlaylistDetails();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future_playlist_entries,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print("x");
          return Scaffold(
            appBar: StackedScreenAppbar(widget.playlist_name),
            body: ListView(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: SizedBox.square(
                        dimension: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: const Image(
                            image: AssetImage("assets/images/playlist_art.jpg"),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          widget.playlist_name,
                          style: HugeAlbumTitle,
                        ),
                        Text("${snapshot.data!.length} songs", style: AlbumNameInAlbumTile),
                        const SizedBox.square(dimension: 20),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (snapshot.data![0]["song_id"] != -1) {
                                  List<int> toAdd = [];
                                  for (var item in snapshot.data!) {
                                    toAdd.add(item["song_id"] as int);
                                  }
                                  Provider.of<Data>(context, listen: false).addSongsToQueueAndPlay(toAdd);
                                }
                              },
                              icon: const Icon(Icons.play_arrow),
                            ),
                            IconButton(
                              onPressed: () {
                                if (snapshot.data![0]["song_id"] != -1) {
                                  List<int> toAdd = [];
                                  for (var item in snapshot.data!) {
                                    toAdd.add(item["song_id"] as int);
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
                                    if (snapshot.data![0]["song_id"] != -1) {
                                      List<int> toAdd = [];
                                      for (var item in snapshot.data!) {
                                        toAdd.add(item["song_id"] as int);
                                      }
                                      Provider.of<Data>(context, listen: false).addSongsToQueue(toAdd);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Added ${toAdd.length} songs to queue."),
                                      ));
                                    }
                                    break;
                                  case 1:
                                    if (snapshot.data![0]["song_id"] != -1) {
                                      List<int> toAdd = [];
                                      for (var item in snapshot.data!) {
                                        toAdd.add(item["song_id"] as int);
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Added ${toAdd.length} songs to queue."),
                                      ));
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
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                for (var item in snapshot.data!)
                  PlaylistEntryTile(
                    playlist_entry_id: item["id"],
                    playlist_id: widget.playlist_id,
                    song_id: item["song_id"],
                    updatePlaylistEntries: updatePlaylistEntries,
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
