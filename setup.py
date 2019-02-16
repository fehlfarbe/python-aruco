#!/usr/bin/env python
# -*- coding: utf-8 -*-
import platform
from distutils.core import setup, Extension
import shutil
import sys

# use python2/3 version of aruco
if sys.version_info[0] < 3:
    shutil.copy("./py2/aruco.py", ".")
else:
    shutil.copy("./py3/aruco.py", ".")


sourcefiles = ['aruco_wrap.cxx']
extra_cpp_args = ["-std=c++11", "-Wall", "-Wunused-variable"]

# Compiling on OSX does not work with openmp switch
if platform.system().lower() != "darwin":
    extra_cpp_args.append("-fopenmp")

aruco_module = Extension('_aruco',
                         sources=sourcefiles,
                         language="c++",
                         extra_compile_args=extra_cpp_args,
                         include_dirs=["/usr/local/include/opencv2", "/usr/include/eigen3/", "."],
                         libraries=["opencv_core", "opencv_imgproc", "opencv_calib3d", "opencv_highgui", "aruco"],
                         library_dirs=["/usr/local/lib"])

setup(name='aruco',
      version='3.0.4.2',
      author="""ArUco: Rafael Muñoz Salinas, Python wrappers: Marcus Degenkolbe""",
      author_email='marcus@degenkolbe.eu',
      description="""ArUco Python wrappers""",
      url='https://github.com/fehlfarbe/python-aruco',
      keywords='aruco wrapper',
      install_requires=['numpy'],
      ext_modules=[aruco_module],
      py_modules=["aruco"],
      )
