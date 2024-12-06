import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/playlist_addition_form.dart';
import 'package:sonata/custom_widgets/screens/album_view_screen.dart';
import 'package:provider/provider.dart';

class SongTile extends StatefulWidget {
  final int song_id;

  SongTile(this.song_id, {super.key});

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  late Future<Map<String, dynamic>> future_song_data;

  @override
  void initState() {
    future_song_data = DbHelper.instance.getSong(widget.song_id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future_song_data,
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
            subtitle: Text(snapshot.data!['album'] + " - " + snapshot.data!['contributing_artists']),
            trailing: PopupMenuButton<int>(
              onSelected: (value) {
                switch (value) {
                  case 0:
                    Provider.of<Data>(context, listen: false).addSongsToQueue([widget.song_id]);
                    break;
                  case 1:
                    showPlaylistAdditionDialog(context, widget.song_id);
                    break;
                  case 2:
                    Provider.of<Data>(context, listen: false).playSongNext(widget.song_id);
                    break;
                  case 3:
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AlbumViewScreen(snapshot.data!["album_id"])),
                    );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("Add to Queue"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("Add to Playlist"),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text("Play Next"),
                ),
                const PopupMenuItem<int>(
                  value: 3,
                  child: Text("View Album"),
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
