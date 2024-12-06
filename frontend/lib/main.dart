import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/console.dart';
import 'package:sonata/custom_widgets/custom_appbar.dart';
import 'package:sonata/custom_widgets/custom_drawer.dart';
import 'package:sonata/custom_widgets/playlist_creation_form.dart';
import 'package:sonata/custom_widgets/screens/album_screen.dart';
import 'package:sonata/custom_widgets/screens/artist_screen.dart';
import 'package:sonata/custom_widgets/screens/home_screen.dart';
import 'package:sonata/custom_widgets/screens/queue_screen.dart';
import 'package:sonata/custom_widgets/screens/search_screen.dart';
import 'package:sonata/custom_widgets/screens/song_screen.dart';
import 'package:sonata/custom_widgets/screens/genre_screen.dart';
import 'package:sonata/custom_widgets/screens/playlist_screen.dart';
import 'package:sonata/custom_widgets/screens/settings_screen.dart';
import 'package:sonata/misc/constants.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.instance.openDb();
  runApp(
    ChangeNotifierProvider<Data>(
      create: (context) => Data(),
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      themeMode: (Provider.of<Data>(context).themeMode == 0)
          ? ThemeMode.system
          : (Provider.of<Data>(context).themeMode == 1)
              ? ThemeMode.light
              : ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData.light(useMaterial3: true),
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: const CustomAppBar(),
          drawer: const CustomDrawer(),
          body: (Provider.of<Data>(context).screen == HOME_SCREEN)
              ? const HomeScreen()
              : (Provider.of<Data>(context).screen == ALBUM_SCREEN)
                  ? const AlbumScreen()
                  : (Provider.of<Data>(context).screen == ARTIST_SCREEN)
                      ? const ArtistScreen()
                      : (Provider.of<Data>(context).screen == SONG_SCREEN)
                          ? const SongScreen()
                          : (Provider.of<Data>(context).screen == SEARCH_SCREEN)
                              ? const SearchScreen()
                              : (Provider.of<Data>(context).screen == PLAYLIST_SCREEN)
                                  ? const PlaylistScreen()
                                  : (Provider.of<Data>(context).screen == QUEUE_SCREEN)
                                      ? const QueueScreen()
                                      : (Provider.of<Data>(context).screen == GENRE_SCREEN)
                                          ? const GenreScreen()
                                          : const SettingsScreen(),
          bottomNavigationBar: const Console(),
          floatingActionButton: Provider.of<Data>(context).screen == PLAYLIST_SCREEN
              ? FloatingActionButton(
                  onPressed: () {
                    showPlaylistCreationForm(context);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      }),
    );
  }
}
