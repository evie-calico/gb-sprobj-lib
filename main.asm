; Sprite Objects Library example.
INCLUDE "hardware.inc"

SECTION "VBlank Vector", ROM0[$40]
  push af
  push bc
  push de
  push hl
  jp VBlankHandler

SECTION "Entry", ROM0[$100]
  jp Init
  ds $150 - @

SECTION "Main", ROM0
Init:
  ; Wait for VBlank
  ld a, [rLY]
  cp a, 144
  jr c, Init
  
  ; Disable screen
  xor a, a
  ld [rLCDC], a
  
  ; Set palettes
  ld a, %11100100
  ldh [rBGP], a
  ldh [rOBP0], a
  ldh [rOBP1], a
  
  ; Initilize Sprite Object Library.
  call InitSprObjLib
  
  ; Reset hardware OAM
  xor a, a
  ld b, 160
  ld hl, _OAMRAM
.resetOAM
  ld [hli], a
  dec b
  jr nz, .resetOAM
  
  ; Copy Graphics
  ld bc, GfxCat.end - GfxCat
  ld de, GfxCat
  ld hl, $8000
  call MemCopy
  
  ; Reset Positions
  ld c, 4
  ld hl, wSimplePosition
  xor a, a
: ld [hli], a
  dec c
  jr nz, :-
  
  ; Enable VBlank interrupt
  ld a, IEF_VBLANK
  ldh [rIE], a
  
  ; Clear pending interrupts
  xor a, a
  ldh [rIF], a
  
  ; Enable screen
  ld a, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ8 | LCDCF_ON
  ldh [rLCDC], a
  ei
Main:
  call ResetShadowOAM
  
  ld de, $0000
  ld a, [wSimplePosition]
  ld c, a
  ld b, 0
  call RenderSimpleSprite
  sla c
  ld b, 16
  call RenderSimpleSprite
  sla c
  ld b, 32
  call RenderSimpleSprite
  sla c
  ld b, 48
  call RenderSimpleSprite
  ld bc, (96.0 >> 12) & $FFFF
  ld a, [wMetaspritePosition]
  ld e, a
  ld a, [wMetaspritePosition + 1]
  ld d, a
  ld hl, CatMetasprite
  call RenderMetasprite
  
  ld hl, wSimplePosition
  inc [hl]
  
  ld hl, wMetaspriteVelocity
  inc [hl]
  ld a, (2.0 >> 12) & $FF
  cp a, [hl]
  jr nz, .skip
  ld [hl], 0
.skip
  ld a, [wMetaspritePosition]
  add a, [hl]
  ld [wMetaspritePosition], a
  ld a, [wMetaspritePosition + 1]
  adc a, 0
  ld [wMetaspritePosition + 1], a
  
  halt
  jr Main

MemCopy::
  dec bc
  inc b
  inc c
.loop:
  ld a, [de]
  ld [hli], a
  inc de
  dec c
  jr nz, .loop
  dec b
  jr nz, .loop
  ret

SECTION "VBlank Handler", ROM0
VBlankHandler:
  ; Push sprites to OAM
  ld a, HIGH(wShadowOAM)
  call hOAMDMA
  
  pop hl
  pop de
  pop bc
  pop af
  reti

SECTION "Graphics", ROM0
GfxCat:
  INCBIN "cat.2bpp"
.end::

CatMetasprite:
  db 16, 8, 0, 0
  db 12, 16, 0, 0
  db 20, 20, 0, 0
  db 24, 12, 0, 0
  db 128

SECTION "Position Vars", WRAM0
; 8-bit X position
wSimplePosition:
  ds 1

; Q12.4 fixed-point X posiition
wMetaspritePosition:
  dw

; Q4.4 fixed-point velocity
wMetaspriteVelocity::
  db
