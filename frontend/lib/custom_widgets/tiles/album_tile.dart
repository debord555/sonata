import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/custom_text.dart';
import 'package:sonata/custom_widgets/screens/album_view_screen.dart';
import 'package:sonata/misc/constants.dart';

class AlbumTile extends StatefulWidget {
  final int album_id;

  const AlbumTile(this.album_id, {super.key});

  @override
  State<AlbumTile> createState() => _AlbumTileState();
}

class _AlbumTileState extends State<AlbumTile> {
  late Future<Map<String, dynamic>> future_album_data;

  @override
  void initState() {
    future_album_data = DbHelper.instance.getAlbum(widget.album_id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future_album_data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AlbumViewScreen(widget.album_id)),
              );
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: snapshot.data!['album_art'],
                  ),
                  const SizedBox.square(dimension: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: CustomText(
                      snapshot.data!['title'],
                      style: AlbumNameInAlbumTile,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: CustomText(snapshot.data!['album_artists']),
                  ),
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

    // GridTile(
    //   child: Image.asset(
    //     "assets/images/album_placeholder.jpg",
    //     fit: BoxFit.contain,
    //   ),
    //   footer: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text("Album $index"),
    //       Text("Artist $index"),
    //     ],
    //   ),
    // )