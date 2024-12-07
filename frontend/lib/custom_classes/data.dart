import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/src/utf8.dart';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/misc/constants.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

class Data extends ChangeNotifier {
  int screen = HOME_SCREEN;
  int current_playing_id = -1;
  bool playing = false;
  bool shuffle = false;
  int repeat = 0;
  int current_playing_index = -1;
  int index_to_play_next = -1;
  List<int> song_ids = [];
  List<int> album_ids = [];
  List<int> artist_ids = [];
  List<int> now_playing_queue = [];
  List<bool> already_played = [];
  List<int> rewind_stack = [];
  List<int> playlist_ids = [];
  List<int> genre_ids = [];
  late AudioPlayer player;
  List<String> search_paths = [];
  int themeMode = 0;

  Data() {
    // print("Constructed Data");
    player = AudioPlayer();
    player.positionStream.listen((position) {
      if (position == player.duration) {
        // print("Playing completed!");
        tryToPlayNextSong();
      }
    });
    init();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void init() async {
    await readSettings();
    getAllInfo().then(
      (input) {
        // print("No. of songs: ${song_ids.length}");
        // print("No. of albums: ${album_ids.length}");
        // print("No. of artists: ${artist_ids.length}");
      },
    );
  }

  Future<void> readSettings() async {
    String settingsFilePath = join((await getApplicationDocumentsDirectory()).path, "Project DBS", "settings.json");
    try {
      Map<String, dynamic> jsonStuff = jsonDecode(File(settingsFilePath).readAsStringSync());
      List<dynamic> sp = jsonStuff["search_paths"];
      for (var item in sp) {
        search_paths.add(item as String);
      }
      repeat = jsonStuff["repeat"] as int;
      shuffle = jsonStuff["shuffle"] as bool;
      themeMode = jsonStuff["themeMode"] as int;
      if ({-1, 0, 1}.contains(themeMode) == false) {
        throw "Unknown theme integer: $themeMode";
      }
    } catch (e) {
      // print("Error while reading settings: $e");
      search_paths = [];
      repeat = 0;
      shuffle = false;
      themeMode = 0;
    }
    notifyListeners();
  }

  void saveSettings() async {
    String settingsFilePath = join((await getApplicationDocumentsDirectory()).path, "Project DBS", "settings.json");
    try {
      File file = File(settingsFilePath);
      Map<String, dynamic> settingsMap = {
        "search_paths": search_paths,
        "repeat": repeat,
        "shuffle": shuffle,
        "themeMode": themeMode,
      };
      file.writeAsStringSync(jsonEncode(settingsMap));
      // print("Settings saved.");
    } catch (e) {
      // print("Error while saving settings: $e");
    }
  }

  int addSearchPath(String newSearchPath) {
    if (search_paths.contains(newSearchPath)) {
      return -1;
    } else {
      search_paths.add(newSearchPath);
      saveSettings();
      notifyListeners();
      return 0;
    }
  }

  void removeSearchPath(int index) {
    search_paths.removeAt(index);
    saveSettings();
    notifyListeners();
  }

  void setThemeMode(int i) {
    if (i == -1 || i == 0 || i == 1) {
      themeMode = i;
      saveSettings();
      notifyListeners();
    }
  }

  Future<int> getAllInfo() async {
    song_ids = await DbHelper.instance.getSongIds();
    album_ids = await DbHelper.instance.getAlbumIds();
    genre_ids = await DbHelper.instance.getGenreIds();
    artist_ids = await DbHelper.instance.getArtistIds();
    playlist_ids = await DbHelper.instance.getPlaylistIds();
    return 0;
  }

  void updateScreen(int newScreen) {
    screen = newScreen;
    notifyListeners();
  }

  void setCurrentPlayingSongId(int newId) {
    current_playing_id = newId;
    notifyListeners();
  }

  void setPlaying() {
    playing = true;
    notifyListeners();
  }

  void setPaused() {
    playing = false;
    notifyListeners();
  }

  void changeRepeat() {
    repeat = (repeat + 1) % 3;
    notifyListeners();
    saveSettings();
  }

  void toggleShuffle() {
    shuffle = !shuffle;
    notifyListeners();
    saveSettings();
  }

  void setAndPlaySong(int id) async {
    try {
      Map<String, dynamic> info = await DbHelper.instance.getSong(id);
      // print("${info["location"]}");
      if (player.playing) {
        await player.stop();
      }
      player.setFilePath(info["location"]);
      player.play();
      setCurrentPlayingSongId(id);
      DbHelper.instance.increasePlayCount(id);
    } catch (e) {
      // print("Error while playing: $e");
    }
  }

  void addSongsToQueue(List<int> songIds) {
    for (var item in songIds) {
      now_playing_queue.add(item);
      already_played.add(false);
    }
    notifyListeners();
  }

  void deleteSongFromQueue(int toDeleteIndex) {
    now_playing_queue.removeAt(toDeleteIndex);
    already_played.removeAt(toDeleteIndex);
    if (current_playing_index == toDeleteIndex) {
      current_playing_index = -1;
    } else if (toDeleteIndex < current_playing_index) {
      current_playing_index--;
    }
    notifyListeners();
  }

  void addSongsToQueueShuffled(List<int> songIds) {
    Random random = Random();
    while (songIds.isNotEmpty) {
      int index = random.nextInt(songIds.length);
      now_playing_queue.add(songIds[index]);
      already_played.add(false);
      songIds.removeAt(index);
    }
    notifyListeners();
  }

  void addSongsToQueueAndPlay(List<int> songIds) {
    now_playing_queue.clear();
    already_played.clear();
    current_playing_index = -1;
    for (var item in songIds) {
      now_playing_queue.add(item);
      already_played.add(false);
    }
    tryToPlayNextSong();
    notifyListeners();
  }

  void addSongsToQueueShuffledAndPlay(List<int> songIds) {
    now_playing_queue.clear();
    already_played.clear();
    current_playing_index = -1;
    Random random = Random();
    while (songIds.isNotEmpty) {
      int index = random.nextInt(songIds.length);
      now_playing_queue.add(songIds[index]);
      already_played.add(false);
      songIds.removeAt(index);
    }
    tryToPlayNextSong();
    notifyListeners();
  }

  void playSongNext(int songId) {
    addSongsToQueue([songId]);
    index_to_play_next = now_playing_queue.length - 1;
    notifyListeners();
  }

  void playSongNow(int songId) {
    if (current_playing_id != -1) {
      addSongToRewindStack(current_playing_id);
    }
    now_playing_queue.clear();
    already_played.clear();
    addSongsToQueue([songId]);
    current_playing_index = 0;
    already_played[0] = true;
    current_playing_id = songId;
    setAndPlaySong(songId);
    notifyListeners();
  }

  void playQueueEntryNext(int index) {
    index_to_play_next = index;
    notifyListeners();
  }

  void playQueueEntryNow(int index) {
    // print("Queue Now: $now_playing_queue");
    if (current_playing_id != -1) {
      addSongToRewindStack(current_playing_id);
    }
    if (index_to_play_next == index) {
      index_to_play_next = -1;
    }
    current_playing_index = index;
    already_played[index] = true;
    current_playing_id = now_playing_queue[index];
    setAndPlaySong(current_playing_id);
    notifyListeners();
  }

  void tryToPlayNextSong() {
    // print("Trying to play next song.");
    if (now_playing_queue.isEmpty) {
      // print("Queue is empty, so exiting");
      return;
    }
    if (repeat == 1) {
      // print("Repeat is one-track");
      if (current_playing_id != -1) {
        // print("Playing current track again");
        setAndPlaySong(current_playing_id);
      } else {
        // print("No track is playing, so exiting");
      }
      return;
    } else {
      // print("Repeat is not one-track");
      if (index_to_play_next != -1) {
        // print("Playing next-marked track");
        current_playing_index = index_to_play_next;
        current_playing_id = now_playing_queue[index_to_play_next];
        already_played[current_playing_index] = true;
        index_to_play_next = -1;
        setAndPlaySong(current_playing_id);
      } else {
        // print("No track has been marked next");
        if (haveAllBeenPlayed()) {
          // print("All queued tracks were already played");
          if (repeat == 0) {
            // print("Repeat is off, so exiting");
            return;
          } else {
            // print("Repeat is all-track, so clearing played-status, and playing random track.");
            clearPlayedStatus();
            if (shuffle) {
              // print("Shuffle is on, selecting random track from queue");
              current_playing_index = Random().nextInt(now_playing_queue.length);
              playQueueEntryNow(current_playing_index);
            } else {
              // print("Shuffle is off, selecting first track from queue");
              playQueueEntryNow(0);
            }
          }
        } else {
          // print("Some queued tracks still left to play");
          if (shuffle) {
            // print("Shuffle is on, selecting random non-played track from queue");
            index_to_play_next = Random().nextInt(now_playing_queue.length);
            while (already_played[index_to_play_next]) {
              index_to_play_next = Random().nextInt(now_playing_queue.length);
            }
            playQueueEntryNow(index_to_play_next);
          } else {
            // print("Shuffle is off, selecting first non-played track from queue");
            if (current_playing_index == -1) {
              current_playing_index++;
            }
            for (int i = current_playing_index; i < already_played.length; i++) {
              if (!already_played[i]) {
                index_to_play_next = i;
                // print("Playing song id $i");
                playQueueEntryNow(index_to_play_next);
                break;
              }
            }
          }
        }
      }
    }
    notifyListeners();
  }

  void forceTryToPlayNextSong() {
    if (haveAllBeenPlayed()) {
      clearPlayedStatus();
    }
    tryToPlayNextSong();
  }

  void addSongToRewindStack(int songId) {
    rewind_stack.add(songId);
    if (rewind_stack.length > 100) {
      rewind_stack.removeAt(0);
    }
    notifyListeners();
  }

  void clearPlayedStatus() {
    for (int i = 0; i < already_played.length; i++) {
      already_played[i] = false;
    }
  }

  bool haveAllBeenPlayed() {
    for (var item in already_played) {
      if (!item) {
        return false;
      }
    }
    return true;
  }

  void createPlaylist(String title) async {
    await DbHelper.instance.addPlaylist(title);
    playlist_ids = await DbHelper.instance.getPlaylistIds();
    notifyListeners();
  }

  void deletePlaylist(int id) async {
    await DbHelper.instance.deletePlaylist(id);
    playlist_ids = await DbHelper.instance.getPlaylistIds();
    notifyListeners();
  }

  void deletePlaylistEntry(int entryId, int playlistId) async {
    await DbHelper.instance.deletePlaylistEntry(entryId, playlistId);
    notifyListeners();
  }

  void playPreviousSong() {
    if (rewind_stack.isNotEmpty) {
      int toPlay = rewind_stack.removeLast();
      current_playing_id = toPlay;
      current_playing_index = -1;
      setAndPlaySong(toPlay);
      notifyListeners();
    }
  }

  Future<int> update(BuildContext context) async {
    // print("About to update!!");
    final String databaseLocation = join((await getApplicationDocumentsDirectory()).path, "Project DBS", "database.db");
    final String albumArtDirectory = join((await getApplicationDocumentsDirectory()).path, "Project DBS", "album_art");
    final Map<String, dynamic> prejson = {
      "search_paths": search_paths,
      "database_location": databaseLocation,
      "album_art_directory": albumArtDirectory,
    };
    String json = jsonEncode(prejson);
    Pointer<Utf8> inputPtr = json.toNativeUtf8();
    DbHelper.instance.updatorFunction(inputPtr);
    // print("Done updating!");
    getAllInfo();
    notifyListeners();
    return 0;
  }

  void stopPlaying() {
    player.stop();
    player.seek(Duration.zero);
    notifyListeners();
  }
}
