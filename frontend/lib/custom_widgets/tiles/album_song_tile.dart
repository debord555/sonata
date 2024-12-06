import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_widgets/playlist_addition_form.dart';
import 'package:provider/provider.dart';

class AlbumSongTile extends StatelessWidget {
  final int track_number;
  final int disc_number;
  final String song_name;
  final String contributing_artists;
  final int song_id;

  const AlbumSongTile(
      {super.key, required this.track_number, required this.disc_number, required this.song_name, required this.contributing_artists, required this.song_id});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Provider.of<Data>(context, listen: false).playSongNow(song_id);
      },
      leading: const Icon(Icons.music_note),
      title: Text("$disc_number - $track_number  $song_name"),
      subtitle: Text(contributing_artists),
      trailing: PopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 0:
              Provider.of<Data>(context, listen: false).addSongsToQueue([song_id]);
              break;
            case 1:
              showPlaylistAdditionDialog(context, song_id);
              break;
            case 2:
              Provider.of<Data>(context, listen: false).playSongNext(song_id);
              break;
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
        ],
      ),
    );
  }
}
