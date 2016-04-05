/************************************

Swig Module for ArUco Python wrapper

************************************/

// module name
%module(directors="1") aruco

// needed
%include <std_string.i>

%{
	#define SWIG_FILE_WITH_INIT
%}

// NumPy <--> OpenCV typemaps
%include "okapi-typemaps.i"

/************************************

ArUco stuff

************************************/


%{
	#define SWIG_FILE_WITH_INIT
	#include "aruco/exports.h"
	#include "aruco/cameraparameters.h"
	#include "aruco/marker.h"
	#include "aruco/board.h"
	#include "aruco/cvdrawingutils.h"
%}


%include "aruco/exports.h"
%include "aruco/cameraparameters.h"
%include "aruco/marker.h"
%include "aruco/board.h"
%include "aruco/cvdrawingutils.h"


// rename detect function because of polymorphism problems
%rename("detect_mat") aruco::BoardDetector::detect(const cv::Mat&);


// some stuff to support nested class MarkerCandidate in boarddetector.h

// Suppress SWIG warning
#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_CLASS
// nested class in markerdetector

class MarkerCandidate : public aruco::Marker {
      public:
        MarkerCandidate() {}
        MarkerCandidate(const aruco::Marker &M) : Maruco::arker(M) {}
        MarkerCandidate(const MarkerCandidate &M) : aruco::Marker(M) {
            contour = M.contour;
            idx = M.idx;
        }
        MarkerCandidate &operator=(const MarkerCandidate &M) {
            (*(aruco::Marker *)this) = (*(aruco::Marker *)&M);
            contour = M.contour;
            idx = M.idx;
            return *this;
        }

        vector< cv::Point > contour; // all the points of its contour
        int idx; // index position in the global contour list
};

%{
	#include "aruco/markerdetector.h"
%}

%include "aruco/markerdetector.h"

%{
// SWIG thinks that Inner is a global class, so we need to trick the C++
// compiler into understanding this so called global type.
typedef aruco::MarkerDetector::MarkerCandidate MarkerCandidate;
%}

%{
	#include "aruco/boarddetector.h"
%}

%include "aruco/boarddetector.h"
