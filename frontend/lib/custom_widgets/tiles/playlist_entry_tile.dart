import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/screens/album_view_screen.dart';
import 'package:provider/provider.dart';

class PlaylistEntryTile extends StatelessWidget {
  final int playlist_entry_id;
  final int playlist_id;
  final int song_id;
  final Function updatePlaylistEntries;

  const PlaylistEntryTile({super.key, required this.playlist_entry_id, required this.playlist_id, required this.song_id, required this.updatePlaylistEntries});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DbHelper.instance.getSong(song_id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            onTap: () {
              Provider.of<Data>(context, listen: false).playSongNow(snapshot.data!["id"]);
            },
            tileColor: (Provider.of<Data>(context).current_playing_id == snapshot.data!["id"]) ? Theme.of(context).primaryColor.withOpacity(0.2) : null,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image(
                image: snapshot.data!["album_art"],
                fit: BoxFit.contain,
              ),
            ),
            title: Text(snapshot.data!['title']),
            subtitle: Text(snapshot.data!['album'] + " - " + snapshot.data!['album_artist']),
            trailing: PopupMenuButton<int>(
              onSelected: (value) {
                switch (value) {
                  case 0:
                    Provider.of<Data>(context, listen: false).addSongsToQueue([song_id]);
                    break;
                  case 2:
                    Provider.of<Data>(context, listen: false).playSongNow(song_id);
                    break;
                  case 3:
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AlbumViewScreen(snapshot.data!["album_id"])),
                    );
                    break;
                  case 4:
                    Provider.of<Data>(context, listen: false).deletePlaylistEntry(playlist_entry_id, playlist_id);
                    updatePlaylistEntries();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("Add to Queue"),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text("Play Next"),
                ),
                const PopupMenuItem<int>(
                  value: 3,
                  child: Text("View Album"),
                ),
                const PopupMenuItem<int>(
                  value: 4,
                  child: Text("Remove"),
                )
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
