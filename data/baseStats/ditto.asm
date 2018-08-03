db DEX_DITTO ; pokedex id
db 44 ; base hp
db 44 ; base attack
db 44 ; base defense
db 44 ; base speed
db 44 ; base special, changed all stats from 48 to 44 for S Y M M E T R Y
db NORMAL ; species type 1
db NORMAL ; species type 2
db 35 ; catch rate
db 61 ; base exp yield
INCBIN "pic/bmon/ditto.pic",0,1 ; 55, sprite dimensions
dw DittoPicFront
dw DittoPicBack
; attacks known at lvl 0
db TRANSFORM
db 0
db 0
db 0
db 3 ; growth rate, changed from 0 to 3
; learnset
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
db 0 ; padding
