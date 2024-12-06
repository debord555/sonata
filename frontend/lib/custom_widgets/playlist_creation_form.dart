import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:provider/provider.dart';

void showPlaylistCreationForm(BuildContext context) {
  final createPlaylistFunction = Provider.of<Data>(context, listen: false).createPlaylist;
  showDialog(
    context: context,
    builder: (context) => PlaylistCreationForm(createPlaylistFunction),
  );
}

class PlaylistCreationForm extends StatefulWidget {
  final Function onCreatePlaylist;
  const PlaylistCreationForm(this.onCreatePlaylist, {super.key});

  @override
  State<PlaylistCreationForm> createState() => _PlaylistCreationFormState();
}

class _PlaylistCreationFormState extends State<PlaylistCreationForm> {
  final TextEditingController _playlist_name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Playlist"),
      content: Form(
        child: TextFormField(controller: _playlist_name),
      ),
      actions: [
        TextButton(
          onPressed: () => {
            Navigator.of(context).pop(),
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (_playlist_name.text.isNotEmpty) {
              widget.onCreatePlaylist(_playlist_name.text);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Playlist name cannot be empty!"),
                ),
              );
            }
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
