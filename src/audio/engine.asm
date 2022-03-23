;****************************************************************************************
;	File: musicengine.asm (Game Boy LR35902)
;	Description: Audio Engine
;	Author: biggs
;	Date:
;****************************************************************************************

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SetupSound_Ext:: ; f4000 (3d:4000)
	jp MusicInit

SoundTimerHandler_Ext:: ; f4003 (3d:4003)
	jp MusicUpdate

Func_f4006:: ; f4006 (3d:4006)
	jp MusicPlaySong

Func_f4009:: ; f4009 (3d:4009)
	jp Func_f402d

Func_f400c:: ; f400c (3d:400c)
	jp Func_f404e

Func_f400f:: ; f400f (3d:400f)
	jp Func_f4052

Func_f4012:: ; f4012 (3d:4012)
	jp Func_f405c

Func_f4015:: ; f4015 (3d:4015)
	jp Func_f4066

Func_f4018:: ; f4018 (3d:4018)
	jp Func_f406f

Func_f401b:: ; f401b (3d:401b)
	jp MusicPauseSong

Func_f401e:: ; f401e (3d:401e)
	jp MusicResumeSong

;****************************************************************************************
;	MusicPlaySong -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicPlaySong:
	push hl
	ld hl, NumberOfSongs
	cp [hl]
	jr nc, .invalidID
	ld [wCurSongID], a
.invalidID
	pop hl
	ret

Func_f402d: ; f402d (3d:402d)
	push bc
	push hl
	ld b, $0
	ld c, a
	or a
	jr z, .asm_f4043
	ld hl, Unknown_f4e85
	add hl, bc
	ld b, [hl]
	ld a, [wdd83]
	or a
	jr z, .asm_f4043
	cp b
	jr c, .asm_f404b
.asm_f4043
	ld a, b
	ld [wdd83], a
	ld a, c
	ld [wCurSfxID], a
.asm_f404b
	pop hl
	pop bc
	ret

Func_f404e: ; f404e (3d:404e)
	ld [wddf0], a
	ret

Func_f4052: ; f4052 (3d:4052)
	ld a, [wCurSongID]
	cp $80
	ld a, $1
	ret nz
	xor a
	ret

Func_f405c: ; f405c (3d:405c)
	ld a, [wCurSfxID]
	cp $80
	ld a, $1
	ret nz
	xor a
	ret

Func_f4066: ; f4066 (3d:4066)
	ld a, [wddf2]
	xor $1
	ld [wddf2], a
	ret

Func_f406f: ; f406f (3d:406f)
	push bc
	push af
	and $7
	ld b, a
	swap b
	or b
	ld [wMusicPanning], a
	pop af
	pop bc
	ret
	
;****************************************************************************************
;	MusicInit - 
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************

MusicInit: ; f407d (3d:407d)
	xor a
	ld [rNR52], a
	ld a, $80
	ld [rNR52], a
	ld a, $77
	ld [rNR50], a
	ld a, $ff
	ld [rNR51], a
	ld a, $3d
	ld [wCurSongBank], a
	ld a, $80
	ld [wCurSongID], a
	ld [wCurSfxID], a
	ld a, $77 ; set both speakers to max volume
	ld [wMusicPanning], a
	xor a
	ld [wdd8c], a
	ld [wde53], a
	ld [wMusicWaveChange], a
	ld [wddef], a
	ld [wddf0], a
	ld [wddf2], a
	dec a
	ld [wMusicDC], a
	ld de, $0001
	ld bc, $0000
.zeroLoop1
	ld hl, wMusicIsPlaying
	add hl, bc
	ld [hl], d
	ld hl, wMusicTie
	add hl, bc
	ld [hl], d
	ld hl, wddb3
	add hl, bc
	ld [hl], d
	ld hl, wMusicEC
	add hl, bc
	ld [hl], d
	ld hl, wMusicE8
	add hl, bc
	ld [hl], d
	inc c
	ld a, c
	cp $4
	jr nz, .zeroLoop1
	ld hl, MusicChannelLoopStacks
	ld bc, wMusicChannelStackPointers
	ld d, $8
.zeroLoop2
	ld a, [hli]
	ld [bc], a
	inc bc
	dec d
	jr nz, .zeroLoop2
	ret

;****************************************************************************************
;	MusicUpdate -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicUpdate: ; f40e9 (3d:40e9)
	call MusicEmptyFunc
	call MusicCheckForNewSound
	ld hl, Func_fc003
	call Bankswitch3dTo3f
	ld a, [wCurSongBank]
	ldh [hBankROM], a
	ld [MBC3RomBank], a
	ld a, [wddf2]
	cp $0
	jr z, .updateChannels
	call Func_f4980
	jr .skipChannelUpdates
.updateChannels
	call MusicUpdateChannel1
	call MusicUpdateChannel2
	call MusicUpdateChannel3
	call MusicUpdateChannel4
.skipChannelUpdates
	call Func_f4866
	call MusicCheckForEndOfSong
	ret

MusicCheckForNewSound: ; f411c (3d:411c)
	ld a, [wCurSongID]
	rla
	jr c, .checkForNewSfx
	call MusicStopAllChannels
	ld a, [wCurSongID]
	call MusicBeginSong
	ld a, [wCurSongID]
	or $80
	ld [wCurSongID], a
.checkForNewSfx
	ld a, [wCurSfxID]
	rla
	jr c, .noNewSound
	ld a, [wCurSfxID]
	ld hl, Func_fc000
	call Bankswitch3dTo3f
	ld a, [wCurSfxID]
	or $80
	ld [wCurSfxID], a
.noNewSound
	ret

