import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/custom_text.dart';
import 'package:sonata/custom_widgets/screens/artist_view_screen.dart';

class ArtistTile extends StatefulWidget {
  final int artist_id;

  const ArtistTile(this.artist_id, {super.key});

  @override
  State<ArtistTile> createState() => _ArtistTileState();
}

class _ArtistTileState extends State<ArtistTile> {
  late Future<Map<String, dynamic>> future_artist_data;

  @override
  void initState() {
    future_artist_data = DbHelper.instance.getArtist(widget.artist_id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future_artist_data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ArtistViewScreen(artist_id: widget.artist_id),
                ),
              );
            },
            child: Card(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: snapshot.data!['artist_art'],
                      radius: 80,
                    ),
                  ),
                  CustomText(snapshot.data!['name']),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
