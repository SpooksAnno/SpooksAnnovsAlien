/obj/item/fishing
	name = "fishing tackle"
	icon = 'icons/obj/items/fishing.dmi'
	icon_state = "worm"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/toys_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/toys_right.dmi',
		)
	force = 0
	w_class = WEIGHT_CLASS_TINY

/obj/item/fishing/reel
	name = "red reel"
	desc = "A reel of red fishing wire."
	icon_state = "reel_red"

/obj/item/fishing/reel/blue
	name = "blue reel"
	desc = "A reel of blue fishing wire."
	icon_state = "reel_blue"

/obj/item/fishing/reel/white
	name = "white reel"
	desc = "A reel of white fishing wire."
	icon_state = "reel_white"

/obj/item/fishing/reel/green
	name = "green reel"
	desc = "A reel of green fishing wire."
	icon_state = "reel_green"

/obj/item/fishing/bait_can
	name = "bait can"
	desc = "What could be inside?"
	icon_state = "bait_can_closed"
	var/bait_left = 6

/obj/item/fishing/bait_can/examine(mob/user)
	. = ..()
	if(bait_left)
		. += span_notice("It has [bait_left] [bait_left == 1 ? "worm" : "worms"] left.")
	else
		. += span_notice("It is empty.")

/obj/item/fishing/bait_can/attack_self(mob/user)
	. = ..()
	if(!bait_left)
		to_chat(user, span_warning("[src] is empty."))
		return
	bait_left--
	new /obj/item/fishing/worm(get_turf(user))
	if(bait_left)
		icon_state = "bait_can_open"
		to_chat(user, span_notice("You take a worm from [src]."))
	else
		icon_state = "bait_can_empty"
		to_chat(user, span_notice("You take the last worm from [src]."))

/obj/item/fishing/bait_can/open
	desc = "Full of worms."
	icon_state = "bait_can_open"

/obj/item/fishing/bait_can/empty
	desc = "Its contents have been emptied."
	icon_state = "bait_can_empty"
	bait_left = 0

/obj/item/fishing/hook
	name = "hook"
	desc = "It's very sharp and pointy at the end."
	icon_state = "hook"

/obj/item/fishing/hook/rescue
	name = "rescue hook"
	desc = "Contains double the hooks for more precision."
	icon_state = "rescue_hook"

/obj/item/fishing/worm
	name = "worm"
	desc = "It's still twitching."
	icon_state = "worm"
	var/bait_quality = 2

/obj/item/fishing/lure
	name = "lure"
	desc = "It's buoyant and has bait attached."
	icon_state = "lure"
	var/bait_quality = 3

/obj/item/fishing/rod
	name = "fishing rod"
	desc = "You can fish with this. Use a worm or lure on it, then click nearby water to cast."
	icon_state = "fishing_rod"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/fishing_rod_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/fishing_rod_righthand.dmi',
	)
	worn_icon_state = "rod"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	force = 8
	w_class = WEIGHT_CLASS_HUGE
	var/baited = FALSE
	var/bait_quality = 0
	var/fishing = FALSE
	var/cast_range = 4
	var/fishing_time = 7 SECONDS
	var/list/fish_table = list(
		/obj/item/fishing/fish = 24,
		/obj/item/fishing/fish/guppy = 24,
		/obj/item/fishing/fish/jelly = 12,
		/obj/item/fishing/fish/puffer = 10,
		/obj/item/fishing/fish/lanternfish = 8,
		/obj/item/fishing/fish/crab = 10,
		/obj/item/fishing/fish/starfish = 8,
		/obj/item/fishing/fish/firefish = 4,
	)
	var/list/junk_table = list(
		/obj/item/fishing/hook = 8,
		/obj/item/fishing/reel = 5,
		/obj/item/stack/rods = 3,
	)

/obj/item/fishing/rod/examine(mob/user)
	. = ..()
	if(baited)
		. += span_notice("It is baited and ready to cast.")
	else
		. += span_notice("It needs bait before it can catch fish.")

/obj/item/fishing/rod/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	var/new_quality = 0
	if(istype(I, /obj/item/fishing/worm))
		var/obj/item/fishing/worm/worm = I
		new_quality = worm.bait_quality
	else if(istype(I, /obj/item/fishing/lure))
		var/obj/item/fishing/lure/lure = I
		new_quality = lure.bait_quality
	else
		return
	if(baited)
		to_chat(user, span_warning("[src] is already baited."))
		return
	baited = TRUE
	bait_quality = new_quality
	to_chat(user, span_notice("You bait [src] with [I]."))
	qdel(I)

/obj/item/fishing/rod/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/turf/cast_turf = get_turf(target)
	if(!cast_turf || !iswater(cast_turf))
		return
	if(fishing)
		to_chat(user, span_warning("You are already fishing."))
		return
	if(!baited)
		to_chat(user, span_warning("You need to bait [src] first."))
		return
	if(get_dist(user, cast_turf) > cast_range)
		to_chat(user, span_warning("That water is too far away to cast into."))
		return
	fish(cast_turf, user)

