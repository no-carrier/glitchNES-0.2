;       ----------------------------------------------------

;    glitchNES - version 0.2
;    Copyright 2010 Don Miller
;    For more information, visit: http://www.no-carrier.com

;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.

;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.

;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.

;       ----------------------------------------------------

tilenum = $c2
scroll_h = $c3
scroll_v = $c4
PPU_ADDR = $c5
delay = $d0
write_toggle = $d2
NewButtons = $41
OldButtons = $42
JustPressed = $43
ScreenNumber = $44
OldScreen = $45
NewButtons2 = $46
OldButtons2 = $47
JustPressed2 = $48
up = $49
down = $50
left = $51
right = $52
bank1 = $53
PaletteNumber = $54
flash = $57
tapThreshold = $e0
tapCounter = $e1
tapEnabled = $e2
toggleEffect = $e3
pause = $e4

;       ---------------------------------------------------- NES header

        .ORG $7ff0
Header:                         ;16 byte .NES header (iNES)
	.db "NES", $1a		;NES followed by MS-DOS end-of-file
	.db $02			;size of PRG ROM in 16kb units
	.db $04                 ;size of CHR ROM in 8kb units
	.db #%00010000		;flags 6, set to: mapper 4, HORZ mirroring
	.db #%00000000		;flags 7, set to: mapper 4
        .db $00                 ;size of PRG RAM in 8kb RAM
        .db $00                 ;flags 9 -- SET to 0 for NTSC
        .db $00                 ;flags 10, set to 0
        .db $00                 ;11 - the rest are zeroed out
        .db $00                 ;12
        .db $00                 ;13
        .db $00                 ;14
        .db $00                 ;15

;       ---------------------------------------------------- reset routine

Reset:
        SEI
        CLD
	LDX #$00
	STX $2000
	STX $2001
	DEX
	TXS
  	LDX #0
  	TXA
ClearMemory:
	STA 0, X
	STA $100, X
	STA $200, X
	STA $300, X
	STA $400, X
	STA $500, X
	STA $600, X
	STA $700, X
        STA $800, X
        STA $900, X
        INX
	BNE ClearMemory

;       ---------------------------------------------------- MMC1 setup

        LDA #$80
        STA $8000               ; reset mapper

        LDA #%00010011
        JSR setMMC1ControlMode  ; 32kb PRG, 8KB CHR, HORZ mapping

        LDA #$00
        JSR setCHRPage0000

        LDA #$01
        JSR setCHRPage1000

        LDA #$00
        JSR setPRGBank

        JMP SET_VARI

;       ---------------------------------------------------- MMC1 subroutines

setMMC1ControlMode:
        STA $8000
        LSR A
        STA $8000
        LSR A
        STA $8000
        LSR A
        STA $8000
        LSR A
        STA $8000
        RTS

setCHRPage0000:
        STA $A000
        LSR A
        STA $A000
        LSR A
        STA $A000
        LSR A
        STA $A000
        LSR A
        STA $A000
        RTS

setCHRPage1000:
        STA $C000
        LSR A
        STA $C000
        LSR A
        STA $C000
        LSR A
        STA $C000
        LSR A
        STA $C000
        RTS

setPRGBank:
        STA $E000
        LSR A
        STA $E000
        LSR A
        STA $E000
        LSR A
        STA $E000
        LSR A
        STA $E000
        RTS

;       ---------------------------------------------------- setting up variables

SET_VARI:

        lda #$00
        sta scroll_h
        sta scroll_v
        sta PPU_ADDR+1
        STA ScreenNumber
        STA PaletteNumber
        sta up
        sta down
        sta left
        sta right
        sta toggleEffect
        sta write_toggle
        sta bank1
        sta flash
        sta pause

        lda #$20
        sta PPU_ADDR+0

        lda #4
        sta delay

;       ---------------------------------------------------- warm up

	LDX #$02
WarmUp:
	bit $2002
	bpl WarmUp
	dex
	BNE WarmUp

       	LDA #$3F
	STA $2006
	LDA #$00
	STA $2006
load_pal:                       ; load palette
        LDA palette,x
        sta $2007
        inx
        cpx #$20
        bne load_pal

	LDA #$20
	STA $2006
	LDA #$00
	STA $2006

	ldy #$04                ; clear nametables