;****************************************************************************************
;	MusicStopAllChannels - 
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicStopAllChannels: ; f414b (3d:414b)
	ld a, [wdd8c]
	ld d, a
	xor a
	ld [wMusicIsPlaying], a
	bit 0, d
	jr nz, .stopChannel2
	ld a, $8
	ld [rNR12], a
	swap a
	ld [rNR14], a
.stopChannel2
	xor a
	ld [wMusicIsPlaying + 1], a
	bit 1, d
	jr nz, .stopChannel4
	ld a, $8
	ld [rNR22], a
	swap a
	ld [rNR24], a
.stopChannel4
	xor a
	ld [wMusicIsPlaying + 3], a
	bit 3, d
	jr nz, .stopChannel3
	ld a, $8
	ld [rNR42], a
	swap a
	ld [rNR44], a
.stopChannel3
	xor a
	ld [wMusicIsPlaying + 2], a
	bit 2, d
	jr nz, .done
	ld a, $0
	ld [rNR32], a
.done
	ret

;****************************************************************************************
;	MusicBeginSong - plays the song given by the id in a
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	

MusicBeginSong:
	push af
	ld c, a
	ld b, $0
	ld hl, SongBanks1
	add hl, bc
	ld a, [hl]
	ld [wCurSongBank], a
	ldh [hBankROM], a
	ld [MBC3RomBank], a
	pop af
	add a
	ld c, a
	ld b, $0
	ld hl, SongHeaderPointers1
	add hl, bc
	ld e, [hl]
	inc hl
	ld h, [hl]
	ld l, e
	ld e, [hl]
	inc hl
	ld b, h
	ld c, l
	rr e
	jr nc, .noChannel1
	ld a, [bc]
	inc bc
	ld [wMusicChannelPointers], a
	ld [wMusicMainLoopStart], a
	ld a, [bc]
	inc bc
	ld [wMusicChannelPointers + 1], a
	ld [wMusicMainLoopStart + 1], a
	ld a, $1
	ld [wddbb], a
	ld [wMusicIsPlaying], a
	xor a
	ld [wMusicTie], a
	ld [wMusicE4], a
	ld [wMusicE8], a
	ld [wMusicVibratoDelay], a
	ld [wMusicEC], a
	ld a, [MusicChannelLoopStacks]
	ld [wMusicChannelStackPointers], a
	ld a, [MusicChannelLoopStacks + 1]
	ld [wMusicChannelStackPointers + 1], a
	ld a, $8
	ld [wMusicE9], a
.noChannel1
	rr e
	jr nc, .noChannel2
	ld a, [bc]
	inc bc
	ld [wMusicChannelPointers + 2], a
	ld [wMusicMainLoopStart + 2], a
	ld a, [bc]
	inc bc
	ld [wMusicChannelPointers + 3], a
	ld [wMusicMainLoopStart + 3], a
	ld a, $1
	ld [wddbb + 1], a
	ld [wMusicIsPlaying + 1], a
	xor a
	ld [wMusicTie + 1], a
	ld [wMusicE4 + 1], a
	ld [wMusicE8 + 1], a
	ld [wMusicVibratoDelay + 1], a
	ld [wMusicEC + 1], a
	ld a, [MusicChannelLoopStacks + 2]
	ld [wMusicChannelStackPointers + 2], a
	ld a, [MusicChannelLoopStacks + 3]
	ld [wMusicChannelStackPointers + 3], a
	ld a, $8
	ld [wMusicE9 + 1], a
.noChannel2
	rr e
	jr nc, .noChannel3
	ld a, [bc]
	inc bc
	ld [wMusicChannelPointers + 4], a
	ld [wMusicMainLoopStart + 4], a
	ld a, [bc]
	inc bc
	ld [wMusicChannelPointers + 5], a
	ld [wMusicMainLoopStart + 5], a
	ld a, $1
	ld [wddbb + 2], a
	ld [wMusicIsPlaying + 2], a
	xor a
	ld [wMusicTie + 2], a
	ld [wMusicE4 + 2], a
	ld [wMusicE8 + 2], a
	ld [wMusicVibratoDelay + 2], a
	ld [wMusicEC + 2], a
	ld a, [MusicChannelLoopStacks + 4]
	ld [wMusicChannelStackPointers + 4], a
	ld a, [MusicChannelLoopStacks + 5]
	ld [wMusicChannelStackPointers + 5], a
	ld a, $40
	ld [wMusicE9 + 2], a
.noChannel3
	rr e
	jr nc, .noChannel4
	ld a, [bc]
	inc bc
	ld [wMusicChannelPointers + 6], a
	ld [wMusicMainLoopStart + 6], a
	ld a, [bc]
	inc bc
	ld [wMusicChannelPointers + 7], a
	ld [wMusicMainLoopStart + 7], a
	ld a, $1
	ld [wddbb + 3], a
	ld [wMusicIsPlaying + 3], a
	xor a
	ld [wMusicTie + 3], a
	ld [wMusicE8 + 3], a
	ld [wMusicVibratoDelay + 3], a
	ld [wMusicEC + 3], a
	ld a, [MusicChannelLoopStacks + 6]
	ld [wMusicChannelStackPointers + 6], a
	ld a, [MusicChannelLoopStacks + 7]
	ld [wMusicChannelStackPointers + 7], a
	ld a, $40
	ld [wMusicE9 + 3], a
.noChannel4
	xor a
	ld [wddf2], a
	ret

MusicEmptyFunc:
	ret

