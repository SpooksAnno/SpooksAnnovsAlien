/obj/structure/arachnid_web
	name = "sticky web"
	desc = "A thick mat of sticky, freshly spun webbing."
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"
	layer = ABOVE_NORMAL_TURF_LAYER
	anchored = TRUE
	density = FALSE
	obj_flags = CAN_BE_HIT
	resistance_flags = NONE
	max_integrity = 30

/obj/structure/arachnid_web/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(decay)), 10 MINUTES)

/obj/structure/arachnid_web/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/webbed = arrived
	webbed.next_move_slowdown += 3

/obj/structure/arachnid_web/proc/decay()
	qdel(src)

/obj/structure/arachnid_cocoon
	name = "silk cocoon"
	desc = "A thick cocoon spun from sticky silk."
	icon = 'icons/obj/cocoon.dmi'
	icon_state = "xeno_cocoon_unnested"
	density = FALSE
	layer = BELOW_OBJ_LAYER
	anchored = FALSE
	obj_flags = CAN_BE_HIT
	max_integrity = 70
	var/atom/movable/wrapped_atom

/obj/structure/arachnid_cocoon/Initialize(mapload, atom/movable/wrapped)
	. = ..()
	wrapped_atom = wrapped
	if(wrapped_atom)
		wrapped_atom.forceMove(src)

/obj/structure/arachnid_cocoon/Destroy()
	release_wrapped()
	return ..()

/obj/structure/arachnid_cocoon/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	. = ..()
	if(obj_integrity <= 0)
		qdel(src)

/obj/structure/arachnid_cocoon/attack_hand(mob/living/user)
	if(!wrapped_atom)
		return ..()
	user.visible_message(span_notice("[user] starts tearing open [src]."), span_notice("You start tearing open [src]."))
	if(!do_after(user, 8 SECONDS, TRUE, src))
		return
	release_wrapped()
	qdel(src)

/obj/structure/arachnid_cocoon/proc/release_wrapped()
	if(!wrapped_atom)
		return
	wrapped_atom.forceMove(drop_location())
	wrapped_atom = null

/datum/action/ability/spin_web
	name = "Spin Web"
	desc = "Spin a sticky web on your turf, slowing anyone who crosses it."
	action_icon = 'icons/Xeno/actions/widow.dmi'
	action_icon_state = "web_spit"
	cooldown_duration = 20 SECONDS
	use_state_flags = ABILITY_USE_STAGGERED
	var/nutrition_cost = 25
	var/nutrition_threshold = NUTRITION_HUNGRY

/datum/action/ability/spin_web/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(!carbon_owner)
		return FALSE
	if(carbon_owner.nutrition < nutrition_threshold)
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "too hungry!")
		return FALSE
	var/turf/current_turf = get_turf(carbon_owner)
	if(!current_turf)
		return FALSE
	if(locate(/obj/structure/arachnid_web) in current_turf)
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "web already here!")
		return FALSE

/datum/action/ability/spin_web/action_activate()
	var/mob/living/carbon/carbon_owner = owner
	if(!can_use_action())
		return fail_activate()
	var/turf/current_turf = get_turf(carbon_owner)
	carbon_owner.visible_message(span_notice("[carbon_owner] begins spinning silk across the floor."), span_notice("You begin spinning silk across the floor."))
	if(!do_after(carbon_owner, 5 SECONDS, TRUE, current_turf, BUSY_ICON_FRIENDLY))
		carbon_owner.balloon_alert(carbon_owner, "interrupted!")
		return fail_activate()
	if(!can_use_action(TRUE))
		return fail_activate()
	new /obj/structure/arachnid_web(current_turf)
	carbon_owner.adjust_nutrition(-nutrition_cost)
	carbon_owner.visible_message(span_notice("[carbon_owner] finishes spinning a sticky web."), span_notice("You finish spinning a sticky web."))
	succeed_activate()
	add_cooldown()