ClearName:
	LDX #$00
	LDA #$00
PPULoop:
	STA $2007
	DEX
	BNE PPULoop

	DEY
	BNE ClearName

;       ----------------------------------------------------

        LDA #<pic0              ; load low byte of first picture
        STA $10

        LDA #>pic0              ; load high byte of first picture
        STA $11

;       ---------------------------------------------------- write the welcome message

        lda #$20
        sta $2006
        lda #$82
        sta $2006
        ldx #$00
WriteWelcome:
        lda WelcomeText,x
        cmp #$0d
        beq DoneWelcome
        sta $2007
        INX
        JMP WriteWelcome
DoneWelcome:

;       ---------------------------------------------------- turn on screen

        JSR Vblank

;       ---------------------------------------------------- loop forever

InfLoop:

        inc tilenum

CheckPause:
        lda pause
        beq CheckWrite
        JMP InfLoop
CheckWrite:
        lda toggleEffect
        beq CheckWrite2
        jsr writer
CheckWrite2:
        lda write_toggle
        beq CheckUpTog
        jsr writer
CheckUpTog:
        lda up
        beq CheckDownTog
        inc scroll_v
CheckDownTog:
        lda down
        beq CheckLeftTog
        dec scroll_v
CheckLeftTog:
        lda left
        beq CheckRightTog
        dec scroll_h
CheckRightTog:
        lda right
        beq CheckFlash
        inc scroll_h
CheckFlash:
        lda flash
        beq CheckOver
        lda #$3f
        sta $2006
        lda #$00
        sta $2006
        ldx #0
        lda <32
FlashLoop:
        sta $2007
        inx
        inx
        inx
        inx
        cpx #32
        bne FlashLoop
        inc <32

CheckOver:

        jsr delay_loop

        JMP InfLoop

;       ---------------------------------------------------- magic delay loop

delay_loop:                     ; First delay subroutine
       ldx delay
LOOP1:
       NOP
       LDY #13                  ; Second delay parameter
LOOP2:
       NOP
       DEY
       BNE LOOP2

       DEX
       BNE LOOP1
       RTS

;       ---------------------------------------------------- palette loading routine

LoadNewPalette:
       	LDX PaletteNumber       ; load palette lookup value
        LDY #$00
        LDA #$3F
	STA $2006
	LDA #$00
	STA $2006
LoadNewPal:                     ; load palette
        LDA palette, x
        STA $2007
        INX
        INY
        CPY #$10
        BNE LoadNewPal
        RTS

;       ---------------------------------------------------- draw screen(s)

DrawScreen:

   	LDA #$20                ; set to beginning of first nametable
    	STA $2006
    	LDA #$00
    	STA $2006

        LDY #$00
        LDX #$04

NameLoop:                       ; loop to draw entire nametable
        LDA ($10),y
        STA $2007
        INY
        BNE NameLoop
        INC $11
        DEX
        BNE NameLoop

        RTS

;       ----------------------------------------------------

DrawScreen2:

   	LDA #$28                ; set to beginning of first nametable
    	STA $2006
    	LDA #$00
    	STA $2006

        LDY #$00
        LDX #$04

NameLoop2:                       ; loop to draw entire nametable
        LDA ($10),y
        STA $2007
        INY
        BNE NameLoop2
        INC $11
        DEX
        BNE NameLoop2

        RTS

;       ---------------------------------------------------- screen on: start the party

Vblank:
	bit $2002
	bpl Vblank

        ldx scroll_h
        stx $2005
        ldx scroll_v
        stx $2005

	LDA #%10001000
	STA $2000
        LDA #%00001110
	STA $2001

        RTS

;       ---------------------------------------------------- load new screen

LoadScreen:

        LDA ScreenNumber

Test0:
        CMP #0                  ; compare ScreenNumber to find out which picture / palette to load
        BNE Test1
        LDA #<pic0              ; load low byte of picture
        STA $10
        LDA #>pic0              ; load high byte of picture
        STA $11
        LDA #$00
        STA PaletteNumber       ; set palette lookup location
        LDA #0
        STA bank1               ; set up CHR banks
        RTS

