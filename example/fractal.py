import os
import sys
import cv2
import numpy as np
import aruco

if __name__ == '__main__':

    # create fractaldetector and set config
    detector = aruco.FractalDetector()
    print(detector.setConfiguration(0))

    # load test image
    frame = cv2.imread(os.path.join(os.path.dirname(__file__), "fractal_test.jpg"))

    # detect markers
    detected = detector.detect(frame)

    if detected:
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

    # show frame
    if 'DISPLAY' in os.environ.keys():
        cv2.imshow("frame", frame)
        cv2.waitKey(0)
    else:
        print("No display!")
