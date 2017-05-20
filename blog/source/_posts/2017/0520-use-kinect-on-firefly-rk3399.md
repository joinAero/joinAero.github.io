---
title: Use Kinect on Firefly-RK3399
date: 2017-05-20 13:09:46
categories:
- Tech
tags:
- Firefly-RK3399
- OpenCV
- OpenNI2
- libfreenect
---

## Preparation

{% raw %}
<style type="text/css">
.post-body .fancybox img { margin: 0 auto 25px; }
</style>
{% endraw %}

### Install [libfreenect](https://github.com/OpenKinect/libfreenect)

> Note:
> &nbsp;&nbsp;libfreenect  for Kinect Xbox 360
> &nbsp;&nbsp;libfreenect2 for Kinect Xbox One

```
# download latest code, instead of latest release v0.5.5
$ git clone https://github.com/OpenKinect/libfreenect.git
$ cd libfreenect/

# fix issue with OpenCV, in line 173
$ vi OpenNI2-FreenectDriver/src/DepthStream.hpp

        case XN_STREAM_PROPERTY_ZERO_PLANE_DISTANCE:    // unsigned long long or unsigned int (for OpenNI2/OpenCV)
          if (*pDataSize != sizeof(unsigned long long) && *pDataSize != sizeof(unsigned int))
          {
            LogError("Unexpected size for XN_STREAM_PROPERTY_ZERO_PLANE_DISTANCE");
            return ONI_STATUS_ERROR;
          } else {
            if (*pDataSize != sizeof(unsigned long long)) {
              *(static_cast<unsigned long long*>(data)) = ZERO_PLANE_DISTANCE_VAL;
            } else {
              *(static_cast<unsigned int*>(data)) = (unsigned int) ZERO_PLANE_DISTANCE_VAL;
            }
          }
          return ONI_STATUS_OK;

# build
$ mkdir build
$ cd build
$ cmake -DBUILD_OPENNI2_DRIVER=ON ..
$ make

# preview
$ ./bin/freenect-glview
```

<!-- more -->

{% asset_img freenect-glview.png %}

### Install [OpenNI](https://structure.io/openni)

```
# download this, aarch64 platform support
$ git clone -b develop https://github.com/joinAero/OpenNI2.git
$ cd OpenNI2/

# deps
$ sudo apt-get install libudev-dev
# or, all
$ sudo apt-get install \
    g++              \
    python           \
    libusb-1.0-0-dev \
    libudev-dev      \
    openjdk-6-jdk    \
    freeglut3-dev    \
    doxygen          \
    graphviz

# build
$ make

# setup
$ echo "export OPENNI2_INCLUDE=`pwd`/Include" >> ~/.bashrc
$ echo "export OPENNI2_REDIST=`pwd`/Bin/AArch64-Release" >> ~/.bashrc
```

Then, copy the freenect driver to OpenNI2 driver repository:

```
$ cd libfreenect/build/
$ cd lib/OpenNI2-FreenectDriver/

$ export FREENECT_DRIVER_LIB=libFreenectDriver.so
$ export FREENECT_DRIVER_REAL_LIB=$(python - <<'EOF'
import os
lib = os.environ['FREENECT_DRIVER_LIB']
while os.path.islink(lib):
    lib = os.readlink(lib)
print(lib)
EOF
)
$ ln -sf `pwd`/$FREENECT_DRIVER_REAL_LIB $OPENNI2_REDIST/OpenNI2/Drivers/$FREENECT_DRIVER_LIB
```

<!--
# ARM options: https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html
# AArch64 Options: https://gcc.gnu.org/onlinedocs/gcc-7.1.0/gcc/AArch64-Options.html
# `cat /proc/cpuinfo`
# `lscpu`
-->

### Build OpenCV with OpenNI

