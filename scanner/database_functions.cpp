#include <unordered_set>
#include <filesystem>

#include "database_functions.hpp"
#include "tag_functions.hpp"
#include "misc.hpp"
#include "trie.hpp"

/**
 * @brief Creates a new SQLite database file at the given path, and creates
 *        tables within it according to TABLE_CREATION_SQL.
 *
 * @details This function will also delete any existing data within the
 *          database, if it already exists.
 *
 * @param[in] db_path The path to the database file to be created.
 *
 * @return 0 on success, -1 on failure.
 */
int createDatabase(const char *db_path)
{
    sqlite3 *db;
    int rc;

    rc = sqlite3_open(db_path, &db);
    if (rc != SQLITE_OK)
    {
        log("Can't open database %s: %s\n", db_path, sqlite3_errmsg(db));
        sqlite3_close(db);
        return -1;
    }

    // The following code is to fully delete the data within the database, if anything exists.
    sqlite3_db_config(db, SQLITE_DBCONFIG_RESET_DATABASE, 1, 0);
    sqlite3_exec(db, "VACUUM", 0, 0, 0);
    sqlite3_db_config(db, SQLITE_DBCONFIG_RESET_DATABASE, 0, 0);

    // Creating tables
    if (createTables(db) != 0)
    {
        log("Unable to create tables for new database @ %s\n", db_path);
        sqlite3_close(db);
        return -1;
    }
    log("Database with tables created successfully @ %s\n", db_path);
    sqlite3_close(db);
    return 0;
}

/**
 * @brief Creates all tables needed for the database, according to the
 *        k_create array of strings.
 *
 * @details This function should be called after a database has been created
 *          with createDatabase.
 *
 * @param[in] db The database to create tables in.
 *
 * @return 0 on success, -1 on failure.
 */
int createTables(sqlite3 *db)
{
    int rc, i;
    char *error_message;
    const char *k_create[] = {
        "CREATE TABLE Albums ( 	id INTEGER PRIMARY KEY AUTOINCREMENT, 	title VARCHAR(512), 	album_art_location VARCHAR(2048) );",
        "CREATE TABLE Songs ( 	id INTEGER PRIMARY KEY AUTOINCREMENT, 	title VARCHAR(512), 	track_number INTEGER, 	disc_number INTEGER, 	rating SMALLINT DEFAULT 0, 	album_id INTEGER, 	location VARCHAR(2048), 	FOREIGN KEY (album_id) REFERENCES Albums(id) ON DELETE CASCADE );",
        "CREATE TABLE Artists ( 	id INTEGER PRIMARY KEY AUTOINCREMENT, 	name VARCHAR(512), 	description VARCHAR(1024), 	photo_location VARCHAR(2048) );",
        "CREATE TABLE Genres ( 	id INTEGER PRIMARY KEY AUTOINCREMENT, 	name VARCHAR(128) );",
        "CREATE TABLE ContributingArtists ( 	song_id INTEGER, 	artist_id INTEGER, 	PRIMARY KEY (song_id, artist_id), 	FOREIGN KEY (song_id) REFERENCES Songs(id) ON DELETE CASCADE, 	FOREIGN KEY (artist_id) REFERENCES Artists(id) ON DELETE CASCADE);",
        "CREATE TABLE AlbumArtists ( 	album_id INTEGER, 	artist_id INTEGER, 	PRIMARY KEY (album_id, artist_id), 	FOREIGN KEY (album_id) REFERENCES Albums(id) ON DELETE CASCADE, 	FOREIGN KEY (artist_id) REFERENCES Artists(id) ON DELETE CASCADE);",
        "CREATE TABLE SongGenreMap ( 	song_id INTEGER, 	genre_id INTEGER, 	PRIMARY KEY (song_id, genre_id), 	FOREIGN KEY (song_id) REFERENCES Songs(id) ON DELETE CASCADE, 	FOREIGN KEY (genre_id) REFERENCES Genres(id) ON DELETE CASCADE);",
        "CREATE TABLE Playlists ( 	id INTEGER PRIMARY KEY AUTOINCREMENT, 	title VARCHAR(512) );",
        "CREATE TABLE PlaylistSongs ( 	id INTEGER PRIMARY KEY AUTOINCREMENT, 	playlist_id INTEGER, 	song_id INTEGER, 	FOREIGN KEY (playlist_id) REFERENCES Playlists(id) ON DELETE CASCADE, 	FOREIGN KEY (song_id) REFERENCES Songs(id) ON DELETE CASCADE );"};

    for (i = 0; i < 9; i++)
    {
        rc = sqlite3_exec(db, k_create[i], NULL, NULL, &error_message);
        if (rc != SQLITE_OK)
        {
            log("Error while creating table %d: %s\n", i, error_message);
            sqlite3_free(error_message);
        }
    }
    return 0;
}

