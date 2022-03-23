;****************************************************************************************
;	File: header.asm (Game Boy LR35902)
;	Description:
;	Author: biggs
;	Date:
;****************************************************************************************

; $0104-$0133 (Nintendo logo - do _not_ modify the logo data here or the GB will not run the program)
DB	$CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
DB	$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
DB	$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

; $0134-$013E (Game title - up to 11 upper case ASCII characters; pad with $00)
DB	"UNTITLEDRPG"
	;0123456789A

; $013F-$0142 (Product code - 4 ASCII characters, assigned by Nintendo, just leave blank)
DB	"    "
	;0123

; $0143 (Color GameBoy compatibility code)
DB	$00	; $00 - DMG 
		; $80 - DMG/GBC
		; $C0 - GBC Only cartridge

; $0144 (High-nibble of license code - normally $00 if $014B != $33)
DB	$00

; $0145 (Low-nibble of license code - normally $00 if $014B != $33)
DB	$00

; $0146 (GameBoy/Super GameBoy indicator)
DB	$00	; $00 - GameBoy

; $0147 (Cartridge type - all Color GameBoy cartridges are at least $19)
DB	$01	; $03 - ROM+MBC1+RAM+BATT

; $0148 (ROM size)
DB	$00	; $00 - 256Kbit = 32Kbyte = 2 banks

; $0149 (RAM size)
DB	$00	; $00 - None

; $014A (Destination code)
DB	$00	; $01 - All others
		; $00 - Japan

; $014B (Licensee code - this _must_ be $33)
DB	$33	; $33 - Check $0144/$0145 for Licensee code.

; $014C (Mask ROM version - handled by RGBFIX)
DB	$00

; $014D (Complement check - handled by RGBFIX)
DB	$00

; $014E-$014F (Cartridge checksum - handled by RGBFIX)
DW	$00