# OpenTX BLE Joystick

Use your OpenTX Blueooth Trainer as a virtual joystick on macOS.

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
