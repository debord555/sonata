import 'package:flutter/material.dart';
import 'package:sonata/custom_widgets/tiles/drawer_item.dart';
import 'package:sonata/misc/constants.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/drawer_art.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Text(
              'Sonata Music',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          DrawerItem(Icons.home_rounded, "Home", HOME_SCREEN),
          DrawerItem(Icons.album_rounded, "Albums", ALBUM_SCREEN),
          DrawerItem(Icons.person_rounded, "Artists", ARTIST_SCREEN),
          DrawerItem(Icons.music_note_rounded, "Songs", SONG_SCREEN),
          DrawerItem(Icons.search_rounded, "Search", SEARCH_SCREEN),
          DrawerItem(Icons.lightbulb, "Genres", GENRE_SCREEN),
          DrawerItem(Icons.playlist_play_rounded, "Playlists", PLAYLIST_SCREEN),
          DrawerItem(Icons.queue_music_rounded, "Now Playing", QUEUE_SCREEN),
          DrawerItem(Icons.settings_rounded, "Settings", SETTINGS_SCREEN),
        ],
      ),
    );
  }
}
