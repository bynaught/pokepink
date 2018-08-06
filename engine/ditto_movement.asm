ApplyDittoMovementData_::
	ld a, b
	ld [wDittoMovementScriptBank], a
	ld a, l
	ld [wDittoMovementScriptAddress], a
	ld a, h
	ld [wDittoMovementScriptAddress + 1], a
	call .SwapSpriteStateData
.loop
	call LoadDittoMovementCommandData
	jr nc, .done
	call ExecuteDittoMovementCommand
	jr .loop

.done
	call .SwapSpriteStateData
	call DelayFrame
	ret

.SwapSpriteStateData:
	ld a, [wUpdateSpritesEnabled]
	push af
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	push hl
	push de
	push bc

	ld hl, wPlayerSpriteStateData1
	ld de, wDittoSpriteStateData1
	ld c, $10
	call .SwapBytes

	ld hl, wPlayerSpriteStateData2
	ld de, wDittoSpriteStateData2
	ld c, $10
	call .SwapBytes

	pop bc
	pop de
	pop hl
	pop af
	ld [wUpdateSpritesEnabled], a
	ret

.SwapBytes:
	ld b, [hl]
	ld a, [de]
	ld [hli], a
	ld a, b
	ld [de], a
	inc de
	dec c
	jr nz, .SwapBytes
	ret

LoadDittoMovementCommandData:
	call GetDittoMovementScriptByte
	cp $3f
	ret z
	ld c, a
	ld b, 0
	ld hl, DittoMovementDatabase
	add hl, bc
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld [wCurPikaMovementFunc1], a
	ld a, [hli]
	cp $80
	jr nz, .no_param
	call GetDittoMovementScriptByte
.no_param
	ld [wCurPikaMovementParam1], a
	ld a, [hli]
	ld [wCurPikaMovementFunc2], a
	ld a, [hli]
	cp $80
	jr nz, .no_param2
	call GetDittoMovementScriptByte
.no_param2
	ld [wCurPikaMovementParam2], a
	xor a
	ld [wd451], a
	scf
	ret

ExecuteDittoMovementCommand:
	xor a
	ld [wDittoMovementFlags], a
	ld [wDittoStepTimer], a
	ld [wDittoStepSubtimer], a
	ld a, [wPlayerGrassPriority]
	push af
.loop
	ld bc, wPlayerSpriteStateData1 ; Currently holds Ditto's sprite state data
	ld a, [wCurPikaMovementFunc1]
	ld hl, PikaMovementFunc1Jumptable
	call .JumpTable
	ld a, [wCurPikaMovementFunc2]
	ld hl, PikaMovementFunc2Jumptable
	call .JumpTable
	call GetCoordsForDittoShadow
	call AnimateDittoShadow
	call DelayFrame
	call DelayFrame
	ld hl, wDittoMovementFlags
	bit 7, [hl]
	jr z, .loop
	pop af
	ld [wPlayerGrassPriority], a
	scf
	ret

.JumpTable:
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

GetCoordsForDittoShadow:
	ld hl, wPlayerSpriteImageIdx - wPlayerSpriteStateData1
	add hl, bc
	ld a, [wCurPikaMovementSpriteImageIdx]
	ld [hl], a
	ld a, [wPikaSpriteY]
	ld d, a
	ld a, [wDittoMovementYOffset]
	add d
	ld hl, wPlayerYPixels - wPlayerSpriteStateData1
	add hl, bc
	ld [hl], a
	ld a, [wPikaSpriteX]
	ld d, a
	ld a, [wDittoMovementXOffset]
	add d
	ld hl, wPlayerXPixels - wPlayerSpriteStateData1
	add hl, bc
	ld [hl], a
	ld hl, wDittoMovementFlags
	bit 6, [hl]
	ret z
	ld hl, wPlayerGrassPriority - wPlayerSpriteStateData1
	add hl, bc
	ld [hl], 0
	ret

AnimateDittoShadow:
	ld hl, wDittoMovementFlags
	bit 6, [hl]
	res 6, [hl]
	ld hl, wd736
	res 6, [hl]
	ret z
	set 6, [hl]
	call LoadDittoShadowOAMData
	ret

