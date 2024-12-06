import 'package:flutter/material.dart';

// Numeric Constants

const int HOME_SCREEN = 0;
const int ALBUM_SCREEN = 1;
const int ARTIST_SCREEN = 2;
const int SONG_SCREEN = 3;
const int GENRE_SCREEN = 4;
const int PLAYLIST_SCREEN = 5;
const int SETTINGS_SCREEN = 6;
const int QUEUE_SCREEN = 7;
const int SEARCH_SCREEN = 8;

// Strings

const List<String> screen_names = ["Sonata Music Player", "Albums", "Artists", "Songs", "Genres", "Playlists", "Settings", "Now Playing", "Search"];

// Text Styles

const TextStyle AlbumNameInAlbumTile = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
);

const TextStyle HugeAlbumTitle = TextStyle(
  fontSize: 48.0,
  fontWeight: FontWeight.bold
);

// SQL Queries below:

const String CREATE_ALL_TABLES = """
CREATE TABLE Albums (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	title VARCHAR(512),
	album_art_location VARCHAR(2048)
);

CREATE TABLE Songs (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	title VARCHAR(512),
	track_number INTEGER,
	disc_number INTEGER,
	rating SMALLINT DEFAULT 0,
	album_id INTEGER,
	location VARCHAR(2048),
  play_count INTEGER DEFAULT 0,
	FOREIGN KEY (album_id) REFERENCES Albums(id) ON DELETE CASCADE
);

CREATE TABLE Artists (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name VARCHAR(512),
	description VARCHAR(1024),
	photo_location VARCHAR(2048)
);

CREATE TABLE Genres (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name VARCHAR(128)
);

CREATE TABLE ContributingArtists (
	song_id INTEGER,
	artist_id INTEGER,
	PRIMARY KEY (song_id, artist_id),
	FOREIGN KEY (song_id) REFERENCES Songs(id) ON DELETE CASCADE,
	FOREIGN KEY (artist_id) REFERENCES Artists(id) ON DELETE CASCADE
);

CREATE TABLE AlbumArtists (
	album_id INTEGER,
	artist_id INTEGER,
	PRIMARY KEY (album_id, artist_id),
	FOREIGN KEY (album_id) REFERENCES Albums(id) ON DELETE CASCADE,
	FOREIGN KEY (artist_id) REFERENCES Artists(id) ON DELETE CASCADE
);

CREATE TABLE SongGenreMap (
	song_id INTEGER,
	genre_id INTEGER,
	PRIMARY KEY (song_id, genre_id),
	FOREIGN KEY (song_id) REFERENCES Songs(id) ON DELETE CASCADE,
	FOREIGN KEY (genre_id) REFERENCES Genres(id) ON DELETE CASCADE
);

CREATE TABLE Playlists (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	title VARCHAR(512)
);

CREATE TABLE PlaylistSongs (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	playlist_id INTEGER,
	song_id INTEGER,
	FOREIGN KEY (playlist_id) REFERENCES Playlists(id) ON DELETE CASCADE,
	FOREIGN KEY (song_id) REFERENCES Songs(id) ON DELETE CASCADE
);


""";

const String CREATE_ALBUMS = "CREATE TABLE Albums ( id INTEGER PRIMARY KEY, title VARCHAR(512), release_year INT );";
const String CREATE_SONGS =
    "CREATE TABLE Songs ( id INTEGER PRIMARY KEY, title VARCHAR(512), track_number INT, disc_number INT, album_id INT, rating SMALLINT DEFAULT -1, location VARCHAR(1024), FOREIGN KEY (album_id) REFERENCES Albums(id) );";
const String CREATE_ARTISTS = "CREATE TABLE Artists ( id INTEGER PRIMARY KEY, artist_name VARCHAR(256), about VARCHAR(10240) );";
const String CREATE_CONTRIBUTING_ARTISTS =
    "CREATE TABLE ContributingArtists ( song_id INT NOT NULL, artist_id INT NOT NULL, PRIMARY KEY (song_id, artist_id), FOREIGN KEY (song_id) REFERENCES Songs(id), FOREIGN KEY (artist_id) REFERENCES Artists(id) );";
const String CREATE_ALBUM_ARTISTS =
    "CREATE TABLE AlbumArtists ( album_id INT NOT NULL, artist_id INT NOT NULL, PRIMARY KEY (album_id, artist_id), FOREIGN KEY (album_id) REFERENCES Albums(id), FOREIGN KEY (artist_id) REFERENCES Artists(id) );";

const String GET_SONG_DATA = """
SELECT S.id, S.title, S.track_number, S.disc_number, A.title AS album, REPLACE(GROUP_CONCAT(DISTINCT AAA.name), ",", ", ") AS album_artist, REPLACE(GROUP_CONCAT(DISTINCT CAA.name), ",", ", ") AS contributing_artists, S.location, A.album_art_location
FROM Songs S, Albums A, Artists AAA, Artists CAA, AlbumArtists AA, ContributingArtists CA
WHERE S.album_id = A.id AND AA.album_id = A.id AND CA.song_id = S.id AND AA.artist_id = AAA.id AND CA.artist_id = CAA.id
GROUP BY S.id;
""";

const String GET_SONG_IDS = "SELECT id FROM Songs ORDER BY title ASC;";

const String GET_SONG_DATA_BY_ID = """
SELECT S.id, S.title, S.track_number, S.disc_number, A.title AS album, REPLACE(GROUP_CONCAT(DISTINCT AAA.name), ",", ", ") AS album_artist, REPLACE(GROUP_CONCAT(DISTINCT CAA.name), ",", ", ") AS contributing_artists, S.location, A.album_art_location, A.id AS album_id
FROM Songs S 
LEFT JOIN Albums A ON S.album_id = A.id
LEFT JOIN AlbumArtists AA ON A.id = AA.album_id
LEFT JOIN ContributingArtists CA ON S.id = CA.song_id
LEFT JOIN Artists CAA ON CA.artist_id = CAA.id
LEFT JOIN Artists AAA ON AA.artist_id = AAA.id
WHERE S.id = ?
GROUP BY S.id;
""";

const String GET_ALBUMS_BY_ID = """
SELECT A.id, A.title, GROUP_CONCAT(AAA.name) AS album_artists, A.album_art_location
FROM Albums A, Artists AAA, AlbumArtists AA
WHERE A.id = AA.album_id AND AA.artist_id = AAA.id AND A.id = ?
GROUP BY A.id;
""";

const String GET_ARTISTS_BY_ID = """
SELECT A.id, A.name, A.description
FROM Artists A WHERE id = ?;
""";

const String GET_ALBUM_SONG_DATA = """
SELECT S.id, S.title, S.track_number, S.disc_number, A.title AS album, REPLACE(GROUP_CONCAT(DISTINCT AAA.name), ",", ", ") AS album_artist, REPLACE(GROUP_CONCAT(DISTINCT CAA.name), ",", ", ") AS contributing_artists, S.location, A.album_art_location
FROM Songs S, Albums A, Artists AAA, Artists CAA, AlbumArtists AA, ContributingArtists CA
WHERE S.album_id = A.id AND AA.album_id = A.id AND CA.song_id = S.id AND AA.artist_id = AAA.id AND CA.artist_id = CAA.id AND A.id = ?
GROUP BY S.id
ORDER BY disc_number ASC, track_number ASC;
""";