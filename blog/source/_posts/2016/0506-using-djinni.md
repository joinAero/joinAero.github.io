---
title: '使用 Djinni 开发 Android, iOS 共享库'
date: 2016-05-06 15:30:41
categories:
- Tech
tags:
- Djinni
- Cpp
- Android
- iOS
---

> 版权声明：[署名-非商业性使用-禁止演绎 4.0 国际 (CC BY-NC-ND 4.0)](http://creativecommons.org/licenses/by-nc-nd/4.0/deed.zh)

{% raw %}
<style type="text/css">
.post-body .fancybox img {
    margin: 0 auto 25px;
}
</style>
{% endraw %}


[Djinni]: https://github.com/dropbox/djinni


[Djinni][] 是一个用来生成跨语言的类型声明和接口绑定的工具，主要用于 C++ 和 Java 以及 Objective-C 间的互通。

此文，将介绍如何使用 [Djinni][] 开发 Android, iOS 的共享库。这会带来几个好处：

* 用了接口描述文件。声明清晰、修改简易，并保证了跨平台接口的一致性。
* 自动生成接口绑定代码。免去了绑定 C++ 和 Java (JNI) 及 Objective-C (Objective-C++) 的麻烦。


## 初见：Djinni 及其样例

### 下载 Djinni

``` bash
$ git clone https://github.com/dropbox/djinni.git
```

### 编译 Djinni

``` bash
$ cd [djinni_root]/
$ src/build
```

于`[djinni_root]/src/support/sbt.resolvers.properties`内可添加镜像源。

* [sbt下载慢？](http://www.zhihu.com/question/31158252)

### 使用 Djinni

生成样例接口代码：

``` bash
$ cd [djinni_root]/example/  # example_root
$ ./run_djinni.sh
```

即会生成到`djinni-output-temp`临时目录，最终复制到`generated-src`生成目录。

这里可以看到：依据描述文件`example.djinni`，C++ 和 Java 及 Objective-C 的绑定代码都会自动生成好。继续要做的，只是写它们的具体实现，见样例的`handwritten-src`目录。

如果要清除输出目录：

``` bash
$ ./run_djinni.sh clean
```

### 编译样例

`[djinni_root]/Makefile`已配置好了依赖，执行相应目标即可。

``` bash
$ cd [djinni_root]/
```

> 注：下载好 Djinni ，即可开始编译样例了。

编译 Android 工程：

``` bash
$ make example_android
```

样例的 Android 工程在`[example_root]/android`目录， 动态库生成在`[example_root]/android/app/libs`目录。或者，利用 Android Studio / Gradle 来运行编译。

编译 iOS 工程：

``` bash
$ make example_ios
```

样例的 iOS 工程在`[example_root]/objc`目录， lib 工程生成在`[djinni_root]\build_ios`目录。然后，可以打开`[example_root]/objc/TextSort.xcworkspace`来运行编译。

如果要清理工程：

``` bash
$ make clean
```

### 准备 GYP

编译样例时， Android NDK 与 iOS 的 Library 工程都需依赖 GYP 生成。 make 时，会自行 clone 到`[djinni_root]/deps/gyp`目录。

``` bash
$ git clone https://chromium.googlesource.com/external/gyp.git
```

GYP 生成 Android Makefile 时，目前会遇到如下错误：

> ImportError: No module named android

所以，需要切换到旧版本。此后的那个 commit 移除了 Android 的生成器。

```
$ cd gyp/
$ git checkout -q 0bb67471bca068996e15b56738fa4824dfa19de0
```

> 注：[Stop using gyp's android generator](https://github.com/dropbox/djinni/issues/87)


## 从无到有：Hello Djinni

### C++ 接口

#### 定义接口描述文件

``` bash hellodjinni.djinni https://github.com/joinAero/XCalculator/blob/master/sample/hellodjinni/hellodjinni.djinni hellodjinni.djinni
hello_djinni = interface +c {
    static create(): hello_djinni;
    get_hello_djinni(): string;
}
```

#### 生成接口绑定代码

写了个简单的 Shell 脚本来执行 Djinni 命令，如下：

``` bash run_djinni.sh: https://github.com/joinAero/XCalculator/blob/master/sample/hellodjinni/run_djinni.sh run_djinni.sh
#!/bin/bash
set -e
shopt -s nullglob

base_dir=$(cd "`dirname "$0"`" && pwd)

# Read local properties
eval $(cat $base_dir/local.properties | sed 's/<[^>]*>//g' | sed 's/\./_/g')
if [[ -z $djinni_dir ]]; then
    echo "Unspecified djinni.dir in local.properties" 1>&2
    exit 1
fi


out_dir="$base_dir/generated-src"

cpp_out="$out_dir/cpp"
jni_out="$out_dir/jni"
objc_out="$out_dir/objc"
java_out="$out_dir/java/cc/eevee/hellodjinni"

java_package="cc.eevee.hellodjinni"
cpp_namespace="hellodjinni"
objc_type_prefix="HD"
djinni_file="$base_dir/hellodjinni.djinni"


[[ -e $out_dir ]] && rm -rf $out_dir

$djinni_dir/src/run-assume-built \
    --java-out $java_out \
    --java-package $java_package \
    --ident-java-field mFooBar \
    \
    --cpp-out $cpp_out \
    --cpp-namespace $cpp_namespace \
    \
    --jni-out $jni_out \
    --ident-jni-class NativeFooBar \
    --ident-jni-file NativeFooBar \
    \
    --objc-out $objc_out \
    --objcpp-out $objc_out \
    --objc-type-prefix $objc_type_prefix \
    \
    --idl $djinni_file
```

其读取了`local.properties`内配置的 Djinni 目录路径。

``` bash local.properties https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/local.properties local.properties
djinni.dir=<path-to-djinni>
gyp.dir=<path-to-gyp>
ndk.dir=<path-to-ndk>
```

运行后，代码生成在了`generated-src`目录。

``` bash
$ ./run_djinni.sh
```

#### 实现 C++ 接口

首先，创建`src`目录，存放手写的代码。然后，于子目录`cpp`内实现 C++ 接口。

``` hpp src/cpp/hello_djinni_impl.hpp https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/src/cpp/hello_djinni_impl.hpp hello_djinni_impl.hpp
#pragma once

#include "hello_djinni.hpp"

namespace hellodjinni {

class HelloDjinniImpl : public HelloDjinni {
public:
    // Constructor
    HelloDjinniImpl();

    // Our method that returns a string
    std::string get_hello_djinni();
};

}  // namespace hellodjinni
```

``` cpp src/cpp/hello_djinni_impl.cpp https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/src/cpp/hello_djinni_impl.cpp hello_djinni_impl.cpp
#include "hello_djinni_impl.hpp"
#include <string>

using namespace hellodjinni;

std::shared_ptr<HelloDjinni> HelloDjinni::create() {
    return std::make_shared<HelloDjinniImpl>();
}

HelloDjinniImpl::HelloDjinniImpl() {
}

std::string HelloDjinniImpl::get_hello_djinni() {
    std::string result = "Hello Djinni! ";

    time_t t = time(0);
    tm now = *localtime(&t);

    char tm_desc[200] = {0};
    if (strftime(tm_desc, sizeof(tm_desc)-1, "%r", &now)>0) {
        result += tm_desc;
    }

    return result;
}
```

### C++ 工程

这里用 XCode 创建一个 C++ 工程，来测试 C++ 接口代码。

首先，打开 XCode ，选择"Create a new Xcode project"。然后，选择"Command Line Tool"，来新建命令行工具。

{% asset_img cpp_pro_new.png %}

"Next"到下一步时，"Language"选择"C++"。

{% asset_img cpp_pro_new_2.png %}

工程最后保存到了`project/cpp`目录。整个文件结构如下：

{% img /2016/05/06/using-djinni/cpp_pro_structure.png 240 %}

接下来，把以下 C++ 接口代码文件，拖动到 XCode 工程目录来引入。

```
generated-src/cpp/hello_djinni.hpp
src/cpp/hello_djinni_impl.cpp
src/cpp/hello_djinni_impl.hpp
```

> 注：取消"Copy items if needed"，选择"Create folder references"。只需引用文件，避免复制。

{% asset_img cpp_pro_move.png %}

然后，编写好`main.cpp`的代码：

``` cpp project/cpp/HelloDjinni/HelloDjinni/main.cpp https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/cpp/HelloDjinni/HelloDjinni/main.cpp main.cpp
#include <iostream>
#include "hello_djinni_impl.hpp"

int main(int argc, const char * argv[]) {
    typedef hellodjinni::HelloDjinni HelloDjinni;

    auto hd = HelloDjinni::create();
    auto result = hd->get_hello_djinni();
    std::cout << result << std::endl;

    return 0;
}
```

最后，运行项目，结果如下：

{% asset_img cpp_pro_overview.png %}

或者，写个`project/Cpp.mk`：

``` makefile project/Cpp.mk https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/Cpp.mk Cpp.mk
MD := -mkdir -p
RD := -rm -rf
RM := -rm -f

CC := gcc
CXX := g++
CXXFLAGS := -std=c++11 -Wall

ifdef DEBUG
CXXFLAGS += -g -DDEBUG
else
CXXFLAGS += -O2 -DNDEBUG
endif

OUT_DIR ?= build
CPP_OUT ?= $(OUT_DIR)/cpp

CPP_INCLUDES := \
    ../generated-src/cpp \
    ../src/cpp
CPP_SOURCES := \
    ../src/cpp/hello_djinni_impl.cpp \
    cpp/HelloDjinni/HelloDjinni/main.cpp
CPP_TARGET := $(CPP_OUT)/HelloDjinni


all: cpp_pro

clean:
    $(RD) $(CPP_OUT)/

cpp_pro: $(CPP_SOURCES)
    @echo "\033[1;35;47mBuild cpp project...\033[0m"
    @$(MD) $(CPP_OUT)
    $(CXX) $(CXXFLAGS) $(CPP_SOURCES) -o $(CPP_TARGET) \
        $(foreach d, $(CPP_INCLUDES), -I$d)
    @echo "\033[32mOutput:\033[0m\n$(CPP_TARGET)"
    @echo "\033[32mRunning:\033[0m"
    @$(CPP_TARGET)

.PHONY: cpp_pro clean all
```

然后，`make -f Cpp.mk`编译运行，结果如下：

```
Build cpp project...
g++ -std=c++11 -Wall -O2 -DNDEBUG \
    ../src/cpp/hello_djinni_impl.cpp \
    cpp/HelloDjinni/HelloDjinni/main.cpp \
    -o build/cpp/HelloDjinni \
    -I../generated-src/cpp -I../src/cpp
Output:
build/cpp/HelloDjinni
Running:
Hello Djinni! 11:46:56 PM
```

### iOS 工程

打开 XCode，"File > New > Workspace"新建一个工作区，保存到`project/ios`目录。

接着，"File > New > Project"，选择"Single View Application"，创建 iOS 工程。

{% asset_img ios_pro_new.png %}

"Next"到下一步时，"Language"选择"Objective-C"。

{% asset_img ios_pro_new_2.png %}

工程保存到`project/ios`目录，"Add to"选择刚才的工作区。

{% asset_img ios_pro_new_3.png %}

"Create"完成创建。

#### 生成接口 Libraries 工程

利用 Djinni, GYP 及 Make 生成接口 Libraries 工程。

首先，创建 GYP 文件：

``` json project/libhellodjinni.gyp https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/libhellodjinni.gyp libhellodjinni.gyp
{
  "targets": [
    {
      "target_name": "libhellodjinni_jni",
      "type": "shared_library",
      "dependencies": [
        "<(DJINNI_DIR)/support-lib/support_lib.gyp:djinni_jni",
      ],
      "ldflags": [ "-llog", "-Wl,--build-id,--gc-sections,--exclude-libs,ALL" ],
      "sources": [
        "<(DJINNI_DIR)/support-lib/jni/djinni_main.cpp",
        "<!@(python <(DJINNI_DIR)/example/glob.py ../generated-src/jni '*.cpp')",
        "<!@(python <(DJINNI_DIR)/example/glob.py ../generated-src/cpp '*.cpp')",
        "<!@(python <(DJINNI_DIR)/example/glob.py ../src '*.cpp')",
      ],
      "include_dirs": [
        "../generated-src/jni",
        "../generated-src/cpp",
        "../src/cpp",
      ],
    },
    {
      "target_name": "libhellodjinni_objc",
      "type": "static_library",
      "dependencies": [
        "<(DJINNI_DIR)/support-lib/support_lib.gyp:djinni_objc",
      ],
      "sources": [
        "<!@(python <(DJINNI_DIR)/example/glob.py ../generated-src/objc '*.cpp' '*.mm' '*.m')",
        "<!@(python <(DJINNI_DIR)/example/glob.py ../generated-src/cpp  '*.cpp')",
        "<!@(python <(DJINNI_DIR)/example/glob.py ../src '*.cpp')",
      ],
      "include_dirs": [
        "../generated-src/objc",
        "../generated-src/cpp",
        "../src/cpp",
      ],
    },
  ],
}
```

> 注意：
> 1) `sources`内的路径必须是相对路径。虽然会识别以`/`开头的字符串为绝对路径，但在 XCode 工程内其路径引用是不正确的。
> 2) GYP 生成 Android Makefile 时，运行命令时的工作目录，必须能够直接子目录到所有代码，包括依赖的 Djinni 的 support-lib 。不然，会报如下错误：
>
>   > AssertionError: Path %s attempts to escape from gyp path %s !)
>
> 👌的话，`GypAndroid.mk`会生成到当前工作目录。GYP 生成 Android 时，不允许指定`--generator-output`：
>
>   > AssertionError: The Android backend does not support options.generator_output.