DittoMovementDatabase:
	db $01, 1 - 1, $00, 1 - 1 ; $00 start

	db $03, $80, $01, 1 - 1 ; $01
	db $04, $80, $01, 1 - 1 ; $02
	db $05, $80, $01, 1 - 1 ; $03
	db $06, $80, $01, 1 - 1 ; $04
	db $07, $80, $01, 1 - 1 ; $05
	db $08, $80, $01, 1 - 1 ; $06
	db $09, $80, $01, 1 - 1 ; $07
	db $0a, $80, $01, 1 - 1 ; $08

	db $03, $80, $06, 1 - 1 ; $09
	db $04, $80, $06, 1 - 1 ; $0a
	db $05, $80, $06, 1 - 1 ; $0b
	db $06, $80, $06, 1 - 1 ; $0c
	db $07, $80, $06, 1 - 1 ; $0d
	db $08, $80, $06, 1 - 1 ; $0e
	db $09, $80, $06, 1 - 1 ; $0f
	db $0a, $80, $06, 1 - 1 ; $10

	db $03, $80, $03, $80 ; $11
	db $04, $80, $03, $80 ; $12
	db $05, $80, $03, $80 ; $13
	db $06, $80, $03, $80 ; $14
	db $07, $80, $03, $80 ; $15
	db $08, $80, $03, $80 ; $16
	db $09, $80, $03, $80 ; $17
	db $0a, $80, $03, $80 ; $18

	db $03, $80, $07, $80 ; $19
	db $04, $80, $07, $80 ; $1a
	db $05, $80, $07, $80 ; $1b
	db $06, $80, $07, $80 ; $1c

	db $0b, (1 << 5) | 8 - 1, $02, 1 - 1 ; $1d step down
	db $0c, (1 << 5) | 8 - 1, $02, 1 - 1 ; $1e step up
	db $0d, (1 << 5) | 8 - 1, $02, 1 - 1 ; $1f step left
	db $0e, (1 << 5) | 8 - 1, $02, 1 - 1 ; $20 step right
	db $0f, (1 << 5) | 8 - 1, $02, 1 - 1 ; $21 step down left
	db $10, (1 << 5) | 8 - 1, $02, 1 - 1 ; $22 step down right
	db $11, (1 << 5) | 8 - 1, $02, 1 - 1 ; $23 step up left
	db $12, (1 << 5) | 8 - 1, $02, 1 - 1 ; $24 step up right

	db $0b, 16 - 1, $02, 1 - 1 ; $25 slide down
	db $0c, 16 - 1, $02, 1 - 1 ; $26 slide up
	db $0d, 16 - 1, $02, 1 - 1 ; $27 slide left
	db $0e, 16 - 1, $02, 1 - 1 ; $28 slide right
	db $0f, 16 - 1, $02, 1 - 1 ; $29 slide down left
	db $10, 16 - 1, $02, 1 - 1 ; $2a slide down right
	db $11, 16 - 1, $02, 1 - 1 ; $2b slide up left
	db $12, 16 - 1, $02, 1 - 1 ; $2c slide up right

	db $0b, 16 - 1, $08, (1 << 4) | 8 - 1 ; $2d hop down
	db $0c, 16 - 1, $08, (1 << 4) | 8 - 1 ; $2e hop up
	db $0d, 16 - 1, $08, (1 << 4) | 8 - 1 ; $2f hop left
	db $0e, 16 - 1, $08, (1 << 4) | 8 - 1 ; $30 hop right
	db $0f, 16 - 1, $08, (1 << 4) | 8 - 1 ; $31 hop down left
	db $10, 16 - 1, $08, (1 << 4) | 8 - 1 ; $32 hop down right
	db $11, 16 - 1, $08, (1 << 4) | 8 - 1 ; $33 hop up left
	db $12, 16 - 1, $08, (1 << 4) | 8 - 1 ; $34 hop up right

	db $13, 16 - 1, $06, 1 - 1 ; $35 look down
	db $14, 16 - 1, $06, 1 - 1 ; $36 look up
	db $15, 16 - 1, $06, 1 - 1 ; $37 look left
	db $16, 16 - 1, $06, 1 - 1 ; $38 look right

	db $02, $80, $04, 1 - 1 ; $39
	db $02, $80, $05, 1 - 1 ; $3a
	db $02, $80, $03, $80 ; $3b
	db $02, $80, $07, $80 ; $3c
	db $02, $80, $09, $80 ; $3d
	db $02, $80, $06, 1 - 1 ; $3e