Test1:
        CMP #1
        BNE Test2
        LDA #<pic1
        STA $10
        LDA #>pic1
        STA $11
        LDA #$10
        STA PaletteNumber
        LDA #1
        STA bank1
        RTS

Test2:
        CMP #2
        BNE Test3
        LDA #<pic2
        STA $10
        LDA #>pic2
        STA $11
        LDA #$20
        STA PaletteNumber
        LDA #2
        STA bank1
        RTS

Test3:
        CMP #3
        BNE Test4
        LDA #<pic3
        STA $10
        LDA #>pic3
        STA $11
        LDA #$30
        STA PaletteNumber
        LDA #3
        STA bank1
        RTS

Test4:
        CMP #4
        BNE Test5
        LDA #<pic4
        STA $10
        LDA #>pic4
        STA $11
        LDA #$40
        STA PaletteNumber
        LDA #4
        STA bank1
        RTS

Test5:
        CMP #5
        BNE Test6
        LDA #<pic5
        STA $10
        LDA #>pic5
        STA $11
        LDA #$50
        STA PaletteNumber
        LDA #5
        STA bank1
        RTS

Test6:
        CMP #6
        BNE Test7
        LDA #<pic6
        STA $10
        LDA #>pic6
        STA $11
        LDA #$60
        STA PaletteNumber
        LDA #6
        STA bank1
        RTS

Test7:
        LDA #<pic7
        STA $10
        LDA #>pic7
        STA $11
        LDA #$70
        STA PaletteNumber
        LDA #7
        STA bank1
        RTS

;       ---------------------------------------------------- CHR bankswitching

BankSwitch:

        lda bank1
        jsr setCHRPage0000

        rts

;       ---------------------------------------------------- check for input

controller_test:

        LDA NewButtons
	STA OldButtons

        LDA NewButtons2
	STA OldButtons2

	LDA ScreenNumber        ; save old screen number for later compare
	STA OldScreen

	LDA #$01		; strobe joypad
	STA $4016
	LDA #$00
	STA $4016

        LDX #$00
ConLoop:
	LDA $4016		; check the state of each button
	LSR
	ROR NewButtons
        INX
        CPX #$08
        bne ConLoop

        LDX #$00
ConLoop2:
	LDA $4017		; check the state of each button
	LSR
	ROR NewButtons2
        INX
        CPX #$08
        bne ConLoop2

	LDA OldButtons          ; invert bits
	EOR #$FF
	AND NewButtons
	STA JustPressed

        LDA OldButtons2          ; invert bits
	EOR #$FF
	AND NewButtons2
	STA JustPressed2

CheckSelect:
	LDA #%00000100
	AND JustPressed
	BEQ CheckStart

        lda write_toggle        ; toggle tile writing routine
        eor #$01
        sta write_toggle

CheckStart:
	LDA #%00001000
	AND JustPressed
	BEQ CheckLeft

        inc bank1               ; increases CHR bank, but preserves NAM
        jsr BankSwitch

CheckLeft:
	LDA #%01000000
	AND JustPressed
	BEQ CheckRight

	lda left                ; toggles LEFT movement, turns off RIGHT
	eor #$01
	sta left
	lda #$00
	sta right

CheckRight:
	LDA #%10000000
	AND JustPressed
	BEQ CheckDown

	lda right               ; toggles RIGHT movement, turns off LEFT
	eor #$01
	sta right
	lda #$00
	sta left

CheckDown:
	LDA #%00100000
	AND JustPressed
	BEQ CheckUp

	lda down                ; toggles DOWN movement, turns off UP
	eor #$01
	sta down
	lda #$00
	sta up

CheckUp:
	LDA #%00010000
	AND JustPressed
	BEQ CheckB

	lda up                  ; toggles UP movement, turns off DOWN
	eor #$01
	sta up
	lda #$00
	sta down

CheckB:
	LDA #%00000010
	AND JustPressed
	BEQ CheckA

	dec delay               ; slows down things, kind of...
	lda delay
	cmp #255
	bne CheckA
	lda #0
	sta delay

