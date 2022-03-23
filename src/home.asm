;****************************************************************************************
;	File: home.asm (Game Boy LR35902)
;	Description:
;	Author: biggs
;	Date:
;****************************************************************************************

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;****************************************************************************************
;	Restart Addresses
;
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////

SECTION	"Org $00", HOME[$00]
RST_00:	
	jp	$100

SECTION	"Org $08", HOME[$08]
RST_08:	
	jp	$100

SECTION	"Org $10", HOME[$10]
RST_10:
	jp	$100

SECTION	"Org $18", HOME[$18]
RST_18:
	jp	$100

SECTION	"Org $20", HOME[$20]
RST_20:
	jp	$100

SECTION	"Org $28", HOME[$28]
RST_28:
	jp	$100

SECTION	"Org $30", HOME[$30]
RST_30:
	jp	$100

SECTION	"Org $38", HOME[$38]
RST_38:
	jp	$100

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
;****************************************************************************************
;	Interrupts
;
;****************************************************************************************	
;////////////////////////////////////////////////////////////////////////////////////////
	
SECTION	"V-Blank IRQ Vector", HOME[$40]
VBL_VECT:
	di
	jp VBlank ;VBlank routine

SECTION	"LCD IRQ Vector", HOME[$48]
LCD_VECT:
	jp LCDStatusHandler ;LCD Status routine

SECTION	"Timer IRQ Vector", HOME[$50]
TIMER_VECT:
	reti

SECTION	"Serial IRQ Vector", HOME[$58]
SERIAL_VECT:
	reti

SECTION	"Joypad IRQ Vector", HOME[$60]
JOYPAD_VECT:
	reti

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
;****************************************************************************************
;	Common Subroutines ($61-$FF)
;
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////

;disables the LCD
DisableLCD:
	ldh a, [rLCDC]
	rlca				;put the highest bit of lcdc into the carry flag
	ret nc				;return - lcd is already off
	ldh a, [rIE]
	ld [wIE], a			;store enabled interrupts
	res 0, a
	ldh [rIE], a    	;disable vblank interrupt
.wait:
	ldh a, [rLY]
	cp $91				;has last scanline drawn?
	jr nz, .wait		;no, keep waiting
	
	ldh	a,[rLCDC]	
	res 7, a			;reset bit 7 of LCDC
	ldh [rLCDC], a
	ld a, [wIE]			;reenable vblank interrupt
	ldh [rIE], a
	ret
	
;clears out work RAM & high RAM ($C000-$DFFF, $FF80-$FFFC)
ClearRAM:
	xor a				;set a to 0
	ld hl, $C000		;RAM address $C000
	ld bc, $2000		;2000 bytes
	call MemSet16		
ClearHRAM:
	xor a				;set a to zero
	ld c, $80			;jump to address $FF80
	ld b, $7D			;125 bytes - leaves the last 2 bytes for the stack pointer ($FFEE-$FFEF)!
.hramloop
	ld [$FF00+c], a
	inc c
	dec b				;is b zero?
	jr nz, .hramloop	;no keep looping
	ret

;clears the sprite table
ClearOAM:
	xor a
	ld	hl, wOAMBuffer		;OAM data location ($C000)
	ld	bc, 40 * 4			;OAM data length 4 bytes * 40 sprites
	call MemSet8
	ret
	
;clears the BG map
ClearBGMap:
	xor a					;load 0 into A (since our tile 0 is blank)
	ld	hl, _SCRN0			;loads the address of the bg map ($9800) into HL
	ld	bc, SCRN_VX_B * SCRN_VY_B
	call MemSet16
	ret

;****************************************************************************************
; Boot Loader & Header Info
;
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////
	
SECTION	"Start", HOME[$100]
	nop
	jp	Init
	
INCLUDE "header.asm"

;****************************************************************************************
;	Program Initilization
;
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////

SECTION "Program Start", HOME[$150]

Init:
	di					;disable interrupts
	ld sp, $FFFF		;temporarily set stack pointer to high ram address ($FFFE)
	
	call ClearRAM		;clear out work & high ram
	call DisableLCD		;turn off LCD
	
	call SetupDMA		;move DMA routine to high RAM
	
	ld	a, IEF_LCDC	| IEF_VBLANK
	ldh	[rIE],a			;enable time, LCDC, & vblank interrupt
	
	call SetupVRAM		;setup VRAM
	call SetupPalettes 	;setup palettes
	call SetupLCD		;setup LCD
	call SetupScreen	;setup screen routine
	call SetupAudio		;setup sound

