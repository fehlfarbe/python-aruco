/************************************

Swig Module for ArUco Python wrapper

************************************/

// module name
%module(directors="1") aruco

// needed
%include <std_string.i>
%include "pyabc.i"
%include "std_vector.i"

%{
	#define SWIG_FILE_WITH_INIT
	using namespace std;
%}

namespace std {
    // for  vector<int> to Python list conversion
    %template(VectorInt) vector<int>;
};

// NumPy <--> OpenCV typemaps
%include "okapi-typemaps.i"
//%include <opencv.i>
//%cv_instantiate_all_defaults

/************************************

ArUco stuff

************************************/


%{
//	#define SWIG_FILE_WITH_INIT
    #include<aruco_cvversioning.h>
    #include<aruco_export.h>
    #include<aruco.h>
    #include<cameraparameters.h>
    #include<cvdrawingutils.h>
    #include<debug.h>
    #include<dictionary_based.h>
    #include<dictionary.h>
    #include<fractaldetector.h>
    #include<ippe.h>
    #include<levmarq.h>
    #include<markerdetector.h>
    #include<markerdetector_impl.h>
    #include<marker.h>
    #include<markerlabeler.h>
    #include<markermap.h>
    #include<picoflann.h>
    #include<posetracker.h>
    #include<timers.h>

//    #include<fractallabelers/fractallabeler.h>
//    #include<fractallabelers/fractalmarker.h>
//    #include<fractallabelers/fractalmarkerset.h>
//    #include<fractallabelers/fractalposetracker.h>

    #include<dcf/dcfmarkermaptracker.h>
    #include<dcf/dcfmarkertracker.h>
    #include<dcf/dcf_utils.h>
    #include<dcf/trackerimpl.h>

//    using namespace aruco;
%}



%include <aruco.h>
%include <aruco_export.h>
%include <cameraparameters.h>
%include <cvdrawingutils.h>
%include <debug.h>
%include <dictionary.h>
%include <levmarq.h>

// Marker is std::vector< cv::Point2f >, template definition
// needed for std::vector -> Python List conversion
%template(Point2fVec) std::vector<cv::Point2f>;
%template(Point3fVec) std::vector<cv::Point3f>;
%template(MarkerPoint3fVecVec) std::vector< aruco::Marker, std::allocator< aruco::Marker > >;
%template(VectorMarker3DInfo) std::vector< aruco::Marker3DInfo >;

%include <marker.h>
/***
 Workaround:
 std::vector<Point2f>.at() --> Point2f conversion doesn't work
 so I just implemented the Python __getitem__() method for aruco::Marker
 to get corner points of the Marker object and added VectorIterator to
 support for-loops
***/

%pythoncode %{
class VectorIterator(object):

    def __init__(self, pointerToVector):
        self.pointerToVector = pointerToVector
        self.index = -1

    def __iter__(self):
        return self

    def __next__(self):
        self.index += 1
        if self.index < len(self.pointerToVector):
            return self.pointerToVector[self.index]
        else:
            raise StopIteration

    def next(self):
        self.index += 1
        if self.index < len(self.pointerToVector):
            return self.pointerToVector[self.index]
        else:
            raise StopIteration
%}

%extend aruco::Marker {
	public:
        cv::Point2f __getitem__(int i) {
            return $self->at(i);
        }
}

%extend aruco::Marker {
%pythoncode {
    def iterator(self):
        return VectorIterator(self)
   }
}


%include <markerdetector.h>
%include <markerlabeler.h>
%include <fractaldetector.h>
%include <markermap.h>
%include <posetracker.h>
%include <fractallabelers/fractalposetracker.h>
%include <fractallabelers/fractallabeler.h>
%include <fractallabelers/fractalmarkerset.h>
%include <fractallabelers/fractalmarker.h>
%include <timers.h>
