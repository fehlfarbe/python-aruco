#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup, Extension
import shutil
import sys

# use python2/3 version of aruco
if sys.version_info[0] < 3:
    shutil.copy("./py2/aruco.py", ".")
else:
    shutil.copy("./py3/aruco.py", ".")

sourcefiles = ['aruco_wrap.cxx']
aruco_module = Extension('_aruco',
                         sources=sourcefiles,
                         language="c++",
                         extra_compile_args=["-std=c++11", "-Wall", "-fopenmp", "-Wunused-variable"],
                         include_dirs=["/usr/local/include/opencv2", "/usr/include/eigen3/", "src/include/"],
                         libraries=["opencv_core", "opencv_imgproc", "opencv_calib3d", "opencv_highgui", "aruco"],
                         library_dirs=["/usr/local/lib"])

setup(name='aruco',
      version='3.0.4.1',
      author="""ArUco: Rafael Muñoz Salinas, Python wrappers: Marcus Degenkolbe""",
      author_email='marcus@degenkolbe.eu',
      description="""ArUco Python wrappers""",
      url='https://github.com/fehlfarbe/python-aruco',
      keywords='aruco wrapper',
      install_requires=['numpy'],
      ext_modules=[aruco_module],
      py_modules=["aruco"],
      )
