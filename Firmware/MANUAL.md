# Open Pixel Poi User Manual

> [!NOTE]  
> This guide is kept in sync with the firmare ware published to the 
> web-based firmware flasher tool. The PCBs from my web store may 
> arrive with outdated firmware, as they are pre-flashed in batches.

## Quirks & Features
Open pixel poi have a single button menu which gives access to

1. Power on/off
1. 15 pattern slots (split into 3 pattern banks w/ auto cycle options)
1. 5 Brightness levels
1. 10 speeds
1. Voltage display

Note: a freshly flashed firmware will have no pattens and display
a yellow strobe for all of the pattern slots, until they are 
filled via the [app](/Software/README.md).

Also Note: The lowest brightness level can only display primary 
colors, this means patterns and color based battery level will 
have very low fidelity. The second to lowest level can also
struggle a little. This concept is known as 
[color depth](https://en.wikipedia.org/wiki/Color_depth).

## Power On/Off
When off, a single button press will turn the poi on.
When on, a single press and hold will turn the poi off.

Note: When turning the poi off, the press andhold will initially
show the blue dot animation, followed by a green/yellow/red battery
level indicator, then the LEDs will do a single blink and fade 
out from the outer ends to the middle. You can release the button 
after the battery level blinks, and the poi will turn off when the 
animation completes.

## Changing Patterns
A single button press will show the blue dot animation, and then
change to the next pattern. After the 5th pattern, the poi will
loop back to the first pattern.

## Changing pattern banks
A single press, followed by a press and hold will show the pink
dot pattern cycling animation, and then ramp up through the pattern
bank slots. There are 3 slots, which hold 5 patterns each. Release
the hold at the desired bank to select it.

## Auto pattern cycling
When changing pattern banks, keep holding past the 3rd bank, and 
blue dots will appear indicating which bank(s) will be set to auto 
cycle. First (after the 3rd bank selection) is all 3, which will 
cycle all 15 patterns, followed by 1st, 2nd, and 3rd banks. 
Release the hold when the desired bank(s) are indicated and the 
poi will auto cycle the patterns in the sleected bank(s), 
changing the pattern every 10 seconds.

## Changing Brightness
A double press, followed by a press and hold will show the white
dot animation, and then ramp up through the brightness levels.
Release the hold at the desired brightness level to select it.

## Changing Speed
A tripple press, followed by a press and hold will show the red
dot animation, and then ramp up through the speed levels.
Release the hold at the desired speed level to select it.

## Battery level monitoring
A single press and hold will show the battery level as a color.
Green is full, red is empty, shades of yellow inbetween.
If you hold too long, it will go into the shutdown sequence.

Pressing the button 5 times which will show the green->red dot 
animation and enter the voltage display mode. In this mode the 
blue leds represent the integer value of the cell voltage, and
remanining leds represent the tenths of a volt fraction. The 
remaining leds are group into 3s for easier counting, and the
color varies from green to red based on the battery level.

## Low battery
When the battery level gets low (below 3.45v) the brightness will
be limited to level 3 max.

When the battery level gets critical (below 3.33v) the poi will
only display 2 red pixels at either end, at the miniumum level.

When the battery level gets even lower (3.25v) the poi will
automatically shut down.

## Charging
The poi charge via the USB-C port. When charging, a blue led will
light up on the pcb, to indicate charging status. The led's
illumination is visible through the wire holes at the top, and
through the reset hole on the side. The blue led will turn off
when charging is complete. The poi charge at a rate of 500ma.
