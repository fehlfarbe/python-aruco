#!/bin/bash

# clean
rm aruco.py
rm aruco_wrap.*
rm _aruco.so
rm -r aruco/

# copy aruco source code
cp -r /usr/local/include/aruco .
# patch it
patch -p0 < namespaces.patch

# creates wrapper and builds shared library
swig3.0 -c++ -python aruco.i && python setup.py build_ext --inplace