;REMOVE
	ld	hl,GIRL_SPRITE	;Load sprite graphics into VRAM
	ld	de,_VRAM 		;$8000
	ld	c, 4*16			;4 tiles
	call MemCopy8
	
	ld	hl,MAP_TILES	;Load tile graphics into VRAM
	ld	c, 8*16			;8 tiles
	call MemCopy8
;REMOVE
	
	ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJON	;set LCD flags
	ldh [rLCDC], a		;turn on the LCD, BG, etc
	
	ld sp, wStack		;set stack pointer to internal RAM ($DFFF) rather than ($FFFE) - this frees up high RAM for faster loading
	ei					;enable interrupts

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
;****************************************************************************************
;	Main Program Loop
;
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////
	
Main:
	halt	 					;stop system clock - (reduces power consumption)
	nop
	
	ld hl, wInterruptFlags
	bit 0, [hl]					;check if vblank interrupt
	jr z, Main		 			;no, another interrupt
	res	0, [hl] 				;clear vblank flag

	call ReadPad        		;get button state
	call wScreen            	;game operation
	
	ldh	a, [hPADSTATE]			;get previous pad state
	ldh	[hPADSTATEOLD], a		;move previous pad state to old
	
	jr Main						;loop forever

;****************************************************************************************
;	Game Operation
;
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////

ReadPad:
	ld a,P1F_5
	ld [rP1],a			;select P15
	ld a,[rP1]
	ld a,[rP1]			;wait a few cycles
	cpl					;complement a
	and $0F				;get the first 4 bits
	swap a				;move bits 3-0 into 7-4
	ld b,a				;and store in b
 
	ld a,P1F_4
	ld [rP1],a			;select P14
	ld a,[rP1]
 	ld a,[rP1]
 	ld a,[rP1]
 	ld a,[rP1]
 	ld a,[rP1]
 	ld a,[rP1]			;wait
 	cpl					;complement a
  	and $0F				;get the first 4 bits
  	or b				;combine with the previous result
	ldh	[hPADSTATE], a	;store current pad state
	ld	 a, $30			;deselect P14 and P15
	ldh [rP1], a		;reset joypad
  	ret

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;****************************************************************************************
;	Interrupt Routines
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////

;VBlank routine
VBlank:
	push af
	push hl
	push de
	push bc							;disable interrupts
	call hDMACode 					;jump to DMA routine in HRAM
	call UpdateVRAM
	ldh a, [hSCX]					;update screen parameters
	ld [rSCX], a
	ldh a, [hSCY]
	ld [rSCY], a
	;ldh a, [hWX]
	;ld [rWX], a
	;ldh a, [hWY]
	;ld [rWY], a
	;ld a, [wLCDC]
	;ld [rLCDC], a
	call UpdateAudio				;update audio
	ei								;enable interrupts
	pop bc
	pop de
	pop hl
	pop af
	reti

;DMA routine	
SetupDMA:
	ld	 de, hDMACode			;location of our DMA code in hRAM
	ld	 hl, DMACode			;address of DMACode in ROM
	ld	 c, DMAEnd - DMACode	;length of DMACode
	call MemCopy8				;copy
	ret
DMACode:
	ld 	a, wOAMBuffer / $100	;bank where OAM Data is stored
	ldh	[rDMA], a				;start DMA
	ld 	a, $28					
.wait							;160µs
	dec	a
	jr	nz, .wait				;wait until DMA routine is complete
	ld	hl, wInterruptFlags
	set 0, [hl]
	ret
DMAEnd:

LCDStatusHandler:
	reti

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;****************************************************************************************
;	Support Routines
;
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////

INCLUDE "home/mem.asm"	;memory setting and copying functions

;Setup VRAM	
SetupVRAM:
	call ClearBGMap		;clear out the BG map
	ret
	
;-----------------------------------------------------------------
;	UpdateVRAM
;	description: Game Boy only has ~1ms (< 96 copied bytes) to update VRAM during VBlank
;	input: none
;	output: none
;-----------------------------------------------------------------
	
