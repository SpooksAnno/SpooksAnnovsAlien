/datum/sprite_accessory/spines
	icon = 'icons/mob/species/lizard/lizard_spines.dmi'
	var/icon_prefix = "m_spines"
	var/color_src = ACCESSORY_COLOR_BODY
	var/color_count = 1
	var/list/render_layers = list(BODY_OVERLAY_LAYER_ADJ)

/datum/sprite_accessory/spines/none
	name = "None"
	icon_state = null
	render_layers = list()

/datum/sprite_accessory/spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines/short_meme
	name = "Short Meme"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines/long_meme
	name = "Long Meme"
	icon_state = "longmeme"

/datum/sprite_accessory/spines/aquatic
	name = "Aquatic"
	icon_state = "aqua"
	render_layers = list(BODY_OVERLAY_LAYER_BEHIND, BODY_OVERLAY_LAYER_ADJ)
