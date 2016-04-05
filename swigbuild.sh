#!/bin/bash

# creates wrapper and builds shared library
swig -c++ -python aruco.i && python setup.py build_ext --inplace