PikaMovementFunc1Jumptable:
	dw PikaMovementFunc1_EndCommand_ ; 00
 	dw PikaMovementFunc1_LoadDittoCurrentPosition ; 01
 	dw PikaMovementFunc1_DelayFrames ; 02
 	dw PikaMovementFunc1_WalkInCurrentFacingDirection ; 03
 	dw PikaMovementFunc1_WalkInOppositeFacingDirection ; 04
 	dw PikaMovementFunc1_StepTurningCounterclockwise ; 05
 	dw PikaMovementFunc1_StepTurningClockwise ; 06
 	dw PikaMovementFunc1_StepForwardLeft ; 07
 	dw PikaMovementFunc1_StepForwardRight ; 08
 	dw PikaMovementFunc1_StepBackwardLeft ; 09
 	dw PikaMovementFunc1_StepBackwardRight ; 0a
 	dw PikaMovementFunc1_MoveDown ; 0b
 	dw PikaMovementFunc1_MoveUp ; 0c
 	dw PikaMovementFunc1_MoveLeft ; 0d
 	dw PikaMovementFunc1_MoveRight ; 0e
 	dw PikaMovementFunc1_MoveDownLeft ; 0f
 	dw PikaMovementFunc1_MoveDownRight ; 10
 	dw PikaMovementFunc1_MoveUpLeft ; 11
 	dw PikaMovementFunc1_MoveUpRight ; 12
 	dw PikaMovementFunc1_LookDown ; 13
 	dw PikaMovementFunc1_LookUp ; 14
 	dw PikaMovementFunc1_LookLeft ; 15
 	dw PikaMovementFunc1_LookRight ; 16
 	dw PikaMovementFunc1_EndCommand_ ; 17

PikaMovementFunc1_EndCommand:
	ld a, [wDittoMovementFlags]
	set 7, a
	ld [wDittoMovementFlags], a
	ret

PikaMovementFunc1_EndCommand_:
	call PikaMovementFunc1_EndCommand
	ret

PikaMovementFunc1_LoadDittoCurrentPosition:
	ld hl, wPlayerYPixels - wPlayerSpriteStateData1
	add hl, bc
	ld a, [hl]
	ld [wPikaSpriteY], a
	ld hl, wPlayerXPixels - wPlayerSpriteStateData1
	add hl, bc
	ld a, [hl]
	ld [wPikaSpriteX], a
	xor a
	ld [wDittoMovementYOffset], a
	ld [wDittoMovementXOffset], a
	call PikaMovementFunc1_EndCommand
	ret

PikaMovementFunc1_DelayFrames:
	call CheckDittoStepTimer1
	ret nz
	call PikaMovementFunc1_EndCommand
	ret

PikaMovementFunc1_WalkInCurrentFacingDirection:
	call GetDittoFacing
	jr PikaMovementFunc1_ApplyStepVector

PikaMovementFunc1_WalkInOppositeFacingDirection:
	call GetDittoFacing
	xor %100
	jr PikaMovementFunc1_ApplyStepVector

PikaMovementFunc1_StepTurningCounterclockwise:
	call GetDittoFacing
	ld hl, .Data
	call PikaMovementFunc1_GetNextFacing
	jr PikaMovementFunc1_ApplyStepVector

.Data:
	db SPRITE_FACING_DOWN,  PIKASTEPDIR_RIGHT << 2
	db SPRITE_FACING_UP,    PIKASTEPDIR_LEFT << 2
	db SPRITE_FACING_LEFT,  PIKASTEPDIR_DOWN << 2
	db SPRITE_FACING_RIGHT, PIKASTEPDIR_UP << 2
	db $ff

