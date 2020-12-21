import os
import sys
import cv2
import numpy as np
import aruco

if __name__ == '__main__':
    # create fractaldetector and set config
    detector = aruco.FractalDetector()
    # set detector config first or it will throw an exception
    detector.setConfiguration(0)
    # load camera parameters
    camparam = aruco.CameraParameters()
    camparam.readFromXMLFile(filePath="rollei_live.yml")
    # set camera parameters
    if camparam.isValid():
        detector.setParams(camparam, 0.17)

    # load test image
    frame = cv2.imread(os.path.join(os.path.dirname(__file__), "rollei_snap.jpg"))

    # detect markers
    detected = detector.detect(frame)

    if detected:
        detector.drawMarkers(frame)
        markers = detector.getMarkers()
        # print id and points
        for marker in markers:
            # print marker ID and point positions
            print("Marker: {:d}".format(marker.id))
            for i, point in enumerate(marker):
                print("\t{:d} {}".format(i, str(point)))
            marker.draw(frame, np.array([255, 255, 255]), 2)

        print("detected ids: {}".format(", ".join(str(m.id) for m in markers)))
        # draw fractal marker using detector
        detector.draw2d(frame)

    # get Pose and draw axis/cube
    if detector.poseEstimation():
        tvec = detector.getTvec()
        rvec = detector.getRvec()
        print("TVec: {}\nR: {}".format(tvec, rvec))
        # draw cube
        detector.draw3d(frame)

    # show frame
    if 'DISPLAY' in os.environ.keys():
        cv2.imshow("frame", frame)
        k = cv2.waitKey(0)
    else:
        print("No display!")
