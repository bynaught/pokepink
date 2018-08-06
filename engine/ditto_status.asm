IsStarterDittoInOurParty::
	ld hl, wPartySpecies
	ld de, wPartyMon1OTID
	ld bc, wPartyMonOT
	push hl
.loop
	pop hl
	ld a, [hli]
	push hl
	inc a
	jr z, .noPlayerDitto
	cp Ditto + 1
	jr nz, .curMonNotPlayerDitto
	ld h, d
	ld l, e
	ld a, [wPlayerID]
	cp [hl]
	jr nz, .curMonNotPlayerDitto
	inc hl
	ld a, [wPlayerID+1]
	cp [hl]
	jr nz, .curMonNotPlayerDitto
	push de
	push bc
	ld hl, wPlayerName
	ld d, $6 ; possible player length - 1
.nameCompareLoop
	dec d
	jr z, .sameOT
	ld a, [bc]
	inc bc
	cp [hl]
	inc hl
	jr z, .nameCompareLoop
	pop bc
	pop de
.curMonNotPlayerDitto
	ld hl, wPartyMon2 - wPartyMon1
	add hl, de
	ld d, h
	ld e, l
	ld hl, NAME_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	jr .loop

.sameOT
	pop bc
	pop de
	ld h, d
	ld l, e
	ld bc, -NAME_LENGTH
	add hl, bc
	ld a, [hli]
	or [hl]
	jr z, .noPlayerDitto ; XXX how is this determined?
	pop hl
	scf
	ret

.noPlayerDitto
	pop hl
	and a
	ret

IsThisPartymonStarterDitto_Box::
	ld hl, wBoxMon1
	ld bc, wBoxMon2 - wBoxMon1
	ld de, wBoxMonOT
	jr asm_fce21

IsThisPartymonStarterDitto_Party::
IsThisPartymonStarterDitto::
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	ld de, wPartyMonOT
asm_fce21:
	ld a, [wWhichPokemon]
	call AddNTimes
	ld a, [hl]
	cp Ditto
	jr nz, .notPlayerDitto
	ld bc, wPartyMon1OTID - wPartyMon1
	add hl, bc
	ld a, [wPlayerID]
	cp [hl]
	jr nz, .notPlayerDitto
	inc hl
	ld a, [wPlayerID+1]
	cp [hl]
	jr nz, .notPlayerDitto
	ld h, d
	ld l, e
	ld a, [wWhichPokemon]
	ld bc, NAME_LENGTH
	call AddNTimes
	ld de, wPlayerName
	ld b, $6
.loop
	dec b
	jr z, .isPlayerDitto
	ld a, [de]
	inc de
	cp [hl]
	inc hl
	jr z, .loop
.notPlayerDitto
	and a
	ret

.isPlayerDitto
	scf
	ret

UpdateDittoMoodAfterBattle::
; because d is always $82 at this function, it serves to
; ensure Ditto's mood is at least 130 after battle
	push de
	call IsStarterDittoInOurParty
	pop de
	ret nc
	ld a, d
	cp 128
	ld a, [wDittoMood]
	jr c, .d_less_than_128 ; we never jump
	cp d
	jr c, .load_d_into_mood
	ret

.d_less_than_128
	cp d
	ret c
.load_d_into_mood
	ld a, d
	ld [wDittoMood], a
	ret

CheckDittoFaintedOrStatused::
; function to test if Ditto is alive?
	xor a
	ld [wWhichPokemon], a
	ld hl, wPartyCount
.loop
	inc hl
	ld a, [hl]
	cp $ff
	jr z, .dead_or_not_in_party
	push hl
	call IsThisPartymonStarterDitto_Party
	pop hl
	jr nc, .next
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1HP
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld a, [hli]
	or [hl]
	ld d, a
	inc hl
	inc hl
	ld a, [hl] ; status
	and a
	jr nz, .alive
	jr .dead_or_not_in_party

.next
	ld a, [wWhichPokemon]
	inc a
	ld [wWhichPokemon], a
	jr .loop

.alive
	scf
	ret

.dead_or_not_in_party
	and a
	ret

IsSurfingDittoInThePlayersParty::
	ld hl, wPartySpecies
	ld de, wPartyMon1Moves
	ld bc, wPartyMonOT
	push hl
.loop
	pop hl
	ld a, [hli]
	push hl
	inc a
	jr z, .noSurfingPlayerDitto
	cp Ditto+1
	jr nz, .curMonNotSurfingPlayerDitto
	ld h, d
	ld l, e
	push hl
	push bc
	ld b, NUM_MOVES
.moveSearchLoop
	ld a, [hli]
	cp SURF
	jr z, .foundSurfingDitto
	dec b
	jr nz, .moveSearchLoop
	pop bc
	pop hl
	jr .curMonNotSurfingPlayerDitto

.foundSurfingDitto
	pop bc
	pop hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [wPlayerID]
	cp [hl]
	jr nz, .curMonNotSurfingPlayerDitto
	inc hl
	ld a, [wPlayerID+1]
	cp [hl]
	jr nz, .curMonNotSurfingPlayerDitto
	push de
	push bc
	ld hl, wPlayerName
	ld d, $6
.nameCompareLoop
	dec d
	jr z, .foundSurfingPlayerDitto
	ld a, [bc]
	inc bc
	cp [hl]
	inc hl
	jr z, .nameCompareLoop
	pop bc
	pop de
.curMonNotSurfingPlayerDitto
	ld hl, wPartyMon2 - wPartyMon1
	add hl, de
	ld d, h
	ld e, l
	ld hl, NAME_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	jr .loop

.foundSurfingPlayerDitto
	pop bc
	pop de
	pop hl
	scf
	ret

.noSurfingPlayerDitto
	pop hl
	and a
	ret