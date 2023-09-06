# Tasmota Berry Script for Shutter control

Small sample to trigger other shutters by controlling the main shutter.
Allows to specify a delay the remote shutter act. 
TODO: Supports a display, to show status

## Use Case 
- Maintain timers at one place
- delay the closing e.g. of the shutter for the terras door, to get a change to enter the house, before locked out by the shutter.
- Simple button to stop the timer program, e.g. for a garden party ;-)

## Features
- allow several open/close times set `open_timers`/`close_timers` to an list of integers. default [1, 2] open, [3, 4] close
- set buttons to stop shutter movement even for the remote shutters. set `stop_buttons`. Default [1, 2, 3], set them at least to your shutter buttons and the timer button
- set `open_delay, close_delay` when initializes object to delay the action in seconds. Default open: 0, close: 60

## Usage
- `./shutter_controller.be` to your esp32
- copy and customize the commands from `./autoexec.be` into yours.

## Todo

- allow more than one remote topic. Workaround: use group topics to control more than one remote shutter. 
- convert it into a package:
  - https://github.com/arendst/Tasmota/blob/development/lib/libesp32/berry_tasmota/src/embedded/persist.be
  - https://tasmota.github.io/docs/Tasmota-Application/
  - https://discord.com/channels/479389167382691863/826169659811168276/1149089442938765324