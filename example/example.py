import os
import sys
import cv2
print(cv2.__file__)
print(cv2.__version__)
import numpy as np
import aruco
print(aruco.__file__)
import pkg_resources  # part of setuptools

if __name__ == '__main__':
    # load board and camera parameters
    #boardconfig = aruco.BoardConfiguration("chessboardinfo_small_meters.yml")
    camparam = aruco.CameraParameters()
    camparam.readFromXMLFile(os.path.join(os.path.dirname(__file__), "dfk72_6mm_param2.yml"))

    # create detector and get parameters
    detector = aruco.MarkerDetector()
    params = detector.getParameters()

    # load video
    cap = cv2.VideoCapture(os.path.join(os.path.dirname(__file__), "example.mp4"))
    ret, frame = cap.read()
    
    if not ret:
        print("can't open video!")
        sys.exit(-1)

    while ret:
        markers = detector.detect(frame)

        for marker in markers:
            # print marker ID and point positions
            print("Marker: {:d}".format(marker.id))
            for i, point in enumerate(marker):
                print("\t{:d} {}".format(i, str(point)))
            marker.draw(frame, np.array([255, 255, 255]), 2)
            print("center: {}".format(marker.getCenter()))
            # print("contour: {}".format(marker.contourPoints))
            mtx = marker.getTransformMatrix()
            print("M: {}".format(mtx))
            points3d = marker.get3DPoints()
            print("3D points: {:}".format(points3d))
            # not working because "vector<Point3f> --> list" conversion doesnt work yet
            for p in points3d:
                print("\t{}".format(p))
            # calculate marker extrinsics for marker size of 3.5cm
            marker.calculateExtrinsics(0.035, camparam)
            # print("Marker extrinsics:\n{}\n{}".format(marker.Tvec, marker.Rvec))
            aruco.CvDrawingUtils.draw3dAxis(frame, camparam, marker.Rvec, marker.Tvec, .1)
            print("detected ids: {}".format(", ".join(str(m.id) for m in markers)))

        # add aruco version to frame
        y, x, c = frame.shape
        text = "aruco {}".format(pkg_resources.require("aruco")[0].version)
        font = cv2.FONT_HERSHEY_PLAIN
        font_scale = 2
        thickness = 2
        cv2.putText(frame, text, (15, y - 15), font, font_scale, (255, 255, 255), thickness,
                    cv2.LINE_AA)

        # show frame
        if 'DISPLAY' in os.environ.keys():
            cv2.imshow("frame", frame)
            cv2.waitKey(10)
        else:
            print("No display!")
        
        # read next frame
        ret, frame = cap.read()
