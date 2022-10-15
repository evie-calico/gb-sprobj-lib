# gb-sprobj-lib
This is a small, lightweight library meant to facilitate the rendering of sprite objects, including Shadow OAM and OAM DMA, single-entry "simple" sprite objects, and Q12.4 fixed-point position metasprite rendering.

# Usage
The library is relatively simple to get set up. First, put the following in your initialization code:
```
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
```

Then put a call to `ResetShadowOAM` at the beginning of your main loop.

Finally, run the following code during VBlank:

```
ld a, HIGH(wShadowOAM)
call hOAMDMA
```

Now you can render sprites :)
