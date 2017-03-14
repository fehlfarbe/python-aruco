#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup, Extension

sourcefiles = ['aruco_wrap.cxx']

aruco_module = Extension('_aruco',
                         sources=sourcefiles,
                         language="c++",
                         extra_compile_args=["-std=c++11", "-Wall", "-fopenmp"],
                         include_dirs=["/usr/local/include/opencv2", "/usr/include/eigen3/", "."],
                         libraries=["opencv_core", "opencv_imgproc", "opencv_calib3d", "opencv_highgui", "aruco"],
                         library_dirs=["/usr/local/lib"])

setup(name='aruco',
      version='2.0',
      author="""ArUco: Rafael Muñoz Salinas, Python wrappers: Marcus Degenkolbe""",
      description="""ArUco Python wrappers""",
      ext_modules=[aruco_module],
      py_modules=["aruco"],
      )
