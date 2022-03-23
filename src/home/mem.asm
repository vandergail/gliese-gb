;****************************************************************************************
;	File: mem.asm (Game Boy LR35902)
;	Description:
;	Author: biggs
;	Date:
;****************************************************************************************

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;MemSet8 - set memory region up to $FF bytes (a - value, hl - pMem, c - bytecount)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MemSet8::
	;inc c				;fail safe if c = 0
	;jr	.skip
.loop
	ld [hl+], a
.skip
	dec	c				;decrease counter
	jr nz, .loop
	ret

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;MemSet16 - set memory region up to $FFFF bytes (a - value, hl - pMem, bc - bytecount)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MemSet16::
	;inc bc				;fail safe if bc = 0
	;jr .skip		
.loop
	ld [hl+], a			;load value to hl and increase address
.skip
	dec c
	jr	nz, .loop
	dec b
	jr  nz, .loop
	ret

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;MemCopy8: copies memory region up to $FF bytes (hl - pSource, de - pDest, c - bytecount)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
MemCopy8::
;	inc	c				;fail safe if c = 0
;	jr .skip
.loop
	ld a, [hl+]			;get value from hl and increase hl
	ld [de], a			;push value into de
	inc	de				;increase de address
.skip
	dec	c				;decrease counter
	jr	nz, .loop		;if not 0 keep looping
	ret
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;MemCopy16: copies memory region up to $FFFF bytes (hl - pSource, de - pDest, bc - bytecount)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
MemCopy16::
;	inc	bc				;fail safe if bc = 0
;	jr .skip
.loop
	ld a, [hl+]			;get value from hl and increase hl
	ld [de], a			;push value into de
	inc	de				;increase de address
.skip
	dec	bc				;decrease counter
	ld  a, c
	or  b
	jr	nz, .loop		;if not 0 keep looping
	ret