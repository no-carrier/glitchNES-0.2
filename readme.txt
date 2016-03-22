--------------------------------------------------------------
glitchNES 0.2 by NO CARRIER
8bitpeoples Research & Development - http://www.8bitpeoples.com
--------------------------------------------------------------

Copyright 2010 Don Miller
For more information, visit: http://www.no-carrier.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

--------------------------------------------------------------
INCLUDED FILES
--------------------------------------------------------------

8bp.pal       - palette file (see below)
asm6          - Mac/Unix ASM6 assembler by loopy
asm6.exe      - Windows ASM6 assembler by loopy
compile.bat   - Batch file to compile glitchNES
compile.sh    - Shell script to compile glitchNES
glitchnes.chr - CHR file (graphics banks)
glitchnes.asm - Source code for glitchNES
glitchnes.asm - Compiled copy of glitchNES
gpl.txt       - GNU General Public License
icon.nam      - nametable file (see below)
order.nam     - nametable file (see below)
pal0.pal      - palette file (see below)
readme.txt    - You're reading it :)

--------------------------------------------------------------
RECOMMENDED SOFTWARE
--------------------------------------------------------------

YY-CHR   - Tile editor  - http://www.briansemu.com/yymarioed/
Context  - Text editor  - http://www.contexteditor.org/
Nestopia - NES emulator - http://nestopia.sourceforge.net/

--------------------------------------------------------------
RECOMMENDED HARDWARE
--------------------------------------------------------------

PowerPak - NES flash cart - http://www.retrousb.com

--------------------------------------------------------------
CONTROLS (MORE DETAILED INFO UNDER "USAGE" BELOW)
--------------------------------------------------------------

---- Controller 1 ----

Select - toggle tile writing (auto-glitch)
Start - bankswitch
Up, Down, Left, Right - toggle movement in that direction
B - slows down everything (kind of)
A - speeds up everything (pretty much)

---- Controller 2 ----

Select - toggle background color cycling
Start - PAUSE (when held down)
Left, Right - not used
Up, Down - change screens and banks
B - tap tempo to control auto-glitch
A - turns off tile writing (auto-glitch) / clears tap tempo

--------------------------------------------------------------
USAGE
--------------------------------------------------------------

glitchNES is an NES ROM image. It will work in Nestopia (see above)
and other NES emulators. It has also been tested on NTSC NES hardware
using both EEPROM development carts and the RetroZone PowerPak.

The controls for 0.2 are very different. Most of them are toggles,
to make it easier to use glitchNES when performing live.

Summary of controller 1 stuff: Select toggles the tile writing routine,
which glitches the screen and scrambles the graphics. Start bankswitches
the CHR / graphics data, but keeps the current nametable loaded. The
arrow keys toggle movement in each direction. B and A slow down and
speed up everything, including the scrolling, tile writing, and the
color flashing on controller 2.

Summary of controller 2 stuff: Select toggles the background color
cycling, which can also scramble the screen depending on the current
speed. Start pauses everything, but only while held down. Left and right
are not used. Up and down changes both the nametable (screen) and the
CHR / graphics bank. B is the tap tempo button. Tap in time to sync
the tile writing routine to the beat. It can also be used for longer
on / off tile writing. If held for 4 beats, it then continue to toggle
the tile writing on and off for 4 beats until you hit the A button,
which turns off the tile writing and clears the tap tempo settings.

All of this can be changed, of course, by editing the source code.
I recommend Context with the 6502 highlighter for easy source code
manipulation. Even easier than editing the source code is changing
the tilesets.

You can use YY-CHR or a tile editor of your choice to edit the NES
ROM image once compiled. Replacing the tiles in the ROM will completely
alter the graphics, but the program will remain the same.

There are two included .NAM files, which are nametables. order.nam is
used for all screens, except for the 8bitpeoples logo. order.nam simply
orders all of the CHR data on the screen four times, as you can see if
you compare the CHR pages to displayed screens inside of glitchNES.
icon.nam places the entire CHR page in the middle of the screen, as you
see on the 8bitpeoples screen. This is good for logos.

If this CHR/NAM stuff confuses you, please download galleryNES and logoNES
from my site, and take a look at the included tools and readme files. It
is very easy to take your .NAM and .CHR files from those tools and use
them with glitchNES. Scroll to the bottom of the source code, and you can
see where the palette and .NAM file for each screen are loaded. Each palette
and .NAM corresponds to one page of CHR data, in order. There are two
example palette files included: pal0.pal and 8bp.pal. pal0.pal is the same
as palettes 1-6, but is included as a binary file to show that external
files can be loaded. 8bp.pal is used just for the final 8bitpeoples logo.
You can used .pal files and hex data entered in at the bottom
interchangeably.

Enjoy!

--------------------------------------------------------------
STILL TO COME
--------------------------------------------------------------

???

--------------------------------------------------------------
BIG UP
--------------------------------------------------------------

Batsly Adams - for the tap tempo code & being the man

KeFF - for good feedback and suggesting the PAUSE feature

loopy - for writing ASM6 and letting me include it here

--------------------------------------------------------------
VERSION HISTORY
--------------------------------------------------------------

0.2 - 08.08.2010 - Lots of new awesome stuff
0.1 - 03.20.2009 - Initial release
