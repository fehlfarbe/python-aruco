## Python
FIND_PACKAGE(SWIG REQUIRED)
INCLUDE(${SWIG_USE_FILE})

find_package (Python3 COMPONENTS Interpreter Development)
#INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_PATH})
#INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})

# clear include directories (remove original aruco includes etc.)
set_property(DIRECTORY . PROPERTY INCLUDE_DIRECTORIES "")
get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
foreach(dir ${dirs})
    message(STATUS "dir='${dir}'")
endforeach()

set_property(SOURCE aruco.i PROPERTY CPLUSPLUS ON)
set_property(SOURCE aruco.i PROPERTY SWIG_MODULE_NAME pyaruco)
set_property(SOURCE aruco.i PROPERTY SWIG_FLAGS "-py3" "-extranative")

swig_add_library(pyaruco
        TYPE SHARED
        LANGUAGE python
        OUTPUT_DIR ${CMAKE_BINARY_DIR}/python/${PROJECT_NAME}
        SOURCES aruco.i)

target_include_directories(pyaruco
        PRIVATE
        ../include
        ../3rdparty/eigen3/
        ${Python3_INCLUDE_DIRS}
        ${NUMPY_INCLUDE_DIRS}
        ${OpenCV_INCLUDE_DIRS}
        )
set_property(TARGET pyaruco PROPERTY SWIG_USE_TARGET_INCLUDE_DIRECTORIES ON)
#message(${pyarcuo_INCLUDE_DIRS})

# note: macOS is APPLE and also UNIX !
if (APPLE)
    set_target_properties(pyaruco PROPERTIES
            SUFFIX ".so"
            #    INSTALL_RPATH "@loader_path;@loader_path/../../${PROJECT_NAME}/.libs"
            INSTALL_RPATH "@loader_path;@loader_path/../../${PROJECT_NAME}/"
            )
    set_property(TARGET pyaruco APPEND PROPERTY
            LINK_FLAGS "-flat_namespace -undefined suppress"
            )
elseif (UNIX)
    set_target_properties(pyaruco PROPERTIES
            #    INSTALL_RPATH "$ORIGIN:$ORIGIN/../../${PROJECT_NAME}/.libs"
            INSTALL_RPATH "$ORIGIN:$ORIGIN/../../${PROJECT_NAME}/"
            )
endif ()
target_link_libraries(pyaruco PRIVATE aruco)

# Variable PYTHON_LIBRARIES can contains keyword `optimized`
# which won't be interpreted inside a generator expression.
# i.e. we can't use: $<$<PLATFORM_ID:Windows>:${PYTHON_LIBRARIES}>
# see: https://cmake.org/cmake/help/git-stage/command/target_link_libraries.html#command:target_link_libraries
if (MSVC)
    target_link_libraries(pyaruco PRIVATE ${Python3_LIBRARIES})
endif ()