;****************************************************************************************
;	MusicUpdateChannel1 -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicUpdateChannel1: ; f42a5 (3d:42a5)
	ld a, [wMusicIsPlaying]
	or a
	jr z, .asm_f42fa
	ld a, [wddb7]
	cp $0
	jr z, .asm_f42d4
	ld a, [wddc3]
	dec a
	ld [wddc3], a
	jr nz, .asm_f42d4
	ld a, [wddbb]
	cp $1
	jr z, .asm_f42d4
	ld a, [wdd8c]
	bit 0, a
	jr nz, .asm_f42d4
	ld hl, rNR12
	ld a, [wMusicE9]
	ld [hli], a
	inc hl
	ld a, $80
	ld [hl], a
.asm_f42d4
	ld a, [wddbb]
	dec a
	ld [wddbb], a
	jr nz, .asm_f42f4
	ld a, [wMusicChannelPointers + 1]
	ld h, a
	ld a, [wMusicChannelPointers]
	ld l, a
	ld bc, $0000
	call MusicPlayNextNote
	ld a, [wMusicIsPlaying]
	or a
	jr z, .asm_f42fa
	call Func_f4714
.asm_f42f4
	ld a, $0
	call Func_f485a
	ret
.asm_f42fa
	ld a, [wdd8c]
	bit 0, a
	jr nz, .asm_f4309
	ld a, $8
	ld [rNR12], a
	swap a
	ld [rNR14], a
.asm_f4309
	ret

;****************************************************************************************
;	MusicUpdateChannel2 -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicUpdateChannel2: ; f430a (3d:430a)
	ld a, [wMusicIsPlaying + 1]
	or a
	jr z, .asm_f435f
	ld a, [wddb8]
	cp $0
	jr z, .asm_f4339
	ld a, [wddc3 + 1]
	dec a
	ld [wddc3 + 1], a
	jr nz, .asm_f4339
	ld a, [wddbb + 1]
	cp $1
	jr z, .asm_f4339
	ld a, [wdd8c]
	bit 1, a
	jr nz, .asm_f4339
	ld hl, rNR22
	ld a, [wMusicE9 + 1]
	ld [hli], a
	inc hl
	ld a, $80
	ld [hl], a
.asm_f4339
	ld a, [wddbb + 1]
	dec a
	ld [wddbb + 1], a
	jr nz, .asm_f4359
	ld a, [wMusicChannelPointers + 3]
	ld h, a
	ld a, [wMusicChannelPointers + 2]
	ld l, a
	ld bc, $0001
	call MusicPlayNextNote
	ld a, [wMusicIsPlaying + 1]
	or a
	jr z, .asm_f435f
	call Func_f475a
.asm_f4359
	ld a, $1
	call Func_f485a
	ret
.asm_f435f
	ld a, [wdd8c]
	bit 1, a
	jr nz, .asm_f436e
	ld a, $8
	ld [rNR22], a
	swap a
	ld [rNR24], a
.asm_f436e
	ret

;****************************************************************************************
;	MusicUpdateChannel3 -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicUpdateChannel3: ; f436f (3d:436f)
	ld a, [wMusicIsPlaying + 2]
	or a
	jr z, .asm_f43be
	ld a, [wddb9]
	cp $0
	jr z, .asm_f4398
	ld a, [wddc3 + 2]
	dec a
	ld [wddc3 + 2], a
	jr nz, .asm_f4398
	ld a, [wdd8c]
	bit 2, a
	jr nz, .asm_f4398
	ld a, [wddbb + 2]
	cp $1
	jr z, .asm_f4398
	ld a, [wMusicE9 + 2]
	ld [rNR32], a
.asm_f4398
	ld a, [wddbb + 2]
	dec a
	ld [wddbb + 2], a
	jr nz, .asm_f43b8
	ld a, [wMusicChannelPointers + 5]
	ld h, a
	ld a, [wMusicChannelPointers + 4]
	ld l, a
	ld bc, $0002
	call MusicPlayNextNote
	ld a, [wMusicIsPlaying + 2]
	or a
	jr z, .asm_f43be
	call Func_f479c
.asm_f43b8
	ld a, $2
	call Func_f485a
	ret
.asm_f43be
	ld a, [wdd8c]
	bit 2, a
	jr nz, .asm_f43cd
	ld a, $0
	ld [rNR32], a
	ld a, $80
	ld [rNR34], a
.asm_f43cd
	ret
	
;****************************************************************************************
;	MusicUpdateChannel4 -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************

MusicUpdateChannel4: ; f43ce (3d:43ce)
	ld a, [wMusicIsPlaying + 3]
	or a
	jr z, .asm_f4400
	ld a, [wddbb + 3]
	dec a
	ld [wddbb + 3], a
	jr nz, .asm_f43f6
	ld a, [wMusicChannelPointers + 7]
	ld h, a
	ld a, [wMusicChannelPointers + 6]
	ld l, a
	ld bc, $0003
	call MusicPlayNextNote
	ld a, [wMusicIsPlaying + 3]
	or a
	jr z, .asm_f4400
	call Func_f480a
	jr .asm_f4413
.asm_f43f6
	ld a, [wddef]
	or a
	jr z, .asm_f4413
	call Func_f4839
	ret
.asm_f4400
	ld a, [wdd8c]
	bit 3, a
	jr nz, .asm_f4413
	xor a
	ld [wddef], a
	ld a, $8
	ld [rNR42], a
	swap a
	ld [rNR44], a
.asm_f4413
	ret

;****************************************************************************************
;	MusicPlayNextNote -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicPlayNextNote:
	ld a, [hli]
	push hl
	push af
	cp $d0
	jr c, Musicnote
	sub $d0
	add a
	ld e, a
	ld d, $0
	ld hl, MusicCommandTable
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	pop af
	jp [hl]

