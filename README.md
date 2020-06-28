# RunTiny
Endless runner game developed for the AVR ATtiny10 microcontroller and a 128x32 monochrome OLED Display.
The input is provided by a push-button so that the entire set-up requires just 3 components (besides power source).

The entire code is written in assembly to optimize the space and fit it into the 1kB flash memory. 
The entire firmware occupies 778 bytes of flash memory. It contains the game as well as handling the microcontroller I/O and display communication (through TWI).

![RunTiny - ATtiny10 Game](./assets/RunTiny_game.jpg)

## Usage
The game mechanics is quite intuitive: use the button to jump the obstacles.
When an obstacle hits the player the microcontroller goes into sleep mode. A new button press will awake the microcontroller and restart the game.

## Power Source
Anything between 3.3V-4.5V will do. 
Tested with:
- 1S 150mAh Lipo 
- CR2032 button battery.

## Wiring
The ATtiny10 has 3 usable I/O (PB3 is the reset) and are all used as follows:
- PB0: SDA
- PB1: SCL
- PB2: Push-button (INT0)

This schematic shows the circuit connections:
<div><img src="./assets/schematics.png" width=350px></div>

## Firmware Build
If you use PlatformIO you can follow [this guide](http://www.bitbanging.space/posts/attiny10-programming-platformio-terminal). It shows how to set-up the ATtiny10 environment. After that, it's very easy to compile and upload the firmware on the chip. 
As an alternative, it can be compiled using avr-gcc directly.

## Firmware Upload
If you just want to upload the firmware, you can do so using avrdude and USBASP. Be sure the USBASP jumper is set on 5V and the firmware is up to date (the firmware loaded on most devices sold doesn't support TPI required for the ATTiny10). You can use [these instructions](http://www.bitbanging.space/posts/usbasp-firmware-update) to update the USBASP firmware.

## ATtiny85 and more
The game should work on other AVR devices (i.e. ATtiny85) with minor changes or none at all (not tested yet though).