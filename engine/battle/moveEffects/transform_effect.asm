TransformEffect_:
	ld hl, wBattleMonSpecies
	ld de, wEnemyMonSpecies
	ld bc, wEnemyBattleStatus3
	ld a, [wEnemyBattleStatus1]
	ld a, [H_WHOSETURN]
	and a
	jr nz, .hitTest
	ld hl, wEnemyMonSpecies
	ld de, wBattleMonSpecies
	ld bc, wPlayerBattleStatus3
	ld [wPlayerMoveListIndex], a
	ld a, [wPlayerBattleStatus1]
.hitTest
	bit INVULNERABLE, a ; is mon invulnerable to typical attacks? (fly/dig)
	jp nz, .failed
	push hl
	push de
	push bc
	ld hl, wPlayerBattleStatus1
	set INVULNERABLE, [hl] 		; make ditto invulerable during transform as a pretend "imposter" ability
								; TODO: make this check to see if Ditto is already transformed, and only set INVULNERABLE if it's the first time? might make the move too weak but I'll see
	ld hl, wPlayerBattleStatus2
	ld a, [H_WHOSETURN]
	and a
	jr z, .transformEffect
	ld hl, wEnemyBattleStatus2
.transformEffect
; animation(s) played are different if target has Substitute up
	bit HAS_SUBSTITUTE_UP, [hl]
	push af
	ld hl, HideSubstituteShowMonAnim
	ld b, BANK(HideSubstituteShowMonAnim)
	call nz, Bankswitch
	ld a, [wOptions]
	add a
	ld hl, PlayCurrentMoveAnimation
	ld b, BANK(PlayCurrentMoveAnimation)
	jr nc, .gotAnimToPlay
	ld hl, AnimationTransformMon
	ld b, BANK(AnimationTransformMon)
.gotAnimToPlay
	call Bankswitch
	ld hl, ReshowSubstituteAnim
	ld b, BANK(ReshowSubstituteAnim)
	pop af
	call nz, Bankswitch
	pop bc
	ld a, [bc]
	set TRANSFORMED, a ; mon is now transformed
	ld [bc], a
	pop de
	pop hl
; transform user into opposing Pokemon
; species
	ld a, [hl]
	ld [de], a

; type 1, type 2, catch rate, and current moves
	ld bc, $5 ; 3 for HP copy
	add hl, bc
	inc de
	inc de
	inc de
	inc de 
	inc de 
	dec bc 
	dec bc 
	call CopyData
	inc de
	ld bc, $3
	call CopyData
	ld a, [H_WHOSETURN]
	and a
	jr z, .next
; save enemy mon DVs at wTransformedEnemyMonOriginalDVs
	ld a, [de]
	ld [wTransformedEnemyMonOriginalDVs], a
	inc de
	ld a, [de]
	ld [wTransformedEnemyMonOriginalDVs + 1], a
	dec de
.next
; DVs
	inc hl
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
; Attack, Defense, Speed, and Special stats
	inc hl
	inc hl
	inc hl
	inc de
	inc de
	inc de
	ld bc, $8
	call CopyData

; THE BELOW HP CHECKS ARE 8-BIT ONLY, WHICH MAY LEAD TO SOME UNLIKELY ISSUES WITH HIGH VALUES
; ADD AN EXTRA COMPARISON TO THE FIRST BYTE IF YOU AREN'T LAZY
; THE FIRST BYTE SHOULD NEVER BE MORE THAN 1 ANYWAY

	; check if my max hp = enemy max hp, in which case no calculation required
	ld hl, wBattleMonStats + 1
	ld a, [hl]
	ld hl, wEnemyMonStats + 1
	ld b, [hl]
	cp b
	jp z, .chooseMoves

	; check if we are 100% hp, in which case we just need to copy enemy max to our max, no calculation required
	ld hl, wBattleMonHP + 1
	ld a, [hl]
	ld hl, wBattleMonStats + 1
	ld b, [hl]
	cp b
	jp nz, .hpCalc

	; execute this if we are 100% hp - copy enemy max hp to our current hp
	ld hl, wEnemyMonStats ; changed from hp to stats
	ld de, wBattleMonHP
	ld a, [hl]
	ld [de], a
	inc hl
	inc de
	ld a, [hl]
	ld [de], a
	ld hl, wBattleMonHP + 1
	ld a, [hl]
	ld hl, wBattleMonStats + 1
	ld b, [hl]
	jp .maxHP