MusicCommandTable: ; f442c (3d:442c)
	dw Musicspeed
	dw Musicoctave
	dw Musicoctave
	dw Musicoctave
	dw Musicoctave
	dw Musicoctave
	dw Musicoctave
	dw Musicinc_octave
	dw Musicdec_octave
	dw Musictie
	dw Musicend
	dw Musicend
	dw Musicmusicdc
	dw MusicMainLoop
	dw MusicEndMainLoop
	dw MusicLoop
	dw MusicEndLoop
	dw Musicjp
	dw Musiccall
	dw Musicret
	dw Musicmusice4
	dw Musicduty
	dw Musicvolume
	dw Musicwave
	dw Musicmusice8
	dw Musicmusice9
	dw Musicvibrato_type
	dw Musicvibrato_delay
	dw Musicmusicec
	dw Musicmusiced
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend
	dw Musicend

;****************************************************************************************
;	Musicnote -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Musicnote: ; f448c (3d:448c)
	push af
	ld a, [hl]
	ld e, a
	ld hl, wMusicTie
	add hl, bc
	ld a, [hl]
	cp $80
	jr z, .asm_f44b0
	ld [hl], $1
	xor a
	ld hl, wdddb
	add hl, bc
	ld [hl], a
	ld hl, wdde3
	add hl, bc
	ld [hl], a
	inc [hl]
	ld hl, wMusicVibratoType2
	add hl, bc
	ld a, [hl]
	ld hl, wMusicVibratoType
	add hl, bc
	ld [hl], a
.asm_f44b0
	pop af
	push de
	ld hl, wMusicSpeed
	add hl, bc
	ld d, [hl]
	and $f
	inc a
	cp d
	jr nc, .asm_f44c0
	ld e, a
	ld a, d
	ld d, e
.asm_f44c0
	ld e, a
.asm_f44c1
	dec d
	jr z, .asm_f44c7
	add e
	jr .asm_f44c1
.asm_f44c7
	ld hl, $ddbb
	add hl, bc
	ld [hl], a
	pop de
	ld d, a
	ld a, e
	cp $d9
	ld a, d
	jr z, .asm_f44fb
	ld e, a
	ld hl, wMusicE8
	add hl, bc
	ld a, [hl]
	cp $8
	ld d, a
	ld a, e
	jr z, .asm_f44fb
	push hl
	push bc
	ld b, $0
	ld c, a
	ld hl, $0000
.asm_f44e8
	add hl, bc
	dec d
	jr nz, .asm_f44e8
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	pop bc
	pop hl
.asm_f44fb
	ld hl, wddc3
	add hl, bc
	ld [hl], a
	pop af
	and $f0
	ld hl, wddb7
	add hl, bc
	ld [hl], a
	or a
	jr nz, .asm_f450e
	jp .asm_f458e
.asm_f450e
	swap a
	dec a
	ld h, a
	ld a, $3
	cp c
	ld a, h
	jr z, .asm_f451a
	jr .asm_f4564
.asm_f451a
	push af
	ld hl, wMusicOctave
	add hl, bc
	ld a, [hl]
	ld d, a
	sla a
	add d
	sla a
	sla a
	sla a
	ld e, a
	pop af
	ld hl, MusicNoiseInstruments
	add a
	ld d, c
	ld c, a
	add hl, bc
	ld c, e
	add hl, bc
	ld c, d
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld d, a
	ld a, [wMusicDC]
	and $77
	or d
	ld [wMusicDC], a
	ld de, wddab
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld b, [hl]
	inc hl
	ld a, [hli]
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	ld b, $0
	ld a, l
	ld d, h
	ld hl, wdded
	ld [hli], a
	ld [hl], d
	ld a, $1
	ld [wddef], a
	jr .asm_f458e
.asm_f4564
	ld hl, wMusicCh1CurPitch
	add hl, bc
	add hl, bc
	push hl
	ld hl, wMusicOctave
	add hl, bc
	ld e, [hl]
	ld d, $0
	ld hl, Unknown_f4c28
	add hl, de
	add a
	ld e, [hl]
	add e
	ld hl, wMusicEC
	add hl, bc
	ld e, [hl]
	add e
	add e
	ld e, a
	ld hl, Unknown_f4c30
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl]
	call Func_f4967
	pop hl
	ld a, e
	ld [hli], a
	ld [hl], d
.asm_f458e
	pop de
	ld hl, wMusicChannelPointers
	add hl, bc
	add hl, bc
	ld [hl], e
	inc hl
	ld [hl], d
	ret

;****************************************************************************************
;	Musicspeed -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Musicspeed: ; f4598 (3d:4598)
	pop hl
	ld a, [hli]
	push hl
	ld hl, wMusicSpeed
	add hl, bc
	ld [hl], a
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	Musicoctave -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Musicoctave: ; f45a3 (3d:45a3)
	and $7
	dec a
	ld hl, wMusicOctave
	add hl, bc
	push af
	ld a, c
	cp $2
	jr nz, .asm_f45b6
	pop af
	inc a
	ld [hl], a
	jp MusicPlayNextNote_pop
.asm_f45b6
	pop af
	ld [hl], a
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	Musicinc_octave -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicinc_octave: ; f45bb (3d:45bb)
	ld hl, wMusicOctave
	add hl, bc
	inc [hl]
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	Musicdec_octave -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicdec_octave: ; f45c3 (3d:45c3)
	ld hl, wMusicOctave
	add hl, bc
	dec [hl]
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	Musictie -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musictie: ; f45cb (3d:45cb)
	ld hl, wMusicTie
	add hl, bc
	ld [hl], $80
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	Musicmusicdc -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicmusicdc: ; f45d4 (3d:45d4)
	pop hl
	ld a, [hli]
	push hl
	push bc
	inc c
	ld e, $ee
.asm_f45db
	dec c
	jr z, .asm_f45e3
	rlca
	rlc e
	jr .asm_f45db