PikaMovementFunc1_StepTurningClockwise:
	call GetDittoFacing
	ld hl, .Data
	call PikaMovementFunc1_GetNextFacing
	jr PikaMovementFunc1_ApplyStepVector

.Data:
	db SPRITE_FACING_DOWN,  PIKASTEPDIR_LEFT << 2
	db SPRITE_FACING_UP,    PIKASTEPDIR_RIGHT << 2
	db SPRITE_FACING_LEFT,  PIKASTEPDIR_UP << 2
	db SPRITE_FACING_RIGHT, PIKASTEPDIR_DOWN << 2
	db $ff

PikaMovementFunc1_StepForwardLeft:
	call GetDittoFacing
	ld hl, .Data
	call PikaMovementFunc1_GetNextFacing
	jr PikaMovementFunc1_ApplyStepVector

.Data:
	db SPRITE_FACING_DOWN,  PIKASTEPDIR_DOWN_RIGHT << 2
	db SPRITE_FACING_UP,    PIKASTEPDIR_UP_LEFT << 2
	db SPRITE_FACING_LEFT,  PIKASTEPDIR_DOWN_LEFT << 2
	db SPRITE_FACING_RIGHT, PIKASTEPDIR_UP_RIGHT << 2

PikaMovementFunc1_StepForwardRight:
	call GetDittoFacing
	ld hl, .Data
	call PikaMovementFunc1_GetNextFacing
	jr PikaMovementFunc1_ApplyStepVector

.Data:
	db SPRITE_FACING_DOWN,  PIKASTEPDIR_DOWN_LEFT << 2
	db SPRITE_FACING_UP,    PIKASTEPDIR_UP_RIGHT << 2
	db SPRITE_FACING_LEFT,  PIKASTEPDIR_UP_LEFT << 2
	db SPRITE_FACING_RIGHT, PIKASTEPDIR_DOWN_RIGHT << 2

PikaMovementFunc1_StepBackwardLeft:
	call GetDittoFacing
	ld hl, .Data
	call PikaMovementFunc1_GetNextFacing
	jr PikaMovementFunc1_ApplyStepVector

.Data:
	db SPRITE_FACING_DOWN,  PIKASTEPDIR_UP_RIGHT << 2
	db SPRITE_FACING_UP,    PIKASTEPDIR_DOWN_LEFT << 2
	db SPRITE_FACING_LEFT,  PIKASTEPDIR_DOWN_RIGHT << 2
	db SPRITE_FACING_RIGHT, PIKASTEPDIR_UP_LEFT << 2

PikaMovementFunc1_StepBackwardRight:
	call GetDittoFacing
	ld hl, .Data
	call PikaMovementFunc1_GetNextFacing
	jr PikaMovementFunc1_ApplyStepVector

.Data:
	db SPRITE_FACING_DOWN,  PIKASTEPDIR_UP_LEFT << 2
	db SPRITE_FACING_UP,    PIKASTEPDIR_DOWN_RIGHT << 2
	db SPRITE_FACING_LEFT,  PIKASTEPDIR_UP_RIGHT << 2
	db SPRITE_FACING_RIGHT, PIKASTEPDIR_DOWN_LEFT << 2

PikaMovementFunc1_ApplyStepVector:
	rrca
	rrca
	and $7
	ld e, a
	call GetDittoStepVectorMagnitude
	ld d, a
	call UpdateDittoPosition
	call CheckDittoStepTimer1
	ret nz
	call PikaMovementFunc1_EndCommand
	ret

PikaMovementFunc1_GetNextFacing:
	push de
	ld d, a
.loop
	ld a, [hli]
	cp d
	jr z, .found
	inc hl
	cp $ff
	jr nz, .loop
	pop de
	ret

.found
	ld a, [hl]
	pop de
	scf
	ret

PikaMovementFunc1_MoveDown:
	ld a, PIKASTEPDIR_DOWN
	jr PikaMovementFunc1_ApplyFacingAndMove

PikaMovementFunc1_MoveUp:
	ld a, PIKASTEPDIR_UP
	jr PikaMovementFunc1_ApplyFacingAndMove

PikaMovementFunc1_MoveLeft:
	ld a, PIKASTEPDIR_LEFT
	jr PikaMovementFunc1_ApplyFacingAndMove

