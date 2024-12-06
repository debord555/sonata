#include "tag_functions.hpp"
#include "misc.hpp"

#include <filesystem>
#include <taglib/tag.h>
#include <taglib/fileref.h>
#include <taglib/tpropertymap.h>
#include <fstream>


/**
 * @brief Gets the metadata of a song from its file location.
 *
 * @details This function reads a music file and extracts its metadata into a
 *          Metadata object. The metadata includes the file location, title,
 *          contributing artists, album, album artists, genres, track number,
 *          disc number, and year.
 *
 * @param[in] file_location The path to the music file.
 * @param[out] metadata The Metadata object to store the extracted metadata.
 *
 * @return 0 on success, -1 on failure.
 */
int getMetadata(std::string file_location, Metadata &metadata)
{
    TagLib::FileRef file_ref(file_location.c_str());
    if (file_ref.isNull())
    {
        log("Could not read metadata from file %s\n", file_location.c_str());
        return -1;
    }
    TagLib::Tag *file_tag = file_ref.tag();
    TagLib::PropertyMap props = file_ref.properties();
    metadata.file_location = std::filesystem::absolute(file_location).generic_string();
    metadata.title = file_tag->title().to8Bit(true);
    metadata.contributing_artists = splitString(file_tag->artist().to8Bit(true));
    metadata.album = file_tag->album().to8Bit(true);
    metadata.album_artists = splitString(props["ALBUMARTIST"].toString().to8Bit(true));
    metadata.genres = splitString(file_tag->genre().to8Bit(true));
    metadata.track_number = file_tag->track();
    metadata.disc_number = props["DISCNUMBER"].toString().toInt();
    metadata.year = file_tag->year();
    if (metadata.title == "")
        metadata.title = "Unknown Song";
    if (metadata.album == "")
        metadata.album = "Unknown Album";
    if (metadata.album_artists.empty())
        metadata.album_artists.push_back("Unknown Artist");
    if (metadata.contributing_artists.empty())
        metadata.contributing_artists.push_back("Unknown Artist");
    if (metadata.genres.empty())
        metadata.genres.push_back("Unknown Genre");
    return 0;
}

std::ostream &operator<<(std::ostream &s, const Metadata &m)
{
    s << "File Location: " << m.file_location << std::endl;
    s << "Title: " << m.title << std::endl;
    s << "Contributing Artists: ";
    for (auto &artist : m.contributing_artists)
        s << artist << ", ";
    s << std::endl;
    s << "Album: " << m.album << std::endl;
    s << "Album Artists: ";
    for (auto &artist : m.album_artists)
        s << artist << ", ";
    s << std::endl;
    s << "Genres: ";
    for (auto &genre : m.genres)
        s << genre << ", ";
    s << std::endl;
    s << "Track Number: " << m.track_number << std::endl;
    s << "Disc Number: " << m.disc_number << std::endl;
    s << "Year: " << m.year << std::endl;
    return s;
}

/**
 * @brief Extracts the embedded image from a music file.
 *
 * @details This function reads a music file and extracts the first embedded image it finds
 *          (if any) from it. The image is saved in a file with a random name
 *          in the given directory.
 *
 * @param[in] file_location The path to the music file.
 * @param[in] directory The directory where the image should be saved.
 *
 * @return The name of the image file, or an empty string if no image was found or error occurred.
 */
std::string getImage(std::string file_location, std::string directory)
{
    TagLib::FileRef file_ref(file_location.c_str());
    if (file_ref.isNull())
    {
        log("Could not read file %s\n", file_location.c_str());
        return "";
    }
    TagLib::StringList complex_property_names = file_ref.complexPropertyKeys();
    for (auto &property_name : complex_property_names)
    {
        if (property_name == "PICTURE")
        {
            TagLib::List<TagLib::VariantMap> property = file_ref.complexProperties(property_name);
            for (TagLib::VariantMap map : property)
            {
                TagLib::ByteVector picture_byte_vector = map["data"].toByteVector();
                std::string random_name = std::to_string(std::rand());
                while (std::filesystem::exists(std::filesystem::path(directory) / std::filesystem::path(random_name)))
                    random_name = std::to_string(std::rand());
                std::ofstream image_file(std::filesystem::path(directory) / std::filesystem::path(random_name), std::ios_base::out | std::ios_base::binary);
                image_file.write(picture_byte_vector.data(), picture_byte_vector.size());
                image_file.close();
                return random_name;
            }
        }
    }
    
    return "";
}

