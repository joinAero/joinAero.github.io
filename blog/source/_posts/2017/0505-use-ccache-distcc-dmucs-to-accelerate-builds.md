---
title: 'Use ccache, distcc, dmucs to accelerate builds'
date: 2017-05-05 11:29:26
categories:
- Tech
tags:
- ccache
- distcc
- dmucs
---

[ccache]: http://ccache.samba.org/
[distcc]: https://github.com/distcc/distcc
[dmucs]: http://dmucs.sourceforge.net/

## [ccache][]

[ccache][] is a compiler cache. It speeds up recompilation by caching previous compilations and detecting when the same compilation is being done again. Supported languages are C, C++, Objective-C and Objective-C++.

Mac:

```
# install
$ brew install ccache

# where
$ brew ls ccache
$ which ccache

$ brew info ccache

# env
$ vi ~/.bash_profile

    export PATH=/usr/local/opt/ccache/libexec:$PATH

# verify
$ source ~/.bash_profile
$ which clang
/usr/local/opt/ccache/libexec/clang
```

Ubuntu:

```
# install
$ sudo apt-get install ccache

# where
$ whereis ccache
$ which ccache

# env
$ vi ~/.bashrc

    export PATH=/usr/lib/ccache:$PATH

# verify
$ source ~/.bashrc
$ which g++ gcc
/usr/lib/ccache/g++
/usr/lib/ccache/gcc
```