PikaMovementFunc1_MoveRight:
	ld a, PIKASTEPDIR_RIGHT
	jr PikaMovementFunc1_ApplyFacingAndMove

PikaMovementFunc1_MoveDownLeft:
	ld e, PIKASTEPDIR_DOWN_LEFT
	jr PikaMovementFunc1_MoveDiagonally

PikaMovementFunc1_MoveDownRight:
	ld e, PIKASTEPDIR_DOWN_RIGHT
	jr PikaMovementFunc1_MoveDiagonally

PikaMovementFunc1_MoveUpLeft:
	ld e, PIKASTEPDIR_UP_LEFT
	jr PikaMovementFunc1_MoveDiagonally

PikaMovementFunc1_MoveUpRight:
	ld e, PIKASTEPDIR_UP_RIGHT
	jr PikaMovementFunc1_MoveDiagonally

PikaMovementFunc1_ApplyFacingAndMove:
	ld e, a
	call SetDittoFacing
PikaMovementFunc1_MoveDiagonally:
	call GetDittoStepVectorMagnitude
	ld d, a
	push de
	call UpdateDittoPosition
	pop de
	call CheckDittoStepTimer1
	ret nz
	ld a, e
	call ApplyDittoStepVector
	call PikaMovementFunc1_EndCommand
	ret

PikaMovementFunc1_LookDown:
	ld a, PIKASTEPDIR_DOWN
	jr PikaMovementFunc1_ApplyFacing

PikaMovementFunc1_LookUp:
	ld a, PIKASTEPDIR_UP
	jr PikaMovementFunc1_ApplyFacing

PikaMovementFunc1_LookLeft:
	ld a, PIKASTEPDIR_LEFT
	jr PikaMovementFunc1_ApplyFacing

PikaMovementFunc1_LookRight:
	ld a, PIKASTEPDIR_RIGHT
	jr PikaMovementFunc1_ApplyFacing

PikaMovementFunc1_ApplyFacing:
	call SetDittoFacing
	call PikaMovementFunc1_EndCommand
	ret

UpdateDittoPosition:
	push de
	ld d, 0
	ld hl, .Jumptable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de
	ld a, d
	jp hl

.Jumptable:
	dw .Down
	dw .Up
	dw .Left
	dw .Right
	dw .DownLeft
	dw .DownRight
	dw .UpLeft
	dw .UpRight

.Down:
	ld d, 0
	ld e, a
	jr .ApplyVector

.Up:
	ld d, 0
	cpl
	inc a
	ld e, a
	jr .ApplyVector

.Left:
	cpl
	inc a
	ld d, a
	ld e, 0
	jr .ApplyVector

.Right:
	ld d, a
	ld e, 0
	jr .ApplyVector

.DownLeft:
	ld e, a
	cpl
	inc a
	ld d, a
	jr .ApplyVector

.DownRight:
	ld e, a
	ld d, a
	jr .ApplyVector

.UpLeft:
	cpl
	inc a
	ld e, a
	ld d, a
	jr .ApplyVector

.UpRight:
	ld d, a
	cpl
	inc a
	ld e, a
	jr .ApplyVector

.ApplyVector:
	ld a, [wPikaSpriteX]
	add d
	ld [wPikaSpriteX], a
	ld a, [wPikaSpriteY]
	add e
	ld [wPikaSpriteY], a
	ret

PikaMovementFunc2Jumptable:
	dw PikaMovementFunc2_ResetFrameCounterAndFaceCurrent ; 0
	dw PikaMovementFunc2_UpdateSpriteImageIdxWithPreviousImageIdxDirection ; 1
	dw PikaMovementFunc2_UpdateSpriteImageIdxWithFacing ; 2
	dw PikaMovementFunc2_TurnParameter ; 3
	dw PikaMovementFunc2_TurnClockwise ; 4
	dw PikaMovementFunc2_TurnCounterClockwise ; 5
	dw PikaMovementFunc2_CopySpriteImageIdxDirectionToSpriteImageIdx ; 6
	dw PikaMovementFunc2_UpdateJumpWithPreviousImageIdxDirection ; 7
	dw PikaMovementFunc2_UpdateJumpWithFacing ; 8
	dw PikaMovementFunc2_CopyFacingToJump ; 9
	dw PikaMovementFunc2_nop ; 10

