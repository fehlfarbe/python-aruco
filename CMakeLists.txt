# ----------------------------------------------------------------------------
#   Basic Configuration
# ----------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.0)
project(aruco VERSION "3.1.12" LANGUAGES CXX)
set(PROJECT_SOVERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_STANDARD 11) # C++11
set(CMAKE_CXX_STANDARD_REQUIRED ON) # is required
set(CMAKE_CXX_EXTENSIONS ON) # with compiler extensions like gnu++11

# add cmake subdirectory
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# OpenCV headers are required
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

# aruco lib is required
find_package(aruco REQUIRED)
if (${aruco_FOUND})
    message("Using aruco ${aruco_VERSION}")
    link_directories(${aruco_LIB_DIR})
    set(aruco_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/include")
    message(${aruco_INCLUDE_DIRS})
endif ()

# numpy headers are required
find_package(NumPy REQUIRED)
include_directories(${NUMPY_INCLUDE_DIRS})

include(python)