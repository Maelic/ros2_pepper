#!/bin/bash
PYTHON2_MAJOR_VERSION=2
PYTHON2_MINOR_VERSION=7
PYTHON2_PATCH_VERSION=17

PYTHON2_VERSION=${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.${PYTHON2_PATCH_VERSION}
BASE_ROOT=$(pwd)

if [[ -z "${BASE_ROOT}" ]]; then
  echo "BASE_ROOT is not defined"
  exit 1
fi

if [[ -z "${MAIN_ROOT}" ]]; then
  echo "MAIN_ROOT is not defined. Set to the original ros2_pepper project"
  exit 1
fi

package=""
package_option=""
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --pkg|--package)
    package="$2"
    shift
    shift
    ;;
esac
done

if [ "$package" != ""  ]; then
  package_option="--pkg $package"
fi

BASE_ROOT=/home/master/pepper_root
SYSTEM_HOST_INSTALL_ROOT="${BASE_ROOT}/"System
SYSTEM_PEPPER_INSTALL_ROOT=System

HOST_INSTALL_ROOT="${BASE_ROOT}/"User
PEPPER_INSTALL_ROOT=User

set -euf -o pipefail

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

mkdir -p ccache-build/
mkdir -p robocup_pepper_ws/src
mkdir -p robocup_pepper_ws/cmake
mkdir -p ${HOST_INSTALL_ROOT}/robocup_inst

cp ${MAIN_ROOT}/ctc-cmake-toolchain.cmake robocup_pepper_ws/
#cp ctc-robocup.cmake robocup_pepper_ws/
#cp ${MAIN_ROOT}/cmake/eigen3-config.cmake robocup_pepper_ws/cmake/




# docker run -it --rm \
#   -u $(id -u $USER) \
#   -e PYTHON2_VERSION=${PYTHON2_VERSION} \
#   -v ${PWD}/Python-${PYTHON2_VERSION}:/home/nao/Python-${PYTHON2_VERSION}-src \
#   -v ${HOST_INSTALL_ROOT}/Python-${PYTHON2_VERSION}:/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION} \
#   -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
#   ros1-pepper \
#   bash -c "\
#     wget -O - -q https://bootstrap.pypa.io/pip/2.7/get-pip.py | /home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/python && \
#     /home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/pip install opencv scikit-learn"



docker run -it --rm \
  -u $(id -u $USER) \
  -e PEPPER_INSTALL_ROOT=${PEPPER_INSTALL_ROOT} \
  -e SYSTEM_PEPPER_INSTALL_ROOT=${SYSTEM_PEPPER_INSTALL_ROOT} \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e PYTHON2_MAJOR_VERSION=${PYTHON2_MAJOR_VERSION} \
  -e PYTHON2_MINOR_VERSION=${PYTHON2_MINOR_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -v ${PWD}/ccache-build:/home/nao/.ccache \
  -v ${MAIN_ROOT}/Python-${PYTHON2_VERSION}-host:/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}:ro \
  -v ${MAIN_ROOT}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host:ro \
  -v ${SYSTEM_HOST_INSTALL_ROOT}/Python-${PYTHON2_VERSION}:/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper:ro \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc:ro \
  -v ${SYSTEM_HOST_INSTALL_ROOT}/ros1_dependencies:/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/ros1_dependencies:ro \
  -v ${SYSTEM_HOST_INSTALL_ROOT}/ros1_inst:/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/ros1_inst:ro \
  -v ${HOST_INSTALL_ROOT}/robocup_inst:/home/nao/${PEPPER_INSTALL_ROOT}/robocup_inst:rw \
  -v ${PWD}/robocup_pepper_ws:/home/nao/robocup_pepper_ws:rw \
  ros1-pepper \
  bash -c "\
    set -ef -o pipefail && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib && \
    export PATH=/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:$PATH && \
    source /home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/ros1_inst/setup.bash && \
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/ros1_dependencies/lib/pkgconfig && \
    cd robocup_pepper_ws/src && \
    cd .. &&\
    catkin_make_isolated $package_option --install --install-space /home/nao/${PEPPER_INSTALL_ROOT}/robocup_inst -DCMAKE_BUILD_TYPE=Release \
    --cmake-args \
      -DOPENSSL_ROOT_DIR=/home/nao/ctc/openssl \
      -DWITH_QT=OFF \
      -DSETUPTOOLS_DEB_LAYOUT=OFF \
      -DCATKIN_ENABLE_TESTING=OFF \
      -DENABLE_TESTING=OFF \
      -DPYTHON_EXECUTABLE=/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/python \
      -DPYTHON_LIBRARY=/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper/lib/libpython${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.so \
      -DTHIRDPARTY=ON \
      -DCMAKE_TOOLCHAIN_FILE=/home/nao/robocup_pepper_ws/ctc-cmake-toolchain.cmake \
      -DALDE_CTC_CROSS=/home/nao/ctc \
      -DCMAKE_PREFIX_PATH=\"/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/ros1_inst;\" \
      -DCMAKE_FIND_ROOT_PATH=\"/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper;/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/ros1_dependencies;/home/nao/${SYSTEM_PEPPER_INSTALL_ROOT}/ros1_inst;/home/nao/ctc\" \
    "
