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

## Prerequisites

* Ubuntu 14.04 LTS
    * [Download here](https://wiki.ubuntu.com/TrustyTahr/ReleaseNotes)
* NVIDIA CodeWorks for Android 1R4
    * [Doc here](https://docs.nvidia.com/gameworks/index.html#developertools/mobile/codeworks_android/codeworks_android_1r4.htm)
    * [Download here](https://developer.nvidia.com/codeworks-android-archive)
    * Could only select actions: CUDA ToolKit 7.0, CUDA for Android 7.0
* [Android Studio](https://developer.android.com/studio/index.html)
    * [Add C and C++ Code to Your Project](https://developer.android.com/studio/projects/add-native-code.html)

## Prepare

```
# Set environment variables
$ vi ~/.bashrc
# Android SDK & NDK
export ANDROID_SDK=$HOME/Android/Sdk
export ANDROID_NDK=$ANDROID_SDK/ndk-bundle
export ANDROID_STANDALONE_TOOLCHAIN=$ANDROID_NDK/toolchains
export PATH=$PATH:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools:$ANDROID_NDK
# Java SDK 1.8 (could ignore, for latest android command-line tool)
export JAVA_HOME=$HOME/Develop/jdk1.8.0_131
export PATH=$JAVA_HOME/bin:$PATH
$ source ~/.bashrc

# Enable OpenCV Java wrappers
$ sudo apt-get install ant

# Downgrade android command-line tool
$ cd $ANDROID_SDK
$ mv tools/ tools-backup/
$ curl -O https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
$ unzip -q tools_r25.2.3-linux.zip
```

## Build

```
$ cd opencv-3.2.0/platforms/
$ mkdir -p build_android_arm
$ cd build_android_arm/
$ cmake -DCMAKE_BUILD_TYPE=RELEASE \
-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
-DCMAKE_TOOLCHAIN_FILE=../android/android.toolchain.cmake \
\
-DCUDA_TOOLKIT_ROOT_DIR=$HOME/NVPACK/cuda-7.0 \
-DCUDA_ARCH_BIN="5.3" \
-DCUDA_ARCH_PTX="" \
-DCUDA_FAST_MATH=ON \
-DWITH_CUDA=ON \
-DWITH_CUFFT=OFF \
-DWITH_CUBLAS=OFF \
-DWITH_OPENCL=OFF \
\
-DBUILD_SHARED_LIBS=OFF \
-DBUILD_DOCS=OFF \
-DBUILD_EXAMPLES=OFF \
-DBUILD_TESTS=OFF \
-DBUILD_PERF_TESTS=OFF \
../..
```

Result:

```
-- General configuration for OpenCV 3.2.0 =====================================
--   Version control:               unknown
--
--   Platform:
--     Timestamp:                   2017-05-05T05:05:05Z
--     Host:                        Linux 4.4.0-75-generic x86_64
--     Target:                      Linux 1 armv7-a
--     CMake:                       2.8.12.2
--     CMake generator:             Unix Makefiles
--     CMake build tool:            /usr/bin/make
--     Configuration:               RELEASE
--
--   C/C++:
--     Built as dynamic libs?:      NO
--     C++ Compiler:                /home/john/Android/Sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-g++  (ver 4.9)
--     C++ flags (Release):         -fexceptions -frtti -fpic -Wno-psabi --sysroot=/home/john/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm -funwind-tables -finline-limit=64 -fsigned-char -no-canonical-prefixes -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fdata-sections -ffunction-sections -Wa,--noexecstack    -fsigned-char -W -Wall -Werror=return-type -Werror=non-virtual-dtor -Werror=address -Werror=sequence-point -Wformat -Werror=format-security -Wmissing-declarations -Wundef -Winit-self -Wpointer-arith -Wshadow -Wsign-promo -Wno-narrowing -Wno-delete-non-virtual-dtor -Wno-comment -fdiagnostics-show-option -fomit-frame-pointer -mfp16-format=ieee -fvisibility=hidden -fvisibility-inlines-hidden -mthumb -fomit-frame-pointer -fno-strict-aliasing -O3 -DNDEBUG  -DNDEBUG
--     C++ flags (Debug):           -fexceptions -frtti -fpic -Wno-psabi --sysroot=/home/john/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm -funwind-tables -finline-limit=64 -fsigned-char -no-canonical-prefixes -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fdata-sections -ffunction-sections -Wa,--noexecstack    -fsigned-char -W -Wall -Werror=return-type -Werror=non-virtual-dtor -Werror=address -Werror=sequence-point -Wformat -Werror=format-security -Wmissing-declarations -Wundef -Winit-self -Wpointer-arith -Wshadow -Wsign-promo -Wno-narrowing -Wno-delete-non-virtual-dtor -Wno-comment -fdiagnostics-show-option -fomit-frame-pointer -mfp16-format=ieee -fvisibility=hidden -fvisibility-inlines-hidden -marm -fno-omit-frame-pointer -fno-strict-aliasing -O0 -g -DDEBUG -D_DEBUG  -O0 -DDEBUG -D_DEBUG
--     C Compiler:                  /home/john/Android/Sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc
--     C flags (Release):           -fexceptions -fpic -Wno-psabi --sysroot=/home/john/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm -funwind-tables -finline-limit=64 -fsigned-char -no-canonical-prefixes -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fdata-sections -ffunction-sections -Wa,--noexecstack    -fsigned-char -W -Wall -Werror=return-type -Werror=non-virtual-dtor -Werror=address -Werror=sequence-point -Wformat -Werror=format-security -Wmissing-declarations -Wmissing-prototypes -Wstrict-prototypes -Wundef -Winit-self -Wpointer-arith -Wshadow -Wno-narrowing -Wno-comment -fdiagnostics-show-option -fomit-frame-pointer -mfp16-format=ieee -fvisibility=hidden -mthumb -fomit-frame-pointer -fno-strict-aliasing -O3 -DNDEBUG  -DNDEBUG
--     C flags (Debug):             -fexceptions -fpic -Wno-psabi --sysroot=/home/john/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm -funwind-tables -finline-limit=64 -fsigned-char -no-canonical-prefixes -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fdata-sections -ffunction-sections -Wa,--noexecstack    -fsigned-char -W -Wall -Werror=return-type -Werror=non-virtual-dtor -Werror=address -Werror=sequence-point -Wformat -Werror=format-security -Wmissing-declarations -Wmissing-prototypes -Wstrict-prototypes -Wundef -Winit-self -Wpointer-arith -Wshadow -Wno-narrowing -Wno-comment -fdiagnostics-show-option -fomit-frame-pointer -mfp16-format=ieee -fvisibility=hidden -marm -fno-omit-frame-pointer -fno-strict-aliasing -O0 -g -DDEBUG -D_DEBUG  -O0 -DDEBUG -D_DEBUG
--     Linker flags (Release):      -Wl,--fix-cortex-a8 -Wl,--no-undefined -Wl,-allow-shlib-undefined -Wl,--gc-sections -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now
--     Linker flags (Debug):        -Wl,--fix-cortex-a8 -Wl,--no-undefined -Wl,-allow-shlib-undefined -Wl,--gc-sections -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now
--     ccache:                      YES
--     Precompiled headers:         NO
--     Extra dependencies:          z dl m log cudart nppc nppi npps -L/home/john/NVPACK/cuda-7.0/targets/armv7-linux-androideabi/lib -L/home/john/NVPACK/cuda-7.0/targets/armv7-linux-androideabi/lib/stubs
--     3rdparty dependencies:       libjpeg libwebp libpng libtiff libjasper IlmImf tegra_hal
--
--   OpenCV modules:
--     To be built:                 cudev core cudaarithm flann imgproc ml video cudabgsegm cudafilters cudaimgproc cudawarping imgcodecs photo shape videoio cudacodec highgui objdetect features2d calib3d cudafeatures2d cudalegacy cudaobjdetect cudaoptflow cudastereo java stitching superres videostab
--     Disabled:                    world
--     Disabled by dependency:      -
--     Unavailable:                 python2 ts viz
--
--   Android:
--     Android ABI:                 armeabi-v7a
--     STL type:                    gnustl_static
--     Native API level:            android-9
--     SDK target:                  android-21
--     Android NDK:                 /home/john/Android/Sdk/ndk-bundle (toolchain: arm-linux-androideabi-4.9)
--     android tool:                /home/john/Android/Sdk/tools/android (Android SDK Tools, revision 25.2.3.)
--     Google Play manager:         NO
--     Android examples:            YES
--
--   GUI:
--     GTK+:                        NO
--     GThread :                    NO
--     GtkGlExt:                    NO
--     OpenGL support:              NO
--     VTK support:                 NO
--
--   Media I/O:
--     ZLib:                        z (ver 1.2.3)
--     JPEG:                        build (ver 90)
--     WEBP:                        build (ver 0.3.1)
--     PNG:                         build (ver 1.6.24)
--     TIFF:                        build (ver 42 - 4.0.2)
--     JPEG 2000:                   build (ver 1.900.1)
--     OpenEXR:                     build (ver 1.7.1)
--     GDAL:                        NO
--     GDCM:                        NO
--
--   Video I/O:
--
--   Parallel framework:            pthreads
--
--   Other third-party libraries:
--     Use IPP:                     NO
--     Use Eigen:                   YES (ver 3.2.0)
--     Use Cuda:                    YES (ver 7.0)
--     Use OpenCL:                  NO
--     Use OpenVX:                  NO
--     Use custom HAL:              YES (carotene (ver 0.0.1))
--
--   NVIDIA CUDA
--     Use CUFFT:                   NO
--     Use CUBLAS:                  NO
--     USE NVCUVID:                 NO
--     NVIDIA GPU arch:             53
--     NVIDIA PTX archs:
--     Use fast math:               YES
--
--   Python 2:
--     Interpreter:                 /usr/bin/python2.7 (ver 2.7.6)
--
--   Python 3:
--     Interpreter:                 /usr/bin/python3.4 (ver 3.4.3)
--
--   Python (for build):            /usr/bin/python2.7
--
--   Java:
--     ant:                         /usr/bin/ant (ver 1.9.3)
--     Java wrappers:               YES
--     Java tests:                  NO
--
--   Matlab:                        NO
--
--   Tests and samples:
--     Tests:                       NO
--     Performance tests:           NO
--     C/C++ Examples:              NO
--
--   Install path:                  /home/john/Workspace/opencv-3.2.0/platforms/build_android_arm/install
--
--   cvconfig.h is in:              /home/john/Workspace/opencv-3.2.0/platforms/build_android_arm
-- -----------------------------------------------------------------
```

Make:

```
$ make -j8
# Or,
$ make -j$(python -c 'import multiprocessing as mp; print(mp.cpu_count())')
```

Alternatives (ignored):

```
$ cd opencv-3.2.0/platforms/
$ ./scripts/cmake_android_arm.sh

# Tegra X1: https://developer.nvidia.com/content/tegra-x1
-D CUDA_GENERATION=Maxwell
```

## Usage

Open "Android Studio" and,

* "Import Module" from "build_android_arm" directory.
    - Exclude "jni", only keep "aidl", "java", "res/values/attrs.xml"

Ensure it's the same file structure as the offical [OpenCV4Android](http://opencv.org/platforms/android/).

About the sample project, you could find [here](https://github.com/joinAero/DroidTurbo/tree/master-cuda).

## Issues

### Issue when `cmake`

    Failed to get list of installed Android targets.

    CMake Warning at cmake/OpenCVDetectAndroidSDK.cmake:205 (message):
      Can not find any SDK target compatible with: 9 11

And,

```
$ android list target -c
*************************************************************************
The "android" command is deprecated.
For manual SDK, AVD, and project management, please use Android Studio.
For command-line tools, use tools/bin/sdkmanager and tools/bin/avdmanager
*************************************************************************
Running /home/john/Android/Sdk/tools/bin/avdmanager list target -c

Exception in thread "main" java.lang.UnsupportedClassVersionError: com/android/sdklib/tool/AvdManagerCli : Unsupported major.minor version 52.0
    at java.lang.ClassLoader.defineClass1(Native Method)
    at java.lang.ClassLoader.defineClass(ClassLoader.java:803)
    at java.security.SecureClassLoader.defineClass(SecureClassLoader.java:142)
    at java.net.URLClassLoader.defineClass(URLClassLoader.java:442)
    at java.net.URLClassLoader.access$100(URLClassLoader.java:64)
    at java.net.URLClassLoader$1.run(URLClassLoader.java:354)
    at java.net.URLClassLoader$1.run(URLClassLoader.java:348)
    at java.security.AccessController.doPrivileged(Native Method)
    at java.net.URLClassLoader.findClass(URLClassLoader.java:347)
    at java.lang.ClassLoader.loadClass(ClassLoader.java:425)
    at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:308)
    at java.lang.ClassLoader.loadClass(ClassLoader.java:358)
    at sun.launcher.LauncherHelper.checkAndLoadMain(LauncherHelper.java:482)
```

Solution:

* Install Java SDK 1.8
    - Fix "UnsupportedClassVersionError ..."
* Amend match of android sdk targets
    ```
    $ cd opencv-3.2.0/
    $ vi cmake/OpenCVDetectAndroidSDK.cmake
    # line 98, change "[^\n]+" to "android-[0-9]+"
    string(REGEX MATCHALL "android-[0-9]+" ANDROID_SDK_TARGETS "${ANDROID_SDK_TARGETS}")
    ```
    - Or, `cmake` with `-DANDROID_EXECUTABLE=$ANDROID_SDK/tools/bin/avdmanager`
    - WARN： However, `make` still will fail in "Generating OpenCV Android library project."

### Issue when `make`

    [ 92%] Generating OpenCV Android library project. SDK target: android-21
    *************************************************************************
    The "android" command is deprecated.
    For manual SDK, AVD, and project management, please use Android Studio.
    For command-line tools, use tools/bin/sdkmanager and tools/bin/avdmanager
    *************************************************************************
    Invalid or unsupported command "--silent create lib-project --path /home/john/Workspace/opencv-3.2.0/platforms/build_android_arm --target android-21 --name OpenCV --package org.opencv"

    Supported commands are:
    android list target
    android list avd
    android list device
    android create avd
    android move avd
    android delete avd
    android list sdk
    android update sdk
    make[2]: *** [build.xml] Error 2
    make[1]: *** [modules/java/CMakeFiles/opencv_java.dir/all] Error 2
    make: *** [all] Error 2

Solution:

* Downgrade [android](https://developer.android.com/studio/tools/help/android.html) command-line tool
    ```
    $ cd $ANDROID_SDK
    $ mv tools/ tools-backup/

    $ curl -O https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
    $ unzip -q tools_r25.2.3-linux.zip
    ```

Learn more:

* [Tools 25.3.1 deprecation of 'android' command line tool breaks Unity3D build](https://issuetracker.google.com/issues/37137207)

## References

* [OpenCV Platforms Android](http://opencv.org/platforms/android/)
* [Building OpenCV4Android from trunk](http://code.opencv.org/projects/opencv/wiki/Building_OpenCV4Android_from_trunk)
* [Building OpenCV & OpenCV Extra Modules For Android From Source](https://zami0xzami.wordpress.com/2016/03/17/building-opencv-for-android-from-source/)
* [Building OpenCV for Tegra with CUDA](http://docs.opencv.org/master/d6/d15/tutorial_building_tegra_cuda.html)