* [Using CCache on Mac](https://chromium.googlesource.com/chromium/src/+/master/docs/ccache_mac.md)

## [distcc][] on Ubuntu

[distcc][] is a program to distribute compilation of C or C++ code across several machines on a network. [distcc][] should always generate the same results as a local compile, is simple to install and use, and is often two or more times faster than a local compile.

Install:

```
# install
$ sudo apt-get install distcc
# optional
$ sudo apt-get install distccmon-gnome

$ distcc --help

# show ip
$ ifconfig | grep "inet " | grep -v 127.0.0.1
192.168.199.247

# config
$ sudo vi /etc/default/distcc

    STARTDISTCC="true"
    ALLOWEDNETS="192.168.0.0/16"
    LISTENER=""
    ZEROCONF="false"

# start server
$ sudo /etc/init.d/distcc start

# reboot & verify
$ ps aux | grep distccd
```

Usage:

```
# download
$ curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz
$ tar zxf lua-5.3.4.tar.gz

$ cd lua-5.3.4

# build
$ time make linux

# clean
$ make clean; ccache -C

# display distcc jobs, plz in another terminal
$ distccmon-text 2
# or, with gui
$ distccmon-gnome &

# build with distcc
$ export DISTCC_HOSTS="192.168.199.247 192.168.199.104"
$ time make -j12 CC="distcc gcc -std=gnu99" linux
```

Cost:

|        |  normal  |  ccache  |  distcc  | distcc + ccache |
| ------ | -------: | -------: | -------: | --------------: |
|  cost  |   4.069s |   0.134s |   1.301s |          1.296s |

> P.S. distcc: 2 quad-core pc, -j12

| normal |   make   | make -j4 |
| ------ | -------: | -------: |
|  cost  |   4.069s |   1.403s |

Use with [ccache](http://ccache.samba.org/):

> NOTE: This use of ccache is incompatible with use of distcc's "pump" mode.

## [distcc][] on Mac

Install:

```
# install
$ brew install distcc

$ brew info distcc
$ distcc --help
$ distccd --help

# show ip
$ ifconfig | grep "inet " | grep -v 127.0.0.1
192.168.199.182

# config
$ vi /usr/local/Cellar/distcc/3.2rc1/homebrew.mxcl.distcc.plist

    ...
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/opt/distcc/bin/distccd</string>
        <string>--daemon</string>
        <string>--no-detach</string>
        <string>--allow=192.168.0.0/16</string>
    </array>
    ...

# start server
$ brew services start distcc

# reboot & verify
$ ps aux | grep distccd
```

Usage:

```
# download
$ curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz
$ tar zxf lua-5.3.4.tar.gz

$ cd lua-5.3.4

# build
$ time make macosx

# clean
$ make clean; ccache -C

# display distcc jobs, plz in another terminal
$ distccmon-text 2

# build with distcc
$ export DISTCC_HOSTS="192.168.199.182 192.168.199.105"
$ vi src/Makefile

    macosx:
            $(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_MACOSX" SYSLIBS="-lreadline" CC="distcc cc"

$ time make -j12 macosx
```

> Note: It is recommended that using distcc splits different platforms.

## [dmucs][] on Ubuntu

[DMUCS][] is a system that allows a group of users to share a compilation farm.  Each compilation request from each user will be sent to the fastest available machine, every time.

Install:

```
# install
$ sudo apt-get install dmucs

# bug fix for restart on boot
#   dmucs: race condition in start scripts prevents loadavg starting
#   https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=798830
$ sudo vi /etc/init.d/dmucs

    start)
          if [ "$SERVER" = "yes" ]; then
              ...
              if start_server ;  then
              ...
          if [ "$USE_SERVER" ]; then
              ...
              if start_loadavg ;  then
              ...
```

> P.S. Unfortunately, this fix doesn't work on my Ubuntu, although `start_loadavg` result is ok ==.
>
> You could log the output of "/etc/init.d/dmucs" script, add this at the top:
    ```
    exec 1>/tmp/init.log 2>&1
    set -x
    ```

Server machine (e.g. 192.168.199.210):

```
# config
$ sudo vi /etc/default/dmucs

    SERVER=yes
    USE_SERVER=

# hosts-info
$ sudo vi /etc/dmucs.conf

    # Format: machine number-of-cpus power-index
    192.168.199.104   4   8
    192.168.199.247   4  10

# start
$ sudo /etc/init.d/dmucs start

# verify restart on boot
$ sudo reboot
$ ps aux | grep dmucs

# display which hosts/cpus are available
$ monitor
```

Each host (e.g. 192.168.199.104 192.168.199.247):

```
# config
$ sudo vi /etc/default/dmucs

    SERVER=no
    USE_SERVER=192.168.199.210

# start
$ sudo /etc/init.d/dmucs start

# verify restart on boot
$ sudo reboot
$ ps aux | grep loadavg
```

Usage:

```
$ cd lua-5.3.4

# build
$ time make -j12 CC="gethost -s 192.168.199.210 distcc gcc -std=gnu99" linux
```

### Issue: `loadavg` get wrong host on Ubuntu 14.04, then `dmucs` not recognize the hosts

Run `loadavg -s 192.168.199.210 -D`, see "Writing -->127.0.1.1 ...<-- to the server".

Easily avoid this issue as follows:

```
# comment host "127.0.1.1"
$ sudo vi /etc/hosts

    127.0.0.1   localhost
    #127.0.1.1  ubuntu
    ...

# restart loadavg
$ sudo /etc/init.d/dmucs restart
```

However, it will affect dnsmasq at least.

Learn more, plz google "127.0.1.1", "ubuntu dnsmasq 127.0.1.1".

<!--

```
# enable "/etc/init.d/*" scripts
sudo update-rc.d <script> defaults
```

```
# log for "/etc/init.d/*" scripts
exec 1>/tmp/init.log 2>&1
set -x
```

```
# restore configure
# https://askubuntu.com/questions/66533/how-can-i-restore-configuration-files
```

```
# download [here](https://sourceforge.net/projects/dmucs/)
$ tar jxf dmucs-0.6.tar.bz2

$ cd dmucs/

# build
$ ./configure \
CPPFLAGS=-DSERVER_MACH_NAME=\\\"192.168.199.210\\\"
$ make
$ make install
```

* [How to Get Local Host's Real IP Address](http://jhshi.me/2013/11/02/how-to-get-hosts-ip-address/)

-->
