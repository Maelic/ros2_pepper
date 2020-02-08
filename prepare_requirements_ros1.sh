#!/bin/bash

set -euf -o pipefail

PYTHON2_MAJOR_VERSION=2
PYTHON2_MINOR_VERSION=7
PYTHON2_PATCH_VERSION=17

PYTHON3_MAJOR_VERSION=3
PYTHON3_MINOR_VERSION=8
PYTHON3_PATCH_VERSION=1

PYTHON2_VERSION=${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.${PYTHON2_PATCH_VERSION}
PYTHON3_VERSION=${PYTHON3_MAJOR_VERSION}.${PYTHON3_MINOR_VERSION}.${PYTHON3_PATCH_VERSION}

#PYTHON2_VERSION=2.7.17

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
#mkdir -p ${HOST_INSTALL_ROOT}/icu4c-65_1


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
    wget https://fossies.org/linux/misc/bzip2-1.0.8.tar.gz && \
    tar -xvf bzip2-1.0.8.tar.gz && \
    cd bzip2-1.0.8 && \
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
      --enable-unicode=ucs4 \
      ac_cv_file__dev_ptmx=yes \
      ac_cv_file__dev_ptc=no && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib && \
    make -j8 install && \
    wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/python && \
    /home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/pip install empy catkin-pkg setuptools vcstool numpy rospkg defusedxml netifaces Twisted qibuild"





#docker run -it --rm \
#  -u $(id -u $USER) \
#  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
#  -v ${HOST_INSTALL_ROOT}:/home/nao/${PEPPER_INSTALL_ROOT} \
#  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
#  -e CC \
#  -e CPP \
#  -e CXX \
#  -e RANLIB \
#  -e AR \
#  -e AAL \
#  -e LD \
#  -e READELF \
#  -e CFLAGS \
#  -e CPPFLAGS \
#  -e LDFLAGS \
#  ros1-pepper \
#  bash -c "\
#   set -euf -o pipefail && \
#   wget https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.bz2 && \
#   tar --bzip2 -xf boost_1_72_0.tar.bz2 && \
#   mkdir -p build_boost_build && \
#   mkdir -p build_boost && \
#   cd boost_1_72_0/tools/build/ && \
#   ./bootstrap.sh && \
#   ./b2 install --prefix=../../../build_boost_build && \
#   export PATH=$PATH:/home/nao/ctc/bin && \
#   export PATH=$PATH:/home/nao/build_boost_build/bin && \
#   cd ../../ && \
#   b2 \
#      --build-dir=../build_boost \
#      --prefix=/home/nao/${PEPPER_INSTALL_ROOT}/ros1_dependencies \
#      --enable-tests=no \
#      --build=x86_64-linux \
#       architecture=x86 \
#       stage \
#"







docker run -it --rm \
  -u $(id -u $USER) \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${HOST_INSTALL_ROOT}:/home/nao/${PEPPER_INSTALL_ROOT} \
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
   wget https://github.com/unicode-org/icu/releases/download/release-51-3/icu4c-51_3-src.tgz && \
   tar -zxvf icu4c-51_3-src.tgz && \
   mkdir -p build_icu && \
   cd build_icu && \
   CPPFLAGS="-DU_CHARSET_IS_UTF8=1" ../icu/source/runConfigureICU Linux \
      --prefix=/home/nao/icu4c \
      --enable-tests=no && \
   make -j8 && \
   make install && \
   cd /home/nao && \
   mkdir -p build_icu_pepper && \
   cd build_icu_pepper && \
   export PATH=$PATH:/home/nao/ctc/bin && \
   CPPFLAGS="-DU_CHARSET_IS_UTF8=1" ../icu/source/runConfigureICU Linux \
      --prefix=/home/nao/${PEPPER_INSTALL_ROOT}/ros1_dependencies \
      --enable-tests=no \
      --host=i686-aldebaran-linux-gnu \
      --build=x86_64-linux \
      --with-cross-build=/home/nao/build_icu && \
   make -j8 && \
   make install "




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
    make -j8 install && \
    wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/python && \
    /home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/pip install empy catkin-pkg setuptools vcstool numpy rospkg defusedxml netifaces pymongo image tornado && \
    cd .. && \
    wget https://twistedmatrix.com/Releases/Twisted/19.10/Twisted-19.10.0.tar.bz2 && \
    tar -xjvf Twisted-19.10.0.tar.bz2 && \
    cd Twisted-19.10.0 && \
    python setup.py install"
