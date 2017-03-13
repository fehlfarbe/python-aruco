/*****************************
Copyright 2011 Rafael Muñoz Salinas. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY Rafael Muñoz Salinas ''AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Rafael Muñoz Salinas OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Rafael Muñoz Salinas.
********************************/
#ifndef _ARUCO_MarkerDetector_H
#define _ARUCO_MarkerDetector_H
#include <opencv2/core/core.hpp>
#include <cstdio>
#include <iostream>
#include "exports.h"
#include "dictionary.h"
#include "marker.h"
#include "markerlabeler.h"
using namespace std;

namespace aruco {
class CameraParameters;
/**\brief Main class for marker detection
 *
 */
class ARUCO_EXPORTS MarkerDetector {

public:

    /**Methods for corner refinement
     */
    enum CornerRefinementMethod { NONE,   SUBPIX, LINES };

    /**This set the type of thresholding methods available
     */

    enum ThresholdMethods { FIXED_THRES, ADPT_THRES, CANNY };

    /**Operating params
     */
    struct Params{
        //method emplpoyed for image threshold
        ThresholdMethods _thresMethod;
        // Threshold parameters
        double _thresParam1, _thresParam2, _thresParam1_range;

        // Current corner method
        CornerRefinementMethod _cornerMethod;
        //when using subpix, this indicates the search range for optimization (in pixels)
        int _subpix_wsize;
        //size of the image passed to the MarkerLabeler
        int _markerWarpSize;
        // border around image limits in which corners are not allowed to be detected. (0,1)
        float _borderDistThres;

        // minimum and maximum size of a contour lenght. We use the following formula
        // minLenght=  min ( _minSize_pix , _minSize* Is)*4
        // maxLenght=    _maxSize* Is*4
        // being Is=max(imageWidth,imageHeight)
        //the values  _minSize and _maxSize are normalized, thus, depends on camera image size
        //However, _minSize_pix is expressed in pixels and  prevents a marker large enough, but relatively small to the image dimensions
        //to be discarded. For instance, imagine a image of 6000x6000 and a marker of 100x100 in it.
        // The marker is visible, but relatively small, so, we set a minimum size expressed in pixels to avoid discarding it
        float _minSize, _maxSize;
        int _minSize_pix ;
        Params(){
            _thresMethod = ADPT_THRES;
            _thresParam1 = _thresParam2 = 7;
            _cornerMethod = LINES;

            _thresParam1_range = 0;
            _markerWarpSize = 56;

            _minSize = 0.04;_maxSize = 0.95;_minSize_pix=25;
            _borderDistThres = 0.005; // corners at a distance from image boundary nearer than 2.5% of image are ignored
            _subpix_wsize=5;//window size employed for subpixel search (in vase you use _cornerMethod=SUBPIX
        }

    };

    /**
     * See
     */
    MarkerDetector();

    /**
     */
    ~MarkerDetector();
    /**Detects the markers in the image passed
     *
     * If you provide information about the camera parameters and the size of the marker, then, the extrinsics of the markers are detected
     *
     * @param input input color image
     * @param camMatrix intrinsic camera information.
     * @param distCoeff camera distorsion coefficient. If set Mat() if is assumed no camera distorion
     * @param markerSizeMeters size of the marker sides expressed in meters. If not specified this value, the extrinsics of the markers are not detected.
     * @param setYPerperdicular If set the Y axis will be perpendicular to the surface. Otherwise, it will be the Z axis
     * @return vector with the detected markers
     */
    std::vector<aruco::Marker> detect(const cv::Mat &input) throw(cv::Exception);
    std::vector<aruco::Marker> detect(const cv::Mat &input,const aruco::CameraParameters &camParams, float markerSizeMeters , bool setYPerperdicular = false) throw(cv::Exception);

 /**Detects the markers in the image passed
     *
     * If you provide information about the camera parameters and the size of the marker, then, the extrinsics of the markers are detected
     *
     * @param input input color image
     * @param detectedMarkers output vector with the markers detected
     * @param camParams Camera parameters
     * @param markerSizeMeters size of the marker sides expressed in meters
     * @param setYPerperdicular If set the Y axis will be perpendicular to the surface. Otherwise, it will be the Z axis
     */
    void detect(const cv::Mat &input, std::vector< aruco::Marker > &detectedMarkers, aruco::CameraParameters camParams, float markerSizeMeters = -1,
                bool setYPerperdicular = false) throw(cv::Exception);