/**
 * @brief Retrieves the id of an entity from the database, or creates it if it does not exist.
 *
 * @details This function is used to get the id of an entity from the database. If the entity does
 *          not exist, it will create it.
 *
 * @param[in] db The database to query.
 * @param[in] entity_type The type of entity to query for.
 * @param[in] entity_name The name of the entity to query for.
 *
 * @return The id of the entity. If the entity does not exist and cannot be created, -1 is returned.
 */
int getEntityId(sqlite3 *db, EntityType entity_type, const std::string &entity_name)
{
    int entity_id = 0, rc;
    char *sql_stmt, *error_message;
    const char *table_name, *column_name;

    switch (entity_type)
    {
    case EntityType::Album:
        table_name = "Albums";
        column_name = "title";
        break;
    case EntityType::Artist:
        table_name = "Artists";
        column_name = "name";
        break;
    case EntityType::Genre:
        table_name = "Genres";
        column_name = "name";
        break;
    default:
        return -1;
    }

    // Try to find entity id
    sql_stmt = sqlite3_mprintf("SELECT id FROM %s WHERE %s = \"%s\";", table_name, column_name, escapeDQ(entity_name).c_str());
    rc = sqlite3_exec(db, sql_stmt, &__getEntityIdInternalCallback, &entity_id, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Error while executing query to get %s id of %s: %s\n", table_name, entity_name.c_str(), error_message);
        sqlite3_free(sql_stmt);
        sqlite3_free(error_message);
        return -1;
    }
    sqlite3_free(sql_stmt);

    // If entity does not exist, create it
    if (entity_id == 0)
    {
        // Creating the entity
        sql_stmt = sqlite3_mprintf("INSERT INTO %s (id, %s) VALUES (NULL, \"%s\");", table_name, column_name, escapeDQ(entity_name).c_str());
        rc = sqlite3_exec(db, sql_stmt, NULL, NULL, &error_message);
        if (rc != SQLITE_OK)
        {
            log("Error while executing query to create %s %s: %s\n", table_name, entity_name.c_str(), error_message);
            sqlite3_free(sql_stmt);
            sqlite3_free(error_message);
            return -1;
        }
        sqlite3_free(sql_stmt);
        // Getting the entity id, after it has been created
        sql_stmt = sqlite3_mprintf("SELECT id FROM %s WHERE %s = \"%s\";", table_name, column_name, escapeDQ(entity_name).c_str());
        rc = sqlite3_exec(db, sql_stmt, &__getEntityIdInternalCallback, &entity_id, &error_message);
        if (rc != SQLITE_OK)
        {
            log("Error while executing query to get %s id (after creating) of %s: %s\n", table_name, entity_name.c_str(), error_message);
            sqlite3_free(sql_stmt);
            sqlite3_free(error_message);
            return -1;
        }
        sqlite3_free(sql_stmt);
    }

    return entity_id;
}

/**
 * Internal callback for getArtistId.
 *
 * This function is used as a callback for a SQLite query. It takes the result
 * of the query and stores it in the id parameter, which is a pointer to an int.
 *
 * \param id The id to store the result in.
 * \param argc The number of columns in the result.
 * \param argv The result of the query.
 * \param column_names The names of the columns.
 *
 * \return 0
 */
int __getEntityIdInternalCallback(void *id, int argc, char **argv, char **column_names)
{
    if (argc > 0)
        *(int *)id = atoi(argv[0]);
    return 0;
}

/**
 * @brief Finds the id of an album with the given name and artist ids in the
 *        database.
 *
 * @details This function will first try to find an album with the given name
 *          and artist ids. If no such album exists, it will create one.
 *
 * @param[in] db The SQLite database to query.
 * @param[in] album_name The name of the album to find.
 * @param[in] artist_ids The ids of the artists of the album to find.
 *
 * @return The id of the album if found, -1 if an error occurred.
 */
