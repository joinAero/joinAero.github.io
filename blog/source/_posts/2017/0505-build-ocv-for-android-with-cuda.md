---
title: Build OpenCV for Android with CUDA
date: 2017-05-05 15:31:13
categories:
- Tech
tags:
- OpenCV
- Android
- CUDA
---

```
$ export ANDROID_NDK=$ANDROID_SDK/ndk-bundle
$ export ANDROID_STANDALONE_TOOLCHAIN=$ANDROID_NDK/toolchains
```

```
$ cd opencv-3.2.0/platforms/
$ mkdir -p build_android_arm
$ cd build_android_arm/
$ cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CUDA_TOOLKIT_ROOT_DIR=$HOME/NVPACK/cuda-7.0 \
-D CUDA_ARCH_BIN="5.3" \
-D CUDA_ARCH_PTX="" \
-D CUDA_FAST_MATH=ON \
-D BUILD_DOCS=OFF \
-D BUILD_EXAMPLES=OFF \
-D BUILD_TESTS=OFF \
-D BUILD_PERF_TESTS=OFF \
-D WITH_CUDA=ON \
-D WITH_CUFFT=OFF \
-D WITH_CUBLAS=OFF \
-D WITH_OPENCL=OFF \
../..

# cmake without ccache in env
-D CMAKE_C_COMPILER=/usr/bin/cc \
-D CMAKE_CXX_COMPILER=/usr/bin/c++ \
```

```
$ cd build_android_arm/
$ make -j8
$ make -j$(python -c 'import multiprocessing as mp; print(mp.cpu_count())')
```

Alternatives:

```
$ cd opencv-3.2.0/platforms/
$ ./scripts/cmake_android_arm.sh

# Tegra X1: https://developer.nvidia.com/content/tegra-x1
-D CUDA_GENERATION=Maxwell

# ARM
-D CUDA_ARCH_BIN="3.2"
-D CUDA_ARCH_PTX=""

# AARCH64
-D CUDA_ARCH_BIN="5.3"
-D CUDA_ARCH_PTX=""
```

## Usage

* "Import Module" from "build_android_arm" directory.
    - Exclude "jni", only keep "aidl", "java", "res/values/attrs.xml"

## References

* [OpenCV Platforms Android](http://opencv.org/platforms/android/)
* [Building OpenCV4Android from trunk](http://code.opencv.org/projects/opencv/wiki/Building_OpenCV4Android_from_trunk)
* [Building OpenCV & OpenCV Extra Modules For Android From Source](https://zami0xzami.wordpress.com/2016/03/17/building-opencv-for-android-from-source/)

* [Building OpenCV for Tegra with CUDA](http://docs.opencv.org/master/d6/d15/tutorial_building_tegra_cuda.html)
