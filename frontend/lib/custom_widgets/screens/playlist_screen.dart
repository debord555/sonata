import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_widgets/tiles/playlist_tile.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: Provider.of<Data>(context).playlist_ids.length,
      itemBuilder: (context, index) => PlaylistTile(
        playlist_id: Provider.of<Data>(context).playlist_ids[index],
      ),
    );
  }
}
