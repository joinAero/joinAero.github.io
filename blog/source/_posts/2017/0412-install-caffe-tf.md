---
title: 'Install Caffe & TensorFlow with Python and CUDA'
date: 2017-04-12 17:22:25
categories:
- Tech
tags:
- Caffe
- TensorFlow
- Python
- CUDA
---

# Install Caffe & TensorFlow with Python and CUDA (macOS)

## Requirements

### Python Installation

[pyenv](https://github.com/pyenv/pyenv)

```
$ brew install pyenv
$ pyenv install --list
$ pyenv install anaconda3-4.3.1
$ pyenv global anaconda3-4.3.1
$ pyenv versions
  system
* anaconda3-4.3.1 (set by /Users/John/.pyenv/version)
```

Enable pyenv in your shell:

```
$ vi ~/.bash_profile
# eval "$(pyenv init -)"
$ exit
```

```
$ python --version
Python 3.6.0 :: Anaconda 4.3.1 (x86_64)
$ pip --version
pip 9.0.1 from /Users/John/.pyenv/versions/anaconda3-4.3.1/lib/python3.6/site-packages (python 3.6)
$ conda --version
conda 4.3.14
```

### CUDA Installation

For Mac OS X, please see [Setup GPU for Mac](https://www.tensorflow.org/versions/r0.12/get_started/os_setup.html#optional-setup-gpu-for-mac)

[CUDA Toolkit 8.0](https://developer.nvidia.com/cuda-toolkit)

[cuDNN v5](https://developer.nvidia.com/cudnn)

```
$ sudo mv include/cudnn.h /Developer/NVIDIA/CUDA-8.0/include/
$ sudo mv lib/libcudnn* /Developer/NVIDIA/CUDA-8.0/lib
$ sudo ln -s /Developer/NVIDIA/CUDA-8.0/lib/libcudnn* /usr/local/cuda/lib/
$ sudo ln -s /usr/local/cuda/lib/libcuda.dylib /usr/local/cuda/lib/libcuda.1.dylib
```

### OpenCV Installation

```
$ curl -O https://github.com/opencv/opencv/archive/3.2.0.zip
```

```
$ cd opencv
$ mkdir build
$ cd build/
$ PY3_DIR=$HOME/.pyenv/versions/anaconda3-4.3.1 && \
export CPLUS_INCLUDE_PATH=$PY3_DIR/include/python3.6m && \
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D PYTHON3_LIBRARY=$PY3_DIR/lib \
-D PYTHON3_INCLUDE_DIR=$PY3_DIR/include/python3.6m \
-D PYTHON3_EXECUTABLE=$HOME/.pyenv/shims/python \
-D BUILD_opencv_python2=OFF \
-D BUILD_opencv_python3=ON \
-D BUILD_EXAMPLES=ON \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D INSTALL_C_EXAMPLES=OFF \
..
$ make -j8
$ make install
```

Issue fixed by `export CPLUS_INCLUDE_PATH=$PY3_DIR/include/python3.6m`:

    [ 73%] Building CXX object modules/python3/CMakeFiles/opencv_python3.dir/__/src2/cv2.cpp.o
    /Users/John/Workspace/Fever/Vision/opencv/modules/python/src2/cv2.cpp:6:10: fatal error: 'Python.h' file not
          found
    #include <Python.h>
             ^
    1 error generated.

## [Caffe](http://caffe.berkeleyvision.org/)

### [Installation](http://caffe.berkeleyvision.org/installation.html)

```
$ brew install -vd snappy leveldb gflags glog szip lmdb
```

```
# with Python pycaffe needs dependencies built from source
$ brew install --build-from-source -vd protobuf --with-python
$ brew install --build-from-source -vd boost
$ brew install --build-from-source -vd boost-python --with-python3 --without-python
```

[Compilation](http://caffe.berkeleyvision.org/installation.html#compilation)

```
$ git clone https://github.com/BVLC/caffe.git
$ cd caffe/
$ git checkout rc5
```

```
$ cp Makefile.config.example Makefile.config
# Adjust Makefile.config (for example, if using Anaconda Python, or if cuDNN is desired)
```

    USE_CUDNN := 1

    OPENCV_VERSION := 3

    # brew install openblas
    BLAS := open
    BLAS_INCLUDE := $(shell brew --prefix openblas)/include
    BLAS_LIB := $(shell brew --prefix openblas)/lib

    # PYTHON_INCLUDE := /usr/include/python2.7 \
            # /usr/lib/python2.7/dist-packages/numpy/core/include

    ANACONDA_HOME := $(HOME)/.pyenv/versions/anaconda3-4.3.1
    PYTHON_INCLUDE := $(ANACONDA_HOME)/include \
            $(ANACONDA_HOME)/include/python3.6m \
            $(ANACONDA_HOME)/lib/python3.6/site-packages/numpy/core/include

    # ll /usr/local/lib/*boost*py*
    PYTHON_LIBRARIES := boost_python3 python3.6m

    # PYTHON_LIB := /usr/lib
    PYTHON_LIB := $(ANACONDA_HOME)/lib

    WITH_PYTHON_LAYER := 1

```
$ make all -j8
$ make pycaffe -j8
```

```
$ vi ~/.bash_profile
# export PYTHONPATH=$HOME/Workspace/Fever/DeepLearning/caffe/python:$PYTHONPATH
$ python
>>> import caffe
>>> caffe.__version__
'1.0.0-rc5'
# Or,
$ python -c "import caffe; print(caffe.__version__)"
1.0.0-rc5
```

### Issues

#### Issue, `make pycaffe`:

    Undefined symbols for architecture x86_64:
      "boost::python::detail::init_module(PyModuleDef&, void (*)())", referenced from:
          _PyInit__caffe in _caffe-57cf03.o
    ld: symbol(s) not found for architecture x86_64
    clang: error: linker command failed with exit code 1 (use -v to see invocation)
    make: *** [python/caffe/_caffe.so] Error 1

Solution:

```
$ brew info boost-python
$ brew reinstall boost-python --with-python3 --without-python
```

#### Issue, `import caffe`:

    >>> import caffe
    Failed to include caffe_pb2, things might go wrong!
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
      File "/Users/John/Workspace/Fever/DeepLearning/caffe/python/caffe/__init__.py", line 4, in <module>
        from .proto.caffe_pb2 import TRAIN, TEST
      File "/Users/John/Workspace/Fever/DeepLearning/caffe/python/caffe/proto/caffe_pb2.py", line 6, in <module>
        from google.protobuf.internal import enum_type_wrapper
    ModuleNotFoundError: No module named 'google'

Solution:

```
$ pip install protobuf
```

    # https://anaconda.org/anaconda/protobuf/files
    $ conda install protobuf
    Fetching package metadata .........
    Solving package specifications: .

    UnsatisfiableError: The following specifications were found to be in conflict:
      - protobuf -> python 2.7* -> openssl 1.0.1*
      - python 3.6*
    Use "conda info <package>" to see the dependencies for each package.

### Others

How display dependencies:

```
$ cd build/lib/
# ldd -r libcaffe.so.1.0.0-rc5
$ otool -L libcaffe.so.1.0.0-rc5
```

## [TensorFlow](https://www.tensorflow.org/)

### [Installation](https://www.tensorflow.org/versions/r0.12/get_started/os_setup.html#download-and-setup)

```
$ pip install tensorflow-gpu
# Or,
# tensorflow-gpu: https://pypi.python.org/pypi/tensorflow-gpu
$ export TF_BINARY_URL=https://pypi.python.org/packages/d6/54/f7cf39483b16c25a8c132dc0b81aea2ae91e367da749f17dddeaf739123a/tensorflow_gpu-1.1.0rc1-cp36-cp36m-macosx_10_11_x86_64.whl
$ pip install --upgrade $TF_BINARY_URL
```

```
$ python
...
>>> import tensorflow as tf
>>> hello = tf.constant('Hello, TensorFlow!')
>>> sess = tf.Session()
>>> print(sess.run(hello))
Hello, TensorFlow!
>>> a = tf.constant(10)
>>> b = tf.constant(32)
>>> print(sess.run(a + b))
42
>>>
```

### Issues

#### Issue, `import tensorflow`:

    >>> import tensorflow as tf
    I tensorflow/stream_executor/dso_loader.cc:135] successfully opened CUDA library libcublas.8.0.dylib locally
    I tensorflow/stream_executor/dso_loader.cc:135] successfully opened CUDA library libcudnn.5.dylib locally
    I tensorflow/stream_executor/dso_loader.cc:135] successfully opened CUDA library libcufft.8.0.dylib locally
    Segmentation fault: 11

Solution:

```
$ sudo ln -s /usr/local/cuda/lib/libcuda.dylib /usr/local/cuda/lib/libcuda.1.dylib
```

* [Installing Tensorflow with GPU support on os x 10.11](https://github.com/tensorflow/tensorflow/issues/2940)

#### Issue, "Library not loaded: @rpath/libcublas.8.0.dylib":

    ImportError: dlopen(/Users/John/.pyenv/versions/anaconda3-4.3.1/lib/python3.6/site-packages/tensorflow/python/_pywrap_tensorflow_internal.so, 10): Library not loaded: @rpath/libcublas.8.0.dylib

Solution: Disbale [SIP](https://support.apple.com/en-us/HT204899)

Reboot into "Recovery OS",

```
$ csrutil disable
```

Restart into macOS,

```
$ python -c "import tensorflow; print(tensorflow.__version__)"
1.1.0-rc1
```

### References

* [Awesome TensorFlow](https://github.com/jtoy/awesome-tensorflow)