/obj/item/fishing/rod/proc/fish(turf/open/liquid/water/fishing_spot, mob/user)
	fishing = TRUE
	user.visible_message(span_notice("[user] casts [src] into [fishing_spot]."), span_notice("You cast [src] into [fishing_spot]."))
	if(!do_after(user, fishing_time, TRUE, fishing_spot, BUSY_ICON_GENERIC))
		fishing = FALSE
		to_chat(user, span_warning("You stop fishing."))
		return
	fishing = FALSE
	var/atom/movable/caught_item = roll_catch(user, fishing_spot)
	baited = FALSE
	bait_quality = 0
	if(!caught_item)
		user.visible_message(span_notice("[user] reels [src] back in with nothing on the hook."), span_notice("Nothing bites."))
		return
	user.visible_message(span_notice("[user] reels in [caught_item]!"), span_notice("You caught [caught_item]!"))
	user.put_in_hands(caught_item)

/obj/item/fishing/rod/proc/roll_catch(mob/user, turf/open/liquid/water/fishing_spot)
	var/fish_chance = 45 + (bait_quality * 12)
	if(istype(fishing_spot, /turf/open/liquid/water/sea))
		fish_chance += 10
	else if(istype(fishing_spot, /turf/open/liquid/water/river/deep))
		fish_chance += 5
	if(!prob(fish_chance))
		if(prob(35))
			var/junk_path = pickweight(junk_table)
			return new junk_path(get_turf(user))
		return null
	var/fish_path = pickweight(fish_table)
	return new fish_path(get_turf(user))

/obj/item/fishing/rod/telescopic
	name = "telescopic fishing rod"
	icon_state = "telescopic_fishing_rod"
	cast_range = 6
	fishing_time = 6 SECONDS

/obj/item/fishing/fish
	name = "goldfish"
	desc = "It tastes funny."
	icon_state = "goldfish"
	force = 2
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fishing/fish/guppy
	name = "guppyfish"
	desc = "It tastes weird."
	icon_state = "guppyfish"

/obj/item/fishing/fish/jelly
	name = "jellyfish"
	desc = "This one is slightly transparent."
	icon_state = "jellyfish"

/obj/item/fishing/fish/puffer
	name = "pufferfish"
	desc = "It is permanently swollen."
	icon_state = "pufferfish"

/obj/item/fishing/fish/lanternfish
	name = "lanternfish"
	desc = "Usually found in the depths of the ocean."
	icon_state = "lanternfish"

/obj/item/fishing/fish/crab
	name = "crab"
	desc = "It appears dead."
	icon_state = "crab"

/obj/item/fishing/fish/starfish
	name = "starfish"
	desc = "These ones are found on beaches."
	icon_state = "starfish"

/obj/item/fishing/fish/firefish
	name = "firefish"
	desc = "Has an exotic color."
	icon_state = "firefish"

/obj/item/storage/box/fishing
	name = "fishing tackle box"
	desc = "A compact kit for passing time near water."
	icon_state = "box"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/box/fishing

/obj/item/storage/box/fishing/PopulateContents()
	new /obj/item/fishing/rod/telescopic(src)
	new /obj/item/fishing/bait_can/open(src)
	new /obj/item/fishing/lure(src)
	new /obj/item/fishing/hook(src)
	new /obj/item/fishing/reel/blue(src)

/obj/item/storage/box/fishing/empty
	desc = "A compact box for holding fishing tackle."

/obj/item/storage/box/fishing/empty/PopulateContents()
	return

/datum/storage/box/fishing
	max_w_class = WEIGHT_CLASS_HUGE
	storage_slots = 7
	max_storage_space = 14

/datum/storage/box/fishing/New(atom/parent)
	. = ..()
	set_holdable(list(/obj/item/fishing))

/datum/crafting_recipe/fishing_hook
	name = "Fishing Hook"
	result = /obj/item/fishing/hook
	time = 2 SECONDS
	reqs = list(/obj/item/stack/rods = 1)
	tool_behaviors = list(TOOL_WIRECUTTER)
	category = CAT_TOOLS

/datum/crafting_recipe/fishing_reel
	name = "Fishing Reel"
	result = /obj/item/fishing/reel
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/rods = 1,
	)
	category = CAT_TOOLS

/datum/crafting_recipe/fishing_lure
	name = "Fishing Lure"
	result = /obj/item/fishing/lure
	time = 2 SECONDS
	reqs = list(
		/obj/item/fishing/hook = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/metal = 1,
	)
	tool_behaviors = list(TOOL_WIRECUTTER)
	category = CAT_TOOLS

/datum/crafting_recipe/fishing_rod
	name = "Fishing Rod"
	result = /obj/item/fishing/rod
	time = 5 SECONDS
	reqs = list(
		/obj/item/fishing/hook = 1,
		/obj/item/fishing/reel = 1,
		/obj/item/stack/rods = 2,
		/obj/item/stack/cable_coil = 5,
	)
	category = CAT_TOOLS

/datum/crafting_recipe/fishing_tackle_box
	name = "Fishing Tackle Box"
	result = /obj/item/storage/box/fishing/empty
	time = 3 SECONDS
	reqs = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/stack/sheet/metal = 1,
	)
	category = CAT_CONTAINERS
