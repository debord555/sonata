import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/console.dart';
import 'package:sonata/custom_widgets/custom_text.dart';
import 'package:sonata/custom_widgets/screens/album_view_screen.dart';
import 'package:sonata/custom_widgets/stacked_screen_appbar.dart';
import 'package:sonata/custom_widgets/tiles/song_tile.dart';
import 'package:sonata/misc/constants.dart';

class ArtistViewScreen extends StatefulWidget {
  final artist_id;
  const ArtistViewScreen({super.key, this.artist_id});

  @override
  State<ArtistViewScreen> createState() => _ArtistViewScreenState();
}

class _ArtistViewScreenState extends State<ArtistViewScreen> {
  late Future<Map<String, dynamic>> future_artist_full_data;
  @override
  void initState() {
    future_artist_full_data = DbHelper.instance.getArtistFullData(widget.artist_id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future_artist_full_data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> toDraw = [];
          toDraw.add(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: SizedBox.square(
                    dimension: 200,
                    child: CircleAvatar(
                      foregroundImage: snapshot.data!["artist_art"],

                      //borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        snapshot.data!["name"],
                        style: HugeAlbumTitle,
                      ),
                      Text("${snapshot.data!["artist_song_ids"].length} songs, ${snapshot.data!["artist_album_ids"].length} albums",
                          style: AlbumNameInAlbumTile),
                      const SizedBox.square(dimension: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
          // print("Added base scaffold!");
          if (snapshot.data!["artist_album_ids"].isNotEmpty) {
            toDraw.add(
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 0, 8),
                child: Text(
                  "Albums",
                  style: TextStyle(fontSize: 36),
                ),
              ),
            );
            toDraw.add(
              SizedBox(
                height: 250,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1.25,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  shrinkWrap: false,
                  itemBuilder: (builder, index) => AlbumViewTileInArtistView(album_id: snapshot.data!["artist_album_ids"][index]),
                  itemCount: snapshot.data!["artist_album_ids"].length,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            );
          }
          if (snapshot.data!["artist_song_ids"].isNotEmpty) {
            toDraw.add(
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 0, 8),
                child: Text(
                  "Songs",
                  style: TextStyle(fontSize: 36),
                ),
              ),
            );
            for (int i = 0; i < snapshot.data!["artist_song_ids"].length; i++) {
              toDraw.add(SongTile(snapshot.data!["artist_song_ids"][i]));
            }
          }
          toDraw.add(const SizedBox.square(dimension: 32,));
          // print("Added album stuff");
          return Scaffold(
            appBar: StackedScreenAppbar(snapshot.data!["name"]),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: toDraw,
                ),
              ),
            ),
            bottomNavigationBar: const Console(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class AlbumViewTileInArtistView extends StatelessWidget {
  final int album_id;
  const AlbumViewTileInArtistView({super.key, required this.album_id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DbHelper.instance.getAlbum(album_id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AlbumViewScreen(album_id)));
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: snapshot.data!["album_art"],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: CustomText(
                    snapshot.data!["title"],
                    style: AlbumNameInAlbumTile,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