.asm_f45e3
	ld d, a
	ld hl, wMusicDC
	ld a, [hl]
	and e
	or d
	ld [hl], a
	pop bc
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	MusicMainLoop -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
MusicMainLoop: ; f45ef (3d:45ef)
	pop de
	push de
	dec de
	ld hl, wMusicMainLoopStart
	add hl, bc
	add hl, bc
	ld [hl], e
	inc hl
	ld [hl], d
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	MusicEndMainLoop -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
MusicEndMainLoop: ; f45fd (3d:45fd)
	pop hl
	ld hl, wMusicMainLoopStart
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp MusicPlayNextNote

;****************************************************************************************
;	MusicLoop -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
MusicLoop: ; f4609 (3d:4609)
	pop de
	ld a, [de] ; get loop count
	inc de
	push af
	call MusicGetChannelStackPointer
	ld [hl], e ; 
	inc hl     ; store address of command at beginning of loop
	ld [hl], d ; 
	inc hl
	pop af
	ld [hl], a ; store loop count
	inc hl
	push de
	call MusicSetChannelStackPointer
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	MusicEndLoop -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
MusicEndLoop: ; f461e (3d:461e)
	call MusicGetChannelStackPointer
	dec hl
	ld a, [hl] ; get remaining loop count
	dec a
	jr z, .loopDone
	ld [hld], a
	ld d, [hl]
	dec hl
	ld e, [hl]
	pop hl
	ld h, d ; 
	ld l, e ; go to address of beginning of loop
	jp MusicPlayNextNote
.loopDone
	dec hl
	dec hl
	call MusicSetChannelStackPointer
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	Musicjp -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicjp: ; f4638 (3d:4638)
	pop hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp MusicPlayNextNote

;****************************************************************************************
;	MusicCall -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musiccall: ; f463f (3d:463f)
	call MusicGetChannelStackPointer
	pop de
	ld a, e
	ld [hli], a ; 
	ld a, d     ; store address of command after call
	ld [hli], a ; 
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld d, a
	ld e, b
	ld b, $0
	push de
	call MusicSetChannelStackPointer
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	Musicret -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicret: ; f4656 (3d:4656)
	pop de
	call MusicGetChannelStackPointer
	dec hl
	ld a, [hld] ; 
	ld e, [hl]  ; retrieve address of caller of this sub branch
	ld d, a
	inc de
	inc de
	push de
	call MusicSetChannelStackPointer
	jp MusicPlayNextNote_pop

;****************************************************************************************
;	Musicmusice4 -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicmusice4:
	pop de
	ld a, [de]
	inc de
	ld hl, wMusicE4
	add hl, bc
	ld [hl], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote

;****************************************************************************************
;	Musicduty -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicduty:
	pop de
	ld a, [de]
	and $c0
	inc de
	ld hl, wMusicDuty1
	add hl, bc
	ld [hl], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote

;****************************************************************************************
;	Musicvolume -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicvolume:
	pop de
	ld a, [de]
	inc de
	ld hl, wMusicVolume
	add hl, bc
	ld [hl], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote

;****************************************************************************************
;	Musicwave -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicwave:
	pop de
	ld a, [de]
	inc de
	ld [wMusicWave], a
	ld a, $1
	ld [wMusicWaveChange], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote

;****************************************************************************************
;	Musicmusice8 -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicmusice8: ; f46a0 (3d:46a0)
	pop de
	ld a, [de]
	inc de
	ld hl, wMusicE8
	add hl, bc
	ld [hl], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote
	
;****************************************************************************************
;	Musicmusice9 -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	

Musicmusice9: ; f46ad (3d:46ad)
	pop de
	ld a, [de]
	inc de
	ld hl, wMusicE9
	add hl, bc
	ld [hl], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote

;****************************************************************************************
;	Musicvibratotype -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicvibrato_type: ; f46ba (3d:46ba)
	pop de
	ld a, [de]
	inc de
	ld hl, wMusicVibratoType
	add hl, bc
	ld [hl], a
	ld hl, wMusicVibratoType2
	add hl, bc
	ld [hl], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote

;****************************************************************************************
;	Musicvibrato_delay -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicvibrato_delay: ; f46cc (3d:46cc)
	pop de
	ld a, [de]
	inc de
	ld hl, wMusicVibratoDelay
	add hl, bc
	ld [hl], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote

;****************************************************************************************
;	Musicmusicec -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicmusicec:
	pop de
	ld a, [de]
	inc de
	ld hl, wMusicEC
	add hl, bc
	ld [hl], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote

;****************************************************************************************
;	Musicmusiced -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************		
	
Musicmusiced:
	pop de
	ld a, [de]
	inc de
	ld hl, wMusicEC
	add hl, bc
	add [hl]
	ld [hl], a
	ld h, d
	ld l, e
	jp MusicPlayNextNote

;****************************************************************************************
;	MusicEnd -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Musicend: ; f46f4 (3d:46f4)
	ld hl, wMusicIsPlaying
	add hl, bc
	ld [hl], $0
	pop hl
	ret

;****************************************************************************************
;	MusicGetChannelStackPointer - returns the address of the top of 
;								  the stack for the current channel;
;								  used for loops and calls
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	

MusicGetChannelStackPointer:
	ld hl, wMusicChannelStackPointers
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

;****************************************************************************************
;	MusicSetChannelStackPointer -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicSetChannelStackPointer:
	ld d, h
	ld e, l
	ld hl, wMusicChannelStackPointers
	add hl, bc
	add hl, bc
	ld [hl], e
	inc hl
	ld [hl], d
	ret

;****************************************************************************************
;	MusicPlayNextNote_pop -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicPlayNextNote_pop ; f4710 (3d:4710)
	pop hl
	jp MusicPlayNextNote