所以，简单的解决办法是，文件结构与`[djinni_root]/example`一致，并`git submodule` Djinni 与 GYP 到工程目录内。

``` bash
$ git init
$ git submodule add https://github.com/dropbox/djinni.git deps/djinni
$ git submodule add https://chromium.googlesource.com/external/gyp.git deps/gyp
```

如果仍想要 Djinni 与 GYP 独立于工程目录外，同时又能够工作在工程目录，那么需要把依赖的东西复制进工程目录。之后，即是这样做的。

接下来，创建 Makefile 文件：

``` makefile project/Makefile https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/Makefile Makefile
MD := -mkdir -p
RD := -rm -rf
RM := -rm -f

SED_PROP := "s/<[^>]*>//g;s/.*=\(.*\)/\1/"

define read_prop
    $(eval $(1) := $(shell ../tools/read_properties.sh \
        | grep -m1 $(2) | sed $(SED_PROP)))
endef

$(call read_prop,GYP_DIR,gyp_dir)
$(call read_prop,NDK_DIR,ndk_dir)


OUT_DIR ?= build
IOS_OUT ?= $(OUT_DIR)/ios

DEPS_DIR ?= deps
DEPS_DJINNI_DIR := $(DEPS_DIR)/djinni


all: cpp_pro ios_pro android_pro android_pro2

clean:
    @make ios_pro_clean
    @make android_pro_clean
    @make android_pro2_clean
    @echo "\033[1;35;47mClean others...\033[0m"
    $(RD) $(OUT_DIR)/
    $(RD) $(DEPS_DIR)/
    $(RD) ../generated-src/
    $(RM) ../GypAndroid.mk
    $(RM) libhellodjinni_jni.target.mk
    @# @make cpp_pro_clean

cpp_pro: djinni
    @make -f Cpp.mk cpp_pro

cpp_pro_clean:
    @make -f Cpp.mk clean

libhellodjinni.xcodeproj: deps djinni libhellodjinni.gyp \
        $(DEPS_DJINNI_DIR)/support-lib/support_lib.gyp
    @$(GYP_DIR)/gyp --depth=. -f xcode -DOS=ios \
        --generator-output $(IOS_OUT) \
        -DDJINNI_DIR=$(DEPS_DJINNI_DIR) \
        -I$(DEPS_DJINNI_DIR)/common.gypi \
        libhellodjinni.gyp

ios_pro: libhellodjinni.xcodeproj
    @echo "\033[1;35;47mBuild ios project...\033[0m"
    xcodebuild -workspace ios/HelloDjinni.xcworkspace \
        -scheme HelloDjinni -configuration 'Debug' -sdk iphonesimulator

ios_pro_clean:
    @echo "\033[1;35;47mClean ios project...\033[0m"
    @-xcodebuild -workspace ios/HelloDjinni.xcworkspace \
        -scheme HelloDjinni -configuration 'Debug' -sdk iphonesimulator clean

GypAndroid.mk: deps djinni libhellodjinni.gyp \
        $(DEPS_DJINNI_DIR)/support-lib/support_lib.gyp
    @make gyp_android
    @cd .. && ANDROID_BUILD_TOP=$(NDK_DIR) \
        $(GYP_DIR)/gyp --depth=. -f android -DOS=android \
        -DDJINNI_DIR=$(DEPS_DJINNI_DIR) \
        -Iproject/$(DEPS_DJINNI_DIR)/common.gypi \
        project/libhellodjinni.gyp \
        --root-target=libhellodjinni_jni
    @make gyp_master

android_pro: GypAndroid.mk
    @echo "\033[1;35;47mBuild android project (HelloDjinni)...\033[0m"
    cd android/HelloDjinni/ && ./gradlew app:assembleDebug
    @echo "\033[32mApks produced at:\033[0m"
    @python $(DEPS_DJINNI_DIR)/example/glob.py \
        android/HelloDjinni/app/build/outputs/apk/ '*.apk'

android_pro_clean: GypAndroid.mk
    @echo "\033[1;35;47mClean android project (HelloDjinni)...\033[0m"
    @ndk-build -C android/HelloDjinni/app-core clean
    @-cd android/HelloDjinni/ && ./gradlew clean

android_pro2: deps djinni libhellodjinni.gyp \
        $(DEPS_DJINNI_DIR)/support-lib/support_lib.gyp
    @echo "\033[1;35;47mBuild android project (HelloDjinni2)...\033[0m"
    cd android/HelloDjinni2/ && ./gradlew app:assembleDebug
    @echo "\033[32mApks produced at:\033[0m"
    @python $(DEPS_DJINNI_DIR)/example/glob.py \
        android/HelloDjinni2/app/build/outputs/apk/ '*.apk'

android_pro2_clean:
    @echo "\033[1;35;47mClean android project (HelloDjinni2)...\033[0m"
    @-cd android/HelloDjinni2/ && ./gradlew clean

deps:
    @echo "\033[1;35;47mPrepare dependencies...\033[0m"
    @../tools/prepare_deps.sh $(DEPS_DIR)

djinni: ../hellodjinni.djinni
    @echo "\033[1;35;47mGenerate djinni interface code...\033[0m"
    @[[ -e "../generated-src" ]] || ../run_djinni.sh

gyp_status:
    @cd $(GYP_DIR) && git status

gyp_master:
    @echo "\033[1;35;47mCheckout gyp to master...\033[0m"
    @cd $(GYP_DIR) && git checkout master

gyp_android:
    @echo "\033[1;35;47mCheckout gyp to android generator...\033[0m"
    @cd $(GYP_DIR) && git checkout -q 0bb67471bca068996e15b56738fa4824dfa19de0

test:
    @echo "\033[1;35;47mPrint variables...\033[0m"
    @echo GYP_DIR=$(GYP_DIR)
    @echo NDK_DIR=$(NDK_DIR)
    @echo OUT_DIR=$(OUT_DIR)
    @echo IOS_OUT=$(IOS_OUT)
    @echo DEPS_DIR=$(DEPS_DIR)
    @echo DEPS_DJINNI_DIR=$(DEPS_DJINNI_DIR)
    @make gyp_android
    @make gyp_status
    @make gyp_master
    @make deps
    @make djinni

.PHONY: cpp_pro ios_pro android_pro android_pro2 clean all test
```