    /**Detects the markers in the image passed
     *
     * If you provide information about the camera parameters and the size of the marker, then, the extrinsics of the markers are detected
     *
     * NOTE: be sure that the camera matrix is for this image size. If you do not know what I am talking about, use functions above and not this one
     * @param input input color image
     * @param detectedMarkers output vector with the markers detected
     * @param camMatrix intrinsic camera information.
     * @param distCoeff camera distorsion coefficient. If set Mat() if is assumed no camera distorion
     * @param markerSizeMeters size of the marker sides expressed in meters
     * @param setYPerperdicular If set the Y axis will be perpendicular to the surface. Otherwise, it will be the Z axis
     */
    void detect(const cv::Mat &input, std::vector< aruco::Marker > &detectedMarkers, cv::Mat camMatrix = cv::Mat(), cv::Mat distCoeff = cv::Mat(),
                float markerSizeMeters = -1, bool setYPerperdicular = false) throw(cv::Exception);

    /**Sets operating params
     */
    void setParams(Params p){_params =p;}
    /**Returns operating params
     */
    Params getParams()const {return _params;}
    /** Sets the dictionary to be employed.
     * You can choose:ARUCO,//original aruco dictionary. By default
                     ARUCO_MIP_25h7,
                     ARUCO_MIP_16h3,
                     ARUCO_MIP_36h12, **** recommended
                     ARTAG,//
                     ARTOOLKITPLUS,
                     ARTOOLKITPLUSBCH,//
                     TAG16h5,TAG25h7,TAG25h9,TAG36h11,TAG36h10//APRIL TAGS DICIONARIES
                     CHILITAGS,//chili tags dictionary . NOT RECOMMENDED. It has distance 0. Markers 806 and 682 should not be used!!!

      If dict_type is none of the above ones, it is assumed you mean a CUSTOM dicionary saved in a file @see Dictionary::loadFromFile
      Then, it tries to open it
    */
    void setDictionary(std::string dict_type,float error_correction_rate=0)throw(cv::Exception);

    /**
     * @brief setDictionary Specifies the dictionary you want to use for marker decoding
     * @param dict_type dictionary employed for decoding markers @see Dictionary
     * @param error_correction_rate value indicating the correction error allowed. Is in range [0,1]. 0 means no correction at all. So
     * an erroneous bit will result in discarding the marker. 1, mean full correction. The maximum number of bits that can be corrected depends on each ditionary.
     * We recommend using values from 0 to 0.5. (in general, this will allow up to 3 bits or correction).
     */
    void setDictionary(Dictionary::DICT_TYPES dict_type,float error_correction_rate=0)throw(cv::Exception);


    /**
     * Returns a reference to the internal image thresholded. It is for visualization purposes and to adjust manually
     * the parameters
     */
    const cv::Mat &getThresholdedImage() { return thres; }


    //Below this point, you are most probably not interested
    //--- deprecated accesor modifiers ue the new setParams() and getParams() methods instead
    /** @deprecated use setParams() and getParams()
     * Sets the threshold method
     */
    void setThresholdMethod(ThresholdMethods m) { _params._thresMethod = m; }
    /**Returns the current threshold method
     */
    ThresholdMethods getThresholdMethod() const { return _params._thresMethod; }
    /** @deprecated use setParams() and getParams()
     * Set the parameters of the threshold method
     * We are currently using the Adptive threshold ee opencv doc of adaptiveThreshold for more info
     *   @param param1: blockSize of the pixel neighborhood that is used to calculate a threshold value for the pixel
     *   @param param2: The constant subtracted from the mean or weighted mean
     */
    void setThresholdParams(double param1, double param2) {
        _params._thresParam1 = param1;
        _params._thresParam2 = param2;
    }

    /** @deprecated use setParams() and getParams()
     * Allows for a parallel search of several values of the param1 simultaneously (in different threads)
     * The param r1 the indicates how many values around the current value of param1 are evaluated. In other words
     * if r1>0, param1 is searched in range [param1- r1 ,param1+ r1 ]
     *
     * r2 unused yet. Added in case of future need.
     */
    void setThresholdParamRange(size_t r1 = 0, size_t r2 = 0) {_params. _thresParam1_range = r1; (void)(r2); }

