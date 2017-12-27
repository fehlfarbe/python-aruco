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

# creates wrapper and builds shared library
swig -c++ -${SWIG_PYTHON} -I. -I/usr/local/include aruco.i && ${PYTHON_INTERPRETER} setup.py build_ext --inplace