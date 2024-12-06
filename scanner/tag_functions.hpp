#pragma once

#include <vector>
#include <string>
#include <iostream>

struct Metadata {
    std::string file_location;
    std::string title;
    std::vector<std::string> contributing_artists;
    std::string album;
    std::vector<std::string> album_artists;
    std::vector<std::string> genres;
    unsigned int track_number;
    unsigned int disc_number;
    unsigned int year;
};

int getMetadata(std::string file_location, Metadata &metadata);
std::ostream &operator<<(std::ostream &s, const Metadata &m);

std::string getImage(std::string file_location, std::string directory);
