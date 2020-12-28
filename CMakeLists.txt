# ----------------------------------------------------------------------------
#   Basic Configuration
# ----------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.12)
project(aruco VERSION "3.1.12.0" LANGUAGES CXX)
set(PROJECT_SOVERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_STANDARD 11) # C++11
set(CMAKE_CXX_STANDARD_REQUIRED ON) # is required
set(CMAKE_CXX_EXTENSIONS ON) # with compiler extensions like gnu++11

# Build type
# Set a default build type if none was specified
set(default_build_type "Release")
if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
    set(default_build_type "Debug")
endif()

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
    set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
            STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
            "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# add cmake subdirectory
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# OpenCV headers are required
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

# aruco lib is required
find_package(aruco REQUIRED)
if (${aruco_FOUND})
    message(STATUS "Using aruco ${aruco_VERSION}")
    link_directories(${aruco_LIB_DIR})
    set(aruco_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/include")
    message(STATUS "Aruco include dir ${aruco_INCLUDE_DIRS}")
endif ()

# numpy headers are required
find_package(NumPy REQUIRED)
if (${NUMPY_FOUND})
    message(STATUS "Using NumPy ${NUMPY_VERSION}")
    message(STATUS "NumPy include dir ${NUMPY_INCLUDE_DIRS}")
endif ()

include(python)