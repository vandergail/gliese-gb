;****************************************************************************************
;	File: musicheaders.asm (Game Boy LR35902)
;	Description:
;	Author: biggs
;	Date:
;****************************************************************************************

NumberOfSongs:
	db $01
	
SongBanks:
	db BANK(Music_Test)
	
SongHeaderPointers:
	dw Music_Test
	
Music_Test:
	db %1111
	dw Music_Test_Ch1
	dw Music_Test_Ch2
	dw Music_Test_Ch3
	dw Music_Test_Ch4