CheckA:
	LDA #%00000001
	AND JustPressed
	BEQ CheckSelect2

        inc delay               ; speeds things up, pretty much...

;       ---------------------------------------------------- controller #2

CheckSelect2:
	LDA #%00000100
	AND JustPressed2
	BEQ CheckStart2

        lda flash               ; toggles flashing background color #0
        eor #$01
        sta flash

CheckStart2:
	LDA #%00001000
	AND NewButtons2         ; notice this is NewButtons2
        BEQ NoPause

        lda #1                  ; if start is held, pause everything
        sta pause
        jmp CheckLeft2

NoPause:
        lda #0
        sta pause

CheckLeft2:
	LDA #%01000000
	AND JustPressed2
	BEQ CheckRight2

        ; DO SOMETHING HERE

CheckRight2:
	LDA #%10000000
	AND JustPressed2
	BEQ CheckDown2

        ; DO SOMETHING HERE, TOO

CheckDown2:
	LDA #%00100000          ; changes the screen / NAM & CHR bank
	AND JustPressed2
	BEQ CheckUp2

	DEC ScreenNumber        ; decrement screen number here
        LDA ScreenNumber
        BPL CheckUp2
	LDA #7	                ; equal to total # of screens, starting from 0
	STA ScreenNumber

CheckUp2:
	LDA #%00010000          ; changes the screen / NAM & CHR bank
	AND JustPressed2
	BEQ CheckB2

	INC ScreenNumber        ; increment screen number here
        LDA ScreenNumber
	CMP #8	                ; equal to total # of screens +1, starting from 0
	BNE CheckB2
	LDA #0
	STA ScreenNumber

;       ---------------------------------------------------- tap tempo

CheckB2:
	LDA #%00000010          ; tap tempo feature by Batsly Adams - hell, yeah!
        AND OldButtons2
	BNE JHigh

JLow:
        LDA #%00000010
        AND NewButtons2
        BEQ ButtonIdle          ; J/C = 0/0 -> The button is idle
        JMP ButtonHit           ; J/C = 0/1 -> The button is newly hit

JHigh:
        LDA #%00000010
        AND NewButtons2
        BEQ ButtonReleased      ; J/C = 1/0 -> The button was just released
        JMP ButtonHeld          ; J/C = 1/1 -> The button is being held

ButtonIdle:                     ; Do nothing
        JMP CheckA2

ButtonHit:

        lda #0
        sta write_toggle        ; turn off writing routine if its toggled on

        LDA #$00
        STA tapThreshold        ; Reset the threshold
        STA tapCounter          ; Reset the counter
        STA tapEnabled          ; Disable the effect in infloop for now to avoid concurrency
        LDA #$01
        STA toggleEffect        ; Enable the effect immediately
        JMP CheckA2 ;Over

ButtonReleased:
        LDA #$00
        STA tapCounter          ; Reset the tapCounter
        STA toggleEffect        ; Bring the toggleEffect low to show immediate change

        LDA #$01
        STA tapEnabled          ; Enable the tap routine in infloop
        JMP CheckA2 ;Over

ButtonHeld:
        INC tapThreshold        ; Increase the length of the effect
        LDA #$01
        STA toggleEffect        ; Make sure the effect stays high for visual feedback

;       ----------------------------------------------------

CheckA2:
	LDA #%00000001          ; turn off all tile writing routines
	AND JustPressed2
	BEQ EndDrawChk

        lda #0
        sta tapThreshold        ; Reset the threshold
        sta tapCounter          ; Reset the counter
        sta tapEnabled          ; Disable the effect in infloop for now to avoid concurrency
        sta toggleEffect        ; Might already be defined in your glitchnes code
        sta write_toggle        ; turn this off so its not doubled up

EndDrawChk:                     ; check to see if its time to draw a new screen

        LDA ScreenNumber        ; has screen number changed? if not, skip redraw
	CMP OldScreen
	BEQ ConCheckOver

    	LDA #%00000000          ; disable NMI's and screen display
 	STA $2000
   	LDA #%00000000
   	STA $2001

        JSR LoadScreen          ; turn off and load new screen data
        JSR LoadNewPalette      ; load new palette
        JSR DrawScreen          ; draw new screen
        JSR LoadScreen          ; turn off and load new screen data
        JSR DrawScreen2         ; draw new screen
        JSR BankSwitch          ; CHR bankswitch

        lda #$00                ; reset scroll
        sta scroll_h
        sta scroll_v

        JSR Vblank              ; turn the screen back on

