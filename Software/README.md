# Open Pixel Poi Software
<div>
<img src="./Screenshot_1.jpg" width="100" height="190"/>
<img src="./Screenshot_2.jpg" width="100" height="190"/>
<img src="./Screenshot_3.jpg" width="100" height="190"/>
<img src="./Screenshot_4.jpg" width="100" height="190"/>
<img src="./Screenshot_5.jpg" width="100" height="190"/>
</div>

## About
This app is written using flutter, a multi-platform framework. It is designed to run on mobile sized screens, but will work on anything. Currently, I have built the app for [Android](#android-releases), [Windows](#windows-releases), and [Web](#web-releases).

This app is the only way transmit patterns to the poi hardware.

All patterns are images. To import a new pattern to the app, it must be a bitmap/png/jpg format. Then simply tap/click/etc the pattern to overwrite the currently active pattern on all connected poi. See the [pattern info doc](./PATTERN_INFO.md) for more details.

App use may require a poi [firmware update](https://mitchlol.github.io/#openpixelpoi)

###### Tips & Tricks
- Select multiple devices to connect to multiple devices.
- Long press scan to proceed to app without any connections.
- Long press a pattern to see it's size, or delete/flip/mirror it.
- Selecting the ∞ pattern slot will trigger auto pattern looping.
- Long press the app name on the patterns page to enter the secret [device settings](../Firmware/CONFIG.md) page.
- The text pattern creation input only accepts capital letters.
- When creating stacked patterns, be mindful of the widths, if the least common multiple is greater than 400, it will crop.
- Buy a \$2000 macbook, a \$1000 iphone and a dev license to build the app for iOS.


## Android Releases
###### ⚠️Uninstall the app  before switching versions.⚠️
- [Open Pixel Poi v2.0.0](https://github.com/Mitchlol/Open-Pixel-Poi/raw/refs/heads/main/Software/open_pixel_poi_v2.0.0.apk)
- [Open Pixel Poi v1.0.0](https://github.com/Mitchlol/Open-Pixel-Poi/raw/refs/heads/main/Software/open_pixel_poi_v1.0.0.apk)

## Windows Releases
- [Open Pixel Poi v2.0.0](https://github.com/Mitchlol/Open-Pixel-Poi/raw/refs/heads/main/Software/open_pixel_poi_windows_v2.0.0.zip)
- [Open Pixel Poi v1.0.0](https://github.com/Mitchlol/Open-Pixel-Poi/raw/refs/heads/main/Software/open_pixel_poi_windows_v1.0.0.zip)

## Web Releases
> [!TIP]
> Web bluetooth api is limited to a single device connection at a time.
> Also, it is unspported on iOS 🤦‍♂️.

- [Open Pixel Poi Web v2.0.0](https://mitchlol.github.io/opp_flutter_app_2.0/index.html)
- [Open Pixel Poi Web v1.0.0](https://mitchlol.github.io/opp_flutter_app_1.0/index.html)
