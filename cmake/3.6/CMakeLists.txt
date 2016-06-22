cmake_minimum_required(VERSION 2.8)

#
#  This CMake file installs some module files from CMake 3.6
#  into Torch cmake install directory.
#

INSTALL(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/Modules/"
        DESTINATION "share/cmake/torch")
