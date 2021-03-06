;****************************************************************************************
;	File: macros.asm (Game Boy LR35902)
;	Description:
;	Author: biggs
;	Date:
;****************************************************************************************

;****************************************************************************************
;	General Purpose Macros
;****************************************************************************************

farcall: MACRO
	ldh a, [hBankROM]
	push af
	ld a, BANK(\1)
	call BankswitchHome
	call \1	
	pop af
	call BankswitchHome
ENDM


;****************************************************************************************
;	 Audio Macros
;****************************************************************************************

;Note commands for channels 1, 2, & 3 are ORed together as one byte command
;parameters: note, note length (max of 16)

C_: MACRO
	db $10 | (\1 - 1)
ENDM

C#: MACRO
	db $20 | (\1 - 1)
ENDM

D_: MACRO
	db $30 | (\1 - 1)
ENDM

D#: MACRO
	db $40 | (\1 - 1)
ENDM

E_: MACRO
	db $50 | (\1 - 1)
ENDM

F_: MACRO
	db $60 | (\1 - 1)
ENDM

F#: MACRO
	db $70 | (\1 - 1)
ENDM

G_: MACRO
	db $80 | (\1 - 1)
ENDM

G#: MACRO
	db $90 | (\1 - 1)
ENDM

A_: MACRO
	db $A0 | (\1 - 1)
ENDM

A#: MACRO
	db $B0 | (\1 - 1)
ENDM

B_: MACRO
	db $C0 | (\1 - 1)
ENDM

;Note commands for channel 4 is predefined noise instrument
;parameters: instrument name, note length (max of 16)

bass: MACRO
	db $10 | (\1 - 1)
ENDM

snare1: MACRO ; medium length
	db $30 | (\1 - 1)
ENDM

snare2: MACRO ; medium length
	db $50 | (\1 - 1)
ENDM

snare3: MACRO ; short
	db $70 | (\1 - 1)
ENDM

snare4: MACRO ; long
	db $90 | (\1 - 1)
ENDM

snare5: MACRO ; long
	db $C0 | (\1 - 1)
ENDM

;Rest
;

rest: MACRO
	db \1 - 1
ENDM

speed: MACRO
	db $D0, \1
ENDM

octave: MACRO
	db ($d << 4) | \1
ENDM

octave_up: MACRO
	db $d7
ENDM

octave_down: MACRO
	db $d8
ENDM

tie: MACRO
	db $d9
ENDM

musicdc: MACRO
	db $dc, \1
ENDM

MainLoop: MACRO
	db $dd
ENDM

EndMainLoop: MACRO
	db $de
ENDM

Loop: MACRO
	db $df, \1
ENDM

EndLoop: MACRO
	db $e0
ENDM

;unused
music_jp: MACRO
	db $E1
	dw \1
ENDM

CallChannel: MACRO
	db $e2
	dw \1
ENDM

ReturnChannel: MACRO
	db $e3
ENDM

musice4: MACRO
	db $e4, \1
ENDM

duty: MACRO
	db $e5, \1 << 6
ENDM

volume: MACRO
	db $e6, \1
ENDM

wave: MACRO
	db $e7, \1
ENDM

musice8: MACRO
	db $e8, \1
ENDM

musice9: MACRO
	db $e9, \1
ENDM

vibrato_type: MACRO
	db $ea, \1
ENDM

vibrato_delay: MACRO
	db $eb, \1
ENDM

;unused
musicec: MACRO
	db $EC, \1
ENDM

;unused
musiced: MACRO
	db $ED, \1
ENDM

EndChannel: MACRO
	db $FF
ENDM

;sfx_0: MACRO
;	db \1, \2
;ENDM

;sfx_1: MACRO
;	db $10, \1
;ENDM

;sfx_2: MACRO
;	db $20 | \1
;ENDM

;sfx_loop: MACRO
;	db $30, \1
;ENDM

;sfx_endloop: MACRO
;	db $40
;ENDM

;sfx_5: MACRO
;	db $50, \1
;ENDM

;sfx_6: MACRO
;	db $60, \1
;ENDM

;sfx_8: MACRO
;	db $80, \1
;ENDM

;sfx_end: MACRO
;	db $f0
;ENDM