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
rm aruco.py
rm aruco_wrap.*
rm _aruco*.so
rm -r aruco/

# copy aruco source code
cp -r /usr/local/include/aruco .
# patch it
patch -p0 < namespaces.patch

# creates wrapper and builds shared library
swig3.0 -c++ -${SWIG_PYTHON} aruco.i && ${PYTHON_INTERPRETER} setup.py build_ext --inplace