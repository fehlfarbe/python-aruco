#!/bin/bash

# clean
rm aruco.py
rm aruco_wrap.*
rm _aruco.so

# creates wrapper and builds shared library
swig3.0 -I/usr/local/include/ -c++ -python aruco.i && python setup.py build_ext --inplace