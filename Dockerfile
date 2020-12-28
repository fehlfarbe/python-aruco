# Dockerfile to run and test compilation and installation
FROM ubuntu:18.04
SHELL ["/bin/bash", "-c"]

# Replace 1000 with your user / group id
RUN apt-get update && apt-get install -y sudo apt-utils

# install tools and libs
RUN apt-get update \
&& apt-get install -y git-core bash-completion \
wget build-essential cmake pkg-config libjpeg8-dev libtiff5-dev libpng-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
libxvidcore-dev libx264-dev libgtk-3-dev libatlas-base-dev gfortran \
python2.7-dev python3-dev python-pip python3-pip swig unzip python3-numpy libeigen3-dev
RUN pip3 install --upgrade pip setuptools wheel cython numpy

# install opencv
RUN mkdir -p /home/user/src \
&& cd /home/user/src/ && wget -q -O opencv.zip https://github.com/opencv/opencv/archive/4.5.0.zip && ls -l && unzip opencv.zip \
&& cd opencv-4.5.0 && mkdir build && cd build && cmake -D CMAKE_BUILD_TYPE=RELEASE -DCMAKE_CXX_STANDARD=11 -DENABLE_PRECOMPILED_HEADERS=OFF .. \
&& make -j$(grep -c ^processor /proc/cpuinfo) \
&& make install \
&& cd /home/user/src/

# install aruco
RUN cd /home/user/src/ \
&& wget -O aruco.zip https://downloads.sourceforge.net/project/aruco/3.1.12/aruco-3.1.12.zip?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Faruco%2Ffiles%2Flatest%2Fdownload \
&& ls -l \
&& unzip aruco.zip \
&& cd aruco-3.1.12 \
&& ls -l \
&& mkdir build \
&& cd build \
&& cmake .. \
&& make -j$(grep -c ^processor /proc/cpuinfo) \
&& make install

#RUN mkdir -p /home/user/src/python-aruco
COPY . /home/user/src/python-aruco
RUN cd /home/user/src/ \
&& cd python-aruco \
&& mkdir build \
&& cd build \
&& rm -rf * \
&& pip3 install --upgrade pip \
&& pip3 install --upgrade cmake \
#&& pip3 install --upgrade numpy \
&& ldconfig \
&& python3 -c "import numpy as n; print(n.__version__); print(n.get_include());" \
&& cmake .. \
&& ls -l /usr/local/include/ \
#&& cmake --build . --target python_package_sdist -- -j 6 \
&& make -j6 \
# test compiled whl package
&& pip3 install --force-reinstall python/dist/aruco-*.whl \
&& python3 -c "import aruco; print(aruco.__version__)" \
&& python3 ../example/fractal.py \
&& python3 ../example/example.py \
# test sdist package
&& pip3 uninstall -y aruco \
&& make python_package_sdist -j6 \
&& pip3 install python/dist/aruco-*.tar.gz \
&& python3 -c "import aruco; print(aruco.__version__)" \
&& python3 ../example/fractal.py \
&& python3 ../example/example.py \
# test sdist package from testpypi
&& pip uninstall -y aruco \
&& pip install -i https://test.pypi.org/simple/ aruco --no-cache-dir \
&& python3 -c "import aruco; print(aruco.__version__)" \
&& echo "SUCCESS!"
