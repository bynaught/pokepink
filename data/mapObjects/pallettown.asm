PalletTownObject:
	db $b ; border block

	db 3 ; warps
	warp 5, 5, 0, REDS_HOUSE_1F
	warp 13, 5, 0, BLUES_HOUSE
	warp 12, 11, 1, OAKS_LAB

	db 4 ; signs
	sign 13, 13, 6 ; PalletTownText6
	sign 7, 9, 7 ; PalletTownText7
	sign 3, 5, 8 ; PalletTownText8
	sign 11, 5, 9 ; PalletTownText9

	db 5 ; objects
	object SPRITE_OAK, 9, 6, STAY, NONE, 1 ; person
	object SPRITE_GIRL, 3, 8, WALK, 1, 2 ; person
	object SPRITE_FISHER2, 11, 14, WALK, 0, 3 ; person
	object SPRITE_SIGN, 10, 1, STAY, DOWN, 4 ; sign
	object SPRITE_DITTO, 10, 1, STAY, DOWN, 5 ; ditto

	; warp-to
	warp_to 5, 5, PALLET_TOWN_WIDTH ; REDS_HOUSE_1F
	warp_to 13, 5, PALLET_TOWN_WIDTH ; BLUES_HOUSE
	warp_to 12, 11, PALLET_TOWN_WIDTH ; OAKS_LAB
