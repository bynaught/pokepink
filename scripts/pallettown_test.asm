PalletTownScript:
    CheckEvent EVENT_FOLLOWED_OAK_INTO_LAB
    jr nz, .next
    ld a, HS_SECRET_SIGN
	ld [wMissableObjectIndex], a    ; hide the sign. IT'S YOUR FRIEND NOW
	predef HideObject
	CheckEvent EVENT_GOT_POKEBALLS_FROM_OAK
	jr z, .next
	SetEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS
.next
	call EnableAutoTextBoxDrawing
	ld hl, PalletTownScriptPointers
	ld a, [wPalletTownCurScript]
	jp CallFunctionInTable

PalletTownScriptPointers:
	dw PalletTownScript0
	dw PalletTownScript1
	dw PalletTownScript2
	dw PalletTownScript3
	dw PalletTownScript4
	dw PalletTownScript5
	dw PalletTownScript6

PalletTownScript0:
	CheckEvent EVENT_FOLLOWED_OAK_INTO_LAB
	ret nz
	ld a, [wYCoord]
	cp 1 ; is player near north exit?
	ret nz
	xor a
	ld [hJoyHeld], a   ; stop movement
	ld a, PLAYER_DIR_DOWN 
	ld [wPlayerMovingDirection], a ; make player face down
	ld a, $FC
	ld [wJoyIgnore], a   ; ignore input for now
	


; below is the script that spawns rival in oaks lab
; when you deliver oak's parcel.
;
; adapt this (with existing pallet script) to do to the following
; - talk to sign
; - sign transforms (despawn and then respawn hidden/missableobjects)
; - oak appears (spawn object)
; - leads you to lab

; OaksLabScript15:
; 	xor a
; 	ld [hJoyHeld], a
; 	call EnableAutoTextBoxDrawing
; 	ld a, $ff
; 	ld [wNewSoundID], a
; 	call PlaySound
; 	callba Music_RivalAlternateStart
; 	ld a, $15
; 	ld [hSpriteIndexOrTextID], a
; 	call DisplayTextID
; 	call OaksLabScript_1d02b
; 	
; 	ld a, [wNPCMovementDirections2Index]
; 	ld [wSavedNPCMovementDirections2Index], a
; 	ld b, 0
; 	ld c, a
; 	ld hl, wNPCMovementDirections2
; 	ld a, NPC_MOVEMENT_UP
; 	call FillMemory
; 	ld [hl], $ff
; 	ld a, $1
; 	ld [H_SPRITEINDEX], a
; 	ld de, wNPCMovementDirections2
; 	call MoveSprite
    

; 	ld a, $10
; 	ld [wOaksLabCurScript], a
; 	ret

	; trigger the next script
	ld a, 1
	ld [wPalletTownCurScript], a   ; to go script 1 (the value loaded into A)
	ret

PalletTownScript1:
	xor a
	ld [wcf0d], a   ; this address is used to decide which oak text to use
	ld a, 1
	ld [hSpriteIndexOrTextID], a ; display pallet town text 1
	call DisplayTextID ; hey stop it's dangerous text
	;ld a, $FC
	;ld [wJoyIgnore], a   ; keep ignoring?
	; trigger the next script
	ld a, 2
	ld [wPalletTownCurScript], a   ; script 2
	call StartSimulatingJoypadStates
	ld a, $1
	ld [wSimulatedJoypadStatesIndex], a
	ld a, D_DOWN     
	ld [wSimulatedJoypadStatesEnd], a   ; move downwards 1?
	xor a
	ld [wSpriteStateData1 + 9], a  ; player is facing down (0 = down)
	ld [wJoyIgnore], a     ; stop ignoring directions, start, select
    ;ld a, [wSimulatedJoypadStatesIndex] not sure if i need these parts
	;and a
	;ret nz  ; this makes sure the player can move again?
	;call Delay3
	;ld a, 0
	ld [wPalletTownCurScript], a   ; return to normal at script 0
	ret

