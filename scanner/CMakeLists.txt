CMAKE_MINIMUM_REQUIRED(VERSION 3.25)
PROJECT(project_dbs)

# INCLUDE_DIRECTORIES(C:/taglib/include)
# LINK_DIRECTORIES(C:/taglib/lib)

# ADD_EXECUTABLE(readtag read_tags.cpp tag_functions.cpp misc.cpp)
# TARGET_LINK_LIBRARIES(readtag tag)

# ADD_EXECUTABLE(test test.cpp tag_functions.cpp trie.cpp database_functions.cpp misc.cpp project_dbs_ffi.cpp)
# TARGET_LINK_LIBRARIES(test tag sqlite3)

ADD_LIBRARY(for_ffi SHARED tag_functions.cpp database_functions.cpp misc.cpp project_dbs_ffi.cpp trie.cpp)
TARGET_LINK_LIBRARIES(for_ffi tag sqlite3)