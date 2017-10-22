# python-aruco
[SWIG](http://www.swig.org/) generated Python wrappers for ArUco library.
Works with OpenCV Python module cv2 resp. numpy array data types.

Tested on Linux Mint 17.1 x86_64, OpenCV 3.2.0, ArUco 2.0.19, Python 2.7.6 and NumPy 1.10.4

Installation Python2
--------------------

1. Install / compile [OpenCV](http://opencv.org/) >= 2.4.9 with Python2 support
2. download, compile and install ArUco: http://www.uco.es/investiga/grupos/ava/node/26,
also install `libeigen` headers for ArUco 2.0: `sudo apt-get install libeigen3-dev`
3. Install swig3: `sudo apt-get install swig3.0` for Debian/Ubuntu like systems
4. Install NumPy `sudo pip install numpy` (maybe you already need it for OpenCV Python support) or install via system packet manager
5. run `./swigbuild.sh`: it compiles the shared library (_aruco.so) and generates Python wrappers (aruco.py)
6. run `sudo python setup.py install` to install the library globally

Installation Python3 (experimental)
-----------------------------------

Tested on Ubuntu 14.04, OpenCV3.3, Python3.4, Aruco 2.0.19
1. Install / compile [OpenCV](http://opencv.org/) >= 2.4.9 with Python3 support. [Install-OpenCV script helps to install the latest version.](https://github.com/jayrambhia/Install-OpenCV/)
2. download, compile and install ArUco: http://www.uco.es/investiga/grupos/ava/node/26:
also install `libeigen` headers for ArUco 2.0: `sudo apt-get install libeigen3-dev`. Note that the instructions are wrong on the readme, the recommended commands needed are: `cd aruco; mkdir build; cd build; cmake ..; make -j4; sudo checkinstall`. Choose 2 and choose "aruco" and the package will be installed as Aruco for easy uninstall or sharing the deb installer file.
3. Install swig3: `sudo apt-get install swig3.0` for Debian/Ubuntu like systems. On 14.04 and other older systems you will need to go to "Software Sources" and check backports in the Updates tab, and reload before installing.
4. Install NumPy `sudo pip3 install numpy` (maybe you already need it for OpenCV Python support) or install via system package manager.
5. run `./swigbuild.sh python3`: it compiles the shared library (_aruco.so) and generates Python3 wrappers (aruco.py)
6. run `sudo python3 setup.py install` to install the library globally

Test
----

open a prompt in `example/` and run: `python ./example.py` or `python3 ./example.py` for Python3 (depends on your default Python interpreter)

If the Python doesn't find some shared objects, add the library location to LD_LIBRARY_PATH:
`export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH`

Problems
--------

This wrapper is totally in beta state. I just tested some basic functions with `example/example.py`.
Please report errors and problems.
