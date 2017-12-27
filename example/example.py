import os
import sys
import cv2
import numpy as np
import aruco

if __name__ == '__main__':

    # load board and camera parameters
    #boardconfig = aruco.BoardConfiguration("chessboardinfo_small_meters.yml")
    camparam = aruco.CameraParameters()
    camparam.readFromXMLFile(os.path.join(os.path.dirname(__file__), "dfk72_6mm_param2.yml"))

    # create detector and get parameters
    detector = aruco.MarkerDetector()
    params = detector.getParameters()

    # print detector parameters
    print("detector params:")
    for val in dir(params):
        if not val.startswith("__"):
            print("\t{} : {}".format(val, params.__getattribute__(val)))

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

            # calculate marker extrinsics for marker size of 3.5cm
            marker.calculateExtrinsics(0.035, camparam)
            # print("Marker extrinsics:\n{}\n{}".format(marker.Tvec, marker.Rvec))
            print("detected ids: {}".format(", ".join(str(m.id) for m in markers)))

        # show frame
        cv2.imshow("frame", frame)
        cv2.waitKey(100)
        
        # read next frame
        ret, frame = cap.read()
