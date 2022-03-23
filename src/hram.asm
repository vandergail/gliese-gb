;****************************************************************************************
;	File: hram.asm (Game Boy LR35902)
;	Description:
;	Author: biggs
;	Date:
;****************************************************************************************

;****************************************************************************************
;	HRAM	($FF80-$FFFE)
;****************************************************************************************

SECTION "HRAM", HRAM

;--------------------------------------;
; location of DMA code ($FF80 - $FF8F) ;
;--------------------------------------;
hDMACode::
	ds DMAEnd - DMACode

;------------------;
; current ROM bank ;
;------------------;
hBankROM::
	ds 1

;-------------------------;
; screen scroll registers ;
;-------------------------;
hSCX::
	ds 1
	
hSCY::
	ds 1
	
;----------------;
; hVRAMCopyFlags ;
;----------------;	
;bit 0 - update BG map
;bit 1 - update character sprite 1
;bit 2 - update animated tiles
;bit 3 - update on/off BG tiles
;bit 4 - update text	
hVRAMUpdateFlags::
	ds 1

;-------------------;	
; current pad state ;
;-------------------;
hPADSTATE::
	ds 1

;---------------;	
; old pad state	;
;---------------;
hPADSTATEOLD::
	ds 1
