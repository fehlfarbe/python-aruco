#!/usr/bin/env python
# -*- coding: utf-8 -*-
import platform
from setuptools import setup, Extension
import shutil
import sys
import numpy as np
import glob

# use python2/3 version of aruco
if sys.version_info[0] < 3:
    shutil.copy("./py2/aruco.py", ".")
else:
    shutil.copy("./py3/aruco.py", ".")

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

sourcefiles = ['aruco_wrap.cxx']
sourcefiles.extend(glob.glob("src/aruco/*.cpp"))
sourcefiles.extend(glob.glob("src/aruco/fractallabelers/*.cpp"))

extra_cpp_args = ["-std=c++11", "-Wall", "-O3", "-g0", "-DNDEBUG"]

# Compiling on OSX does not work with openmp switch
if platform.system().lower() not in ("darwin", "osx"):
    extra_cpp_args.append("-fopenmp")

aruco_module = Extension('_aruco',
                         sources=sourcefiles,
                         language="c++",
                         extra_compile_args=extra_cpp_args,
                         include_dirs=[
                             np.get_include(),
                             "/usr/local/include/opencv4/",
                             "/usr/include/opencv4/opencv2/",
                             "/usr/local/include/opencv2",
                             "/usr/include/eigen3/",
                             "src/"],
                         libraries=["opencv_core", "opencv_imgproc", "opencv_calib3d", "opencv_highgui", "opencv_ml"],
                         library_dirs=["/usr/local/lib"])

setup(name='aruco',
      version='3.1.2.0',
      author="""ArUco: Rafael Muñoz Salinas, Python wrappers: Marcus Degenkolbe""",
      author_email='marcus@degenkolbe.eu',
      description="""ArUco Python wrappers""",
      long_description=long_description,
      long_description_content_type='text/markdown',
      license="Copyright 2011 Rafael Muñoz Salinas. All rights reserved.",
      url='https://github.com/fehlfarbe/python-aruco',
      keywords='aruco wrapper',
      install_requires=['numpy', 'opencv-contrib-python'],
      ext_modules=[aruco_module],
      py_modules=["aruco"],
      )

