---
title: Build OpenCV on Firefly-RK3399
date: 2017-05-17 12:49:56
categories:
tags:
- Firefly-RK3399
- OpenCV
---

## Install

### Required Packages

```
# compiler ✓
$ sudo apt-get install build-essential
# required ✓
$ sudo apt-get install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev

# optional ✓
$ sudo apt-get install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
```

### Getting OpenCV Source Code

```
$ git clone https://github.com/opencv/opencv.git
$ cd opencv/
$ git checkout 3.2.0
```

If use extra modules:

```
$ git clone https://github.com/opencv/opencv_contrib.git
$ cd opencv_contrib/
$ git checkout 3.2.0
```

### Building OpenCV from Source

<!-- more -->

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

<!--
$ cmake ... \
-DWITH_V4L=ON \
-DWITH_LIBV4L=ON \
...

--     V4L/V4L2:                    Using libv4l1 (ver 1.10.0) / libv4l2 (ver 1.10.0)
-->

**`cmake` result:**

```
-- General configuration for OpenCV 3.2.0 =====================================
--   Version control:               3.2.0
--
--   Extra modules:
--     Location (extra):            /home/firefly/Workspace/opencv_contrib/modules
--     Version control (extra):     3.2.0
--
--   Platform:
--     Timestamp:                   2017-05-13T13:43:22Z
--     Host:                        Linux 4.4.16 aarch64
--     CMake:                       3.5.1
--     CMake generator:             Unix Makefiles
--     CMake build tool:            /usr/bin/make
--     Configuration:               RELEASE
--
--   C/C++:
--     Built as dynamic libs?:      YES
--     C++ Compiler:                /usr/bin/c++  (ver 5.4.0)
--     C++ flags (Release):         -fsigned-char -W -Wall -Werror=return-type -Werror=non-virtual-dtor -Werror=address -Werror=sequence-point -Wformat -Werror=format-security -Wmissing-declarations -Wundef -Winit-self -Wpointer-arith -Wshadow -Wsign-promo -Wno-narrowing -Wno-delete-non-virtual-dtor -Wno-comment -fdiagnostics-show-option -pthread -fomit-frame-pointer -ffunction-sections -fvisibility=hidden -fvisibility-inlines-hidden -O3 -DNDEBUG  -DNDEBUG
--     C++ flags (Debug):           -fsigned-char -W -Wall -Werror=return-type -Werror=non-virtual-dtor -Werror=address -Werror=sequence-point -Wformat -Werror=format-security -Wmissing-declarations -Wundef -Winit-self -Wpointer-arith -Wshadow -Wsign-promo -Wno-narrowing -Wno-delete-non-virtual-dtor -Wno-comment -fdiagnostics-show-option -pthread -fomit-frame-pointer -ffunction-sections -fvisibility=hidden -fvisibility-inlines-hidden -g  -O0 -DDEBUG -D_DEBUG
--     C Compiler:                  /usr/bin/cc
--     C flags (Release):           -fsigned-char -W -Wall -Werror=return-type -Werror=non-virtual-dtor -Werror=address -Werror=sequence-point -Wformat -Werror=format-security -Wmissing-declarations -Wmissing-prototypes -Wstrict-prototypes -Wundef -Winit-self -Wpointer-arith -Wshadow -Wno-narrowing -Wno-comment -fdiagnostics-show-option -pthread -fomit-frame-pointer -ffunction-sections -fvisibility=hidden -O3 -DNDEBUG  -DNDEBUG
--     C flags (Debug):             -fsigned-char -W -Wall -Werror=return-type -Werror=non-virtual-dtor -Werror=address -Werror=sequence-point -Wformat -Werror=format-security -Wmissing-declarations -Wmissing-prototypes -Wstrict-prototypes -Wundef -Winit-self -Wpointer-arith -Wshadow -Wno-narrowing -Wno-comment -fdiagnostics-show-option -pthread -fomit-frame-pointer -ffunction-sections -fvisibility=hidden -g  -O0 -DDEBUG -D_DEBUG
--     Linker flags (Release):
--     Linker flags (Debug):
--     ccache:                      NO
--     Precompiled headers:         YES
--     Extra dependencies:          /usr/lib/aarch64-linux-gnu/libpng.so /usr/lib/aarch64-linux-gnu/libz.so /usr/lib/aarch64-linux-gnu/libtiff.so /usr/lib/aarch64-linux-gnu/libjasper.so /usr/lib/aarch64-linux-gnu/libjpeg.so gtk-x11-2.0 gdk-x11-2.0 pangocairo-1.0 atk-1.0 cairo gdk_pixbuf-2.0 gio-2.0 pangoft2-1.0 pango-1.0 gobject-2.0 glib-2.0 fontconfig freetype gthread-2.0 dc1394 avcodec-ffmpeg avformat-ffmpeg avutil-ffmpeg swscale-ffmpeg dl m pthread rt
--     3rdparty dependencies:       libwebp IlmImf tegra_hal
--
--   OpenCV modules:
--     To be built:                 core flann imgproc ml photo reg surface_matching video freetype fuzzy imgcodecs shape videoio highgui objdetect plot superres xobjdetect xphoto bgsegm bioinspired dpm face features2d line_descriptor saliency text calib3d ccalib datasets rgbd stereo videostab xfeatures2d ximgproc aruco optflow phase_unwrapping stitching structured_light python2
--     Disabled:                    world contrib_world
--     Disabled by dependency:      tracking
--     Unavailable:                 cudaarithm cudabgsegm cudacodec cudafeatures2d cudafilters cudaimgproc cudalegacy cudaobjdetect cudaoptflow cudastereo cudawarping cudev java python3 ts viz cnn_3dobj cvv dnn hdf matlab sfm
--
--   GUI:
--     QT:                          NO
--     GTK+ 2.x:                    YES (ver 2.24.30)
--     GThread :                    YES (ver 2.48.2)
--     GtkGlExt:                    NO
--     OpenGL support:              NO
--     VTK support:                 NO
--
--   Media I/O:
--     ZLib:                        /usr/lib/aarch64-linux-gnu/libz.so (ver 1.2.8)
--     JPEG:                        /usr/lib/aarch64-linux-gnu/libjpeg.so (ver )
--     WEBP:                        build (ver 0.3.1)
--     PNG:                         /usr/lib/aarch64-linux-gnu/libpng.so (ver 1.2.54)
--     TIFF:                        /usr/lib/aarch64-linux-gnu/libtiff.so (ver 42 - 4.0.6)
--     JPEG 2000:                   /usr/lib/aarch64-linux-gnu/libjasper.so (ver 1.900.1)
--     OpenEXR:                     build (ver 1.7.1)
--     GDAL:                        NO
--     GDCM:                        NO
--
--   Video I/O:
--     DC1394 1.x:                  NO
--     DC1394 2.x:                  YES (ver 2.2.4)
--     FFMPEG:                      YES
--       avcodec:                   YES (ver 56.60.100)
--       avformat:                  YES (ver 56.40.101)
--       avutil:                    YES (ver 54.31.100)
--       swscale:                   YES (ver 3.1.101)
--       avresample:                NO
--     GStreamer:                   NO
--     OpenNI:                      NO
--     OpenNI PrimeSensor Modules:  NO
--     OpenNI2:                     NO
--     PvAPI:                       NO
--     GigEVisionSDK:               NO
--     Aravis SDK:                  NO
--     UniCap:                      NO
--     UniCap ucil:                 NO
--     V4L/V4L2:                    NO/YES
--     XIMEA:                       NO
--     Xine:                        NO
--     gPhoto2:                     NO
--
--   Parallel framework:            pthreads
--
--   Other third-party libraries:
--     Use IPP:                     NO
--     Use VA:                      NO
--     Use Intel VA-API/OpenCL:     NO
--     Use Lapack:                  NO
--     Use Eigen:                   NO
--     Use Cuda:                    NO
--     Use OpenCL:                  YES
--     Use OpenVX:                  NO
--     Use custom HAL:              YES (carotene (ver 0.0.1))
--
--   OpenCL:                        <Dynamic loading of OpenCL library>
--     Include path:                /home/firefly/Workspace/opencv/3rdparty/include/opencl/1.2
--     Use AMDFFT:                  NO
--     Use AMDBLAS:                 NO
--
--   Python 2:
--     Interpreter:                 /usr/bin/python (ver 2.7.12)
--     Libraries:                   /usr/lib/aarch64-linux-gnu/libpython2.7.so (ver 2.7.12)
--     numpy:                       /usr/lib/python2.7/dist-packages/numpy/core/include/ (ver 1.11.0)
--     packages path:               lib/python2.7/dist-packages
--
--   Python 3:
--     Interpreter:                 /usr/bin/python3 (ver 3.5.2)
--
--   Python (for build):            /usr/bin/python
--
--   Java:
--     ant:                         NO
--     JNI:                         NO
--     Java wrappers:               NO
--     Java tests:                  NO
--
--   Matlab:                        Matlab not found or implicitly disabled
--
--   Tests and samples:
--     Tests:                       NO
--     Performance tests:           NO
--     C/C++ Examples:              NO
--
--   Install path:                  /usr/local
--
--   cvconfig.h is in:              /home/firefly/Workspace/opencv/build
-- -----------------------------------------------------------------
```

### Extra Links

* [Installation in Linux](http://docs.opencv.org/master/d7/d9f/tutorial_linux_install.html)

## Examples

### [Canny Edge Detection](http://docs.opencv.org/master/da/d22/tutorial_py_canny.html)

`canny.py`:

```
#!/usr/bin/env python

import cv2
import numpy as np

def main():
    img = cv2.imread('../data/messi5.jpg', 0)
    edges = cv2.Canny(img, 100, 200)

    cv2.imshow('Original & Edge', np.vstack((img, edges)))
    cv2.waitKey()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()
```

{% asset_img canny.png %}

## Appendix

### Install [pip](https://pip.pypa.io/en/stable/installing/)

```
$ python --version
Python 2.7.12

$ curl -O https://bootstrap.pypa.io/get-pip.py
$ python get-pip.py

$ vi ~/.pip/pip.conf
[global]
format=columns
index-url=http://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host=mirrors.aliyun.com
```
