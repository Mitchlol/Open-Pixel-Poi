# Open Pixel Poi Assembly Guide

## intro

This is basic assembly guide, and while assembly should be intuitive, this guide includes a few tips, tricks, and order of operations optimizations.

Assembly is identical for both the 25 & 55 pixel LED strips. If you wish to solder your own LED strips or have a 2.2.1 version of the kit, see the <a href="./2.2.1/README.md">2.2.1 Assembly Guide</a> 

## Step 1: 
### Gather your parts
For a single poi you will need:
1. 3D Printed outer shell (clear TPU) - 1x
1. 3D Printed body top (PLA) - 1x
1. 3D Printed body bottom (PLA) - 1x
1. 3D Printed button (PLA) - 1x
1. M3 x 8mm Hex Socket Head Cap Screw - 4x
1. 18650 Li-Ion battery - 1x
1. Open Pixel Poi PCB - 1x
1. Open Pixel Poi LED Strip - 3x

![wiring](./assembly_step_1.jpg)

## Step 2
### Insert 2 led stips. 
Feed 2 led strips in though the holes at the top of the 3D printed top body piece.
![wiring](./assembly_step_2.jpg)

## Step 3
### Connect 2 LED strips to the PCB
Ensure the black levers on the connectors are lifted up (perpendicular) from the PCB.  
Insert the FPC(ribbon cable) connections into the 2 outer connectors.  
Be gentle, minimal force is required, if it catches on something, pull back and try again.  
Secure the ribbon cables by rotating/folding/pushing the black levers down, so they are parallel with the board.  
The LED connections work both ways (like USB-C). I reccomend matching the directions in the photo with the yellow background to avoid twists.  
Look at the 2nd photo with red markings for a generic close up view of the insertion and lever mechanism.  
![wiring](./assembly_step_3.jpg)
![wiring](./assembly_step_3b.jpg)

## Step 4
### Thread 3rd led strip through the PCB
Thread 3rd led strip through the small hole in the PCB.  
Give yourself plenty of slack.  
![wiring](./assembly_step_4.jpg)

## Step 5
### Connect the 3rd LED strip to the PCB
Same as step 3, but using the middle connector.  
Once connected, pull the slack back through the hole in the PCB.  
The LED connections work both ways (like USB-C). I reccomend matching the directions in the photos to avoid twists.  
![wiring](./assembly_step_5a.jpg)
![wiring](./assembly_step_5b.jpg)

## Step 6
### Insert the battery into the top of the body
Push the battery into the body, making sure the positive end is towards the USB port, and lines up with the batt+ label on the board.  
It is a tight fit, this is intentional.  
It goes in easiest if you slide it in all at once, rather than one end first.  
![wiring](./assembly_step_6.jpg)

## Step 7
### Slot in the PCB
Order is important here.  
First slide the usb port into the usb port hole at the top of the poi, while keeping the switch end of the board elevated.  
Then, carefully lever down the board over the battery, this will turn the poi on.  
Finally, make sure the bottom (and sides) of the pcb are fully seated and flush with the body.  
This is often tight as well and may snap in.  
You can turn the poi off with the switch see the [user manual](../../Firmware/MANUAL.md)
![wiring](./assembly_step_7a.jpg)
![wiring](./assembly_step_7b.jpg)

## Step 8
### Snap the button into body
Push the button into the body, it is a snap fit.
> [!CAUTION]
> **Take extra care to avoid contact with the switch on bottom of the board!**
> **It can break easy.**

> [!TIP]
> After writing this guide, I came across a potentialy safer alternative assembly method. Place the button in before putting the PCB in, then hold the body vertically such that gravity lets the button fall to the down position. Then snap the board in without fear of tearing the switch off the pcb, as gravity holds the button away. Maybe this will be useful if someone is assembling many kits.

![wiring](./assembly_step_8.jpg)

## Step 9
### Thread the 3rd led strip through the bottom of the body
Thread the 3rd led strip through the hole at the top of the bottom body half, from the inside to out, make sure it is twisted the right way.
![wiring](./assembly_step_9.jpg)

## Step 10
### Push the 2 body halves together
Once again, the battery is snug. Make sure the LED stips don's get pinched.
![wiring](./assembly_step_10.jpg)

## Step 11
### Screw the two halves together
These screws are going directly into a 3d print, so be gentle, you don't want to strip the threads. You can hold it up to the light to make sure there is no visible gap between the 2 halfs, to know it is snug.

Alternativley, you can just wrap the sucker in packing tape, just make sure you do it after sticking on the LEDs.
![wiring](./assembly_step_11.jpg)

## Step 12
### Apply the LED strips
Peel the backing off the LED strips, and apply to the to body. 
One for each recess.  
Start from the bottom of the poi (by the botton) and work back towards the top.  
If you leave about 0.5mm space at the bottom, it should line up perfectly, and prevent accidental peeling.  
Do this for all 3 strips.  
![wiring](./assembly_step_12a.jpg)
![wiring](./assembly_step_12b.jpg)

## Step 13
### Tuck excess led strip into the body
Start with your hands, and feed the stips into the holes.  
Fold the strips tightly around the plastic edge.  
Use blunt tweezers to help apply the adhesive inside the holes.  
![wiring](./assembly_step_13.jpg)

## Step 14
### Slot the body into the shell
Pull the two longer tabs apart to get the clearnace needed.
![wiring](./assembly_step_14.jpg)

## Step 15
### Party!
> [!NOTE]
> I reccomend doing a <a href="https://mitchlol.github.io/#openpixelpoi">Firmware update</a>. The newest firmware fixes a timing issue that can cause poi to drift out of sync. At the time of writing that is the only change from the currently shipping units. 

Woah! Where did that 2nd poi come from?
![wiring](./2.2.1/assembly_step_15.jpg)
