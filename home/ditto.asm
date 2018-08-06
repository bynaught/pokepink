Func_1510::
	push hl
	ld hl, wDittoOverworldStateFlags
	set 7, [hl]
	ld hl, wDittoSpriteImageIdx ; Ditto data?
	ld [hl], $ff
	pop hl
	ret

Func_151d::
	push hl
	ld hl, wDittoOverworldStateFlags
	res 7, [hl]
	pop hl
	ret

EnableDittoOverworldSpriteDrawing::
	push hl
	ld hl, wDittoOverworldStateFlags
	res 3, [hl]
	pop hl
	ret

DisableDittoOverworldSpriteDrawing::
	push hl
	ld hl, wDittoOverworldStateFlags
	set 3, [hl]
	ld hl, wDittoSpriteImageIdx ; Ditto data?
	ld [hl], $ff
	pop hl
	ret

DisableDittoFollowingPlayer::
	push hl
	ld hl, wDittoOverworldStateFlags
	set 1, [hl]
	pop hl
	ret

EnableDittoFollowingPlayer::
	push hl
	ld hl, wDittoOverworldStateFlags
	res 1, [hl]
	pop hl
	ret

CheckDittoFollowingPlayer::
	push hl
	ld hl, wDittoOverworldStateFlags
	bit 1, [hl]
	pop hl
	ret

SpawnDitto::
	ld a, [hl]
	dec a
	swap a
	ld [hTilePlayerStandingOn], a
	homecall SpawnDitto_ ; 3f:46d5
	ret

Ditto_IsInArray::
	ld b, $0
	ld c, a
.loop
	inc b
	ld a, [hli]
	cp $ff
	jr z, .not_in_array
	cp c
	jr nz, .loop
	dec b
	dec hl
	scf
	ret

.not_in_array
	dec b
	dec hl
	and a
	ret

GetDittoMovementScriptByte::
	push hl
	push bc
	ld a, [H_LOADEDROMBANK]
	push af
	ld a, [wDittoMovementScriptBank]
	call BankswitchCommon
	ld hl, wDittoMovementScriptAddress
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld a, [bc]
	inc bc
	ld [hl], b
	dec hl
	ld [hl], c
	ld c, a
	pop af
	call BankswitchCommon
	ld a, c
	pop bc
	pop hl
	ret

ApplyDittoMovementData::
	ld a, [H_LOADEDROMBANK]
	ld b, a
	push af
	callbs ApplyDittoMovementData_
	pop af
	call BankswitchCommon
	ret