int getAlbumId(sqlite3 *db, const std::string &album_name, std::vector<int> &artist_ids)
{
    int rc, album_id = 0;
    char *sql_stmt, *error_message;

    std::string artist_ids_string = escapeDQ(stringifyIntVector(artist_ids));

    sql_stmt = sqlite3_mprintf("SELECT A.id FROM Albums A, AlbumArtists B, Artists C WHERE A.title = \"%s\" AND A.id = B.album_id AND B.artist_id = C.id AND C.id IN %s GROUP BY A.id HAVING COUNT(DISTINCT C.id) = ( SELECT COUNT(DISTINCT D.id) FROM Artists D WHERE D.id IN %s );", escapeDQ(album_name).c_str(), artist_ids_string.c_str(), artist_ids_string.c_str());
    rc = sqlite3_exec(db, sql_stmt, &__getEntityIdInternalCallback, &album_id, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Error while executing query to get album id of %s: %s (Query was %s)\n", album_name.c_str(), error_message, sql_stmt);
        sqlite3_free(sql_stmt);
        sqlite3_free(error_message);
        return -1;
    }
    sqlite3_free(sql_stmt);

    if (album_id == 0)
    {
        sql_stmt = sqlite3_mprintf("INSERT INTO Albums (id, title) VALUES (NULL, \"%s\");", escapeDQ(album_name).c_str());
        rc = sqlite3_exec(db, sql_stmt, NULL, NULL, &error_message);
        if (rc != SQLITE_OK)
        {
            log("Error while executing query to create album %s: %s\n", album_name.c_str(), error_message);
            sqlite3_free(sql_stmt);
            sqlite3_free(error_message);
            return -1;
        }
        sqlite3_free(sql_stmt);

        sql_stmt = sqlite3_mprintf("SELECT id FROM Albums WHERE ROWID = %d;", sqlite3_last_insert_rowid(db));
        rc = sqlite3_exec(db, sql_stmt, &__getEntityIdInternalCallback, &album_id, &error_message);
        if (rc != SQLITE_OK)
        {
            log("Error while executing query to get album id (after creating) of %s: %s\n", escapeDQ(album_name).c_str(), error_message);
            sqlite3_free(sql_stmt);
            sqlite3_free(error_message);
            return -1;
        }
        sqlite3_free(sql_stmt);

        for (int i = 0; i < artist_ids.size(); i++)
            addAlbumArtistRelationship(db, album_id, artist_ids[i]);
    }

    return album_id;
}

/**
 * Converts a vector of integers to a string.
 *
 * The string is a comma separated list of the integers, enclosed in
 * parentheses. For example, the vector [1, 2, 3] would be converted to
 * (1, 2, 3).
 *
 * \param[in] vec The vector to convert.
 *
 * \return A string representation of the vector.
 */
std::string stringifyIntVector(std::vector<int> &vec)
{
    std::string result = "(";
    if (vec.size() != 0)
    {
        result += std::to_string(vec[0]);
        for (int i = 1; i < vec.size(); i++)
        {
            result += ", ";
            result += std::to_string(vec[i]);
        }
    }
    result += ")";
    return result;
}

/**
 * @brief Adds a relationship between an album and an artist in the database.
 *
 * @details This function inserts a new row into the AlbumArtists table in the
 *          SQLite database, establishing a relationship between the specified
 *          album and artist. If the operation fails, it logs the error message
 *          and returns -1.
 *
 * @param[in] db A pointer to the SQLite database connection.
 * @param[in] album_id The ID of the album to associate with the artist.
 * @param[in] artist_id The ID of the artist to associate with the album.
 *
 * @return 0 on success, -1 on failure.
 */
int addAlbumArtistRelationship(sqlite3 *db, int album_id, int artist_id)
{
    char *sql_stmt, *error_message;
    sql_stmt = sqlite3_mprintf("INSERT INTO AlbumArtists (album_id, artist_id) VALUES (%d, %d);", album_id, artist_id);
    int rc = sqlite3_exec(db, sql_stmt, NULL, NULL, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Error while executing query to add album artist relationship: %s\n", error_message);
        sqlite3_free(sql_stmt);
        sqlite3_free(error_message);
        return -1;
    }
    sqlite3_free(sql_stmt);
    return 0;
}