> NOTE: Please see how to [Build OpenCV on Firefly-RK3399](http://eevee.cc/2017/05/17/build-opencv-on-firefly-rk3399/).

```
$ cd opencv/
$ mkdir build
$ cd build/

$ export PY_NAME=$(python -c 'from sys import version_info as v; print("python%d.%d" % v[:2])')
$ export PY_NUMPY_DIR=$(python -c 'import os.path, numpy.core; print(os.path.dirname(numpy.core.__file__))')

$ cmake -DCMAKE_BUILD_TYPE=RELEASE \
-DCMAKE_INSTALL_PREFIX=/usr/local \
\
-DPYTHON2_EXECUTABLE=$(which python) \
-DPYTHON_INCLUDE_DIR=/usr/include/$PY_NAME \
-DPYTHON_INCLUDE_DIR2=/usr/include/aarch64-linux-gnu/$PY_NAME \
-DPYTHON_LIBRARY=/usr/lib/aarch64-linux-gnu/lib$PY_NAME.so \
-DPYTHON2_NUMPY_INCLUDE_DIRS=/usr/lib/$PY_NAME/dist-packages/numpy/core/include/ \
\
-DWITH_OPENNI2=ON \
\
-DBUILD_DOCS=OFF \
-DBUILD_EXAMPLES=OFF \
-DBUILD_TESTS=OFF \
-DBUILD_PERF_TESTS=OFF \
\
-DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
..

$ make -j$(nproc --all)
$ sudo make install
```

## Usage

### C++

`kinect.cc`:

```
#include "camera.hpp"

int main(int argc, char const *argv[]) {
    Camera cam(cv::CAP_OPENNI2);
    if (!cam.IsOpened()) {
        std::cerr << "ERROR: Open camera failed" << std::endl;
        return 1;
    }
    std::cout << "\033[1;32mPress ESC/Q to terminate\033[0m\n\n";

    double min, max;
    cv::Mat adjmap, colormap;
    cam.Capture([&](const cv::Mat& frame, const cv::Mat& depthmap) {
        cv::minMaxIdx(depthmap, &min, &max);
        const float scale = 255 / (max-min);
        depthmap.convertTo(adjmap, CV_8UC1, scale, -min*scale);

        //applyColorMap(adjmap, colormap, cv::COLORMAP_AUTUMN);

        cam.DrawInfo(frame);
        cam.DrawInfo(adjmap);
        cv::imshow("frame", frame);
        cv::imshow("depthmap", adjmap);

        const int key = cv::waitKey(10);
        return !(key == 27 || key == 'q' || key == 'Q'); // ESC/Q
    });

    return 0;
}
```

`./build/bin/kinect`:

{% asset_img kinect-sample.png %}

Could get complete C++ code [here](https://gist.github.com/joinAero/40f2bf867b8d7beed2d2c5de3b6f933a), Python code [here](https://gist.github.com/joinAero/1f76844278f141cea8338d1118423648).

> NOTE: Unable to retrieve correct image using Python code now. Please see this [issue](https://github.com/opencv/opencv/issues/4735).

## References

* [Using Kinect and other OpenNI compatible depth sensors](http://docs.opencv.org/master/d7/d6f/tutorial_kinect_openni.html)
* [OpenNI2 with OpenCV 3 (macOS)](http://stackoverflow.com/questions/37946618/openni2-with-opencv-3)
    - How to use Kinect using OpenNI2 with OpenCV 3 on macOS

## Issues

### Failed to use libfreenect form `sudo apt-get install freenect`

**Install:**

```
$ sudo apt-get install freenect

$ apt-cache show freenect
$ dpkg -L freenect
$ dpkg -L libfreenect-bin
$ dpkg -L libfreenect-dev
$ dpkg -L libfreenect0.5
$ dpkg -L libfreenect-doc
```

**Cause:** not install freenect driver.

### Failed to build libfreenect on Firefly-RK3399 (aarch64)

**Error when build libfreenect:**

    [ 94%] Building CXX object OpenNI2-FreenectDriver/CMakeFiles/FreenectDriver.dir/src/ColorStream.cpp.o
    In file included from /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/extern/OpenNI-Linux-x64-2.2.0.33/Include/Driver/OniDriverAPI.h:24:0,
                     from /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/src/ColorStream.hpp:6,
                     from /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/src/ColorStream.cpp:2:
    /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/extern/OpenNI-Linux-x64-2.2.0.33/Include/OniPlatform.h:49:3: error: #error Xiron Platform Abstraction Layer - Unsupported Platform!
     # error Xiron Platform Abstraction Layer - Unsupported Platform!
       ^
    In file included from /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/extern/OpenNI-Linux-x64-2.2.0.33/Include/Driver/OniDriverAPI.h:25:0,
                     from /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/src/ColorStream.hpp:6,
                     from /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/src/ColorStream.cpp:2:
    /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/extern/OpenNI-Linux-x64-2.2.0.33/Include/OniCTypes.h:115:32: error: expected ')' before '*' token
     typedef void (ONI_CALLBACK_TYPE* OniNewFrameCallback)(OniStreamHandle stream, void* pCookie);
                                    ^
    ...
    In file included from /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/src/ColorStream.hpp:7:0,
                     from /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/src/ColorStream.cpp:2:
    /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/src/VideoStream.hpp: In constructor 'FreenectDriver::VideoStream::VideoStream(Freenect::FreenectDevice*)':
    /home/firefly/Workspace/libfreenect-0.5.5/OpenNI2-FreenectDriver/src/VideoStream.hpp:34:46: error: 'memset' was not declared in this scope
             memset(&cropping, 0, sizeof(cropping));
                                                  ^
    OpenNI2-FreenectDriver/CMakeFiles/FreenectDriver.dir/build.make:62: recipe for target 'OpenNI2-FreenectDriver/CMakeFiles/FreenectDriver.dir/src/ColorStream.cpp.o' failed
    make[2]: *** [OpenNI2-FreenectDriver/CMakeFiles/FreenectDriver.dir/src/ColorStream.cpp.o] Error 1
    CMakeFiles/Makefile2:902: recipe for target 'OpenNI2-FreenectDriver/CMakeFiles/FreenectDriver.dir/all' failed
    make[1]: *** [OpenNI2-FreenectDriver/CMakeFiles/FreenectDriver.dir/all] Error 2
    Makefile:127: recipe for target 'all' failed
    make: *** [all] Error 2

**Case:** not support aarch64 platform if build from latest release v0.5.5.

**Solution:** use latest code instead of latest release v0.5.5.

See this commit, [OpenNI2: Add aarch64 platform detection](https://github.com/OpenKinect/libfreenect/commit/873a2cc6f625221d34856c6574a959cfe8277a1e).

### Failed to use OpenNI2 from `sudo apt-get install libopenni2-dev`

**Install:**

```
# install
$ sudo apt-get install libopenni2-dev

$ apt-cache show libopenni2-dev
$ dpkg -L libopenni2-dev

# copy driver
$ cd libfreenect/build/
$ cd lib/OpenNI2-FreenectDriver/
$ export FREENECT_DRIVER_LIB=libFreenectDriver.so
$ export FREENECT_DRIVER_REAL_LIB=$(python - <<'EOF'
import os
lib = os.environ['FREENECT_DRIVER_LIB']
while os.path.islink(lib):
    lib = os.readlink(lib)
print(lib)
EOF
)
$ ln -sf `pwd`/$FREENECT_DRIVER_REAL_LIB /usr/lib/OpenNI2/Drivers/$FREENECT_DRIVER_LIB
```

**Error when run sample:**

    OpenCV Error: Unspecified error (OpenCVKinect: Device open failed see:  DeviceOpen using default: no devices found

    ) in CvCapture_OpenNI2, file /home/firefly/Workspace/opencv/modules/videoio/src/cap_openni2.cpp, line 237
    VIDEOIO(cvCreateCameraCapture_OpenNI2(index)): raised OpenCV exception:

    /home/firefly/Workspace/opencv/modules/videoio/src/cap_openni2.cpp:237: error: (-2) OpenCVKinect: Device open failed see:   DeviceOpen using default: no devices found

     in function CvCapture_OpenNI2

**Case:** not found freenect driver! why?

### Failed to use OpenNI2 from `OpenNI-Linux-Arm-2.2.0.33.tar.bz2`

**Install:**

```
# download
$ curl -O https://s3.amazonaws.com/com.occipital.openni/OpenNI-Linux-Arm-2.2.0.33.tar.bz2
$ tar jxf OpenNI-Linux-Arm-2.2.0.33.tar.bz2
$ cd OpenNI-Linux-Arm-2.2/

# install
$ sudo ./install.sh
$ cat OpenNIDevEnvironment >> ~/.bashrc
$ source ~/.bashrc
```

* [OpenNI2 Wiki](http://wiki.icub.org/wiki/OpenNI2)

Then, copy the freenect driver to OpenNI2 driver repository:

```
$ cd libfreenect/build/
$ cd lib/OpenNI2-FreenectDriver/

$ export FREENECT_DRIVER_LIB=libFreenectDriver.so
$ export FREENECT_DRIVER_REAL_LIB=$(python - <<'EOF'
import os
lib = os.environ['FREENECT_DRIVER_LIB']
while os.path.islink(lib):
    lib = os.readlink(lib)
print(lib)
EOF
)
$ ln -sf `pwd`/$FREENECT_DRIVER_REAL_LIB $OPENNI2_REDIST/OpenNI2/Drivers/$FREENECT_DRIVER_LIB
```

**Error when rebuild OpenCV:**

    [ 61%] Building CXX object modules/videoio/CMakeFiles/opencv_videoio.dir/src/cap_openni2.cpp.o
    In file included from /home/firefly/Workspace/OpenNI-Linux-Arm-2.2/Include/OpenNI.h:24:0,
                     from /home/firefly/Workspace/opencv/modules/videoio/src/cap_openni2.cpp:69:
    /home/firefly/Workspace/OpenNI-Linux-Arm-2.2/Include/OniPlatform.h:49:3: error: #error Xiron Platform Abstraction Layer - Unsupported Platform!
     # error Xiron Platform Abstraction Layer - Unsupported Platform!
       ^
    In file included from /home/firefly/Workspace/OpenNI-Linux-Arm-2.2/Include/OniCAPI.h:25:0,
                     from /home/firefly/Workspace/OpenNI-Linux-Arm-2.2/Include/OpenNI.h:28,
                     from /home/firefly/Workspace/opencv/modules/videoio/src/cap_openni2.cpp:69:
    /home/firefly/Workspace/OpenNI-Linux-Arm-2.2/Include/OniCTypes.h:115:32: error: expected ')' before '*' token
     typedef void (ONI_CALLBACK_TYPE* OniNewFrameCallback)(OniStreamHandle stream, void* pCookie);
                                    ^
    ...
    /home/firefly/Workspace/opencv/modules/videoio/src/cap_openni2.cpp: In member function 'bool CvCapture_OpenNI2::setDepthGeneratorProperty(int, double)':
    /home/firefly/Workspace/opencv/modules/videoio/src/cap_openni2.cpp:612:60: warning: logical not is only applied to the left hand side of comparison [-Wlogical-not-parentheses]
                         if( !device.getImageRegistrationMode() == mode )
                                                                ^
    modules/videoio/CMakeFiles/opencv_videoio.dir/build.make:206: recipe for target 'modules/videoio/CMakeFiles/opencv_videoio.dir/src/cap_openni2.cpp.o' failed
    make[2]: *** [modules/videoio/CMakeFiles/opencv_videoio.dir/src/cap_openni2.cpp.o] Error 1
    CMakeFiles/Makefile2:3987: recipe for target 'modules/videoio/CMakeFiles/opencv_videoio.dir/all' failed
    make[1]: *** [modules/videoio/CMakeFiles/opencv_videoio.dir/all] Error 2

**Case:** not support aarch64 platform.

**Solution:**

```
$ cd OpenNI-Linux-Arm-2.2
# add `__aarch64__` in line 42
$ vi Include/OniPlatform.h

#elif (__linux__ && (__arm__ || __aarch64__))
```

**Error when rebuild OpenCV again:**

    [ 60%] Linking CXX shared library ../../lib/libopencv_videoio.so
    /usr/bin/ld: skipping incompatible /home/firefly/Workspace/OpenNI-Linux-Arm-2.2/Redist/libOpenNI2.so when searching for -lOpenNI2
    /usr/bin/ld: cannot find -lOpenNI2
    collect2: error: ld returned 1 exit status
    modules/videoio/CMakeFiles/opencv_videoio.dir/build.make:281: recipe for target 'lib/libopencv_videoio.so.3.2.0' failed
    make[2]: *** [lib/libopencv_videoio.so.3.2.0] Error 1
    CMakeFiles/Makefile2:3987: recipe for target 'modules/videoio/CMakeFiles/opencv_videoio.dir/all' failed
    make[1]: *** [modules/videoio/CMakeFiles/opencv_videoio.dir/all] Error 2
    Makefile:149: recipe for target 'all' failed
    make: *** [all] Error 2

**Case:** not incompatible "libOpenNI2.so".

**Solution:** build form source.

### Failed to use libfreenect with OpenNI2 (from source)

**Error when run sample:**

    OpenNI2-FreenectDriver: (ERROR) Unexpected size for XN_STREAM_PROPERTY_ZERO_PLANE_DISTANCE
    OpenCV Error: Unspecified error (CvCapture_OpenNI2::readCamerasParams : Could not read virtual plane distance!
    ) in readCamerasParams, file /home/firefly/Workspace/opencv/modules/videoio/src/cap_openni2.cpp, line 404
    write_register: 0x0005 <= 0x00
    write_register: 0x0006 <= 0x00
    OpenNI2-FreenectDriver: Closing device freenect://0
    VIDEOIO(cvCreateCameraCapture_OpenNI2(index)): raised OpenCV exception:

    /home/firefly/Workspace/opencv/modules/videoio/src/cap_openni2.cpp:404: error: (-2) CvCapture_OpenNI2::readCamerasParams : Could not read virtual plane distance!
     in function readCamerasParams

**Solution:** fix this issue, plz see [here](http://stackoverflow.com/questions/33657103/using-microsoft-kinect-with-opencv-3-0-0).