其也包括了 Android 工程的配置。

> 注：额外依赖了两个辅助脚本，说明如下：
> `read_properties.sh`，读取`local.properties`内配置的路径。
> `prepare_deps.sh`，准备依赖的文件到指定目录。

然后，运行生成 XCode 的 libhellodjinni 工程。

``` bash
$ cd project/
$ make ios_pro
```

其生成在`project/build/ios`目录。 XCode 直接打开`libhellodjinni.xcodeproj`，即可选择目标进行编译。

但可能此时 libhellodjinni_jni 与 djinni_jni (support_lib) 目标，不能够找到`jni.h`。由于 ios 上不需要 jni 绑定，后续也不需依赖，没多大影响。

也让其可通过编译的话，只需要选择目标，在"Build Settings > Header Search Paths"内，添加 Java VM include 就好。

运行如下命令，获得当前的 Java 头文件路径：

``` bash
$ ls -l `which java` | sed 's/^.*-> *\(.*Current\).*$/\1\/Headers/;q'
```

结果，如："/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers"。

或者，这里找："/Library/Java/JavaVirtualMachines/jdk1.8.0_25.jdk/Contents/Home/include/"。

{% asset_img ios_pro_lib_header.png %}

#### 添加接口 Libraries 依赖

现在，给 iOS 工程上添加上接口 Libraries 的依赖。

