---
title: Headless Raspberry Pi Setup
date: 2017-05-09 09:12:33
categories:
- Tech
tags:
- Raspberry Pi
- SSH
---

## Install

1. [Download](https://www.raspberrypi.org/downloads/raspbian/) "RASPBIAN JESSIE LITE" without PIXEL desktop.
2. Unzip it to get the image file (.img) for writing to your SD card.
3. Setup headless settings, if don’t have an extra keyboard or HDMI cable.
    1. Add "ssh" file to the SD card root. Then boot your Pi.
    2. Connect it to the router with wire. Then get its ip from the router.
    3. Use SSH to connect to your Pi.
        - `ssh pi@<IP>`, password: raspberry.
    4. Configure your Pi.
        - `sudo raspi-config`
    5. Setting WIFI up and reboot wireless.
        - `sudo vi /etc/wpa_supplicant/wpa_supplicant.conf`
        ```
        network={
            ssid="ssid"
            psk="password"
            priority=1
            id_str="home"
        }
        ```
        - `sudo reboot`
    6. Setting static ip.
        - `ifconfig`
        - `sudo nano /etc/dhcpcd.conf`
        ```
        # Custom static IP address
        interface wlan0
        static ip_address = 192.168.1.121/24
        static routers = 192.168.1.9
        ```
3. Writing the image to the SD card, see the guide for your system:
    - [Linux](https://www.raspberrypi.org/documentation/installation/installing-images/linux.md)
    - [Mac OS](https://www.raspberrypi.org/documentation/installation/installing-images/mac.md)
    - [Windows](https://www.raspberrypi.org/documentation/installation/installing-images/windows.md)

* [Installation Guide](https://www.raspberrypi.org/documentation/installation/installing-images/README.md)
* [Headless Raspberry Pi Setup](https://hackernoon.com/raspberry-pi-headless-install-462ccabd75d0)
* [Mac下安装树莓派系统raspbian](http://www.jianshu.com/p/5dc83db2b78e)

## Prepare

```
sudo apt-get update
```

### Vim

```
# vim
sudo apt-get remove vim-common
sudo apt-get install vim

# config vim
sudo vi /etc/vim/vimrc

# 显示行号
set nu
# tab 退四格
set tabstop=4
# 语法高亮
syntax on
# 显示空白符
# http://stackoverflow.com/questions/1675688/make-vim-show-all-white-spaces-as-a-character

# howto: http://vimsheet.com/
```

### Samba

```
# samba
sudo apt-get install samba samba-common-bin

# config samba
sudo vi /etc/samba/smb.conf

[homes]
  read only = no

# restart
sudo /etc/init.d/samba restart
# add user
sudo smbpasswd -a pi

# Connect it under "Shared of Finder on Mac"
```

### Python

```
python --version

# pip
which pip
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py

# config pip
vi ~/.pip/pip.conf

[global]
format=columns
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com

pip list [--outdated]
sudo pip install --upgrade (package)

# GPIO
sudo pip install RPi.GPIO
```

### Then

```
sudo apt-get remove
```

## Usage

Light a LED and so on.

RPi.GPIO: https://sourceforge.net/p/raspberry-gpio-python/wiki/Home/

`vi led.py`:

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-
import RPi.GPIO as GPIO
import time

print(GPIO.RPI_INFO)

LED = 26

GPIO.setmode(GPIO.BCM)
GPIO.setup(LED, GPIO.OUT)
try:
    while True:
        GPIO.output(LED, GPIO.HIGH)
        time.sleep(1)
        GPIO.output(LED, GPIO.LOW)
        time.sleep(1)
except:
    print("except")
GPIO.cleanup()
```

`vi key.py`:

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-
import RPi.GPIO as GPIO
import time

KEY = 20

GPIO.setmode(GPIO.BCM)
GPIO.setup(KEY, GPIO.IN, GPIO.PUD_UP)
while True:
    time.sleep(0.05)
    if GPIO.input(KEY) == 0:
        print("KEY PRESS")
        while GPIO.input(KEY) == 0:
            time.sleep(0.01)
```

`vi event.py`:

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-
import RPi.GPIO as GPIO
import time

KEY = 20

def MyInterrupt(KEY):
    print("KEY PRESS")

GPIO.setmode(GPIO.BCM)
GPIO.setup(KEY, GPIO.IN, GPIO.PUD_UP)
GPIO.add_event_detect(KEY, GPIO.FALLING, MyInterrupt, 200)

while True:
    time.sleep(1)
```