/datum/action/ability/spin_cocoon
	name = "Spin Cocoon"
	desc = "Prepare silk, then Alt-click an adjacent movable target to cocoon it."
	action_icon = 'icons/Xeno/actions/widow.dmi'
	action_icon_state = "leash_ball"
	cooldown_duration = 30 SECONDS
	use_state_flags = ABILITY_USE_STAGGERED
	var/nutrition_cost = 75
	var/nutrition_threshold = NUTRITION_WELLFED
	var/waiting_for_target = FALSE

/datum/action/ability/spin_cocoon/remove_action(mob/living/L)
	if(waiting_for_target && owner)
		UnregisterSignal(owner, COMSIG_MOB_CLICK_ALT)
	waiting_for_target = FALSE
	return ..()

/datum/action/ability/spin_cocoon/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(!carbon_owner)
		return FALSE
	if(carbon_owner.nutrition < nutrition_threshold)
		if(!silent)
			carbon_owner.balloon_alert(carbon_owner, "too hungry!")
		return FALSE

/datum/action/ability/spin_cocoon/action_activate()
	var/mob/living/carbon/carbon_owner = owner
	if(!can_use_action())
		return fail_activate()
	if(waiting_for_target)
		UnregisterSignal(carbon_owner, COMSIG_MOB_CLICK_ALT)
		waiting_for_target = FALSE
		carbon_owner.balloon_alert(carbon_owner, "canceled")
		return fail_activate()
	RegisterSignal(carbon_owner, COMSIG_MOB_CLICK_ALT, PROC_REF(cocoon_target))
	waiting_for_target = TRUE
	carbon_owner.balloon_alert(carbon_owner, "Alt-click target")
	to_chat(carbon_owner, span_notice("You pull out a strand of silk. Alt-click an adjacent target to cocoon it."))

/datum/action/ability/spin_cocoon/proc/cocoon_target(mob/living/carbon/carbon_owner, atom/movable/target)
	SIGNAL_HANDLER
	UnregisterSignal(carbon_owner, COMSIG_MOB_CLICK_ALT)
	waiting_for_target = FALSE
	if(!target || target == carbon_owner)
		return COMSIG_MOB_CLICK_HANDLED
	if(!carbon_owner.Adjacent(target))
		carbon_owner.balloon_alert(carbon_owner, "too far!")
		return COMSIG_MOB_CLICK_HANDLED
	if(istype(target, /obj/structure/arachnid_cocoon) || istype(target, /obj/effect))
		carbon_owner.balloon_alert(carbon_owner, "can't wrap!")
		return COMSIG_MOB_CLICK_HANDLED
	if(target.anchored && !isliving(target))
		carbon_owner.balloon_alert(carbon_owner, "anchored!")
		return COMSIG_MOB_CLICK_HANDLED
	if(carbon_owner.nutrition < nutrition_cost)
		carbon_owner.balloon_alert(carbon_owner, "too hungry!")
		return COMSIG_MOB_CLICK_HANDLED
	carbon_owner.visible_message(span_danger("[carbon_owner] starts wrapping [target] in silk!"), span_warning("You start wrapping [target] in silk."))
	if(!do_after(carbon_owner, 10 SECONDS, TRUE, target, BUSY_ICON_HOSTILE))
		carbon_owner.balloon_alert(carbon_owner, "interrupted!")
		return COMSIG_MOB_CLICK_HANDLED
	if(QDELETED(target) || !carbon_owner.Adjacent(target))
		return COMSIG_MOB_CLICK_HANDLED
	new /obj/structure/arachnid_cocoon(get_turf(target), target)
	carbon_owner.adjust_nutrition(-nutrition_cost)
	carbon_owner.visible_message(span_danger("[carbon_owner] wraps [target] into a silk cocoon!"), span_notice("You wrap [target] into a silk cocoon."))
	succeed_activate()
	add_cooldown()
	return COMSIG_MOB_CLICK_HANDLED