首先，打开先前的工作区`project/ios/HelloDjinni.xcworkspace`。于左侧项目导航的灰色区域，"Ctrl+Click"或右击打开菜单。选择"Add Files to "HelloDjinni""，添加生成好的`libhellodjinni.xcodeproj`和`support_lib.xcodeproj`两个库工程。

之后，项目导航选中"HelloDjinni"工程，并选择"HelloDjinni"目标。在"Build Phases"标签页的"Link Binaries With Libraries"选项下，新增 libhellodjinni_objc.a 与 libdjinni_objc.a 的依赖，如下：

{% asset_img ios_pro_lib_link.png %}

在"Build Settings"标签页，找到"Header Search Paths"，添加头文件搜索路径：

```
$(SRCROOT)/../../deps/djinni/support-lib/objc
$(SRCROOT)/../../../generated-src/objc
```

为了兼容 Objective-C++ 桥接代码，需要将`HelloWorld/Supporting Files/main.m`重命名为`main.mm`。

最终，工作区会类似于下面这样：

{% asset_img ios_pro_overview.png %}

#### 完成 UI 并运行

于`ViewController.m`内编写代码，创建 UI 并调用接口代码。

``` objc project/ios/HelloDjinni/HelloDjinni/ViewController.m https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/ios/HelloDjinni/HelloDjinni/ViewController.m ViewController.m
#import "ViewController.h"
#import "HDHelloDjinni.h"

@interface ViewController ()

@end

@implementation ViewController {
    HDHelloDjinni *_helloDjinniInterface;
    UIButton *_button;
    UITextView *_textView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // instantiate our library interface
    _helloDjinniInterface = [HDHelloDjinni create];

    // create a button programatically for the demo
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_button addTarget:self
                action:@selector(buttonWasPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    [_button setTitle:@"Get Hello Djinni!" forState:UIControlStateNormal];
    _button.frame = CGRectMake(20.0, 20.0, 280.0, 40.0);
    [self.view addSubview:_button];

    // create a text view programatically
    _textView = [[UITextView alloc] init];
    // x, y, width, height
    _textView.frame = CGRectMake(20.0, 80.0, 280.0, 380.0);
    [self.view addSubview:_textView];
}

- (void)buttonWasPressed:(UIButton *)sender {
    NSString *response = [_helloDjinniInterface getHelloDjinni];
    _textView.text = [NSString stringWithFormat:@"%@\n%@", response, _textView.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
```

