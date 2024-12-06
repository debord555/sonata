import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:provider/provider.dart';

void showPlaylistAdditionDialog(BuildContext context, int songId) {
  showDialog(
    context: context,
    builder: (context) => PlaylistAdditionForm(songId),
  );
}

class PlaylistAdditionForm extends StatefulWidget {
  final song_id;
  const PlaylistAdditionForm(this.song_id, {super.key});

  @override
  State<PlaylistAdditionForm> createState() => _PlaylistAdditionFormState();
}

class _PlaylistAdditionFormState extends State<PlaylistAdditionForm> {
  List<int> playlist_ids = [];
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add to Playlist"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemBuilder: (context, index) => FutureBuilder(
            future: DbHelper.instance.getPlaylistDetails(
              Provider.of<Data>(context).playlist_ids[index],
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CheckboxListTile(
                  value: (playlist_ids.contains(snapshot.data!["id"])),
                  title: Text(snapshot.data!["title"]),
                  onChanged: (value) {
                    if (value == null || value == false) {
                      setState(() {
                        playlist_ids.remove(snapshot.data!["id"]);
                      });
                    } else {
                      setState(() {
                        playlist_ids.add(snapshot.data!["id"]);
                      });
                    }
                  },
                );
              } else {
                return CheckboxListTile(
                  value: false,
                  onChanged: (value) {},
                );
              }
            },
          ),
          itemCount: Provider.of<Data>(context).playlist_ids.length,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            for (var item in playlist_ids) {
              DbHelper.instance.addSongToPlaylist(widget.song_id, item);
            }
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
