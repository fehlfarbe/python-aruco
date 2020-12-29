# python-aruco
[SWIG](http://www.swig.org/) generated Python wrappers for ArUco library.
Works with OpenCV Python module cv2 resp. numpy array data types.

Tested on Linux Mint 19 x86_64, OpenCV 4.1.0, ArUco 3.1.12 Python 3.6.9 and NumPy 1.18.0

## Installation via pip

1. Install / compile [OpenCV](http://opencv.org/) with Python3 support
2. Install / compile [ArUco 3.1.12](https://sourceforge.net/projects/aruco/files/)
3. run `pip3 install aruco`

## Build Python3 module via CMake

1. Install / compile [OpenCV](http://opencv.org/) with Python2 support
2. Install / compile [ArUco 3.1.12](https://sourceforge.net/projects/aruco/files/)
3. Install swig3: `sudo apt-get install swig3.0` for Debian/Ubuntu like systems. On 14.04 and other older systems you will need to go to "Software Sources" and check backports in the Updates tab, and reload before installing.
4. Install NumPy `pip3 install numpy` (maybe you already need it for OpenCV Python support) or install via system package manager.
5. Build the Python wrapper:
   - Create a new directory `build` in this project: `mkdir build && cd build`
   - Run CMake to configure the project: `cmake ..`
   - Run make to build the wrappers: `make`
6. The built package is now located in `python/dist/`, you can install it via pip: `pip3 install python/dist/*.whl`

## Test

### example video
open a prompt in `example/` and run: `python3 ./example.py`

### fractal marker example
open a prompt in `example/` and run: `python3 ./fractal.py`

If the Python doesn't find some shared objects, add the library location to LD_LIBRARY_PATH:
`export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH`

## Problems

I just tested some basic functions with `example/example.py` / `example/fractal.py`.
Please report errors and problems.

- Some return value templates like `std::vector<Point3f>` don't work yet (e.g. for `marker.get3DPoints()`)

## Thanks

- Thanks to [Mizux](https://github.com/Mizux) for the great [cmake-swig](https://github.com/Mizux/cmake-swig) example project