"Product > Run"运行项目。 UI 上"Get Hello Djinni!"的按钮，每点击下就会添加条从 C++ 返回的信息。

{% img /2016/05/06/using-djinni/ios_pro_result.png 300 %}

### Android 工程

Android 工程介绍了两种方式，来整合 NDK Library ：

* 一是，使用 GYP 生成的 Android Makefile ， Gradle 配置 ndk-build 进行编译。
* 二是，使用 Experimental Plugin ，直接配置成支持 NDK 的工程。

#### 使用 GypMakefile

GYP 生成 Android Makefile ，使用之前写好的`project/Makefile`：

``` bash
$ cd project/
$ make android_pro
```

`GypAndroid.mk`会生成到父级`hellodjinni`目录。

如果还没准备好 Studio 工程，不会继续生成 APK ，会报“找不到`android/HelloDjinni/`”。

现在，打开 Android Studio，选择"Start a new Android Studio Project"。

"New"页，"Project Location"存到`project/android/HelloDjinni`，如下：

{% asset_img android_pro_new.png %}

之后，"Target"页选"Phone and Tablet"，"Add"页选"Empty Activity"，最终完成新建。

于"File > Project Structure > SDK Location > Android NDK Location"，设置 NDK 路径：

{% asset_img android_pro_sdk.png %}

接下来，独立建一个 app-core Library 模块来引用 C++ 代码。"File > New Module"，选"Android Library"：

{% asset_img android_pro_new_lib.png %}

然后，修改此 app-core 的`build.gradle`，添加引用及 NDK 编译。变更如下：