PikaMovement_SetSpawnShadow:
	ld hl, wDittoMovementFlags
	set 6, [hl]
	ret

PikaMovementFunc2_ResetFrameCounterAndFaceCurrent:
	ld hl, wPlayerIntraAnimFrameCounter - wPlayerSpriteStateData1
	add hl, bc
	xor a
	ld [hli], a
	ld [hl], a
	call PikaMovementFunc2_GetImageBaseOffset
	ld d, a
	call GetDittoFacing
	or d
	ld [wCurPikaMovementSpriteImageIdx], a
	ret

PikaMovementFunc2_nop:
	ret

PikaMovementFunc2_CopySpriteImageIdxDirectionToSpriteImageIdx:
	call PikaMovementFunc2_GetImageBaseOffset
	ld d, a
	call PikaMovementFunc2_GetSpriteImageIdxDirection
	or d
	ld [wCurPikaMovementSpriteImageIdx], a
	ret

PikaMovementFunc2_UpdateSpriteImageIdxWithFacing:
	call PikaMovementFunc2_GetImageBaseOffset
	ld d, a
	call GetDittoFacing
	or d
	ld d, a
	jr PikaMovementFunc2_UpdateSpriteImageIdx

PikaMovementFunc2_UpdateSpriteImageIdxWithPreviousImageIdxDirection:
	call PikaMovementFunc2_GetImageBaseOffset
	ld d, a
	call PikaMovementFunc2_GetSpriteImageIdxDirection
	or d
	ld d, a
PikaMovementFunc2_UpdateSpriteImageIdx:
	ld hl, wPlayerAnimFrameCounter - wPlayerSpriteStateData1
	add hl, bc
	call CheckDittoStepTimer2 ; does not preserve hl
	jr nz, .skip
	inc [hl]
.skip
	ld a, [hl]
	rrca
	rrca
	and 3
	or d
	ld [wCurPikaMovementSpriteImageIdx], a
	ret

PikaMovementFunc2_UpdateJumpWithFacing:
	call GetDittoFacing
	ld d, a
	jr PikaMovementFunc2_UpdateJump

PikaMovementFunc2_UpdateJumpWithPreviousImageIdxDirection:
	call PikaMovementFunc2_GetSpriteImageIdxDirection
	ld d, a
PikaMovementFunc2_UpdateJump:
	call PikaMovementFunc2_GetImageBaseOffset
	or d
	ld d, a
	call PikaMovementFunc2_Timer
	or d
	ld [wCurPikaMovementSpriteImageIdx], a
	call PikaMovementFunc_Sine
	ld [wDittoMovementYOffset], a
	and a
	ret z
	call PikaMovement_SetSpawnShadow
	ret

PikaMovementFunc2_CopyFacingToJump:
	call GetDittoFacing
	ld d, a
	call PikaMovementFunc2_GetImageBaseOffset
	or d
	ld [wCurPikaMovementSpriteImageIdx], a
	call PikaMovementFunc_Sine
	ld [wDittoMovementYOffset], a
	ret

PikaMovementFunc2_TurnParameter:
	ld a, [wCurPikaMovementParam2]
	and $40
	cp $40
	jr z, PikaMovementFunc2_TurnClockwise
	jr PikaMovementFunc2_TurnCounterClockwise

PikaMovementFunc2_TurnClockwise:
	call PikaMovementFunc2_GetSpriteImageIdxDirection
	ld d, a
	call CheckDittoStepTimer2
	jr nz, .skip
	ld hl, Data_fd731
.loop
	ld a, [hli]
	cp d
	jr nz, .loop
	ld d, [hl]
.skip
	call PikaMovementFunc2_GetImageBaseOffset
	or d
	ld [wCurPikaMovementSpriteImageIdx], a
	ret

PikaMovementFunc2_TurnCounterClockwise:
	call PikaMovementFunc2_GetSpriteImageIdxDirection
	ld d, a
	call CheckDittoStepTimer2
	jr nz, .skip
	ld hl, Data_fd731End
