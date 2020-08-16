# python-aruco
[SWIG](http://www.swig.org/) generated Python wrappers for ArUco library.
Works with OpenCV Python module cv2 resp. numpy array data types.

Tested on Linux Mint 19 x86_64, OpenCV 4.1.0, ArUco 3.1.2 Python 3.6.1 and NumPy 1.16.3

Installation via pip
--------------------
1. Install / compile [OpenCV](http://opencv.org/) >= 3.3.1 with Python2 support
2. run `sudo -H pip install aruco`

Installation Python2
--------------------

1. Install / compile [OpenCV](http://opencv.org/) >= 2.4.9 with Python2 support
3. Install swig3: `sudo apt-get install swig3.0` for Debian/Ubuntu like systems
4. Install NumPy `sudo pip install numpy` (maybe you already need it for OpenCV Python support) or install via system packet manager
5. run `./swigbuild.sh`: it compiles the shared library (_aruco.so) and generates Python wrappers (aruco.py)
6. run `sudo python setup.py install` to install the library globally

Installation Python3
--------------------

1. Install / compile [OpenCV](http://opencv.org/) >= 2.4.9 with Python3 support. [Install-OpenCV script helps to install the latest version.](https://github.com/jayrambhia/Install-OpenCV/)
3. Install swig3: `sudo apt-get install swig3.0` for Debian/Ubuntu like systems. On 14.04 and other older systems you will need to go to "Software Sources" and check backports in the Updates tab, and reload before installing.
4. Install NumPy `sudo pip3 install numpy` (maybe you already need it for OpenCV Python support) or install via system package manager.
5. Create a symlink `sudo ln -s /usr/local/include/opencv4/opencv2/ /usr/local/include/opencv2`
6. run `./swigbuild.sh python3`: it compiles the shared library (_aruco.so) and generates Python3 wrappers (aruco.py)
6. run `sudo python3 setup.py install` to install the library globally

Test
----

#### example video
open a prompt in `example/` and run: `python ./example.py` or `python3 ./example.py` for Python3 (depends on your default Python interpreter)

#### fractal marker example
open a prompt in `example/` and run: `python ./fractal.py` or `python3 ./fractal.py` for Python3 (depends on your default Python interpreter)

If the Python doesn't find some shared objects, add the library location to LD_LIBRARY_PATH:
`export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH`

Problems
--------

I just tested some basic functions with `example/example.py` / `example/fractal.py`.
Please report errors and problems.