``` gradle project/android/HelloDjinni/app-core/build.gradle https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni/app-core/build.gradle build.gradle
apply plugin: 'com.android.library'

android {
    ...
    sourceSets {
        main {
            java.srcDirs += ['../../../../generated-src/java']
            jni.srcDirs = []
            jniLibs.srcDirs = ['libs']
        }
    }
}

dependencies {
    ...
    //compile 'com.android.support:appcompat-v7:23.3.0'
}

task ndkBuild(type: Exec) {
    def moduleDir = System.getProperty("user.dir") + "/app-core/"
    def ndkDir = plugins.getPlugin('com.android.library').sdkHandler.ndkFolder
    if (ndkDir == null) {
        def gradle_project_root = project.rootProject.rootDir
        throw new GradleException("NDK is not configured. Make sure there is a local.properties " +
                "file with an ndk.dir entry in the directory ${gradle_project_root}.")
    }
    def ndkBuildExecutable = new File(ndkDir, 'ndk-build')
    if (!ndkBuildExecutable.exists()) {
        throw new GradleException("Could not find ndk-build. The configured NDK directory ${ndkDir} may not be correct.")
    }
    environment("NDK_PROJECT_PATH", moduleDir)
    environment("GYP_CONFIGURATION", "Release")
    commandLine ndkBuildExecutable
}

tasks.withType(JavaCompile) {
    compileTask -> compileTask.dependsOn ndkBuild
}
```

项目导航栏切到 Project 视图，在 app-core 下新建`jni`目录，创建 NDK 的工程文件。

``` makefile project/android/HelloDjinni/app-core/jni/Android.mk https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni/app-core/jni/Android.mk Android.mk
# always force this build to re-run its dependencies
FORCE_GYP := $(shell make -C ../../../../ GypAndroid.mk)
include ../../../../GypAndroid.mk
```

``` makefile project/android/HelloDjinni/app-core/jni/Application.mk https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni/app-core/jni/Application.mk Application.mk
# Android makefile for libhellodjinni shared lib

# Application.mk: http://developer.android.com/ndk/guides/application_mk.html

# APP_ABI := all
# skipping mips / mips64
APP_ABI := armeabi armeabi-v7a arm64-v8a x86 x86_64
APP_OPTIM := release
APP_PLATFORM := android-14
# GCC 4.9 Toolchain - requires NDK r10
NDK_TOOLCHAIN_VERSION = 4.9
# GNU libc++ is the only Android STL which supports C++11 features
APP_CFLAGS += -Wall
APP_CPPFLAGS += -std=c++11 -frtti -fexceptions
APP_STL := gnustl_static
APP_BUILD_SCRIPT := jni/Android.mk
APP_MODULES := libhellodjinni_jni
```

这样，独立的 app-core Library 就👌了。

回到 app ，修改其`build.gradle`，以依赖 app-core 。变更如下：

``` gradle project/android/HelloDjinni/app/build.gradle https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni/app/build.gradle build.gradle
dependencies {
    ...
    compile project(':app-core')
}
```

新建`MyApplication.java`，作为自定义 Application。并设置到`AndroidManifest.xml`内"application"的"name"字段。

``` java project/android/HelloDjinni/app/src/.../MyApplication.java https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni/app/src/main/java/cc/eevee/hellodjinni/MyApplication.java MyApplication.java
package cc.eevee.hellodjinni;

import android.app.Application;

public class MyApplication extends Application {

    static {
        try {
            System.loadLibrary("hellodjinni_jni");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Native code library failed to load.\n" + e);
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }
}
```

最终，项目导航 Android 和 Project 视图类似下面这样：

{% asset_img android_pro_nav.png %}

接着，修改 app UI，`MainActivity.java`及其布局`activity_main.xml`：

``` java project/android/HelloDjinni/app/src/.../MainActivity.java https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni/app/src/main/java/cc/eevee/hellodjinni/MainActivity.java MainActivity.java
package cc.eevee.hellodjinni;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ScrollView;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    private TextView mTextView;
    private ScrollView mScrollView;

    private HelloDjinni mHelloDjinniInterface = HelloDjinni.create();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mTextView = (TextView) findViewById(R.id.textView);
        mScrollView = (ScrollView) findViewById(R.id.scrollView);
    }

    public void onButtonClick(View view) {
        mTextView.append(mHelloDjinniInterface.getHelloDjinni() + "\n");
        mScrollView.fullScroll(ScrollView.FOCUS_DOWN);
    }
}
```

``` xml project/android/HelloDjinni/app/src/.../activity_main.xml https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni/app/src/main/res/layout/activity_main.xml activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:paddingBottom="@dimen/activity_vertical_margin"
    android:paddingLeft="@dimen/activity_horizontal_margin"
    android:paddingRight="@dimen/activity_horizontal_margin"
    android:paddingTop="@dimen/activity_vertical_margin"
    tools:context="cc.eevee.hellodjinni.MainActivity">

    <Button
        android:id="@+id/button"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Get Hello Djinni!"
        android:gravity="center"
        android:onClick="onButtonClick"/>

    <ScrollView
        android:id="@+id/scrollView"
        android:layout_width="match_parent"
        android:layout_height="match_parent">

        <TextView
            android:id="@+id/textView"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"/>
    </ScrollView>
</LinearLayout>
```

"Run > Run 'app'"运行项目。 UI 上"Get Hello Djinni!"的按钮，每点击下就会添加条从 C++ 返回的信息。

{% img /2016/05/06/using-djinni/android_pro_result.png 300 %}

#### 使用新试验性插件

Android Studio 1.3 版本开始支持 NDK，需要使用 Experimental Plugin 。这里为当前最新的 0.7.0 版本。

同样，打开 Android Studio，选择"Start a new Android Studio Project"，新建一个"HelloDjinni2"工程。

{% asset_img android_pro2_new.png %}

之后，"Target"页选"Phone and Tablet"，"Add"页选"Empty Activity"，最终完成新建。

