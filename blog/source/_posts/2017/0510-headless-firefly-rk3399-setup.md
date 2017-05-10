---
title: Headless Firefly-RK3399 Setup
date: 2017-05-10 21:40:10
categories:
- Tech
tags:
- Firefly-RK3399
- Screen Sharing
- Ubuntu
---

{% raw %}
<style type="text/css">
li p { margin: 0; }
.post-body .fancybox img { margin: 0 auto; }
.post-body .fancybox img[alt="install-rk-usb-driver.png"] { margin: 0 auto; }
.code {
  font-family: consolas, Menlo, "PingFang SC", "Microsoft YaHei", monospace;
  padding: 2px 4px;
  word-wrap: break-word;
  color: #555;
  background: #eee;
  border-radius: 3px;
  font-size: 13px;
}
</style>
{% endraw %}

[Firefly-RK3399]: http://www.t-firefly.com/zh/firenow/Firefly-rk3399/

# [Firefly-RK3399][]

## [Flash Image](http://wiki.t-firefly.com/index.php/Firefly-RK3399/Flash_image/en)

Windows:

1. Download [here](http://en.t-firefly.com/en/firenow/Firefly_RK3399/download/), 或[这里](http://www.t-firefly.com/zh/firenow/Firefly-rk3399/download/)
    - Ubuntu 16.04 image: Firefly-RK3399_Ubuntu16.04_201703181519.img
    - RK Tool: AndroidTool_Release_v2.38.rar
    - RK USB driver: DriverAssitant_v4.5.rar
2. Install RK USB Driver
    - Run "DriverAssitant_v4.5/DriverInstall.exe"

        {% asset_img install-rk-usb-driver.png %}

3. Connect device to host
    1. Connect the power adapter to board.
    2. Use Type-C cable to connect host and device together.
    3. Press and hold RECOVERY key.
    4. Shortly press RESET key.
    5. After around two seconds, release RECOVERY key.

    <!-- more -->

    The host will prompt to have new device detected and configured. Open the Device Management, you'll find a new device name "Rockusb Device", as shown below. Return to previous step to reinstall driver if it is not shown.

    {% asset_img rk-usb-device-detected.png %}

4. Flush image
    1. Run "AndroidTool_Release_v2.38/AndroidTool.exe" as Administrator.
        - Edit "config.ini", set "Selected=2" to English

        {% asset_img android-tool.png %}

    2. Switch to "Upgrade Firmware" tab page.
    3. Click "Firmware" button and open the image file.
        - Detail information of the image file, like version and chip, is shown.
    4. Click "Upgrade" button to start flash.

        {% asset_img upgrade-firmware.png %}

    5. If upgrade fails, please try "LowerFormat" in the "Download Image" tab page first, then try again.

    > WARN: If you flash firmware laoder different version of the original machine, please click "Erase Flash" before upgrading the firmware.

## Setup Firefly

1. Connect Display or TV with HDMI cable
2. Connect the power adapter to the board
    - The board will boot automatically once power on
3. Plug USB mouse & keyboard to the board

Now, you can control the board.

    Username: firefly
    Password: firefly

1. Connect the Wi-Fi
2. Enable SSH server
    - Detect SSH server, `ps aux | grep sshd`
        - Otherwise, `sudo apt-get install openssh-server` and `sudo /etc/init.d/ssh start`
    - Get ip address, `ifconfig | grep "inet "`
    - SSH from remote pc, `ssh firefly@<ip>`
3. Screen Sharing from Firefly
    - Install, `sudo apt-get install vino`
    - Config, <span class="code">vino-preferences</span>

        {% asset_img vino-preferences.png %}

    - Start, `/usr/lib/vino/vino-server --sm-disable`
    - Autostart, open "Session and Startup" and check "Desktop Sharing",

        {% asset_img startup.png %}

4. Remote access from Ubuntu
    - Open "Remmina Remote Desktop Client" and add connection,

        {% asset_img remote-desktop-client.png %}

    - Or, remote access from Mac, plz see [here](/2017/05/09/screen-sharing-from-ubuntu-to-mac/).

**Finally, you can control the board from remote PC, without extra accessories or devices.**

> NOTE: You could get ip address of the board from your router’s home page.