/**
 * @brief Adds a song to the database, according to the given
 *        metadata object.
 *
 * @details This function adds a song to the database, given the metadata.
 *          It completely adds all information, like album, artists, genres, etc.
 *
 * @param[in] db A pointer to the SQLite database connection.
 * @param[in] metadata The metadata for the song to add.
 *
 * @return 0 on success, -1 on failure.
 */
int addSong(sqlite3 *db, Metadata &metadata, std::string &album_art_directory)
{
    std::vector<int> album_artist_ids, contrib_artist_ids, genre_ids;
    bool error = false;

    for (int i = 0; i < metadata.album_artists.size(); i++)
    {
        int id = getEntityId(db, EntityType::Artist, metadata.album_artists[i]);
        if (id != -1)
            album_artist_ids.push_back(id);
        else
            error = true;
    }
    for (int i = 0; i < metadata.contributing_artists.size(); i++)
    {
        int id = getEntityId(db, EntityType::Artist, metadata.contributing_artists[i]);
        if (id != -1)
            contrib_artist_ids.push_back(id);
        else
            error = true;
    }
    for (int i = 0; i < metadata.genres.size(); i++)
    {
        int id = getEntityId(db, EntityType::Genre, metadata.genres[i]);
        if (id != -1)
            genre_ids.push_back(id);
        else
            error = true;
    }

    int album_id = getAlbumId(db, metadata.album, album_artist_ids);
    if (album_id == -1)
    {
        log("Unable to add album %s\n", metadata.album.c_str());
        return -1;
    }
    if (!hasAlbumArt(db, album_id))
    {
        std::string image_location = getImage(metadata.file_location, album_art_directory);
        if (image_location != "")
            addAlbumArt(db, album_id, image_location);
    }
    int song_id = addSongEntryToTable(
        db,
        metadata.title,
        metadata.track_number,
        metadata.disc_number,
        album_id,
        metadata.file_location);
    if (song_id == -1)
    {
        log("Unable to add song %s\n", metadata.file_location.c_str());
        return -1;
    }
    for (auto item : contrib_artist_ids)
        addContribArtistRelationship(db, song_id, item);
    for (auto item : genre_ids)
        addSongGenreRelationship(db, song_id, item);

    if (errno)
        return -2;
    else
        return 0;
}

/**
 * @brief Adds a song entry to the database.
 *
 * @details This function will create a new entry in the Songs table with the
 *          given title, track number, disc number, album id, and location.
 *
 * @param[in] db The SQLite database to add the song entry to.
 * @param[in] title The title of the song.
 * @param[in] track_number The track number of the song.
 * @param[in] disc_number The disc number of the song.
 * @param[in] album_id The id of the album the song belongs to.
 * @param[in] location The file location of the song.
 *
 * @return The id of the newly created song entry, or -1 on failure.
 */
int addSongEntryToTable(
    sqlite3 *db,
    std::string title,
    int track_number,
    int disc_number,
    int album_id,
    std::string location)
{
    char *sql_stmt, *error_message;
    int song_id;

    sql_stmt = sqlite3_mprintf("INSERT INTO Songs (title, track_number, disc_number, album_id, location) VALUES (\"%s\", %d, %d, %d, \"%s\");", escapeDQ(title).c_str(), track_number, disc_number, album_id, escapeDQ(location).c_str());
    int rc = sqlite3_exec(db, sql_stmt, NULL, NULL, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Unable to insert song entry of %s : %s | query was %s\n", location.c_str(), error_message, sql_stmt);
        sqlite3_free(error_message);
        sqlite3_free(sql_stmt);
        return -1;
    }
    sqlite3_free(sql_stmt);

    sql_stmt = sqlite3_mprintf("SELECT id FROM Songs WHERE ROWID = %d;", sqlite3_last_insert_rowid(db));
    rc = sqlite3_exec(db, sql_stmt, __getEntityIdInternalCallback, &song_id, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Unable to find song id after insertion of %s : %s\n", location.c_str(), error_message);
        sqlite3_free(error_message);
        sqlite3_free(sql_stmt);
        return -1;
    }

    return song_id;
}