ConCheckOver:

        RTS

;       ---------------------------------------------------- tile writing routine

writer:                         ; this routine increases tile number and screen location
        ldy #$ff                ; then draws to the screen
write_tile:
        LDA PPU_ADDR+0
    	STA $2006
    	LDA PPU_ADDR+1
    	STA $2006

        inc tilenum
        lda tilenum
        sta $2007

        inc PPU_ADDR+1
        lda PPU_ADDR+1
        bne end_write
        inc PPU_ADDR+0

end_write:
        dey
        bne write_tile
        RTS

;       ---------------------------------------------------- <3 the NMI

NMI:
        jsr controller_test

        ldx scroll_h
        stx $2005
        ldx scroll_v
        stx $2005

;       ---------------------------------------------------- tap tempo handler

        LDA tapEnabled          ; This controls the tap tempo effects
        BEQ Over1               ; Skip routine if tapEnabled = 0

        LDA tapCounter
        CMP tapThreshold
        BNE TempLabel           ; If tapCounter = tapThreshold

        LDA toggleEffect        ; Toggle the effect
        EOR #$01
        STA toggleEffect
        LDA #$00
        STA tapCounter          ; Reset the counter
        JMP Over1

TempLabel:
        INC tapCounter          ; Else increase the tapCounter

Over1:

;       ----------------------------------------------------

        RTI
IRQ:
        RTI

;       ----------------------------------------------------  data

palette:                        ; palette data

        .INCBIN "pal0.pal"                                                    ; palette 0 - aligns with pic0 below
        .byte $0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30 ; palette 1 - alings with pic1 below
        .byte $0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30 ; palette 2 - etc.
        .byte $0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30 ; palette 3
        .byte $0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30 ; palette 4
        .byte $0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30 ; palette 5
        .byte $0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30,$0F,$00,$10,$30 ; palette 6
        .INCBIN "8bp.pal"                                                     ; palette 7 - for the 8bitpeoples logo

;       ----------------------------------------------------

pic0:
        .INCBIN "order.nam"
pic1:
        .INCBIN "order.nam"
pic2:
        .INCBIN "order.nam"
pic3:
        .INCBIN "order.nam"
pic4:
        .INCBIN "order.nam"
pic5:
        .INCBIN "order.nam"
pic6:
        .INCBIN "order.nam"
pic7:
        .INCBIN "icon.nam"
        
WelcomeText:
        .db "GLITCHNES 0.2 BY NO CARRIER",$0D

;       ----------------------------------------------------

	.ORG $fffa
	.dw NMI
	.dw Reset
	.dw IRQ

;       ----------------------------------------------------

;                             8888
;                         8888888888888888888888
;                        888888888888888888888888888
;                        888   8888888888888888888888888
;                        888 8888  8888888888888888888888888
;                        888 88888888  8888888888888 8888888
;                        888 888888888888  888888888 8888888
;                        888 88888  888888888  88888 888  88
;                        888 8888    8  888888888888 888  88
;                        888 8888        88888888888 888  88
;                        888 88888       88888888888 888  88
;                  88    888 888888    8888888888888 888  88
;               888888888  8888888888888888888888888 8888888
;                 88888888888  888888888888888888888 88888
;           88        88888888888  88888888888888888 888 88888
;               88        88888  8888  8888888888888 8 888888888
;        8          88        88888  8888  888888888 88888888888
;     88     8          88        88888888888  888  888888888888
; 8       88     8          88        88888888888  888888888
;   888       88     8          88        888888  888  8
;       888       88     8          88        88888888
;           888       88     8          88       88888
;               888       88     8               88888
;                   888       88     8           88888
;                       888       88           888
;                           888            888
;                               888    888
;                                    8
;
;            8BITPEOPLES RESEARCH AND DEVELOPMENT 2010
;                       WWW.8BITPEOPLES.COM
;                    FEEL THE POWER, NEVER DIE