于”File > Project Structure > SDK Location > Android NDK Location”，设置 NDK 路径。

接下来，修改成 Experimental Plugin 。先是工程配置：

``` gradle project/android/HelloDjinni2/build.gradle https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni2/build.gradle build.gradle
// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        jcenter()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle-experimental:0.7.0'

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        jcenter()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

接着是 app 模块配置：

``` gradle project/android/HelloDjinni2/app/build.gradle https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni2/app/build.gradle build.gradle
apply plugin: 'com.android.model.application'

model {
    android {
        compileSdkVersion = 23
        buildToolsVersion = '23.0.3'

        defaultConfig {
            applicationId = 'cc.eevee.hellodjinni2'
            minSdkVersion.apiLevel    = 14
            targetSdkVersion.apiLevel = 23
            versionCode = 1
            versionName = '1.0'
        }
        buildTypes {
            release {
                minifyEnabled = false
                proguardFiles.add(file('proguard-rules.pro'))
            }
        }
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    testCompile 'junit:junit:4.12'
    compile 'com.android.support:appcompat-v7:23.3.0'
    //compile project(':app-core')
}
```

这样， Experimental Plugin 就修改完成了。

接下来，仍旧独立建一个 app-core Library 模块来引用 C++ 代码。"File > New Module"，选"Android Library"：

{% asset_img android_pro2_new_lib.png %}

然后，修改此 app-core 的`build.gradle`，支持 Experimental Plugin 并配置 NDK 。如下：

``` gradle project/android/HelloDjinni2/app-core/build.gradle https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni2/app-core/build.gradle build.gradle
apply plugin: 'com.android.model.library'

model {
    android {
        compileSdkVersion = 23
        buildToolsVersion = '23.0.3'

        defaultConfig {
            minSdkVersion.apiLevel    = 14
            targetSdkVersion.apiLevel = 23
        }
        ndk {
            moduleName = 'hellodjinni'
            platformVersion = 14
            toolchain = 'gcc'
            toolchainVersion = '4.9'
            stl = 'gnustl_shared'
            CFlags.addAll(['-Wall', '-Werror'])
            cppFlags.addAll(['-std=c++11', '-fexceptions', '-frtti'])
            cppFlags.addAll([
                    "-I${file('../../../deps/djinni/support-lib')}".toString(),
                    "-I${file('../../../deps/djinni/support-lib/jni')}".toString(),
                    "-I${file('../../../../generated-src/cpp')}".toString(),
                    "-I${file('../../../../generated-src/jni')}".toString(),
            ])
            ldLibs.addAll(['log'])
            abiFilters.addAll(['armeabi', 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'])
        }
        sources {
            //noinspection GroovyAssignabilityCheck
            main {
                jni {
                    source {
                        srcDirs += [
                            '../../../deps/djinni/support-lib/jni',
                            '../../../../generated-src/cpp',
                            '../../../../generated-src/jni',
                            '../../../../src/cpp',
                        ]
                    }
                }
                java {
                    source {
                        srcDirs += [
                            '../../../../generated-src/java',
                        ]
                    }
                }
            }
        }
        buildTypes {
            release {
                minifyEnabled = false
                proguardFiles.add(file('proguard-rules.pro'))
            }
        }
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    testCompile 'junit:junit:4.12'
    //compile 'com.android.support:appcompat-v7:23.3.0'
}
```

这样之后，可以在 app-core 下看得`jni`目录，包括了所有 C++ 代码。

回到 app ，修改其`build.gradle`，以依赖 app-core 。变更如下：

``` gradle project/android/HelloDjinni2/app/build.gradle https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni2/app/build.gradle build.gradle
dependencies {
    ...
    compile project(':app-core')
}
```

新建`MyApplication.java`，作为自定义 Application。并设置到`AndroidManifest.xml`内"application"的"name"字段。

``` java project/android/HelloDjinni2/app/src/.../MyApplication.java https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni2/app/src/main/java/cc/eevee/hellodjinni2/MyApplication.java MyApplication.java
package cc.eevee.hellodjinni2;

import android.app.Application;

public class MyApplication extends Application {

    static {
        try {
            System.loadLibrary("gnustl_shared");
            System.loadLibrary("hellodjinni");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Native code library failed to load.\n" + e);
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }
}
```

最终，项目导航 Android 和 Project 视图类似下面这样：

{% asset_img android_pro2_nav.png %}

接着，修改 app UI，`MainActivity.java`及其布局`activity_main.xml`：

``` java project/android/HelloDjinni2/app/src/.../MainActivity.java https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni2/app/src/main/java/cc/eevee/hellodjinni2/MainActivity.java MainActivity.java
package cc.eevee.hellodjinni2;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ScrollView;
import android.widget.TextView;

import cc.eevee.hellodjinni.HelloDjinni;

public class MainActivity extends AppCompatActivity {

    private TextView mTextView;
    private ScrollView mScrollView;

    private HelloDjinni mHelloDjinniInterface = HelloDjinni.create();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mTextView = (TextView) findViewById(R.id.textView);
        mScrollView = (ScrollView) findViewById(R.id.scrollView);
    }

    public void onButtonClick(View view) {
        mTextView.append(mHelloDjinniInterface.getHelloDjinni() + "\n");
        mScrollView.fullScroll(ScrollView.FOCUS_DOWN);
    }
}
```

``` xml project/android/HelloDjinni2/app/src/.../activity_main.xml https://github.com/joinAero/XCalculator/tree/master/sample/hellodjinni/project/android/HelloDjinni2/app/src/main/res/layout/activity_main.xml activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:paddingBottom="@dimen/activity_vertical_margin"
    android:paddingLeft="@dimen/activity_horizontal_margin"
    android:paddingRight="@dimen/activity_horizontal_margin"
    android:paddingTop="@dimen/activity_vertical_margin"
    tools:context="cc.eevee.hellodjinni2.MainActivity">

    <Button
        android:id="@+id/button"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Get Hello Djinni!"
        android:gravity="center"
        android:onClick="onButtonClick"/>

    <ScrollView
        android:id="@+id/scrollView"
        android:layout_width="match_parent"
        android:layout_height="match_parent">

        <TextView
            android:id="@+id/textView"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"/>
    </ScrollView>
</LinearLayout>
```

"Run > Run 'app'"运行项目。 UI 上"Get Hello Djinni!"的按钮，每点击下就会添加条从 C++ 返回的信息。

{% img /2016/05/06/using-djinni/android_pro2_result.png 300 %}

#### NDK 参考

* [NDK Guides](http://developer.android.com/ndk/guides/index.html)
* [Android NDK Preview](http://tools.android.com/tech-docs/android-ndk-preview)
* [Experimental Plugin User Guide](http://tools.android.com/tech-docs/new-build-system/gradle-experimental)
* [Error: NDK integration is deprecated in the current plugin](http://stackoverflow.com/questions/31979965/after-updating-android-studio-to-version-1-3-0-i-am-getting-ndk-integration-is)


## 结语：开始使用 Djinni 吧


## 附：源码

Hello Djinni 的源码，这样得到：

``` bash
$ git clone https://github.com/joinAero/XCalculator.git
$ cd sample/hellodjinni/
```

修改`local.properties`设好环境。执行`make`编译，`make clean`清理。

**文件结构：**

```
hellodjinni/
├─project/
│  ├─android/
│  │  ├─HelloDjinni/                # Android Project with GYP & ndk-build
│  │  └─HelloDjinni2/               # Android Project with Experimental Plugin
│  ├─cpp/
│  │  └─HelloDjinni/                # Cpp Test Project
│  └─ios/
│      ├─HelloDjinni/
│      └─HelloDjinni.xcworkspace/   # iOS Project Workspace
├─src/
│  └─cpp/                           # Cpp Interface Impls
├─tools/                            # Helper Scripts
└─local.properties                  # Local Properties
```


## 附：运行环境

``` bash
# OS
ProductName: Mac OS X ProductVersion: 10.11.4 BuildVersion: 15E65

# XCode
Xcode 7.3.1 Build version 7D1014

# XCode 命令行工具
# xcode-select --install
xcode-select version 2343.

# Java
java version "1.8.0_25"
Java(TM) SE Runtime Environment (build 1.8.0_25-b17)
Java HotSpot(TM) 64-Bit Server VM (build 25.25-b02, mixed mode)

# Android Studio
# Android Studio > About Android Studio
# Android Studio > Appearance & Behavior > System Settings > Updates
Android Studio 2.1
Build #AI-143.2790544

# Android NDK
GNU Make 3.81 Copyright (C) 2006 Free Software Foundation, Inc. This is free software; see the source for copying conditions. There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. This program built for i386-apple-darwin11.3.0
```

如果未添加过 Android 环境变量，请于 ~/.bash_profile 文件内设置：

``` bash
export ANDROID_HOME=$HOME/Develop/android-sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

export ANDROID_NDK_HOME=$HOME/Develop/android-ndk
export PATH=$PATH:$ANDROID_NDK_HOME
```

终端运行如下命令可立即生效：

``` bash
$ source ~/.bash_profile
```

验证 SDK 与 NDK 命令行工具可用：

``` bash
$ which android

$ which ndk-build
```

验证 XCode 命令行工具可用：

``` bash
$ which xcrun

$ which xcodebuild
```


## 附：参考内容

* [Your First Cross-Platform Djinni App](http://mobilecpptutorials.com/your-first-cross-platform-djinni-app-part-1-cplusplus/)
* [iOS和Android的C++跨平台开发 | Dropbox](http://www.infoq.com/cn/news/2014/06/dropbox-cpp-crossplatform-mobile/)

<!--
Projects:

* [djinni | dropbox](https://github.com/dropbox/djinni)
* [android-ndk | googlesamples](https://github.com/googlesamples/android-ndk.git)

References:

* [Cpp Reference](http://en.cppreference.com)
* [NDK API Reference](http://developer.android.com/ndk/reference/index.html)
* [iOS Developer Library](https://developer.apple.com/library/ios)
* [Mac Developer Library](https://developer.apple.com/library/mac)

Extra Articles:

* [From C++ to Objective-C](http://pierre.chachatelier.fr/programmation/fichiers/cpp-objc-2_1-en.pdf)

Extra Tools:

* [sbt](http://www.scala-sbt.org/index.html): `brew install sbt`
* [sbt下载慢？](http://www.zhihu.com/question/31158252)
-->