.hpCalc ; this is where we calculate our modified hp post-transformation
    ld hl, wBattleMonHP
	ld a, [hli]
	or [hl]
	xor a
	ld [H_MULTIPLICAND], a
	ld hl, wBattleMonHP
	ld a, [hli]
	ld [H_MULTIPLICAND + 1], a
	ld a, [hl]
	ld [H_MULTIPLICAND + 2], a
	ld a, 50
	ld [H_MULTIPLIER], a
	call Multiply
	ld hl, wBattleMonStats
	ld a, [hli]
	ld b, [hl]
	srl a ;
	rr b ; divide by two by shifting right
	ld a, b
	ld b, 4
	ld [H_DIVISOR], a
	call Divide
	ld a, [H_QUOTIENT + 3] ; a = (curHP*50) / (maxHP/2) = roughly percentage current hp
  	ld hl, wPCHPStore
    ld [hl], a
    xor a
	ld [H_MULTIPLICAND], a
	ld hl, wEnemyMonStats
	ld a, [hli]
	ld [H_MULTIPLICAND + 1], a
	ld a, [hl]
	ld [H_MULTIPLICAND + 2], a
	ld a, [wPCHPStore]
	ld [H_MULTIPLIER], a ; multiply enemy maxhp by current percent
	call Multiply
	ld a, 10
    ld [H_DIVISOR], a ; then divide by 10 
    call Divide
	ld a, 10
    ld [H_DIVISOR], a ; then divide by 10 again to calculate new current HP
    call Divide 	  ; we divide by ten twice to avoid high remainders, which can cause rounding issues with accuracy
    ld a, [H_QUOTIENT + 2]
    ld hl, wBattleMonHP
    ld [hli], a
    ld a, [H_QUOTIENT + 3]
    ld [hl], a

; max HP
.maxHP
	ld hl, wEnemyMonStats
	ld de, wBattleMonStats
	;inc hl
	;inc de
	ld a, [hl]
	ld [de], a
	inc hl
	inc de
	ld a, [hl]
	ld [de], a

.chooseMoves
	ld hl, EvosMovesPointerTable ; access learnset data
	ld b, 0
	ld a, [wcf91]  ; current mon ID
	dec a
	add a
	rl b
	ld c, a
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
.skipEvoEntriesLoop ; if there are evolutions, skip these
	ld c, $0 ; IMPORTANT: set c to 0. from this point on, c is our counter for how many moves are in the list
	ld a, [hli]
	and a
	jr nz, .skipEvoEntriesLoop
    ld de, wTransformMoveList + 1
	ld a, [hl] ; check if the pokemon learns any moves at all (for cases like Weedle)
	and a
	jp z, .addLevelZeroMoves ; if it doesn't, we already have all the moves. jump. this was COPYPP
	ld a, [wBattleMonLevel]
	cp [hl]
	jp c, .addLevelZeroMoves ; if our level isn't high enough, do the same. this was also COPYPP
.countLearnset ; use this to loop over the learnset, incrementing something to write to wTransformMoveList, then write move IDs to subsequent bytes
	ld a, [hl]
	and a ; 0 marks end of learnset, so check that
	jp z, .addLevelZeroMoves ; if it's zero, skip because we're at the end
	ld a, [wBattleMonLevel]
	cp [hl]
	jp c, .addLevelZeroMoves ; compare my level with learnset level, if ls lvl is higher, stop iterating
	inc hl ; incrememnt hl to point to the move ID
    ld a, [hli] ; write move ID to a and increment hl
.addToMoveList
    inc c ; increment to count moves
    ld [de], a ; write the move ID to the list 
    inc de ; move pointer to the next list slot
    jr .countLearnset ;loop back

.addLevelZeroMoves
	ld a, [wcf91]
	ld [wd0b5], a ; input for GetMonHeader
	call GetMonHeader
	ld hl, wMonHMoves
.levelZeroMoveLoop
	ld a, [hl]
	and a
	jp z, .zeroMovesFailsafe
.addToMoveListZero
	inc hl
    inc c ; increment to count moves
    ld [de], a ; write the move ID to the list 
    inc de ; move pointer to the next list slot
    jr .levelZeroMoveLoop ;loop back
    push de ; save the list "cursor" for later

.zeroMovesFailsafe
	ld a, c
    ld [wTransformMoveList], a ; store this for now
    ld b, a
    ld hl, wEnemyMonMoves



.enemyCurrentlearnset    ; the following three blocks add the enemy's current moves into the list if they aren't already in it. this is for cases such as elite four and gym pokemon that know extra moves
    ld a, c              ; TODO: make this an actual loop rather than copy+paste it a bunch of times
    ld b, a
    ld a, [hl]
    and a
    jr z, .finalMoveCount
