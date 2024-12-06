import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_widgets/tiles/artist_tile.dart';
import 'package:provider/provider.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int numColumns = (MediaQuery.of(context).size.width / 200).floor();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: numColumns,
          childAspectRatio: 0.9,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) =>
            ArtistTile(Provider.of<Data>(context).artist_ids[index]),
        itemCount: Provider.of<Data>(context).artist_ids.length,
      ),
    );
  }
}