.loop
	ld a, [hld]
	cp d
	jr nz, .loop
	ld d, [hl]
.skip
	call PikaMovementFunc2_GetImageBaseOffset
	or d
	ld [wCurPikaMovementSpriteImageIdx], a
	ret

Data_fd731:
	db SPRITE_FACING_DOWN
	db SPRITE_FACING_LEFT
	db SPRITE_FACING_UP
	db SPRITE_FACING_RIGHT
	db SPRITE_FACING_DOWN
Data_fd731End:

PikaMovementFunc2_Timer:
	push hl
	ld hl, wPlayerIntraAnimFrameCounter - wPlayerSpriteStateData1
	add hl, bc
	ld a, [hl]
	inc a
	and $3
	ld [hli], a
	jr nz, .load_pop
	ld a, [hl]
	inc a
	and $3
	ld [hl], a
.load_pop
	ld a, [hl]
	pop hl
	ret

PikaMovementFunc2_GetImageBaseOffset:
	push hl
	ld hl, wPlayerSpriteImageBaseOffset - wPlayerSpriteStateData1
	add hl, bc
	ld a, [hl]
	dec a
	swap a
	pop hl
	ret

PikaMovementFunc2_GetSpriteImageIdxDirection:
	push hl
	ld hl, wPlayerSpriteImageIdx - wPlayerSpriteStateData1
	add hl, bc
	ld a, [hl]
	and $c
	pop hl
	ret

GetDittoFacing:
	push hl
	ld hl, wPlayerFacingDirection - wPlayerSpriteStateData1
	add hl, bc
	ld a, [hl]
	and $c
	pop hl
	ret

SetDittoFacing:
	push hl
	ld hl, wPlayerFacingDirection - wPlayerSpriteStateData1
	add hl, bc
	add a
	add a
	and $c
	ld [hl], a
	pop hl
	ret

CheckDittoStepTimer1:
	ld hl, wDittoStepTimer
	inc [hl]
	ld a, [wCurPikaMovementParam1]
	and $1f
	inc a
	cp [hl]
	ret nz
	ld [hl], 0
	ret

GetDittoStepVectorMagnitude:
	; *XX*****
	ld a, [wCurPikaMovementParam1]
	swap a
	rrca
	and $3
	inc a
	ret

CheckDittoStepTimer2:
	ld hl, wDittoStepSubtimer
	inc [hl]
	ld a, [wCurPikaMovementParam2]
	and $f
	inc a
	cp [hl]
	ret nz
	ld [hl], 0
	ret

PikaMovementFunc_Sine:
	call .GetArgument
	ld a, [wDittoStepSubtimer]
	add e
	ld [wDittoStepSubtimer], a
	add $20
	ld e, a
	push hl
	push bc
	call Sine_e
	pop bc
	pop hl
	ret

.GetArgument:
	ld a, [wCurPikaMovementParam2]
	and $f
	inc a
	ld d, a
	ld a, [wCurPikaMovementParam2]
	swap a
	and $7
	ld e, a
	ld a, 1
	jr z, .okay
.loop
	add a
	dec e
	jr nz, .loop
.okay
	ld e, a
	ret

ApplyDittoStepVector:
	push bc
	ld c, a
	ld b, 0
	ld hl, .StepVectors
	add hl, bc
	add hl, bc
	ld d, [hl]
	inc hl
	ld e, [hl]
	pop bc
	ld hl, wPlayerMapY - wPlayerSpriteStateData1
	add hl, bc
	ld a, [hl]
	add e
	ld [hli], a
	ld a, [hl]
	add d
	ld [hl], a
	ret

.StepVectors:
	db  0,  1
	db  0, -1
	db -1,  0
	db  1,  0
	db -1,  1
	db  1,  1
	db -1, -1
	db  1, -1

LoadDittoShadowOAMData:
	push bc
	push de
	push hl
	
	ld bc, wOAMBuffer + 4 * 36
	ld a, [wPikaSpriteY]
	ld e, a
	ld a, [wPikaSpriteX]
	ld d, a
	ld hl, .OAMData
	call .LoadOAMData

	pop hl
	pop de
	pop bc
	ret