/**
 * @brief Adds a contributing artist to a song in the database.
 *
 * @details This function takes a song id and an artist id and adds an entry to
 *          the ContributingArtists table. This table is used to keep track of which
 *          songs an artist contributed to.
 *
 * @param[in] db The database to query.
 * @param[in] song_id The id of the song to associate with the artist.
 * @param[in] artist_id The id of the artist to associate with the song.
 *
 * @return 0 on success, -1 on failure.
 */
int addContribArtistRelationship(sqlite3 *db, int song_id, int artist_id)
{
    char *sql_stmt, *error_message;

    sql_stmt = sqlite3_mprintf("INSERT INTO ContributingArtists(song_id, artist_id) VALUES (%d, %d);", song_id, artist_id);
    int rc = sqlite3_exec(db, sql_stmt, NULL, NULL, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Error while executing query to add contrib artist relationship: %s\n", error_message);
        sqlite3_free(sql_stmt);
        sqlite3_free(error_message);
        return -1;
    }
    sqlite3_free(sql_stmt);
    return 0;
}

/**
 * @brief Adds a relationship between a song and a genre in the database.
 *
 * @details This function inserts a new row into the SongGenreMap table in the
 *          SQLite database, establishing a relationship between the specified
 *          song and genre. If the operation fails, it logs the error message
 *          and returns -1.
 *
 * @param[in] db A pointer to the SQLite database connection.
 * @param[in] song_id The ID of the song to associate with the genre.
 * @param[in] genre_id The ID of the genre to associate with the song.
 *
 * @return 0 on success, -1 on failure.
 */
int addSongGenreRelationship(sqlite3 *db, int song_id, int genre_id)
{
    char *sql_stmt, *error_message;

    sql_stmt = sqlite3_mprintf("INSERT INTO SongGenreMap(song_id, genre_id) VALUES (%d, %d);", song_id, genre_id);
    int rc = sqlite3_exec(db, sql_stmt, NULL, NULL, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Error while executing query to add song genre relationship: %s\n", error_message);
        sqlite3_free(sql_stmt);
        sqlite3_free(error_message);
        return -1;
    }
    sqlite3_free(sql_stmt);
    return 0;
}

/**
 * @brief Checks if an album has an album art.
 *
 * @details This function will execute a query to check if the album with the
 *          specified id has an album art associated with it. It will return
 *          true if the album has an album art, and false otherwise.
 *
 * @param[in] db A pointer to the SQLite database connection.
 * @param[in] album_id The id of the album to check.
 *
 * @return True if the album has an album art, false otherwise. Also true in case of error.
 */
bool hasAlbumArt(sqlite3 *db, int album_id)
{
    char *sql_stmt, *error_message;
    int answer = 0;
    sql_stmt = sqlite3_mprintf("SELECT 1 FROM Albums WHERE album_art_location IS NOT NULL AND id = %d;", album_id);
    int rc = sqlite3_exec(db, sql_stmt, &__getEntityIdInternalCallback, &answer, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Error while executing query to check if album has art: %s\n", error_message);
        sqlite3_free(sql_stmt);
        sqlite3_free(error_message);
        return true;
    }
    sqlite3_free(sql_stmt);
    return answer == 1;
}

/**
 * @brief Adds an album art location to the database.
 *
 * @details This function will add the location of an album art to the database
 *          for the album with the given id.
 *
 * @param[in] db A pointer to the SQLite database connection.
 * @param[in] album_id The id of the album to add the album art to.
 * @param[in] album_art_location The location of the album art. (this is just the filename)
 *
 * @return 0 on success, -1 on failure.
 */
int addAlbumArt(sqlite3 *db, int album_id, std::string album_art_location)
{
    char *sql_stmt, *error_message;
    sql_stmt = sqlite3_mprintf("UPDATE Albums SET album_art_location = \"%s\" WHERE id = %d;", album_art_location.c_str(), album_id);
    int rc = sqlite3_exec(db, sql_stmt, NULL, NULL, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Error while executing query to add album art: %s\n", error_message);
        sqlite3_free(sql_stmt);
        sqlite3_free(error_message);
        return -1;
    }
    sqlite3_free(sql_stmt);
    return 0;
}

