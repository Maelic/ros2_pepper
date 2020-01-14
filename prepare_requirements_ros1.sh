#!/bin/bash

set -euf -o pipefail

PYTHON2_VERSION=2.7.13

HOST_INSTALL_ROOT="${BASE_ROOT:-${PWD}}/"System
PEPPER_INSTALL_ROOT=System


if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

docker build -t ros1-pepper -f docker/Dockerfile_ros1 docker/

if [ ! -e "Python-${PYTHON2_VERSION}.tar.xz" ]; then
  wget -cN https://www.python.org/ftp/python/$PYTHON2_VERSION/Python-${PYTHON2_VERSION}.tar.xz
  tar xvf Python-${PYTHON2_VERSION}.tar.xz
fi

mkdir -p ${PWD}/Python-${PYTHON2_VERSION}-host
mkdir -p ${HOST_INSTALL_ROOT}/Python-${PYTHON2_VERSION}

docker run -it --rm \
  -u $(id -u $USER) \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}:/home/nao/Python-${PYTHON2_VERSION}-src \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION} \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -e CC \
  -e CPP \
  -e CXX \
  -e RANLIB \
  -e AR \
  -e AAL \
  -e LD \
  -e READELF \
  -e CFLAGS \
  -e CPPFLAGS \
  -e LDFLAGS \
  ros1-pepper \
  bash -c "\
    set -euf -o pipefail && \
    wget https://fossies.org/linux/misc/bzip2-1.0.6.tar.gz && \
    tar -xvf bzip2-1.0.6.tar.gz && \
    cd bzip2-1.0.6 && \
    make -f Makefile-libbz2_so && \
    make && \
    make install PREFIX=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION} && \
    cd .. && \
    mkdir -p Python-${PYTHON2_VERSION}-src/build-host && \
    cd Python-${PYTHON2_VERSION}-src/build-host && \
    export PATH=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:$PATH && \
    ../configure \
      --prefix=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION} \
      --disable-ipv6 \
      ac_cv_file__dev_ptmx=yes \
      ac_cv_file__dev_ptc=no && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib && \
    make -j4 install && \
    wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/python && \
    /home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/pip install empy catkin-pkg setuptools vcstool numpy rospkg defusedxml netifaces Twisted"

docker run -it --rm \
  -u $(id -u $USER) \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}:/home/nao/Python-${PYTHON2_VERSION}-src \
  -v ${HOST_INSTALL_ROOT}/Python-${PYTHON2_VERSION}:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION} \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  ros1-pepper \
  bash -c "\
    set -euf -o pipefail && \
    mkdir -p Python-${PYTHON2_VERSION}-src/build-pepper && \
    cd Python-${PYTHON2_VERSION}-src/build-pepper && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib && \
    export PATH=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:$PATH && \
    ../configure \
      --prefix=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION} \
      --host=i686-aldebaran-linux-gnu \
      --build=x86_64-linux \
      --enable-shared \
      --disable-ipv6 \
      ac_cv_file__dev_ptmx=yes \
      ac_cv_file__dev_ptc=no && \
    make -j4 install && \
    wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/python && \
    /home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/pip install empy catkin-pkg setuptools vcstool numpy rospkg defusedxml netifaces pymongo image tornado && \
    cd .. && \
    wget https://twistedmatrix.com/Releases/Twisted/16.0/Twisted-16.0.0.tar.bz2 && \
    tar -xjvf Twisted-16.0.0.tar.bz2 && \
    cd Twisted-16.0.0 && \
    python setup.py install"
