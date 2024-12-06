import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/playlist_addition_form.dart';
import 'package:sonata/custom_widgets/screens/album_view_screen.dart';
import 'package:sonata/custom_widgets/screens/artist_view_screen.dart';
import 'package:provider/provider.dart';

enum SearchType { Song, Album, Artist }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchType selected_type = SearchType.Song;
  bool searched = false;
  String search_term = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: TextField(
            onSubmitted: (inputString) {
              setState(() {
                search_term = inputString;
                searched = true;
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Search',
            ),
          ),
        ),
        SegmentedButton(
          onSelectionChanged: (set) {
            setState(() {
              selected_type = set.first;
            });
          },
          segments: const [
            ButtonSegment(
              value: SearchType.Song,
              label: Text('Song'),
            ),
            ButtonSegment(
              value: SearchType.Album,
              label: Text('Album'),
            ),
            ButtonSegment(
              value: SearchType.Artist,
              label: Text('Artist'),
            ),
          ],
          selected: {selected_type},
          multiSelectionEnabled: false,
        ),
        Expanded(
          child: (!searched)
              ? const Center(
                  child: Text("Search for something"),
                )
              : (selected_type == SearchType.Song)
                  ? SongSearchList(search_term: search_term)
                  : (selected_type == SearchType.Album)
                      ? AlbumSearchList(search_term: search_term)
                      : ArtistSearchList(search_term: search_term),
        ),
      ],
    );
  }
}

class AlbumTileHorizontal extends StatelessWidget {
  final int album_id;
  final String album_title;
  final ImageProvider album_art;
  final String album_artists;
  const AlbumTileHorizontal({super.key, required this.album_id, required this.album_title, required this.album_art, required this.album_artists});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AlbumViewScreen(album_id),
          ),
        );
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Image(image: album_art, fit: BoxFit.contain),
      ),
      title: Text(album_title),
      subtitle: Text(album_artists),
    );
  }
}

class AlbumSearchList extends StatelessWidget {
  final String search_term;
  const AlbumSearchList({super.key, required this.search_term});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DbHelper.instance.getAlbumsLike(search_term),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Nothing found!"),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => AlbumTileHorizontal(
              album_id: (snapshot.data![index])["id"],
              album_title: (snapshot.data![index])["title"],
              album_art: (snapshot.data![index])["album_art"],
              album_artists: (snapshot.data![index])["album_artists"],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class SongSearchList extends StatelessWidget {
  final String search_term;
  const SongSearchList({super.key, required this.search_term});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DbHelper.instance.getSongsLike(search_term),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Nothing found!"),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => SongSearchTile(
              song_id: (snapshot.data![index]),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class SongSearchTile extends StatelessWidget {
  final int song_id;
  const SongSearchTile({super.key, required this.song_id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DbHelper.instance.getSong(song_id),
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
            subtitle: Text(snapshot.data!['album'] + " - " + snapshot.data!['album_artist']),
            trailing: PopupMenuButton<int>(
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

class ArtistTileHorizontal extends StatelessWidget {
  final int artist_id;
  const ArtistTileHorizontal({super.key, required this.artist_id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DbHelper.instance.getArtist(artist_id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ArtistViewScreen(artist_id: artist_id)));
            },
            leading: CircleAvatar(
              foregroundImage: snapshot.data!["artist_art"],
            ),
            title: Text("${snapshot.data!["name"]}"),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ArtistSearchList extends StatelessWidget {
  final String search_term;
  const ArtistSearchList({super.key, required this.search_term});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DbHelper.instance.getArtistsLike(search_term),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Nothing found!"),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) => ArtistTileHorizontal(artist_id: snapshot.data![index]),
            itemCount: snapshot.data!.length,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