std::unordered_set<std::filesystem::path> getFileLocations(sqlite3 *db)
{
    std::unordered_set<std::filesystem::path> result;
    char *sql_stmt, *error_message;
    sql_stmt = sqlite3_mprintf("SELECT location FROM Songs;");
    int rc = sqlite3_exec(db, sql_stmt, &__getFilesCallback, &result, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Error while executing query to get files: %s\n", error_message);
        sqlite3_free(sql_stmt);
        sqlite3_free(error_message);
        return {};
    }
    sqlite3_free(sql_stmt);
    return result;
}

int __getFilesCallback(void *data, int argc, char **argv, char **colnames)
{
    std::unordered_set<std::filesystem::path> *ptr = (std::unordered_set<std::filesystem::path> *)data;
    if (argc > 0)
        ptr->insert(std::filesystem::path(std::string(argv[0])));
    return 0;
}

int deleteSongByLocation(sqlite3 *db, const std::string &location)
{
    char *sql_stmt, *error_message;
    sql_stmt = sqlite3_mprintf("DELETE FROM Songs WHERE location = \"%s\";", escapeDQ(location).c_str());
    int rc = sqlite3_exec(db, sql_stmt, NULL, NULL, &error_message);
    if (rc != SQLITE_OK)
    {
        log("Error while executing query to delete song: %s\n", error_message);
        sqlite3_free(sql_stmt);
        sqlite3_free(error_message);
        return -1;
    }
    sqlite3_free(sql_stmt);
    return 0;
}

int deleteUselessAlbums(sqlite3 *db)
{
    char *error_message;

    if (sqlite3_exec(
            db,
            "DELETE FROM Albums WHERE id NOT IN (SELECT album_id FROM Songs);",
            NULL,
            NULL,
            &error_message) != SQLITE_OK)
    {
        log("Error while executing query to delete useless albums: %s\n", error_message);
        sqlite3_free(error_message);
        return -1;
    }

    return 0;
}

int deleteUselessArtists(sqlite3 *db)
{
    char *error_message;

    if (sqlite3_exec(
            db,
            "DELETE FROM Artists WHERE id NOT IN (SELECT artist_id FROM ContributingArtists UNION ALL SELECT artist_id FROM AlbumArtists);",
            NULL,
            NULL,
            &error_message) != SQLITE_OK)
    {
        log("Error while executing query to delete useless artists: %s\n", error_message);
        sqlite3_free(error_message);
        return -1;
    }

    return 0;
}

int deleteUselessGenres(sqlite3 *db)
{
    char *error_message;

    if (sqlite3_exec(
            db,
            "DELETE FROM Genres WHERE id NOT IN (SELECT genre_id FROM SongGenreMap);",
            NULL,
            NULL,
            &error_message) != SQLITE_OK)
    {
        log("Error while executing query to delete useless genres: %s\n", error_message);
        sqlite3_free(error_message);
        return -1;
    }

    return 0;
}

int deleteUselessAlbumArt(sqlite3 *db, std::string &album_art_directory)
{
    std::list<std::string> album_art_locations;
    char *error_message;

    if (sqlite3_exec(db, "SELECT album_art_location FROM Albums;", &__getAlbumArtLocationsCallback, &album_art_locations, &error_message) != SQLITE_OK)
    {
        log("Error while executing query to get album art locations: %s\n", error_message);
        sqlite3_free(error_message);
        return -1;
    }

    std::unordered_set<std::filesystem::path> required_files;

    for (auto &item : album_art_locations)
        required_files.insert(std::filesystem::path(album_art_directory) / std::filesystem::path(item));

    std::list<std::string> current_files = getFiles(album_art_directory);

    for (std::list<std::string>::iterator it = current_files.begin(); it != current_files.end();)
    {
        std::filesystem::path current_file = std::filesystem::path(*it);
        if (required_files.find(current_file) != required_files.end())
            it = current_files.erase(it);
        else
            ++it;
    }

    for (std::string location : current_files)
    {
        std::remove(
            (std::filesystem::path(album_art_directory) / std::filesystem::path(location))
                .generic_u8string()
                .c_str());
    }

    return 0;
}

int __getAlbumArtLocationsCallback(void *data, int argc, char **argv, char **colnames)
{
    std::list<std::string> *ptr = (std::list<std::string> *)data;
    if (argc > 0 && argv[0] != nullptr)
        ptr->push_back(std::string(argv[0]));
    return 0;
}