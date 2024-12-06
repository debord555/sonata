import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/screens/playlist_view_screen.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatefulWidget {
  final int playlist_id;

  const PlaylistTile({required this.playlist_id, super.key});

  @override
  State<PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
  late Future<Map<String, dynamic>> future_playlist_details;

  @override
  void initState() {
    future_playlist_details = DbHelper.instance.getPlaylistDetails(widget.playlist_id);
    super.initState();
  }

  void updatePlaylistDetails() {
    setState(() {
      future_playlist_details = DbHelper.instance.getPlaylistDetails(widget.playlist_id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future_playlist_details,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlaylistViewScreen(
                    playlist_id: widget.playlist_id,
                    playlist_name: snapshot.data!["title"],
                    num_songs: snapshot.data!["num_songs"],
                    updatePlaylistDetails: updatePlaylistDetails,
                  ),
                ),
              );
            },
            leading: const Icon(Icons.playlist_play),
            title: Text(snapshot.data!["title"]),
            subtitle: Text("${snapshot.data!["num_songs"]} songs"),
            trailing: PopupMenuButton(
              onSelected: (value) {
                switch (value) {
                  case 1:
                    Provider.of<Data>(context, listen: false).deletePlaylist(widget.playlist_id);
                    break;
                  default:
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 0,
                  child: Text("Add to Queue"),
                ),
                const PopupMenuItem(
                  value: 1,
                  child: Text("Delete"),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