.checkDoopLoop
	ld de, wTransformMoveList + 1
    ld a, [de]
    cp [hl] ; compare A (enemy move) to the move in the list
    jr z, .enemyCurrentlearnsetTWO ; already exists - next move
    inc de
    dec b
    jr nz, .checkDoopLoop ; there are still moves left. keep looping 
    ; if we get to here, the move is a new one and will be appended
    ld a, [hl]
    ld [de], a
    inc c
.enemyCurrentlearnsetTWO
    inc hl
    ld a, c
    ld b, a
    ld a, [hl]
    and a
    jr z, .finalMoveCount
.checkDoopLoopTWO
	ld de, wTransformMoveList + 1
    ld a, [de]
    cp [hl] ; compare A (enemy move) to the move in the list
    jp z, .enemyCurrentlearnsetTHREE ; already exists - next move
    inc de
    dec b
    jr nz, .checkDoopLoopTWO ; there are still moves left. keep looping 
    ; if we get to here, the move is a new one and will be appended
    ld a, [hl]
    ld [de], a
    inc c
.enemyCurrentlearnsetTHREE
    inc hl
    ld a, c
    ld b, a
    ld a, [hl]
    and a
    jr z, .finalMoveCount
.checkDoopLoopTHREE
	ld de, wTransformMoveList + 1
    ld a, [de]
    cp [hl] ; compare A (enemy move) to the move in the list
    jp z, .enemyCurrentlearnsetFOUR ; already exists - next move
    inc de
    dec b
    jr nz, .checkDoopLoopTHREE ; there are still moves left. keep looping 
    ; if we get to here, the move is a new one and will be appended
    ld a, [hl]
    ld [de], a
    inc c
.enemyCurrentlearnsetFOUR
    inc hl
    ld a, c
    ld b, a
    ld a, [hl]
    and a
    jr z, .finalMoveCount
.checkDoopLoopFOUR
	ld de, wTransformMoveList + 1
    ld a, [de]
    cp [hl] ; compare A (enemy move) to the move in the list
    jp z, .finalMoveCount ; already exists - we're done
    inc de
    dec b
    jr nz, .checkDoopLoopFOUR ; there are still moves left. keep looping 
    ; if we get to here, the move is a new one and will be appended
    ld a, [hl]
    ld [de], a
    inc hl
    inc c
	inc de

.finalMoveCount
	ld de, wTransformMoveList + 1
    ld a, [de]
    jr nz, .finalMoveCount ; ; make sure we're at the end of the movelist
    ld a, c
	;and a
	;jp z, .copymovePP
	cp $04
	jp c, .collectMoves ; if movelist is less than 4, we already have all of them so skip the menu
	dec c
	ld a, c
	ld [wTransformMoveList], a
	ld a, $96 ; put Splash at the bottom. this stops it from glitching and i have no idea why. in the future, change the way the menu draws to chop off the bottom
	ld [de], a
	jp .drawMoveMenus

.collectMoves
	ld b, 0 ; reset b to zero, which makes bc = c (current movelist length)
	ld hl, wTransformMoveList + 1
	ld de, wUnusedD153
	call CopyData ;copy our list of 2 or 3 into the temporary learning array
	jp .fillMoves ; skip the menu because we only have 3 anyway
    
.drawMoveMenus  ; draw the move selection menu 
				; TODO: make all of this this an actual loop rather than copy+paste it a bunch of times
    call SaveScreenTilesToBuffer2 ; saving screen state
	; if I have to, zero $d153-5 
.drawMoveMenuONE
	ld hl, wTransformMoveList
    ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	ld a, MOVESLISTMENU ; move ID list menu
	ld [wListMenuID], a
	call DisplayListMenuID ; call the menu - do i need anything here that stores input? ; ld a, [wCurrentMenuItem]
	jp c, .drawMoveMenuONE ; if the player tried to exit the menu, redraw it
	ld a, [wcf91] ; store selected value (move id) in A
	ld [wUnusedD153], a
.drawMoveMenuTWO
	ld hl, wTransformMoveList
    ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	ld a, MOVESLISTMENU ; special non-item, non-pokemon menu. might need my own type
	ld [wListMenuID], a
	call DisplayListMenuID ; call the menu - do i need anything here that stores input?
	jp c, .drawMoveMenuTWO
    ld a, [wcf91] ; store selected value (move id) in 
	ld hl, wUnusedD153
	cp [hl] ;jp z, .drawMoveMenuTWO
	jp z, .dupeSecond
	ld [wUnusedD154], a ; a wUnusedD153 check to prevent duplicates by comparing
