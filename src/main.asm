;****************************************************************************************
;	File: main.asm (Game Boy LR35902)
;	Description:
;	Author: biggs
;	Date:
;****************************************************************************************

INCLUDE	"constants.asm"

;****************************************************************************************
;	ROM BANK 0 (Home)
;****************************************************************************************

INCLUDE "home.asm"
INCLUDE "home/gamescreen.asm"

;****************************************************************************************
;	ROM BANK 1 (Tile & Sprite Graphics)
;****************************************************************************************

SECTION "Bank 1", ROMX, BANK[$1]

;sprite graphics
GIRL_SPRITE::
INCBIN "gfx/girl.2bpp"

;map tile graphics.
MAP_TILES::
INCBIN "gfx/tiles.2bpp"

;test map
MAP_1::
INCBIN "maps/testmap.bin"


;****************************************************************************************
;	ROM BANK 1D (Music 1)
;****************************************************************************************

SECTION "Bank 1D", ROMX, BANK[$1D]

;Music Engine
INCLUDE "audio/musicengine.asm"

;Instrument Data
MusicWaveInstruments: INCLUDE "audio/wave_instruments.asm"
MusicNoiseInstruments: INCLUDE "audio/noise_instruments.asm"
MusicVibratoTypes: INCLUDE "audio/vibrato_types.asm"

;Music Headers
INCLUDE "audio/headers/musicheaders.asm"

;Songs
INCLUDE "audio/music/test.mml"

;****************************************************************************************
;	WRAM & HRAM
;****************************************************************************************

INCLUDE "wram.asm"
INCLUDE "hram.asm"

;****************************************************************************************
; EOF