DisplayTrainerParty:
	
	ld hl,wd730
	set 6,[hl] ; no pauses between printing each letter
	ld a,$01
	;ld [H_AUTOBGTRANSFERENABLED],a ; enable continuous WRAM to VRAM transfer each V-blank
	call SaveScreenTilesToBuffer1
 	coord hl, 8, 0
 	ld b, 11
 	ld c, 10
 	call TextBoxBorder
	coord hl, 1, 1
	ld de, .titlestringone
	call PlaceString
	coord hl, 2, 2
	ld de, .titlestringtwo
	call PlaceString
	coord hl, 9, 1
.LoopTrainerData
	ld de, wEnemyMon1
	ld a, [de]
	and a
	jp z, .waitForInput
	ld [wd11e], a
	; write species somewhere (XXX why?)
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	call GetMonName
	call PlaceString
	ld bc, SCREEN_WIDTH + 5; 1 row down and 3 to the right
	add hl, bc
	push de
	ld de, .lvstring
	call PlaceString
	ld bc, 3
	add hl, bc
	pop de
	ld a, [wEnemyMon1Level]
	ld [de], a
	lb bc, 1, 2
	call PrintNumber
	coord hl, 9, 3
	ld a, [wEnemyMon2]
	and a
	jp z, .waitForInput
	ld [wd11e], a
	; write species somewhere (XXX why?)
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	call GetMonName
	call PlaceString
	ld bc, SCREEN_WIDTH + 5; 1 row down and 3 to the right
	add hl, bc
	push de
	ld de, .lvstring
	call PlaceString
	ld bc, 3
	add hl, bc
	pop de
	ld a, [wEnemyMon2Level]
	ld [de], a
	lb bc, 1, 2
	call PrintNumber
	ld bc, SCREEN_WIDTH ; 1 row down and take the 3 back off
	add hl, bc
	coord hl, 9, 5
	ld de, wEnemyMon3
	ld a, [de]
	and a
	jp z, .waitForInput
	ld [wd11e], a
	; write species somewhere (XXX why?)
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	call GetMonName
	call PlaceString
	ld bc, SCREEN_WIDTH + 5; 1 row down and 3 to the right
	add hl, bc
	push de
	ld de, .lvstring
	call PlaceString
	ld bc, 3
	add hl, bc
	pop de
	ld a, [wEnemyMon2Level]
	ld [de], a
	lb bc, 1, 2
	call PrintNumber
	coord hl, 9, 7
	ld a, [wEnemyMon4]
	and a
	jp z, .waitForInput
	ld [wd11e], a
	; write species somewhere (XXX why?)
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	call GetMonName
	call PlaceString
	ld bc, SCREEN_WIDTH + 5; 1 row down and 3 to the right
	add hl, bc
	push de
	ld de, .lvstring
	call PlaceString
	ld bc, 3
	add hl, bc
	pop de
	ld a, [wEnemyMon2Level]
	ld [de], a
	lb bc, 1, 2
	call PrintNumber
	ld bc, SCREEN_WIDTH ; 1 row down and take the 3 back off
	add hl, bc
	coord hl, 9, 9
	ld de, wEnemyMon5
	ld a, [de]
	and a
	jp z, .waitForInput
	ld [wd11e], a
	; write species somewhere (XXX why?)
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	call GetMonName
	ld bc, SCREEN_WIDTH + 5; 1 row down and 3 to the right
	add hl, bc
	push de
	ld de, .lvstring
	call PlaceString
	ld bc, 3
	add hl, bc
	pop de
	ld a, [wEnemyMon2Level]
	ld [de], a
	lb bc, 1, 2
	call PrintNumber
	coord hl, 9, 11
	ld a, [wEnemyMon6]
	and a
	jp z, .waitForInput
	ld [wd11e], a
	; write species somewhere (XXX why?)
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	call GetMonName
	call PlaceString
	ld bc, SCREEN_WIDTH + 5; 1 row down and 3 to the right
	add hl, bc
	push de
	ld de, .lvstring
	call PlaceString
	ld bc, 3
	add hl, bc
	pop de
	ld a, [wEnemyMon2Level]
	ld [de], a
	lb bc, 1, 2
	call PrintNumber
	ld bc, SCREEN_WIDTH ; 1 row down and take the 3 back off
	add hl, bc

	jp .waitForInput
	;jp .LoopTrainerData
	; check if it's the end of the party
 	; change co-ordinates and iterate

.SpecialTrainer

	jr .waitForInput

.waitForInput
	ld hl,wd730
	res 6,[hl] ; no pauses between printing each letter
	;call Delay3
	;call GBPalNormal
	; call WaitForTextScrollButtonPress
	; call LoadScreenTilesFromBuffer1
	; call UpdateSprites
	ret
	;jr .LoopTrainerData

.titlestringone
	db "ENEMY@"

.titlestringtwo
	db "PARTY:@"

.lvstring
	db "Lv.@"

