# OpenTX BLE Joystick

Use your OpenTX Blueooth Trainer as a virtual joystick on macOS.

[Video in action](https://www.instagram.com/p/BcN8UkvhLdp/?taken-by=gary.g.j)

## Notes

* foohid (which lets us mount a virtual joystick via IOKit) doesn't work with all games & sims and is no longer supported.
* I built this specifically to use with Liftoff -- which stopped functioning after an major update. It still works really well for plenty of games & sims. So, if this works for your needs, great, otherwise I recommend checking out the [FrSky USB dongle](https://www.frsky-rc.com/product/xsr-sim/) or making use of [Betaflight's HID joystick support](https://github.com/betaflight/betaflight/wiki/HID-Joystick-Support). Anything that interfaces as a HID joystick via USB is going to have better / broader support. 

## Requirements

[foohid](https://github.com/unbit/foohid) must be installed: [foohid-0.2.1.dmg](https://github.com/garyjohnson/opentx-ble-joystick/releases/download/1.3/foohid-0.2.1.dmg)

This is a copy of the last release of foohid, which the original author has stopped hosting. [Note the author's message](https://github.com/unbit/foohid): 
> The foohid driver is currently unsupported and lacks proper thread-safety (leading to security problems), please do not use it in production unless you want to sponsor the project contacting info at unbit dot it

It's unclear what the specific risks are here, so install foohid at your own risk.

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

Dependencies can be installed via carthage:

```bash
brew install carthage
carthage bootstrap
```

Packaging requires create-dmg:

```bash
npm install -g create-dmg
```

Build tasks are defined using fastlane. Install using bundler:

```bash
gem install bundler
bundle
```

To build:
```bash
fastlane build
```

To build DMG:
```bash
fastlane package
```