.OAMData:
	db 2
	db $0c, $00, $ff, 0
	db $0c, $08, $ff, 1 << OAM_X_FLIP

.LoadOAMData:
	ld a, e
	add $10
	ld e, a
	ld a, d
	add $8
	ld d, a
	ld a, [hli]
.loop
	push af
	ld a, [hli]
	add e
	ld [bc], a
	inc bc
	ld a, [hli]
	add d
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	pop af
	dec a
	jr nz, .loop
	ret

LoadDittoShadowIntoVRAM:
	ld hl, vNPCSprites2 + $7f * $10
	ld de, LedgeHoppingShadowGFX_3F
	lb bc, BANK(LedgeHoppingShadowGFX_3F), (LedgeHoppingShadowGFX_3FEnd - LedgeHoppingShadowGFX_3F) / 8
	jp CopyVideoDataDoubleAlternate

LedgeHoppingShadowGFX_3F:
INCBIN "gfx/ledge_hopping_shadow.1bpp"
LedgeHoppingShadowGFX_3FEnd:

LoadDittoBallIconIntoVRAM:
	ld hl, vNPCSprites2 + $7e * $10
	ld de, GFX_fd86b
	lb bc, BANK(GFX_fd86b), 1
	jp CopyVideoDataDoubleAlternate

Func_fd851:
	ld hl, vNPCSprites + $c * $10
	ld a, 3
.loop
	push af
	push hl
	ld de, GFX_fd86b
	lb bc, BANK(GFX_fd86b), 4
	call CopyVideoDataAlternate
	pop hl
	ld de, 4 * $10
	add hl, de
	pop af
	dec a
	jr nz, .loop
	ret

GFX_fd86b:
INCBIN "gfx/unknown_fd86b.2bpp"

LoadDittoSpriteIntoVRAM:
	ld de, DittoSprite
	lb bc, BANK(DittoSprite), (SandshrewSprite - DittoSprite) / 32
	ld hl, vNPCSprites + $c * $10
	push bc
	call CopyVideoDataAlternate
	ld de, DittoSprite + $c * $10
	ld hl, vNPCSprites2 + $c * $10
	ld a, [h_0xFFFC]
	and a
	jr z, .load
	ld de, DittoSprite + $c * $10
	ld hl, vNPCSprites2 + $4c * $10
.load
	pop bc
	call CopyVideoDataAlternate
	call LoadDittoShadowIntoVRAM
	call LoadDittoBallIconIntoVRAM
	ret

DittoPewterPokecenterCheck:
	ld a, [wCurMap]
	cp PEWTER_POKECENTER
	ret nz
	call EnableDittoFollowingPlayer
	call StarterDittoEmotionCommand_turnawayfromplayer
	ret

DittoFanClubCheck:
	ld a, [wCurMap]
	cp POKEMON_FAN_CLUB
	ret nz
	call EnableDittoFollowingPlayer
	call StarterDittoEmotionCommand_turnawayfromplayer
	ret

DittoBillsHouseCheck:
	ld a, [wCurMap]
	cp BILLS_HOUSE
	ret nz
	call EnableDittoFollowingPlayer
	ret

Ditto_LoadCurrentMapViewUpdateSpritesAndDelay3:
	call LoadCurrentMapView
	call UpdateSprites
	call Delay3
	ret

Cosine_e: ; cosine?
	ld a, e
	add $10
	jr asm_fd908

Sine_e: ; sine?
	ld a, e
asm_fd908
	and $3f
	cp $20
	jr nc, .asm_fd913
	call GetSine
	ld a, h
	ret

.asm_fd913
	and $1f
	call GetSine
	ld a, h
	cpl
	inc a
	ret

GetSine:
	ld e, a
	ld a, d
	ld d, 0
	ld hl, SineWave_3f
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, 0
.asm_fd92b
	srl a
	jr nc, .asm_fd930
	add hl, de
.asm_fd930
	sla e
	rl d
	and a
	jr nz, .asm_fd92b
	ret

SineWave_3f:
	sine_wave $100