UpdateVRAM:
	ld a, [wCharacter1Sprite]
	ld l, a
	ld a, [wCharacter1Sprite+1]
	ld h, a
	ld de, _VRAM
	ld c, $40		;16 * 4 = 64 bytes
	call MemCopy8
	ret

;checks to see if Game Boy is GBC
CheckForCGB:
	ld a, [wConsole]
	cp CONSOLE_CGB
	xor a
	cp 1
	ret z
	scf
	ret
	
SetupLCD:
	xor a
	ldh [rSCY], a
	ldh [rSCX], a
	ld [rWY], a
	ld [rWX], a
	;ld [wcab0], a
	;ld [wcab1], a
	;ld [wcab2], a
	ldh [hSCX], a
	ldh [hSCY], a
	;ldh [hWX], a
	;ldh [hWY], a
	;xor a
	;ld [wReentrancyFlag], a
	;ld a, $c3            ; $c3 = jp nn
	;ld [wLCDCFunctiontrampoline], a
	;ld [wVBlankFunctionTrampoline], a
	;ld hl, wVBlankFunctionTrampoline + 1
	;ld [hl], NopF & $ff  ;
	;inc hl               ; load `jp NopF`
	;ld [hl], NopF >> $8  ;
	;ld a, $47
	;ld [wLCDC], a
	;ld a, $1
	;ld [MBC1LatchClock], a
	;ld a, $a
	;ld [MBC1SRamEnable], a
	;NopF:
	ret
	
SetupPalettes:
	ld	a,%11100100		;load a normal palette up 11 10 01 00 - dark->light
	ldh	[rBGP],a		;set background palette
	ldh [rOBP1],a		;set sprite palette 1
	ld	a,%00011100		;palette set so that transparent color is dark gray
	ldh [rOBP0],a		;set sprite palette 0
;	ld hl, wBGP
;	ld a, $e4
;	ld [rBGP], a
;	ld [hli], a
;	ld [rOBP0], a
;	ld [rOBP1], a
;	ld [hli], a
;	ld [hl], a
;	xor a
;	ld [wFlushPaletteFlags], a
;	ld a, [wConsole]
;	cp CONSOLE_CGB
;	ret nz
;	ld de, wBufPalette
;	ld c, $10
;.asm_387
;	ld hl, InitialPalette
;	ld b, $8
;.asm_38c
;	ld a, [hli]
;	ld [de], a
;	inc de
;	dec b
;	jr nz, .asm_38c
;	dec c
;	jr nz, .asm_387
;	call FlushBothCGBPalettes
	ret
	
SetupScreen:
	ld de, wScreen
	ld hl, ScreenCode
	ld c, ScreenEnd - ScreenCode
	call MemCopy8
	ret
ScreenCode:
	jp SetupGameScreen
ScreenEnd:

;-----------------------------------------------------------------
;	UpdatePointer
;	description: updates pointer in IWRAM
;	input: hl - pointer location, de - new screen address
;	output: none
;-----------------------------------------------------------------	
UpdatePointer:
	ld	a, e
	ld [hl+], a
	ld	a, d
	ld [hl], a 
	ret
	
;-----------------------------------------------------------------
;	BankswitchHome
;	description: switches to a new ROM bank for ($4000-7FFF)
;	input: a - ROM bank id
;	output: none
;-----------------------------------------------------------------	
BankswitchHome:
	ldh [hBankROM], a
	ld [MBC1RomBank], a
	ret
	
;Setup Audio
SetupAudio:
	farcall SetupSound_Ext
	ret

;Play Song	
PlaySong:
	ldh a, [hBankROM]
	push af
	ld a, BANK(Func_f4006)
	call BankswitchHome
	ld a, 0
	call Func_f4006
	pop af
	call BankswitchHome
	ret
	
;Update Audio
UpdateAudio:
	;UPDATE MUSIC
	ldh a, [hBankROM]
	push af									;store ROM bank on stack
	ld a, BANK(SoundTimerHandler_Ext)		;load Music ROM bank
	call BankswitchHome						;switch to new ROM bank
	call SoundTimerHandler_Ext				;update Music
	pop af									;pop previous ROM bank
	call BankswitchHome
	;UPDATE MUSIC
	ret

;----------------------------------------------------------------------------------------
;EOF