FROM ubuntu:xenial
LABEL maintainer="Alex Schultz. mail: alex.c.schultz@gmail.com"

# Install Deps
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get remove -y x264 libx264-dev
RUN apt-get install -y build-essential checkinstall cmake pkg-config yasm
RUN apt-get install -y git gfortran
RUN apt-get install -y libjpeg8-dev libjasper-dev libpng12-dev
RUN apt-get install -y libtiff5-dev
RUN apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev
RUN apt-get install -y libxine2-dev libv4l-dev
RUN apt-get install -y libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev
RUN apt-get install -y qt5-default libgtk2.0-dev libtbb-dev
RUN apt-get install -y libatlas-base-dev
RUN apt-get install -y libfaac-dev libmp3lame-dev libtheora-dev
RUN apt-get install -y libvorbis-dev libxvidcore-dev
RUN apt-get install -y libopencore-amrnb-dev libopencore-amrwb-dev
RUN apt-get install -y x264 v4l-utils
RUN apt-get install -y libprotobuf-dev protobuf-compiler
RUN apt-get install -y libgoogle-glog-dev libgflags-dev
RUN apt-get install -y libgphoto2-dev libeigen3-dev libhdf5-dev doxygen
RUN apt-get install -y wget
RUN apt-get install -y python3
RUN apt-get install -y cpio
RUN apt-get install sudo

# Install Go
RUN wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz && \
 tar -C /usr/local -xzf go1.11.linux-amd64.tar.gz && \
 rm go1.11.linux-amd64.tar.gz

# Setup GoPath
RUN mkdir $HOME/go
ENV GOPATH=$HOME/go
ENV PATH=$PATH:/usr/local/go/bin

# Install gocv
RUN go get -u -d gocv.io/x/gocv
RUN cd $GOPATH/src/gocv.io/x/gocv && \
 make install && \
 make clean

# Install OpenVino Toolkit
COPY l_openvino_toolkit_p_2018.3.343.tgz /tmp/l_openvino_toolkit_p_2018.3.343.tgz
RUN cd /tmp && tar -xf l_openvino_toolkit_p_2018.3.343.tgz && \
 rm l_openvino_toolkit_p_2018.3.343.tgz && \
 cd l_openvino_toolkit_p_2018.3.343 && \
 ./install_cv_sdk_dependencies.sh && \
 sed -i 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' silent.cfg && \
 sed -i 's/#INTEL_SW_IMPROVEMENT_PROGRAM_CONSENT=no/INTEL_SW_IMPROVEMENT_PROGRAM_CONSENT=no/g' silent.cfg && \
 ./install.sh -s silent.cfg

#Cleanup
RUN apt-get remove -y build-essential cmake git pkg-config wget \
 libatlas-base-dev gfortran libjasper-dev libgtk2.0-dev libavcodec-dev libavformat-dev \
 libswscale-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libv4l-dev && \
 apt-get clean && \
 rm -rf /opencv /opencv_contrib /var/lib/apt/lists/* /tmp/*

# Container Setup
EXPOSE 8080
RUN mkdir -p $HOME/data
VOLUME ["$HOME/data"]
WORKDIR $GOPATH

CMD ["bash"]