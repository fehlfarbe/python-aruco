#!/bin/bash

if [ $# -gt 0 ]
then
    if [ $1 == python3 ]
    then
        SWIG_PYTHON="python -py3"
        PYTHON_INTERPRETER="python3"
    fi
else
    SWIG_PYTHON="python"
    PYTHON_INTERPRETER="python"
fi

# clean
rm aruco.py &> /dev/null
rm aruco_wrap.* &> /dev/null
rm _aruco*.so &> /dev/null
rm -rf py2 &> /dev/null
rm -rf py3 &> /dev/null

mkdir py2 &> /dev/null
mkdir py3 &> /dev/null

# creates wrapper for py2 and py3
swig -c++ -python -I./src/include -outdir py2 -Isrc aruco.i
swig -c++ -python -py3 -I./src/include -outdir py3 -Isrc aruco.i

# builds shared library
${PYTHON_INTERPRETER} setup.py build_ext --inplace