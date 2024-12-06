import 'package:flutter/material.dart';
import 'package:sonata/custom_widgets/tiles/song_tile.dart';
import 'package:provider/provider.dart';

import '../../custom_classes/data.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => SongTile(Provider.of<Data>(context).song_ids[index]),
      itemCount: Provider.of<Data>(context).song_ids.length,
    );
  }
}
