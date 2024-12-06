#include <nlohmann/json.hpp>
#include <sqlite3.h>
#include <iostream>
#include <list>
#include <filesystem>

#include "misc.hpp"
#include "tag_functions.hpp"
#include "database_functions.hpp"
#include "project_dbs_ffi.hpp"

int parseInputJSON(nlohmann::json json_input, std::vector<std::string> &search_paths, std::string &database_location, std::string &album_art_directory)
{
    album_art_directory = json_input["album_art_directory"];
    database_location = json_input["database_location"];
    for (std::string path : json_input["search_paths"])
        search_paths.push_back(path);
    return 0;
}

int update(const char *input)
{
    nlohmann::json json_input = nlohmann::json::parse(input);
    std::vector<std::string> search_paths;
    std::string database_location, album_art_directory;
    parseInputJSON(json_input, search_paths, database_location, album_art_directory);

    

    sqlite3 *db;
    if (sqlite3_open(database_location.c_str(), &db) != SQLITE_OK)
    {
        sqlite3_close(db);
        std::cout << "Error while opening database.\n";
        return -1;
    }

    sqlite3_exec(db, "PRAGMA foreign_keys = 1;", NULL, NULL, NULL);

    if (!std::filesystem::exists(std::filesystem::path(album_art_directory)) || !std::filesystem::is_directory(std::filesystem::path(album_art_directory)))
    {
        std::remove(album_art_directory.c_str());
        std::filesystem::create_directory(std::filesystem::path(album_art_directory));
    }

    std::unordered_set<std::filesystem::path> existing = getFileLocations(db);

    std::cout << existing.size() << " files found in database already!" << std::endl;

    std::list<std::string> files;

    for (std::string path : search_paths)
    {
        for (auto &item : getFiles(path))
            files.push_back(item);
    }

    for (std::list<std::string>::iterator it = files.begin(); it != files.end();)
    {
        std::filesystem::path p(*it);
        if (existing.find(p) != existing.end())
        {
            std::cout << "Duplicate file: " << *it << std::endl;
            existing.erase(p);
            it = files.erase(it);
        }
        else
            ++it;
    }

    std::cout << "Scanning " << files.size() << " files." << std::endl;

    for (std::string item : files)
    {
        if (endsWith(item, ".mp3") || endsWith(item, ".flac"))
        {
            Metadata m;
            if (getMetadata(item, m) == 0)
                addSong(db, m, album_art_directory);
        }
    }

    std::cout << "Deleting " << existing.size() << " entries from DB " << std::endl;

    for (std::filesystem::path item : existing)
        deleteSongByLocation(db, item.generic_u8string());

    deleteUselessAlbums(db);
    deleteUselessArtists(db);
    deleteUselessGenres(db);
    //deleteUselessAlbumArt(db, album_art_directory);

    sqlite3_close(db);
    return 0;
}