    /** @deprecated use setParams() and getParams()
     * Set the parameters of the threshold method
     * We are currently using the Adptive threshold ee opencv doc of adaptiveThreshold for more info
     *   param1: blockSize of the pixel neighborhood that is used to calculate a threshold value for the pixel
     *   param2: The constant subtracted from the mean or weighted mean
     */
    void getThresholdParams(double &param1, double &param2) const {
        param1 = _params._thresParam1;
        param2 = _params._thresParam2;
    }



    /**@deprecated use setParams() and getParams()
     * Sets the method for corner refinement
     * When using SUBPIX, the second value indicates the window size in which search is done. Default value is 5
     */
    void setCornerRefinementMethod(CornerRefinementMethod method,int val=-1) { _params._cornerMethod = method; if (val!=-1)_params._subpix_wsize=val;}
    /**@deprecated
     */
    CornerRefinementMethod getCornerRefinementMethod() const { return _params._cornerMethod; }
    /**
     * @deprecated use setParams() and getParams()
     * Specifies the min and max sizes of the markers as a fraction of the image size. By size we mean the maximum
     * of cols and rows.
     * @param min size of the contour to consider a possible marker as valid (0,1]
     * @param max size of the contour to consider a possible marker as valid [0,1)
     *
     */
    void setMinMaxSize(float min = 0.03, float max = 0.5) throw(cv::Exception){
    if (min <= 0 || min > 1)        throw cv::Exception(1, " min parameter out of range", "MarkerDetector::setMinMaxSize", __FILE__, __LINE__);
    if (max <= 0 || max > 1)        throw cv::Exception(1, " max parameter out of range", "MarkerDetector::setMinMaxSize", __FILE__, __LINE__);
    if (min > max)        throw cv::Exception(1, " min>max", "MarkerDetector::setMinMaxSize", __FILE__, __LINE__);
    _params._minSize = min;
    _params._maxSize = max;
    }


    /**@deprecated use setParams() and getParams()
     * reads the min and max sizes employed
     * @param min output size of the contour to consider a possible marker as valid (0,1]
     * @param max output size of the contour to consider a possible marker as valid [0,1)
     *
     */
    void getMinMaxSize(float &min, float &max) {
        min = _params._minSize;
        max = _params._maxSize;
    }


    /**@deprecated
     * Is now null
       */
    void setDesiredSpeed(int val){(void)(val);}
    /**@deprecated
     */
    int getDesiredSpeed() const { return 0; }

    /**@deprecated use setParams() and getParams()
     * Specifies the size for the canonical marker image. A big value makes the detection slower than a small value.
     * Minimun value is 10. Default value is 56.
     */
    void setWarpSize(int val) throw(cv::Exception){
        if (val < 10)
            throw cv::Exception(1, " invalid canonical image size", "MarkerDetector::setWarpSize", __FILE__, __LINE__);
        _params._markerWarpSize = val;
    };
    /**@deprecated use setParams() and getParams()
     */
    int getWarpSize() const { return _params._markerWarpSize; }






    ///-------------------------------------------------
    /// Methods you may not need
    /// Thesde methods do the hard work. They have been set public in case you want to do customizations
    ///-------------------------------------------------


    /**
     * @brief setMakerLabeler sets the labeler employed to analyze the squares and extract the inner binary code
     * @param detector
     */
    void setMarkerLabeler(cv::Ptr<aruco::MarkerLabeler> detector)throw(cv::Exception);
    cv::Ptr<aruco::MarkerLabeler>     getMarkerLabeler()throw(cv::Exception){ return markerIdDetector;}
    // Represent a candidate to be a maker
    class MarkerCandidate : public aruco::Marker {
      public:
        MarkerCandidate() {}
        MarkerCandidate(const aruco::Marker &M) : aruco::Marker(M) {}
        MarkerCandidate(const MarkerCandidate &M) : aruco::Marker(M) {
            contour = M.contour;
            idx = M.idx;
        }
        MarkerCandidate &operator=(const MarkerCandidate &M) {
            (*(Marker *)this) = (*(aruco::Marker *)&M);
            contour = M.contour;
            idx = M.idx;
            return *this;
        }

        vector< cv::Point > contour; // all the points of its contour
        int idx; // index position in the global contour list
    };

