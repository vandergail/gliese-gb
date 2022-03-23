;****************************************************************************************
;	File: gamescreen.asm (Game Boy LR35902)
;	Description:
;	Author: biggs
;	Date:
;****************************************************************************************

;initilize the game screen
SetupGameScreen:
	call DisableLCD			;Disable LCD so the CPU can access to VRAM
	
	ld	a, $0
	;call PlaySong
	
	;remove this
	;need a routine that reads the header of a map
	ld	a, $08				;fill screen with tiles
	ld	hl, _SCRN0
	ld	bc, SCRN_VX_B * SCRN_VY_B
	call MemSet16
	;end remove this
	
	ld hl, wCharacter1Sprite
	ld de, GIRL_SPRITE		;initilize sprite
	call UpdatePointer
	
	ld	 a, 64				
	add	 8
	ld	 [$C001],a		    ; set x value
	add  8
	ld	 [$C005],a			; other half of sprite is x+8
	ld	 a, 64
	add	 16
	ld	 [$C000],a			; set y value
	ld	 [$C004],a 			; other half of sprite is the same
	ld	 a,0
	ld	 [$C002],a			;set sprite pattern
	add	 2
	ld	 [$C006],a
	ld	 a,%00000000		;set sprite flags
	ld	 [$C003],a
	ld	 [$C007],a
	
	ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJON	;set LCD flags
	ldh [rLCDC], a		;turn on the LCD, BG, etc
	
	ld hl, wScreenPointer
	ld de, GameScreen		;update screen routine
	call UpdatePointer
	
;gamescreen routine
GameScreen:
	call MoveCharacter
	call MoveScreen
	call AnimateCharacter	
	ret
	
;move the character on the screen
MoveCharacter:
	ldh a, [hPADSTATE]
	swap a								;swap bits
	and	$0F								;get first 4 bits
	ld	c, a							;store in c
	jr	z, .notmoving					;skip if no dpad buttons are pressed
	cp	$0C
	jr	z, .notmoving					;skip if up / down are both pressed
	cp	$03
	jr	z, .notmoving					;skip if left / right are both pressed
	ld  a, [wCharacter1Flags]			;get character flags
	ld	b, a							;store in b
	and c								;character still moving in same direction?
	jr	nz, .inccount					;yes, don't update character direction
	ld	a, b							;reload flag values
	and $F0								;clear out direction bits
	or	c								;add new direction bits
	set 5, a							;set moving bit to active
	ld [wCharacter1Flags], a			;update 
.inccount
	ld	a, [wCharacter1AnimCounter]		;get animation counter
	inc a								;increase value
	cp	$10								;frame 16?
	jr  z, .notmoving					;yes, reset
	ld	[wCharacter1AnimCounter], a		;no, update animation counter
	jr	.done
.notmoving
	ld	a, [wCharacter1Flags]
	res 5, a
	ld	[wCharacter1Flags], a
	xor	a
	ld	[wCharacter1AnimCounter], a		;reset animation counter
.done
	ret

MoveScreen:
	ldh	a, [hSCX]
	ld	b, a
	ldh	a, [hSCY]
	ld	c, a
	ld  a, [wCharacter1Flags]		;get character flags
	bit 5, a
	jr	z, .done
.down
	bit 3, a
	jr	z, .up
	inc c
	jr .left
.up
	bit 2, a
	jr	z, .left
	dec c
.left
	bit 1, a
	jr	z, .right
	dec b
	jr .done
.right
	bit 0, a
	jr  z, .done
	inc b
.done
	ld	a, b
	ldh	[hSCX], a
	ld	a, c
	ldh	[hSCY], a
	ret
	
AnimateCharacter:
	ld  a, [wCharacter1Flags]		;get character flags
	bit 5, a
	jr  z, .done					;zero - not moving
	bit	2, a						;test bit for up
	jr	z, .down					;no, skip
	ld  de, GIRL_SPRITE + $C0		;set graphics data pointer
	jr	.flip						;test for flip
.down
	bit	3, a						;same as above
	jr	z, .left
	ld  de, GIRL_SPRITE
	jr	.flip
.left
	bit	1, a
	jr	z, .right
	jr	.nextframe
.right
	jr  .nextframe
.flip
	jr  .update
.nextframe
	ld	a, [wCharacter1AnimCounter]
	cp	$08
	jr	c, .firstframe						;if < 8 then go to first frame
	ld  de, GIRL_SPRITE + $80
	jr	.update
.firstframe	
	ld  de, GIRL_SPRITE + $40
.update
	ld  hl, wCharacter1Sprite
	call UpdatePointer
.done
	ret
	
;EOF