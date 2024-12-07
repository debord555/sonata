import 'dart:ffi';
import 'dart:io';
import 'package:ffi/src/utf8.dart';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonata/misc/constants.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

typedef UpdateNativeFunction = Int32 Function(Pointer<Utf8>);
typedef UpdateNative = int Function(Pointer<Utf8>);

class DbHelper {
  static final DbHelper instance = DbHelper._privateConstructor();

  late final DynamicLibrary updator_lib;

  late final updatorFunction;

  Database? database;

  DbHelper._privateConstructor() {
    databaseFactory = databaseFactoryFfi;
  }

  Future<int> openDb() async {
    if (kReleaseMode) {
      // I'm on release mode, absolute linking
      final String localLib = join('data', 'flutter_assets', 'assets', 'libfor_ffi.dll');
      String pathToLib = join(Directory(Platform.resolvedExecutable).parent.path, localLib);
      updator_lib = DynamicLibrary.open(pathToLib);
    } else {
      // I'm on debug mode, local linking
      var path = Directory.current.path;
      updator_lib = DynamicLibrary.open('$path/assets/libfor_ffi.dll');
    }
    updatorFunction = updator_lib.lookupFunction<Int32 Function(Pointer<Utf8>), int Function(Pointer<Utf8>)>("update");
    var directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "Project DBS", "database.db");

    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(CREATE_ALL_TABLES);
        // db.execute(CREATE_SONGS);
        // db.execute(CREATE_ARTISTS);
        // db.execute(CREATE_CONTRIBUTING_ARTISTS);
        // db.execute(CREATE_ALBUM_ARTISTS);
      },
    );
    await database!.rawQuery("PRAGMA foreign_keys = 1;");
    return 0;
  }

  Future<List<Map<String, dynamic>>> getSongs() async {
    return await database!.rawQuery(GET_SONG_DATA);
  }

  Future<List<int>> getSongIds() async {
    var result = await database!.rawQuery(GET_SONG_IDS);
    List<int> ids = [];
    for (var item in result) {
      ids.add(item["id"] as int);
    }
    return ids;
  }

  Future<Map<String, dynamic>> getSong(int id) async {
    var result = await database!.rawQuery(GET_SONG_DATA_BY_ID, [id]);
    if (result.isEmpty) {
      return {
        "id": -1,
        "title": "DELETED",
        "track_number": -1,
        "disc_number": -1,
        "album": "DELETED",
        "album_artist": "DELETED",
        "contributing_artists": "DELETED",
        "location": "DELETED",
        "album_art_location": null,
        "album_art": const AssetImage(
          "assets/images/album_placeholder.jpg",
        ),
        "album_id": -1
      };
    } else {
      Map<String, dynamic> answer = Map<String, dynamic>.from(result[0]);
      if (answer["album_art_location"] == null) {
        answer["album_art"] = const AssetImage(
          "assets/images/album_placeholder.jpg",
        );
      } else {
        try {
          String albumArtAbsoluteLocation = join((await getApplicationDocumentsDirectory()).path, "Project DBS", "album_art", answer["album_art_location"]);
          answer["album_art"] = FileImage(File(albumArtAbsoluteLocation));
        } catch (e) {
          answer["album_art"] = const AssetImage(
            "assets/images/album_placeholder.jpg",
          );
        }
      }
      return answer;
    }
  }

  Future<List<int>> getAlbumIds() async {
    var result = await database!.query("Albums", columns: ["id"], orderBy: "title ASC");
    List<int> answer = [];
    for (var item in result) {
      answer.add(item["id"] as int);
    }
    return answer;
  }

  Future<Map<String, dynamic>> getAlbum(int id) async {
    var result = await database!.rawQuery(GET_ALBUMS_BY_ID, [id]);
    if (result.isEmpty) {
      return {
        "id": -1,
        "title": "DELETED",
        "album_artists": "DELETED",
        "album_art_location": "DELETED",
        "album_art": Image.asset(
          "assets/images/album_placeholder.jpg",
          fit: BoxFit.contain,
        )
      };
    } else {
      Map<String, dynamic> answer = Map<String, dynamic>.from(result[0]);
      if (answer["album_art_location"] == null) {
        answer["album_art"] = Image.asset(
          "assets/images/album_placeholder.jpg",
          fit: BoxFit.contain,
        );
      } else {
        try {
          String albumArtAbsoluteLocation = join((await getApplicationDocumentsDirectory()).path, "Project DBS", "album_art", answer["album_art_location"]);
          answer["album_art"] = Image.file(
            File(albumArtAbsoluteLocation),
            fit: BoxFit.contain,
          );
        } catch (e) {
          answer["album_art"] = Image.asset(
            "assets/images/album_placeholder.jpg",
            fit: BoxFit.contain,
          );
        }
      }
      return answer;
    }
  }

  Future<List<int>> getArtistIds() async {
    var result = await database!.query("Artists", columns: ["id"]);
    List<int> answer = [];
    for (var item in result) {
      answer.add(item["id"] as int);
    }
    return answer;
  }

  Future<Map<String, dynamic>> getArtist(int id) async {
    // print("p");
    var result = await database!.rawQuery(GET_ARTISTS_BY_ID, [id]);

    if (result.isEmpty) {
      return {"id": -1, "name": "DELETED", "description": "DELETED", "artist_art": const AssetImage("assets/images/artist_placeholder.jpg")};
    } else {
      Map<String, dynamic> answer = Map<String, dynamic>.from(result[0]);
      if (answer["photo_location"] == null) {
        answer["artist_art"] = const AssetImage("assets/images/artist_placeholder.jpg");
      } else {
        try {
          String artistArtAbsoluteLocation = join((await getApplicationDocumentsDirectory()).path, "Project DBS", "artist_art", answer["photo_location"]);
          answer["artist_art"] = FileImage(File(artistArtAbsoluteLocation));
        } catch (e) {
          answer["artist_art"] = const AssetImage("assets/images/artist_placeholder.jpg");
        }
      }
      return answer;
    }
  }

  Future<List<Map<String, dynamic>>> getAlbumSongData(int albumId) async {
    List<Map<String, dynamic>> result = await database!.rawQuery(GET_ALBUM_SONG_DATA, [albumId]);

    if (result.isEmpty) {
      return [
        {
          "id": -1,
          "title": "DELETED",
          "track_number": -1,
          "disc_number": -1,
          "album": "DELETED",
          "album_artist": "DELETED",
          "contributing_artists": "DELETED",
          "location": "DELETED",
          "album_art_location": null,
          "album_art": const AssetImage(
            "assets/images/album_placeholder.jpg",
          )
        },
      ];
    } else {
      List<Map<String, dynamic>> answer = [];
      Map<String, dynamic> firstMap = Map<String, dynamic>.from(result[0]);
      if (firstMap["album_art_location"] == null) {
        firstMap["album_art"] = const AssetImage(
          "assets/images/album_placeholder.jpg",
        );
      } else {
        try {
          String albumArtAbsoluteLocation = join((await getApplicationDocumentsDirectory()).path, "Project DBS", "album_art", firstMap["album_art_location"]);
          firstMap["album_art"] = FileImage(File(albumArtAbsoluteLocation));
        } catch (e) {
          firstMap["album_art"] = const AssetImage(
            "assets/images/album_placeholder.jpg",
          );
        }
      }
      answer.add(firstMap);
      for (int i = 1; i < result.length; i++) {
        answer.add(result[i]);
      }
      return answer;
    }
  }

  Future<Map<String, dynamic>> getPlaylistDetails(int playlistId) async {
    var result = await database!.rawQuery("""
      SELECT P.id, P.title, COUNT(DISTINCT PS.id) AS num_songs
      FROM Playlists P LEFT JOIN PlaylistSongs PS ON (P.id = PS.playlist_id)
      WHERE P.id = ?
      GROUP BY P.id;
    """, [playlistId]);
    Map<String, dynamic> answer = (result.isNotEmpty) ? Map<String, dynamic>.from(result[0]) : {"id": -1, "title": "DELETED", "num_songs": -1};
    return answer;
  }

  Future<List<Map<String, dynamic>>> getPlaylistEntries(int playlistId) async {
    var result = await database!.rawQuery("""
      SELECT id, song_id
      FROM PlaylistSongs
      WHERE playlist_id = ?
    """, [playlistId]);
    return result;
  }

  Future<List<int>> getPlaylistIds() async {
    var result = await database!.query("Playlists", columns: ["id"]);
    List<int> answer = [];
    for (var item in result) {
      answer.add(item["id"] as int);
    }
    return answer;
  }

  Future<void> addPlaylist(String title) async {
    await database!.insert("Playlists", {"title": title});
  }

  Future<void> deletePlaylist(int playlistId) async {
    await database!.delete("Playlists", where: "id = ?", whereArgs: [playlistId]);
    await database!.delete("PlaylistSongs", where: "playlist_id = ?", whereArgs: [playlistId]);
  }

  Future<void> deletePlaylistEntry(int entryId, int playlistId) async {
    await database!.delete("PlaylistSongs", where: "playlist_id = ? AND id = ?", whereArgs: [playlistId, entryId]);
  }

  Future<void> addSongToPlaylist(int songId, int playlistId) async {
    await database!.insert("PlaylistSongs", {"playlist_id": playlistId, "song_id": songId});
  }

  Future<List<Map<String, dynamic>>> getAlbumsLike(String name) async {
    var result = await database!.rawQuery("""
      SELECT A.id, A.title, A.album_art_location, REPLACE(GROUP_CONCAT(AA.name), ",", ", ") AS album_artists
      FROM Albums A, Artists AA, AlbumArtists AAA
      WHERE A.id = AAA.album_id AND AA.id = AAA.artist_id AND A.title LIKE ?
      GROUP BY A.id;
    """, ["%$name%"]);
    List<Map<String, dynamic>> answer = [];
    for (var item in result) {
      answer.add(Map<String, dynamic>.from(item));
      answer.last["album_art"] = (item["album_art_location"] == null)
          ? const AssetImage("assets/images/album_placeholder.jpg")
          : FileImage(
              File(
                join(
                  (await getApplicationDocumentsDirectory()).path,
                  "Project DBS",
                  "album_art",
                  item["album_art_location"] as String,
                ),
              ),
            );
    }
    return answer;
  }

  Future<List<int>> getSongsLike(String name) async {
    var result = await database!.rawQuery("""
      SELECT id
      FROM Songs
      WHERE title LIKE ?
    """, ["%$name%"]);
    List<int> answer = [];
    for (var item in result) {
      answer.add(item["id"] as int);
    }

    return answer;
  }

  Future<List<int>> getArtistsLike(String name) async {
    var result = await database!.rawQuery("""
      SELECT id
      FROM Artists
      WHERE name LIKE ?
    """, ["%$name%"]);
    List<int> answer = [];
    for (var item in result) {
      answer.add(item["id"] as int);
    }
    return answer;
  }

  Future<List<Map<String, dynamic>>> getAlbumsArtistAppearsIn(int artistId) async {
    var result = await database!.rawQuery(
      """
      SELECT DISTINCT A.id, A.title, A.album_art_location
      FROM Albums A, Songs S, ContributingArtists CA, AlbumArtists AA, Artists AR
      WHERE ((S.id = CA.song_id AND CA.artist_id = AR.id AND S.album_id = A.id) OR (AA.artist_id = AR.id AND A.id = AA.album_id)) AND AR.id = 4;
      """,
      [artistId],
    );
    List<Map<String, dynamic>> answer = [];
    for (var item in result) {
      answer.add(Map<String, dynamic>.from(item));
      answer.last["album_art"] = (item["album_art_location"] == null)
          ? const AssetImage("assets/images/album_placeholder.jpg")
          : FileImage(
              File(
                join(
                  (await getApplicationDocumentsDirectory()).path,
                  "Project DBS",
                  "album_art",
                  item["album_art_location"] as String,
                ),
              ),
            );
    }
    return answer;
  }

  Future<Map<String, dynamic>> getArtistFullData(int artistId) async {
    var artistInfo = await database!.query("Artists", where: "id = ?", whereArgs: [artistId], limit: 1);
    var artistSongs = await database!.rawQuery(
      """
        SELECT S.id FROM Songs S, ContributingArtists CA
        WHERE S.id = CA.song_id AND CA.artist_id = ?;
      """,
      [artistId],
    );
    var artistAlbums = await database!.rawQuery(
      """
        SELECT id FROM Albums A, AlbumArtists AA WHERE A.id = AA.album_id AND AA.artist_id = ?;
      """,
      [artistId],
    );

    Map<String, dynamic> result = (artistInfo.isNotEmpty)
        ? Map<String, dynamic>.from(artistInfo[0])
        : {
            "id": -1,
            "name": "DELETED",
            "description": "DELETED",
            "photo_location": "DELETED",
            "artist_art": const AssetImage("assets/images/artist_placeholder.jpg"),
          };
    try {
      String artistArtAbsoluteLocation = join((await getApplicationDocumentsDirectory()).path, "Project DBS", "artist_art", result["photo_location"]);
      result["artist_art"] = FileImage(File(result["photo_location"]));
    } catch (e) {
      result["artist_art"] = const AssetImage("assets/images/artist_placeholder.jpg");
    }

    result["artist_song_ids"] = [];
    for (var item in artistSongs) {
      result["artist_song_ids"].add(item["id"] as int);
    }
    result["artist_album_ids"] = [];
    for (var item in artistAlbums) {
      result["artist_album_ids"].add(item["id"] as int);
    }
    return result;
  }

  void increasePlayCount(int songId) async {
    await database!.rawQuery("UPDATE Songs SET play_count = play_count + 1 WHERE id = ?;", [songId]);
  }

  Future<List<int>> getTopSongs(int numSongs) async {
    var result = await database!.rawQuery("SELECT id FROM Songs ORDER BY play_count DESC LIMIT ?;", [numSongs]);
    List<int> answer = [];
    for (var item in result) {
      answer.add(item["id"] as int);
    }
    return answer;
  }

  Future<List<int>> getGenreIds() async {
    var result = await database!.query("Genres", columns: ["id"], orderBy: "name ASC");
    List<int> answer = [];
    for (var item in result) {
      answer.add(item["id"] as int);
    }
    return answer;
  }

  Future<List<int>> getSongIdsOfGenre(int genreId) async {
    var result = await database!.rawQuery("SELECT S.id FROM Songs S, SongGenreMap SGM WHERE S.id = SGM.song_id AND SGM.genre_id = ?;", [genreId]);
    List<int> answer = [];
    for (var item in result) {
      answer.add(item["id"] as int);
    }
    return answer;
  }

  Future<Map<String, dynamic>> getGenreDetails(int genreId) async {
    var result = await database!.rawQuery(
        "SELECT G.name, COUNT(DISTINCT SGM.song_id) AS num_songs FROM Genres G, SongGenreMap SGM WHERE G.id = SGM.genre_id AND G.id = ? GROUP BY G.id;",
        [genreId]);
    return result.isEmpty
        ? {
            "name": "DELETED",
            "num_songs": 0,
          }
        : result[0];
  }
}