;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Func_f4714: ; f4714 (3d:4714)
	ld a, [wdd8c]
	bit 0, a
	jr nz, .asm_f4749
	ld a, [wddb7]
	cp $0
	jr z, .asm_f474a
	ld d, $0
	ld hl, wMusicTie
	ld a, [hl]
	cp $80
	jr z, .asm_f4733
	ld a, [wMusicVolume]
	ld [rNR12], a
	ld d, $80
.asm_f4733
	ld [hl], $2
	ld a, $8
	ld [rNR10], a
	ld a, [wMusicDuty1]
	ld [rNR11], a
	ld a, [wMusicCh1CurPitch]
	ld [rNR13], a
	ld a, [wMusicCh1CurOctave]
	or d
	ld [rNR14], a
.asm_f4749
	ret
.asm_f474a
	ld hl, wMusicTie
	ld [hl], $0
	ld hl, rNR12
	ld a, $8
	ld [hli], a
	inc hl
	swap a
	ld [hl], a
	ret

;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Func_f475a: ; f475a (3d:475a)
	ld a, [wdd8c]
	bit 1, a
	jr nz, .asm_f478b
	ld a, [wddb8]
	cp $0
	jr z, .asm_f478c
	ld d, $0
	ld hl, wMusicTie + 1
	ld a, [hl]
	cp $80
	jr z, .asm_f4779
	ld a, [wMusicVolume + 1]
	ld [rNR22], a
	ld d, $80
.asm_f4779
	ld [hl], $2
	ld a, [wMusicDuty2]
	ld [rNR21], a
	ld a, [wMusicCh2CurPitch]
	ld [rNR23], a
	ld a, [wMusicCh2CurOctave]
	or d
	ld [rNR24], a
.asm_f478b
	ret
.asm_f478c
	ld hl, wMusicTie + 1
	ld [hl], $0
	ld hl, rNR22
	ld a, $8
	ld [hli], a
	inc hl
	swap a
	ld [hl], a
	ret

;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Func_f479c: ; f479c (3d:479c)
	ld a, [wdd8c]
	bit 2, a
	jr nz, .asm_f47e0
	ld d, $0
	ld a, [wMusicWaveChange]
	or a
	jr z, .noWaveChange
	xor a
	ld [rNR30], a
	call MusicLoadWaveInstrument
	ld d, $80
.noWaveChange
	ld a, [wddb9]
	cp $0
	jr z, .asm_f47e1
	ld hl, wMusicTie + 2
	ld a, [hl]
	cp $80
	jr z, .asm_f47cc
	ld a, [wMusicVolume + 2]
	ld [rNR32], a
	xor a
	ld [rNR30], a
	ld d, $80
.asm_f47cc
	ld [hl], $2
	xor a
	ld [rNR31], a
	ld a, [wMusicCh3CurPitch]
	ld [rNR33], a
	ld a, $80
	ld [rNR30], a
	ld a, [wMusicCh3CurOctave]
	or d
	ld [rNR34], a
.asm_f47e0
	ret
.asm_f47e1
	ld hl, wMusicTie
	ld [hl], $0
	xor a
	ld [rNR30], a
	ret

;****************************************************************************************
;	MusicLoadWaveInstruments -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicLoadWaveInstrument: ; f479c (3d:47ea)
	ld a, [wMusicWave]
	add a
	ld d, $0
	ld e, a
	ld hl, MusicWaveInstruments
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, d
	ld de, $ff30
.copyWaveLoop
	ld a, [hli]
	ld [de], a
	inc de
	inc b
	ld a, b
	cp $10
	jr nz, .copyWaveLoop
	xor a
	ld [wMusicWaveChange], a
	ret

;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Func_f480a: ; f480a (3d:480a)
	ld a, [wdd8c]
	bit 3, a
	jr nz, .asm_f4829
	ld a, [wddba]
	cp $0
	jr z, asm_f482a
	ld de, rNR41
	ld hl, wddab
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
.asm_f4829
	ret
asm_f482a
	xor a
	ld [wddef], a
	ld hl, rNR42
	ld a, $8
	ld [hli], a
	inc hl
	swap a
	ld [hl], a
	ret

;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Func_f4839: ; f4839 (3d:4839)
	ld a, [wdd8c]
	bit 3, a
	jr z, .asm_f4846
	xor a
	ld [wddef], a
	jr .asm_f4859
.asm_f4846
	ld hl, wdded
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, [de]
	cp $ff
	jr nz, .asm_f4853
	jr asm_f482a
.asm_f4853
	ld [rNR43], a
	inc de
	ld a, d
	ld [hld], a
	ld [hl], e
.asm_f4859
	ret

;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Func_f485a: ; f485a (3d:485a)
	push af
	ld b, $0
	ld c, a
	call MusicUpdateVibrato
	pop af
	call Func_f490b
	ret

;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Func_f4866: ; f4866 (3d:4866)
	ld a, [wMusicPanning]
	ld [rNR50], a
	ld a, [wdd8c]
	or a
	ld hl, wMusicDC
	ld a, [hli]
	jr z, .asm_f4888
	ld a, [wdd8c]
	and $f
	ld d, a
	swap d
	or d
	ld d, a
	xor $ff
	ld e, a
	ld a, [hld]
	and d
	ld d, a
	ld a, [hl]
	and e
	or d
.asm_f4888
	ld d, a
	ld a, [wddf0]
	xor $ff
	and $f
	ld e, a
	swap e
	or e
	and d
	ld [rNR51], a
	ret

;****************************************************************************************
;	MusicUpdateVibrato -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicUpdateVibrato: ; f4898 (3d:4898)
	ld hl, wMusicVibratoDelay
	add hl, bc
	ld a, [hl]
	cp $0
	jr z, .asm_f4902
	ld hl, wdde3
	add hl, bc
	cp [hl]
	jr z, .asm_f48ab
	inc [hl]
	jr .asm_f4902
