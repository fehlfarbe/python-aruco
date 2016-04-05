# python-aruco
[SWIG](http://www.swig.org/) generated Python wrappers for ArUco library

Tested on Linux Mint 14.1 x86_64, OpenCV 3.1.0, ArUco 1.3.0, Python 2.7.6 and NumPy 1.10.4

Installation
------------

1. Install / compile [OpenCV](http://opencv.org/) >= 2.4.9 with Python support
2. download and compile ArUco: http://www.uco.es/investiga/grupos/ava/node/26
3. Install swig: `sudo apt-get install swig` for Debian/Ubuntu like systems
4. Install NumPy `sudo pip install numpy` (maybe you already need it for OpenCV Python support)
5. run `swigbuild.sh`: it compiles the shared library (_aruco.so) and generates Python wrappers (aruco.py)
6. run `sudo python setup.py install` to install the library globally

Test
----

open a prompt in `test/` and run `python test.py`