.drawMoveMenuTHREE
	ld hl, wTransformMoveList
    ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	ld a, MOVESLISTMENU ; special non-item, non-pokemon menu. might need my own type
	ld [wListMenuID], a
	call DisplayListMenuID ; call the menu - do i need anything here that stores input?
	jp c, .drawMoveMenuTHREE
	ld a, [wcf91] ; store selected value (move id) in a
	ld hl, wUnusedD153
	cp [hl] ;jp z, .drawMoveMenuTHREE
	jp z, .dupeThird
	ld hl, wUnusedD154
	cp [hl] ;jp z, .drawMoveMenuTHREE
	jp z, .dupeThird
	ld [wUnusedD155], a ; a wUnusedD153-4 check to prevent duplicates by comparing
	call LoadScreenTilesFromBuffer1

.fillMoves   ; this block copies the 3 transformed moves into ditto's moves
	ld hl, wUnusedD153
	ld bc, $3
	ld de, wBattleMonMoves ;ld a, $90 ;ld [de], a
	inc de
	call CopyData

	ld hl, wUnusedD153
	ld a, $00
	ld [hli], a
	ld [hli], a
	ld [hl], a    ; reset chosen move list bytes to zero/ not sure if necessary

	ld hl, wTransformMoveList
	ld a, $00
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a  ; all this does is reset all the move list bytes to 00. not sure if necessary 

.copymovePP
	ld de, wBattleMonPP + 1
	ld bc, wPlayerMoveMaxPP + 1
	ld hl, wBattleMonMoves + 1
	ld b, $03
.copyPPLoop ; copies pp values from the moves pointer table
            ; TODO: make this an actual loop rather than copy+paste it a bunch of times
	ld a, [hli]     ; read move ID
	and a
	jp z, .lessThanFourMoves
	push hl
	push de
	dec a
	ld hl, Moves
	ld bc, MoveEnd - Moves
	call AddNTimes
	ld de, wcd6d
	ld a, BANK(Moves)
	call FarCopyData
	ld a, [wcd6d + 5]
	pop de
	ld [de], a
	inc de
	pop hl
	ld a, [hli]     ; read move ID
	and a
	jp z, .lessThanFourMoves
	push hl
	push de
	dec a
	ld hl, Moves
	ld bc, MoveEnd - Moves
	call AddNTimes
	ld de, wcd6d
	ld a, BANK(Moves)
	call FarCopyData
	ld a, [wcd6d + 5]
	pop de
	ld [de], a
	inc de
	pop hl
	ld a, [hl]     ; read move ID
	and a
	jp z, .lessThanFourMoves
	inc hl
	push hl
	push de
	dec a
	ld hl, Moves
	ld bc, MoveEnd - Moves
	call AddNTimes
	ld de, wcd6d
	ld a, BANK(Moves)
	call FarCopyData
	ld a, [wcd6d + 5]
	pop de
	ld [de], a
	pop hl
	jr .copyStats
.lessThanFourMoves
; 0 PP for blank moves
	xor a
	ld [de], a
	inc de
	inc hl
	ld a, [hl]
	and a
	jr z, .lessThanFourMoves

.copyStats
; original (unmodified) stats and stat mods
	ld hl, wEnemyMonSpecies
	ld a, [hl]
	ld [wd11e], a
	call GetMonName
	ld hl, wEnemyMonUnmodifiedAttack
	ld de, wPlayerMonUnmodifiedAttack
	call .copyBasedOnTurn ; original (unmodified) stats
	ld hl, wEnemyMonStatMods
	ld de, wPlayerMonStatMods
	call .copyBasedOnTurn ; stat mods
	ld hl, TransformedText
	jp PrintText

.copyBasedOnTurn
	ld a, [H_WHOSETURN]
	and a
	jr z, .gotStatsOrModsToCopy
	push hl
	ld h, d
	ld l, e
	pop de
.gotStatsOrModsToCopy
	ld bc, $8
	jp CopyData

.dupeSecond
	ld hl, DupeMoveText
	call PrintText
	jp .drawMoveMenuTWO

.dupeThird
	ld hl, DupeMoveText
	call PrintText
	jp .drawMoveMenuTHREE

.failed
	ld hl, PrintButItFailedText_
	jp BankswitchEtoF


TransformedText:
	TX_FAR _TransformedText
	db "@"

DupeMoveText:
	TX_FAR _DupeMoveText
	db "@"
