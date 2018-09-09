ProtectEffect_:
    ; this isn't a perfect implementation of Protect but i think it's good enough
    ; sets the invulnerable flag for a turn
    ; checks if protect has been used last turn
    ; if so, checks how many turns it has been used consecutively
    ; each consecutive turn, probability of success halves
    ; beyond 5 turns, guaranteed fail
	ld de, wPlayerBattleStatus1
    ld hl, wPlayerMoveHistory
	ld a, [H_WHOSETURN]
	and a
	jr z, .notEnemy
    ld de, wEnemyBattleStatus1
    ld hl, wEnemyMoveHistory
.notEnemy
    ld a, [hl]
    ld b, a
    ld a, $a6 ; was protect used last turn?
    cp b
    jr nz, .success ; it wasnt so 100% success
    ld c, 0
.historyLoop
    ; all of this works but it is TERRIBLY inefficient
    ; TODO: recode this to rotate/shift in such a way that it counts up (or down, by halving) the compare number, then call battlerandom once?
    inc c
    ld a, c
    cp 5
    jr z, .fiveice
    ld a, [hli]
    cp b 
    jr z, .historyLoop ; there are still moves left. keep looping 
    ; if we get to here, the move is a new one and will be appended
    ld a, c
    cp 4
    jr z, .fourice
    cp 3
    jr z, .thrice
    cp 2
    jr z, .twice
.once
    call BattleRandom ; if protect was used previously, produce a random number from 0-255
    cp $80 ; compare to 10000000 (50% chance)
    jr c, .success
    jr .failed
.twice
    call BattleRandom ; if protect was used previously, produce a random number from 0-255
    cp $c0 ; compare to 11000000 (25% chance)
    jr c, .success
    jr .failed
.thrice
    call BattleRandom ; if protect was used previously, produce a random number from 0-255
    cp $e0 ; compare to 11100000 (12.5% chance)
    jr c, .success
    jr .failed
.fourice
    call BattleRandom ; if protect was used previously, produce a random number from 0-255
    cp $f0 ; compare to 11110000 (6.25% chance)
    jr c, .success
    jr .failed
.fiveice
    call BattleRandom ; if protect was used previously, produce a random number from 0-255
    cp $f8 ; compare to 1111100 (3.125% chance)
    jr c, .success
    jr .failed
.failed
	ld hl, PrintButItFailedText_
	jp BankswitchEtoF
.success
    callab PlayCurrentMoveAnimation ; add for enemy turn using WHOSTURN
	ld hl, wPlayerBattleStatus1
    set INVULNERABLE, [hl] 
    ld hl, ProtectText ; change this
.printText
	jp PrintText

ProtectText:
	TX_FAR _ProtectText
	db "@"
