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

# install opencv and aruco
RUN mkdir -p /home/user/src \
&& cd /home/user/src/ && wget -q -O opencv.zip https://github.com/opencv/opencv/archive/3.4.5.zip && ls -l && unzip opencv.zip \
&& cd opencv-3.4.5 && mkdir build && cd build && cmake -D CMAKE_BUILD_TYPE=RELEASE -DCMAKE_CXX_STANDARD=11 -DENABLE_PRECOMPILED_HEADERS=OFF .. \
&& make -j6 \
&& make install \
&& cd /home/user/src/

#RUN mkdir -p /home/user/src/python-aruco
COPY . /home/user/src/python-aruco
RUN cd /home/user/src/ \
&& ls -lr /usr/local/include/ \
#&& git clone --single-branch --branch aruco-3.1.2 https://github.com/fehlfarbe/python-aruco.git \
&& cd python-aruco \
&& ls -lr \
&& ./swigbuild.sh python3 \
&& ldconfig \
&& ls -l *.so \
&& python3 setup.py sdist bdist_wheel \
&& pip3 install dist/aruco-3.1.2.0-cp36-cp36m-linux_x86_64.whl \
&& python3 -c "import aruco; print(aruco)" \
&& python3 ./example/fractal.py \
&& echo "SUCCESS!"
