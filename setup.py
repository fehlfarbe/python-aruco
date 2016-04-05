#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup, Extension

sourcefiles = ['aruco_wrap.cxx', 'aruco/ar_omp.cpp', 'aruco/arucofidmarkers.cpp',
               'aruco/board.cpp', 'aruco/boarddetector.cpp', 'aruco/cameraparameters.cpp',
               'aruco/cvdrawingutils.cpp', 'aruco/highlyreliablemarkers.cpp',
               'aruco/marker.cpp', 'aruco/markerdetector.cpp', 'aruco/subpixelcorner.cpp']

aruco_module = Extension('_aruco',
                           sources=sourcefiles,
                           language="c++",
                            include_dirs = ["/usr/include/opencv"],
                            libraries = ["opencv_core", "opencv_imgproc", "opencv_calib3d", "opencv_highgui", "aruco"],
                            library_dirs = ["/usr/local/lib"])

setup (name = 'aruco',
       version = '0.1',
       author      = """ArUco: Rafael Muñoz Salinas, Python wrappers: Marcus Degenkolbe""",
       description = """ArUco Python wrappers""",
       ext_modules = [aruco_module],
       py_modules = ["aruco"],
       )