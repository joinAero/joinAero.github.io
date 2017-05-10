---
title: Screen Sharing from Ubuntu to Mac
date: 2017-05-09 17:00:45
categories:
- Tech
tags:
- Screen Sharing
- Remote Desktop
- Ubuntu
- Mac
---

## Ubuntu

1) Open "Desktop Sharing" and setup,

{% asset_img desktop-sharing.png %}

2) `sudo apt-get install dconf-tools` and run `dconf-editor`,

{% asset_img dconf-editor.png %}

## Mac

1) Spotlight Search "Screen Sharing" and connect to,

<!-- more -->

{% asset_img screen-sharing.png %}

2) View and control "Ubuntu Desktop",

{% asset_img ubuntu-desktop.png %}

## References

* [Can no longer use Screen Share ...](https://askubuntu.com/questions/463486/can-no-longer-use-screen-share-to-connect-mac-to-ubuntu-since-upgrading-to-14-04)

<!--

Alternatives (failed):

```
# 1) Ubuntu:

$ sudo vi /etc/ssh/sshd_config
X11Forwarding yes

$ sudo service ssh restart

# 2) Mac:

# XQuartz: https://www.xquartz.org/
$ brew install Caskroom/cask/xquartz

# 3) XQuartz:

# SSH denied
$ sudo vi /etc/ssh/ssh_config
Host *
    ForwardAgent yes
    ForwardX11 yes
$ ssh -X <user@host>

# Remote Desktop from Mac to Ubuntu
$ Xnest -geometry 1280x800 :1 & DISPLAY=:1 ssh -Y <user@host> gnome-session
```

But,

```
Warning: No xauth data; using fake authentication data for X11 forwarding.
Assertion failed: (key->initialized), function dixGetPrivateAddr, file ../include/privates.h, line 122.
connect /tmp/.X11-unix/X1: Connection refused
connect /tmp/.X11-unix/X1: Connection refused

** (gnome-session:4546): WARNING **: Could not open X display
connect /tmp/.X11-unix/X1: Connection refused
connect /tmp/.X11-unix/X1: Connection refused
connect /tmp/.X11-unix/X1: Connection refused
connect /tmp/.X11-unix/X1: Connection refused

** (gnome-session:4546): WARNING **: Cannot open display:
[1]+  Abort trap: 6           Xnest -geometry 1280x800 :1
```

-->
