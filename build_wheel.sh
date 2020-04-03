#!/bin/bash
# based on instruction at: https://hynek.me/articles/sharing-your-labor-of-love-pypi-quick-and-dirty/

# cleanup
rm -rf build

# build python2 wheel
#python setup.py sdist bdist_wheel

# build python3 wheel
python3 setup.py sdist bdist_wheel

# create python2 env and run example
# rm -rf 27-sdist && virtualenv 27-sdist && 27-sdist/bin/pip install dist/aruco-3.1.2.0-cp27-cp27mu-linux_x86_64.whl && cp /home/kolbe/.local/lib/python2.7/site-packages/cv2/cv2.so 27-sdist/lib/python2.7/site-packages/ && 27-sdist/bin/python example/example.py

# create python3 env and run example
rm -rf 36-sdist && virtualenv -p python3 36-sdist && 36-sdist/bin/pip install dist/aruco-3.1.2.0-cp36-cp36m-linux_x86_64.whl && cp /usr/local/lib/python3.6/dist-packages/cv2/python-3.6/cv2.cpython-36m-x86_64-linux-gnu.so 36-sdist/lib/python3.6/site-packages/ && 36-sdist/bin/python example/example.py

exit 0
# test .tar.gz without wheel
# create python2 env and run example
#rm -rf 27-sdist && virtualenv 27-sdist && 27-sdist/bin/pip install dist/aruco-3.1.2.0.tar.gz && 27-sdist/bin/python example/example.py
# create python3 env and run example
rm -rf 36-sdist && virtualenv -p python3 36-sdist && 36-sdist/bin/pip install dist/aruco-3.1.2.0.tar.gz && 36-sdist/bin/python example/example.py