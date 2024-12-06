#include <sqlite3.h>

#include <list>
#include <string>
#include <unordered_set>
#include <vector>

#include "tag_functions.hpp"

#define CREATE_ALBUMS "CREATE TABLE Albums ( id INTEGER PRIMARY KEY, title VARCHAR(512), release_year INT );"
#define CREATE_SONGS "CREATE TABLE Songs ( id INTEGER PRIMARY KEY, title VARCHAR(512), track_number INT, disc_number INT, album_id INT, rating SMALLINT DEFAULT -1, location VARCHAR(1024), FOREIGN KEY (album_id) REFERENCES Albums(id) );"
#define CREATE_ARTISTS "CREATE TABLE Artists ( id INTEGER PRIMARY KEY, artist_name VARCHAR(256), about VARCHAR(10240) );"
#define CREATE_CONTRIBUTING_ARTISTS "CREATE TABLE ContributingArtists ( song_id INT NOT NULL, artist_id INT NOT NULL, PRIMARY KEY (song_id, artist_id), FOREIGN KEY (song_id) REFERENCES Songs(id), FOREIGN KEY (artist_id) REFERENCES Artists(id) );"
#define CREATE_ALBUM_ARTISTS "CREATE TABLE AlbumArtists ( album_id INT NOT NULL, artist_id INT NOT NULL, PRIMARY KEY (album_id, artist_id), FOREIGN KEY (album_id) REFERENCES Albums(id), FOREIGN KEY (artist_id) REFERENCES Artists(id) );"

enum EntityType {
    Album,
    Artist,
    Genre
};

extern "C" __attribute__((visibility("default"))) __attribute__((used)) int createDatabase(const char *db_path);

int createTables(sqlite3 *db);
int getEntityId(sqlite3 *db, EntityType entity_type, const std::string &artist_name);
int __getEntityIdInternalCallback(void *id, int argc, char **argv, char **column_names);

int getAlbumId(sqlite3 *db, const std::string &album_name, std::vector<int> &artist_ids);

std::string stringifyIntVector(std::vector<int> &vec);

int addAlbumArtistRelationship(sqlite3 *db, int album_id, int artist_id);

int addSong(sqlite3 *db, Metadata &metadata, std::string &album_art_location);

int addSongEntryToTable(sqlite3 *db, std::string title, int track_number, int disc_number, int album_id, std::string location);

int addContribArtistRelationship(sqlite3 *db, int song_id, int artist_id);

int addSongGenreRelationship(sqlite3 *db, int song_id, int genre_id);

bool hasAlbumArt(sqlite3 *db, int album_id);

int addAlbumArt(sqlite3 *db, int album_id, std::string album_art_location);

std::unordered_set<std::filesystem::path> getFileLocations(sqlite3 *db);

int __getFilesCallback(void *data, int argc, char **argv, char **colnames);

int deleteSongByLocation(sqlite3 *db, const std::string &location);

int deleteUselessAlbums(sqlite3 *db);

int deleteUselessArtists(sqlite3 *db);

int deleteUselessGenres(sqlite3 *db);

int deleteUselessAlbumArt(sqlite3 *db, std::string &album_art_directory);

int __getAlbumArtLocationsCallback(void *data, int argc, char **argv, char **colnames);
