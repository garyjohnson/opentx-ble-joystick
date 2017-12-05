# OpenTX BLE Joystick

Use your OpenTX Blueooth Trainer as a virtual joystick on macOS.

<blockquote class="instagram-media" data-instgrm-captioned data-instgrm-version="7" style=" background:#FFF; border:0; border-radius:3px; box-shadow:0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15); margin: 1px; max-width:658px; padding:0; width:99.375%; width:-webkit-calc(100% - 2px); width:calc(100% - 2px);"><div style="padding:8px;"> <div style=" background:#F8F8F8; line-height:0; margin-top:40px; padding:50.0% 0; text-align:center; width:100%;"> <div style=" background:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACwAAAAsCAMAAAApWqozAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAMUExURczMzPf399fX1+bm5mzY9AMAAADiSURBVDjLvZXbEsMgCES5/P8/t9FuRVCRmU73JWlzosgSIIZURCjo/ad+EQJJB4Hv8BFt+IDpQoCx1wjOSBFhh2XssxEIYn3ulI/6MNReE07UIWJEv8UEOWDS88LY97kqyTliJKKtuYBbruAyVh5wOHiXmpi5we58Ek028czwyuQdLKPG1Bkb4NnM+VeAnfHqn1k4+GPT6uGQcvu2h2OVuIf/gWUFyy8OWEpdyZSa3aVCqpVoVvzZZ2VTnn2wU8qzVjDDetO90GSy9mVLqtgYSy231MxrY6I2gGqjrTY0L8fxCxfCBbhWrsYYAAAAAElFTkSuQmCC); display:block; height:44px; margin:0 auto -44px; position:relative; top:-22px; width:44px;"></div></div> <p style=" margin:8px 0 0 0; padding:0 4px;"> <a href="https://www.instagram.com/p/BcN8UkvhLdp/" style=" color:#000; font-family:Arial,sans-serif; font-size:14px; font-style:normal; font-weight:normal; line-height:17px; text-decoration:none; word-wrap:break-word;" target="_blank">wrote a proof-of-concept macos app that translates the #opentx #bluetooth trainer data into a virtual hid joystick for simulator use. using @frsky_rc taranis qx7s and #fpvfreerider #multicopter #dronestagram #taranis #fpv</a></p> <p style=" color:#c9c8cd; font-family:Arial,sans-serif; font-size:14px; line-height:17px; margin-bottom:0; margin-top:8px; overflow:hidden; padding:8px 0 7px; text-align:center; text-overflow:ellipsis; white-space:nowrap;">A post shared by Gary Johnson (@gary.g.j) on <time style=" font-family:Arial,sans-serif; font-size:14px; line-height:17px;" datetime="2017-12-02T23:16:54+00:00">Dec 2, 2017 at 3:16pm PST</time></p></div></blockquote> <script async defer src="//platform.instagram.com/en_US/embeds.js"></script>

## Requirements

[foohid](https://github.com/unbit/foohid) must be installed: [foohid-0.2.1.dmg](https://github.com/unbit/foohid/releases/download/0.2.1/foohid-0.2.1.dmg)

## Latest Release

[Download the latest release](https://github.com/garyjohnson/opentx-ble-joystick/releases/latest)

## Supported Devices

Currenly tested with Taranis Q X7S. Expected to work with Horus devices and other OpenTX devices that support Bluetooth Trainer.

## Model Configuration

Create a model for simulator use. Under model setup, set Internal RF and External RF to **OFF**, set Trainer Mode to **Slave/BT** and Ch. Range to **CH1-8**.

## Usage

OpenTX BLE Joystick will appear in the system tray and will show Searching... until connected. When it finds the radio it will prompt for connection. Use pin **000000** to connect.

## Coming Soon

Currently only supports mapping channels to joystick axis. PPM range calibration and mapping to buttons coming soon.

## Development

Packaging requires create-dmg:

```bash
npm install -g create-dmg
```
