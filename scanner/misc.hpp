#pragma once

#include <vector>
#include <string>
#include <list>

#define LOG_LOCATION "./log.txt"

std::vector<std::string> splitString(const std::string& s);
std::list<std::string> getFiles(std::string root);
void log(const char *fmt, ...);

bool endsWith(const std::string &fullString, const std::string &ending);

std::string escapeDQ(const std::string &s);
