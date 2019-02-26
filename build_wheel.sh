#!/bin/bash
# based on instruction at: https://hynek.me/articles/sharing-your-labor-of-love-pypi-quick-and-dirty/

# cleanup
rm -rf build

# build python2 wheel
python setup.py sdist bdist_wheel

# build python3 wheel
python3 setup.py sdist bdist_wheel

# create python2 env and run example
rm -rf 27-sdist && virtualenv 27-sdist && 27-sdist/bin/pip install dist/aruco-3.0.13.0-cp27-cp27mu-linux_x86_64.whl && 27-sdist/bin/python example/example.py

# create python3 env and run example
rm -rf 36-sdist && virtualenv -p python3 36-sdist && 36-sdist/bin/pip install dist/aruco-3.0.13.0-cp36-cp36m-linux_x86_64.whl && 36-sdist/bin/python example/example.py

# test .tar.gz without wheel
# create python2 env and run example
rm -rf 27-sdist && virtualenv 27-sdist && 27-sdist/bin/pip install dist/aruco-3.0.13.0.tar.gz && 27-sdist/bin/python example/example.py
# create python3 env and run example
rm -rf 36-sdist && virtualenv -p python3 36-sdist && 36-sdist/bin/pip install dist/aruco-3.0.13.0.tar.gz && 36-sdist/bin/python example/example.py