.asm_f48ab
	ld hl, wMusicVibratoType
	add hl, bc
	ld e, [hl]
	ld d, $0
	ld hl, MusicVibratoTypes
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld hl, wdddb
	add hl, bc
	ld d, $0
	ld e, [hl]
	inc [hl]
	pop hl
	add hl, de
	ld a, [hli]
	cp $80
	jr z, .asm_f48ee
	ld hl, wMusicCh1CurPitch
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	bit 7, a
	jr nz, .asm_f48df
	add e
	ld e, a
	ld a, $0
	adc d
	and $7
	ld d, a
	ret
.asm_f48df
	xor $ff
	inc a
	push bc
	ld c, a
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	and $7
	ld d, a
	pop bc
	ret
.asm_f48ee
	push hl
	ld hl, wdddb
	add hl, bc
	ld [hl], $0
	pop hl
	ld a, [hl]
	cp $80
	jr z, .asm_f48ab
	ld hl, wMusicVibratoType
	add hl, bc
	ld [hl], a
	jr .asm_f48ab
.asm_f4902
	ld hl, wMusicCh1CurPitch
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	ret

;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Func_f490b: ; f490b (3d:490b)
	cp $0
	jr nz, .notChannel1
	ld a, [wMusicVibratoDelay]
	cp $0
	jr z, .done
	ld a, [wdd8c]
	bit 0, a
	jr nz, .done
	ld a, e
	ld [rNR13], a
	ld a, [rNR11]
	and $c0
	ld [rNR11], a
	ld a, d
	and $3f
	ld [rNR14], a
	ret
.notChannel1
	cp $1
	jr nz, .notChannel2
	ld a, [wMusicVibratoDelay + 1]
	cp $0
	jr z, .done
	ld a, [wdd8c]
	bit 1, a
	jr nz, .done
	ld a, e
	ld [rNR23], a
	ld a, [rNR21]
	and $c0
	ld [rNR21], a
	ld a, d
	ld [rNR24], a
	ret
.notChannel2
	cp $2
	jr nz, .done
	ld a, [wMusicVibratoDelay + 2]
	cp $0
	jr z, .done
	ld a, [wdd8c]
	bit 2, a
	jr nz, .done
	ld a, e
	ld [rNR33], a
	xor a
	ld [rNR31], a
	ld a, d
	ld [rNR34], a
.done
	ret

;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
Func_f4967: ; f4967 (3d:4967)
	ld hl, wMusicE4
	add hl, bc
	ld a, [hl]
	bit 7, a
	jr nz, .asm_f4976
	add e
	ld e, a
	ld a, d
	adc b
	ld d, a
	ret
.asm_f4976
	xor $ff
	ld h, a
	ld a, e
	sub h
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ret
	
;****************************************************************************************
;	Func -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************

Func_f4980: ; f4980 (3d:4980)
	ld a, [wdd8c]
	ld d, a
	bit 0, d
	jr nz, .asm_f4990
	ld a, $8
	ld [rNR12], a
	swap a
	ld [rNR14], a
.asm_f4990
	bit 1, d
	jr nz, .asm_f499c
	swap a
	ld [rNR22], a
	swap a
	ld [rNR24], a
.asm_f499c
	bit 3, d
	jr nz, .asm_f49a8
	swap a
	ld [rNR42], a
	swap a
	ld [rNR44], a
.asm_f49a8
	bit 2, d
	jr nz, .asm_f49b0
	ld a, $0
	ld [rNR32], a
.asm_f49b0
	ret
	
;****************************************************************************************
;	MusicCheckForEndOfSong -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************

MusicCheckForEndOfSong: ; f49b1 (3d:49b1)
	ld hl, wMusicIsPlaying
	xor a
	add [hl]
	inc hl
	add [hl]
	inc hl
	add [hl]
	inc hl
	add [hl]
	or a
	ret nz
	ld a, $80
	ld [wCurSongID], a
	ret
	
;****************************************************************************************
;	MusicPauseSong -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************

MusicPauseSong: ; f49c4 (3d:49c4)
	di
	call Func_f4980
	call MusicBackupSong
	call MusicStopAllChannels
	ei
	ret

;****************************************************************************************
;	MusicResumeSong -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicResumeSong: ; f49d0 (3d:49d0)
	di
	call Func_f4980
	call MusicStopAllChannels
	call MusicLoadBackup
	ei
	ret

;****************************************************************************************
;	MusicBackupSong -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************	
	
