;****************************************************************************************
;	File: wram.asm (Game Boy LR35902)
;	Description:
;	Author: biggs
;	Date:
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////
;****************************************************************************************
;	WRAM0	($C000-$CFFF)
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////

;****************************************************************************************
;	Oam Buffer ($C000-$C09F)
;****************************************************************************************

SECTION "OAM Buffer", WRAM0[$C000]

wOAMBuffer::
	DS 4 * 40	;40 sprites with 4 bytes each

;****************************************************************************************
;	Audio Data ($C300-$C3FF)
;****************************************************************************************

SECTION "WRAM Bank 3", WRAM0[$C300]

;Current Song ID
; bit 7 is set once the song has been started
wCurSongID::
	ds $1

;Current Song Bank	
;
wCurSongBank::
	ds $1

; Current SFX ID
; bit 7 is set once the sfx has been started
wCurSfxID:: ; dd82
	ds $1

wdd83::
	ds $1

wMusicDC::
	ds $1

wdd85::
	ds $1

wMusicDuty1::
	ds $1

wMusicDuty2::
	ds $3

wMusicWave::
	ds $1

wMusicWaveChange::
	ds $1

wdd8c::
	ds $1

wMusicIsPlaying::
	ds $4

wMusicTie::
	ds $4

; Music Channel Pointers
; 4 pointers to the current music commands being executed
wMusicChannelPointers::
	ds $8

; Music Main Loop Start
; 4 pointers to the addresses of the beginning of the main loop for each channel
wMusicMainLoopStart::
	ds $8

wMusicCh1CurPitch::
	ds $1

wMusicCh1CurOctave::
	ds $1

wMusicCh2CurPitch::
	ds $1

wMusicCh2CurOctave::
	ds $1

wMusicCh3CurPitch::
	ds $1

wMusicCh3CurOctave::
	ds $1

wddab::
	ds $1

wddac::
	ds $3

wMusicOctave::
	ds $4

wddb3::
	ds $4
;-------------------------
wddb7::
	ds $1

wddb8::
	ds $1

wddb9:: ;note tie Channel 3?
	ds $1

wddba::
	ds $1
;-------------------------
wNoteDelayCounters::
	ds $4

wMusicE8::
	ds $4

wddc3::
	ds $4

wMusicE9::
	ds $4

wMusicEC::
	ds $4

wMusicSpeed::
	ds $4

wMusicVibratoType::
	ds $4

wMusicVibratoType2::
	ds $4

wdddb::
	ds $4

wMusicVibratoDelay::
	ds $4

wdde3::
	ds $4

wMusicVolume::
	ds $3

wMusicE4::
	ds $3

wdded::
	ds $2

wddef::
	ds $1

wddf0::
	ds $1

wMusicPanning::
	ds $1

wddf2::
	ds $1

; 4 pointers to the positions on the stack for each channel
wMusicChannelStackPointers::
	ds $8

; these stacks contain the address of the command to return to at the end of a sub branch (2 bytes)
; and also contain the address of the command to return to at the end of a loop (2 bytes for address and
; 1 byte for loop count)
wMusicCh1Stack::
	ds $c
	
wMusicCh2Stack::
	ds $c

wMusicCh3Stack::
	ds $c

wMusicCh4Stack::
	ds $c
	
;--- SFX --------------------------------------------------

wde2b:: ; de2b
	ds $3

wde2e:: ; de2e
	ds $1

wde2f:: ; de2f
	ds $3

wde32:: ; de32
	ds $1

wde33:: ; de33
	ds $4

wde37:: ; de37
	ds $6

wde3d:: ; de3d
	ds $2

wde3f:: ; de3f
	ds $4

wde43:: ; de43
	ds $8

wde4b:: ; de4b
	ds $8

wde53:: ; de53
	ds $1

wde54:: ; de54
	ds $1

wCurSongIDBackup:: ; de55
	ds $1

wCurSongBankBackup:: ; de56
	ds $1

wMusicDCBackup:: ; de57
	ds $1

wMusicDuty1Backup:: ; de58
	ds $4

wMusicWaveBackup:: ; de5c
	ds $1

wMusicWaveChangeBackup:: ; de5d
	ds $1

wMusicIsPlayingBackup:: ; de5e
	ds $4

wMusicTieBackup:: ; de62
	ds $4

wMusicChannelPointersBackup:: ; de66
	ds $8

wMusicMainLoopStartBackup:: ; de6e
	ds $8

wde76:: ; de76
	ds $1

wde77:: ; de77
	ds $1

wMusicOctaveBackup:: ; de78
	ds $4

wde7c:: ; de7c
	ds $4

wde80:: ; de80
	ds $4

wde84:: ; de84
	ds $4

wMusicE8Backup:: ; de88
	ds $4

wde8c:: ; de8c
	ds $4

wMusicE9Backup:: ; de90
	ds $4

wMusicECBackup:: ; de94
	ds $4

wMusicSpeedBackup:: ; de98
	ds $4

wMusicVibratoType2Backup:: ; de9c
	ds $4

wMusicVibratoDelayBackup:: ; dea0
	ds $4

wMusicVolumeBackup:: ; dea4
	ds $3

wMusicE4Backup:: ; dea7
	ds $3

wdeaa:: ; deaa
	ds $2

wdeac:: ; deac
	ds $1

wMusicChannelStackPointersBackup::
	ds $8

wMusicCh1StackBackup::
	ds $C * 4

;****************************************************************************************
;	System Data ($????-$????)
;****************************************************************************************	

;interrupt enable storage
wIE::
	ds $1

wInterruptFlags::
	ds $1

wCounterCtr::
	ds $1
	
;console type - DMG, SGB, CGB
wConsole::
	ds $1
	
;****************************************************************************************
;	Game Data ($????-$????)
;****************************************************************************************

;active screen
wScreen::
	ds 1		;jp instruction
	
wScreenPointer::
	ds 2		;screen pointer

;Character Flags
;bit 3	 right
;bit 2	 left
;bit 1	 down
;bit 0 	 up
wCharacter1Flags::
	ds 1
	
wCharacter1AnimCounter::
	ds 1
	
wCharacter1XCoord::
	ds 1

wCharacter1YCoord::
	ds 1
	
wCharacter1Sprite::
	ds 2
	
;////////////////////////////////////////////////////////////////////////////////////////
;****************************************************************************************
;	WRAM1	($D000-$DFFF)
;****************************************************************************************
;////////////////////////////////////////////////////////////////////////////////////////

;****************************************************************************************
;	Stack Pointer ($DFFF)
;****************************************************************************************

SECTION "Stack", WRAMX[$DFFF], BANK[1]
wStack::
	DS -$100