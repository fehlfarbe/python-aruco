import cv2
import aruco


if __name__ == "__main__":

    fractalmarkerSet = aruco.FractalMarkerSet.loadPredefined(aruco.FractalMarkerSet.FRACTAL_4L_6)
    pixSize = 10
    border = True

    result = fractalmarkerSet.getFractalMarkerImage(pixSize, border)
    cv2.imshow("fractal", result)
    cv2.waitKey(0)