MusicBackupSong: ; f49dc (3d:49dc)
	ld a, [wCurSongID]
	ld [wCurSongIDBackup], a
	ld a, [wCurSongBank]
	ld [wCurSongBankBackup], a
	ld a, [wMusicDC]
	ld [wMusicDCBackup], a
	ld hl, wMusicDuty1
	ld de, wMusicDuty1Backup
	ld a, $4
	call MusicCopyData
	ld a, [wMusicWave]
	ld [wMusicWaveBackup], a
	ld a, [wMusicWaveChange]
	ld [wMusicWaveChangeBackup], a
	ld hl, wMusicIsPlaying
	ld de, wMusicIsPlayingBackup
	ld a, $4
	call MusicCopyData
	ld hl, wMusicTie
	ld de, wMusicTieBackup
	ld a, $4
	call MusicCopyData
	ld hl, wMusicChannelPointers
	ld de, wMusicChannelPointersBackup
	ld a, $8
	call MusicCopyData
	ld hl, wMusicMainLoopStart
	ld de, wMusicMainLoopStartBackup
	ld a, $8
	call MusicCopyData
	ld a, [wddab]
	ld [wde76], a
	ld a, [wddac]
	ld [wde77], a
	ld hl, wMusicOctave
	ld de, wMusicOctaveBackup
	ld a, $4
	call MusicCopyData
	ld hl, wddb3
	ld de, wde7c
	ld a, $4
	call MusicCopyData
	ld hl, wddb7
	ld de, wde80
	ld a, $4
	call MusicCopyData
	ld hl, wddbb
	ld de, wde84
	ld a, $4
	call MusicCopyData
	ld hl, wMusicE8
	ld de, wMusicE8Backup
	ld a, $4
	call MusicCopyData
	ld hl, wddc3
	ld de, wde8c
	ld a, $4
	call MusicCopyData
	ld hl, wMusicE9
	ld de, wMusicE9Backup
	ld a, $4
	call MusicCopyData
	ld hl, wMusicEC
	ld de, wMusicECBackup
	ld a, $4
	call MusicCopyData
	ld hl, wMusicSpeed
	ld de, wMusicSpeedBackup
	ld a, $4
	call MusicCopyData
	ld hl, wMusicVibratoType2
	ld de, wMusicVibratoType2Backup
	ld a, $4
	call MusicCopyData
	ld hl, wMusicVibratoDelay
	ld de, wMusicVibratoDelayBackup
	ld a, $4
	call MusicCopyData
	ld a, $0
	ld [wdddb], a
	ld [wdddb + 1], a
	ld [wdddb + 2], a
	ld [wdddb + 3], a
	ld hl, wMusicVolume
	ld de, wMusicVolumeBackup
	ld a, $3
	call MusicCopyData
	ld hl, wMusicE4
	ld de, wMusicE4Backup
	ld a, $3
	call MusicCopyData
	ld hl, wdded
	ld de, wdeaa
	ld a, $2
	call MusicCopyData
	ld a, $0
	ld [wdeac], a
	ld hl, wMusicChannelStackPointers
	ld de, wMusicChannelStackPointersBackup
	ld a, $8
	call MusicCopyData
	ld hl, wMusicCh1Stack
	ld de, wMusicCh1StackBackup
	ld a, $c * 4
	call MusicCopyData
	ret
	
;****************************************************************************************
;	MusicLoadBackup -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************

MusicLoadBackup:
	ld a, [wCurSongIDBackup]
	ld [wCurSongID], a
	ld a, [wCurSongBankBackup]
	ld [wCurSongBank], a
	ld a, [wMusicDCBackup]
	ld [wMusicDC], a
	ld hl, wMusicDuty1Backup
	ld de, wMusicDuty1
	ld a, $4
	call MusicCopyData
	ld a, [wMusicWaveBackup]
	ld [wMusicWave], a
	ld a, $1
	ld [wMusicWaveChange], a
	ld hl, wMusicIsPlayingBackup
	ld de, wMusicIsPlaying
	ld a, $4
	call MusicCopyData
	ld hl, wMusicTieBackup
	ld de, wMusicTie
	ld a, $4
	call MusicCopyData
	ld hl, wMusicChannelPointersBackup
	ld de, wMusicChannelPointers
	ld a, $8
	call MusicCopyData
	ld hl, wMusicMainLoopStartBackup
	ld de, wMusicMainLoopStart
	ld a, $8
	call MusicCopyData
	ld a, [wde76]
	ld [wddab], a
	ld a, [wde77]
	ld [wddac], a
	ld hl, wMusicOctaveBackup
	ld de, wMusicOctave
	ld a, $4
	call MusicCopyData
	ld hl, wde7c
	ld de, wddb3
	ld a, $4
	call MusicCopyData
	ld hl, wde80
	ld de, wddb7
	ld a, $4
	call MusicCopyData
	ld hl, wde84
	ld de, wddbb
	ld a, $4
	call MusicCopyData
	ld hl, wMusicE8Backup
	ld de, wMusicE8
	ld a, $4
	call MusicCopyData
	ld hl, wde8c
	ld de, wddc3
	ld a, $4
	call MusicCopyData
	ld hl, wMusicE9Backup
	ld de, wMusicE9
	ld a, $4
	call MusicCopyData
	ld hl, wMusicECBackup
	ld de, wMusicEC
	ld a, $4
	call MusicCopyData
	ld hl, wMusicSpeedBackup
	ld de, wMusicSpeed
	ld a, $4
	call MusicCopyData
	ld hl, wMusicVibratoType2Backup
	ld de, wMusicVibratoType2
	ld a, $4
	call MusicCopyData
	ld hl, wMusicVibratoDelayBackup
	ld de, wMusicVibratoDelay
	ld a, $4
	call MusicCopyData
	ld hl, wMusicVolumeBackup
	ld de, wMusicVolume
	ld a, $3
	call MusicCopyData
	ld hl, wMusicE4Backup
	ld de, wMusicE4
	ld a, $3
	call MusicCopyData
	ld hl, wdeaa
	ld de, wdded
	ld a, $2
	call MusicCopyData
	ld a, [wdeac]
	ld [wddef], a
	ld hl, wMusicChannelStackPointersBackup
	ld de, wMusicChannelStackPointers
	ld a, $8
	call MusicCopyData
	ld hl, wMusicCh1StackBackup
	ld de, wMusicCh1Stack
	ld a, $c * 4
	call MusicCopyData
	ret

;****************************************************************************************
;	MusicCopyData -
;
;	Input:	none
;	Output:	none
;
;****************************************************************************************

MusicCopyData:
	ld c, a
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loop
	ret

MusicChannelLoopStacks:
	dw wMusicCh1Stack
	dw wMusicCh2Stack
	dw wMusicCh3Stack
	dw wMusicCh4Stack