    /**
     * Thesholds the passed image with the specified method.
     */
    void thresHold(int method, const cv::Mat &grey, cv::Mat &thresImg, double param1 = -1, double param2 = -1) throw(cv::Exception);
    /**A
     * */
    void  adpt_threshold_multi(const cv::Mat &grey, std::vector<cv::Mat> &out, double param1  , double param1_range , double param2,double param2_range=0 );
    /**
    * Detection of candidates to be markers, i.e., rectangles.
    * This function returns in candidates all the rectangles found in a thresolded image
    */
    void detectRectangles(const cv::Mat &thresImg, vector< std::vector< cv::Point2f > > &candidates);

    /**Returns a list candidates to be markers (rectangles), for which no valid id was found after calling detectRectangles
     */
    const vector< std::vector< cv::Point2f > > &getCandidates() { return _candidates; }

    /**
     * Given the iput image with markers, creates an output image with it in the canonical position
     * @param in input image
     * @param out image with the marker
     * @param size of out
     * @param points 4 corners of the marker in the image in
     * @return true if the operation succeed
     */
    bool warp(cv::Mat &in, cv::Mat &out, cv::Size size, std::vector< cv::Point2f > points) throw(cv::Exception);



    /** Refine MarkerCandidate Corner using LINES method
     * @param candidate candidate to refine corners
     */
    void refineCandidateLines(MarkerCandidate &candidate, const cv::Mat &camMatrix, const cv::Mat &distCoeff);




  private:
    bool warp_cylinder(cv::Mat &in, cv::Mat &out, cv::Size size, MarkerCandidate &mc) throw(cv::Exception);
    /**
    * Detection of candidates to be markers, i.e., rectangles.
    * This function returns in candidates all the rectangles found in a thresolded image
    */
    void detectRectangles(vector< cv::Mat > &vimages, vector< MarkerCandidate > &candidates);
    //operating params
    Params _params;
    // vectr of candidates to be markers. This is a vector with a set of rectangles that have no valid id
    vector< std::vector< cv::Point2f > > _candidates;
    // Images
    cv::Mat grey, thres;
    // pointer to the function that analizes a rectangular region so as to detect its internal marker
    cv::Ptr<aruco::MarkerLabeler> markerIdDetector;

    /**
     */
    bool isInto(cv::Mat &contour, std::vector< cv::Point2f > &b);
    /**
     */
    int perimeter(std::vector< cv::Point2f > &a);

     // auxiliar functions to perform LINES refinement
    void interpolate2Dline(const vector< cv::Point2f > &inPoints, cv::Point3f &outLine);
    cv::Point2f getCrossPoint(const cv::Point3f &line1, const cv::Point3f &line2);
    void distortPoints(vector< cv::Point2f > in, vector< cv::Point2f > &out, const cv::Mat &camMatrix, const cv::Mat &distCoeff);


    /**Given a vector vinout with elements and a boolean vector indicating the lements from it to remove,
     * this function remove the elements
     * @param vinout
     * @param toRemove
     */
    template < typename T > void removeElements(vector< T > &vinout, const vector< bool > &toRemove) {
        // remove the invalid ones by setting the valid in the positions left by the invalids
        size_t indexValid = 0;
        for (size_t i = 0; i < toRemove.size(); i++) {
            if (!toRemove[i]) {
                if (indexValid != i)
                    vinout[indexValid] = vinout[i];
                indexValid++;
            }
        }
        vinout.resize(indexValid);
    }

    // graphical debug
    void drawApproxCurve(cv::Mat &in, std::vector< cv::Point > &approxCurve, cv::Scalar color);
    void drawContour(cv::Mat &in, std::vector< cv::Point > &contour, cv::Scalar);
    void drawAllContours(cv::Mat input, std::vector< std::vector< cv::Point > > &contours);
    void draw(cv::Mat out, const std::vector< aruco::Marker > &markers);
    // method to refine corner detection in case the internal border after threshold is found
    // This was tested in the context of chessboard methods
    void findCornerMaxima(vector< cv::Point2f > &Corners, const cv::Mat &grey, int wsize);



    template < typename T > void joinVectors(vector< vector< T > > &vv, vector< T > &v, bool clearv = false) {
        if (clearv)
            v.clear();
        for (size_t i = 0; i < vv.size(); i++)
            for (size_t j = 0; j < vv[i].size(); j++)
                v.push_back(vv[i][j]);
    }

    vector<cv::Mat > imagePyramid;
};
};
#endif