PalletTownScript2:        ; this should be usable as is? 
	SetEvent EVENT_OAK_APPEARED_IN_PALLET
	ld a, 1
	ld [H_SPRITEINDEX], a
	ld a, SPRITE_FACING_UP
	ld [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	call Delay3
	ld a, 1
	ld [wYCoord], a
	ld a, 1
	ld [hNPCPlayerRelativePosPerspective], a
	ld a, 1
	swap a
	ld [hNPCSpriteOffset], a
	predef CalcPositionOfPlayerRelativeToNPC
	ld hl, hNPCPlayerYDistance
	dec [hl]
	predef FindPathToPlayer ; load Oak’s movement into wNPCMovementDirections2
	ld de, wNPCMovementDirections2
	ld a, 1 ; oak
	ld [H_SPRITEINDEX], a
	call MoveSprite
	ld a, $FF
	ld [wJoyIgnore], a

	; trigger the next script
	ld a, 3
	ld [wPalletTownCurScript], a
	ret

PalletTownScript3:
	ld a, [wd730]
	bit 0, a
	ret nz
	ld a, $c ; ld a, SPRITE_FACING_DOWN
	ld [wSpriteStateData1 + 9], a   ; this points to sprite facing direction?
	ld a, 1
	ld [wcf0d], a
	ld a, $FC    ; $fc = 11111100, meaning only A and B button - the lowest bits - are available
	ld [wJoyIgnore], a
	ld a, 1
	ld [hSpriteIndexOrTextID], a ; oak speaks to you before leading you to lab text
	call DisplayTextID
; set up movement script that causes the player to follow Oak to his lab
	ld a, $FF
	ld [wJoyIgnore], a
	ld a, 1
	ld [wSpriteIndex], a
	xor a
	ld [wNPCMovementScriptFunctionNum], a
	ld a, 1
	ld [wNPCMovementScriptPointerTableNum], a
	ld a, [H_LOADEDROMBANK]
	ld [wNPCMovementScriptBank], a

	; trigger the next script
	ld a, 4
	ld [wPalletTownCurScript], a
	ret

PalletTownScript4:
	ld a, [wNPCMovementScriptPointerTableNum]
	and a ; is the movement script over?
	ret nz

	; trigger the next script
	ld a, 5
	ld [wPalletTownCurScript], a
	ret

PalletTownScript5:
	CheckEvent EVENT_DAISY_WALKING
	jr nz, .next
	CheckBothEventsSet EVENT_GOT_TOWN_MAP, EVENT_ENTERED_BLUES_HOUSE, 1
	jr nz, .next
	SetEvent EVENT_DAISY_WALKING
	ld a, HS_DAISY_SITTING
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_DAISY_WALKING
	ld [wMissableObjectIndex], a
	predef_jump ShowObject
.next
	CheckEvent EVENT_GOT_POKEBALLS_FROM_OAK
	ret z
	SetEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS_2
PalletTownScript6:
	ret

PalletTownTextPointers:
	dw PalletTownText1
	dw PalletTownText2
	dw PalletTownText3
	dw PalletTownText4
	dw PalletTownText5
	dw PalletTownText6
	dw PalletTownText7

PalletTownText1: ; oak warns (text), then appears, walks up, and then speaks to you
	TX_ASM
	ld a, [wcf0d]
	and a
	jr nz, .next
;	ld a, 1
;	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, DangerousText
	jr .done
.next
	ld hl, OakWalksUpText
.done
	call PrintText
	jp TextScriptEnd

DangerousText:
	TX_FAR _DangerousText
	TX_ASM
	ld c, 10
	call DelayFrames
	xor a
	ld [wEmotionBubbleSpriteIndex], a ; player's sprite
	ld [wWhichEmotionBubble], a ; EXCLAMATION_BUBBLE
	predef EmotionBubble
	ld a, PLAYER_DIR_DOWN
	ld [wPlayerMovingDirection], a
	jp TextScriptEnd

OakWalksUpText:
	TX_FAR _OakWalksUpText
	db "@"

; when you speak to an NPC the index of the sprite is also the index of the 
; text that it calls - see sprite order here
; there's no pallettowntext1 because Oak, sprite 1, is hidden


PalletTownText2: ; girl
	TX_FAR _PalletTownText2
	db "@"

PalletTownText3: ; fat man
	TX_FAR _PalletTownText3
	db "@"

PalletTownText4: ; secret sign
	ld a, DITTO
	call PlayCry
	call WaitForSoundToFinish
	ld hl, PalletTownText4
	call PrintText ; one of these?
	;call DisplayTextID
	ld a, $FC
	ld [wJoyIgnore], a
	ld a, HS_SECRET_SIGN
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_SECRET_DITTO
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld hl, PalletTownText5
	call PrintText 
	ld a, HS_PALLET_TOWN_OAK
	ld [wMissableObjectIndex], a
	predef ShowObject

	; trigger the next script
	ld a, 2
	ld [wPalletTownCurScript], a
	ret
	jp TextScriptEnd

PalletTownText5: ; secret ditto
	TX_FAR _PalletTownText5
	db "@"

PalletTownText6: ; sign by lab
	TX_FAR _PalletTownText4
	db "@"

PalletTownText7: ; sign by fence
	TX_FAR _PalletTownText5
	db "@"

PalletTownText8: ; sign by Red’s house
	TX_FAR _PalletTownText6
	db "@"

PalletTownText9: ; sign by Blue’s house
	TX_FAR _PalletTownText7
	db "@"
