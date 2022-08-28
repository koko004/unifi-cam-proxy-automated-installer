[![unifi-cam-proxy Discord](https://img.shields.io/discord/937237037466124330?color=0559C9&label=Discord&logo=discord&logoColor=%23FFFFFF&style=for-the-badge)](https://discord.gg/Bxk9uGT6MW)

UniFi Camera Proxy Automated Install
====================================

## This REPO

This script is made for a fast install and reinstall Non Unifi Cameras in Unifi Protect Instance. 
<br>
App is constructed by keshavdv you can visit his repository here: https://github.com/keshavdv/unifi-cam-proxy 
<br>
I only made an automated script for install, reinstall, remove cameras creating cert, docker image, mac and Unifi-Protect instace.
<br>
## Fast Init
<br>
First run Unifi-Protect installer then add Camera and select G3 Micro cam, follow instructions and capture QR to file.
<br>
Upload the QR captured to https://zxing.org cap copy 4 line, this is the TOKEN and you need paste it in this script in section COMPLETE INSTALL and TOKEN fields. You can change MACs from entrypoint.sh files.
<br>
This script is made for 2 cams you can add more or remove editing COMPLETE INSTALL section.
<br>
<br>
NOTE: You can use same QR for both cameras.
<br>

```
git clone https://github.com/koko004/unifi-cam-proxy-automated-installer
cd unifi-cam-proxy-automated-installer
chmod +x automated-installer-unfi-cam-proxy.sh
./automated-installer-unfi-cam-proxy.sh
```

## About

This script is made from work of keshavdv you can visit his repository here: https://github.com/keshavdv/unifi-cam-proxy

This enables using non-Ubiquiti cameras within the UniFi Protect ecosystem. This is
particularly useful to use existing RTSP-enabled cameras in the same UI and
mobile app as your other Unifi devices.

## Documentation

View the documentation at https://unifi-cam-proxy.com

## Donations

If you would like to make a donation to support development, please use [Github Sponsors](https://github.com/sponsors/keshavdv).
