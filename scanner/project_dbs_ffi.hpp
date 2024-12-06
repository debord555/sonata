#pragma once

#include <nlohmann/json.hpp>
#include <string>
#include <vector>

int parseInputJSON(nlohmann::json json_input, std::vector<std::string> &search_paths, std::string &database_location, std::string &album_art_directory);

extern "C" __attribute__((visibility("default"))) __attribute__((used)) int update(const char *input);
