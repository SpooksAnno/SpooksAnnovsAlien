/datum/action/ability/xenohybrid_psychic_whisper
	name = "Psychic Whisper"
	desc = "Send a message directly to a living target in view."
	action_icon = 'icons/Xeno/actions/shrike.dmi'
	action_icon_state = "psychic_whisper"
	use_state_flags = ABILITY_USE_INCAP|ABILITY_USE_LYING|ABILITY_USE_BUCKLED|ABILITY_USE_STAGGERED|ABILITY_USE_NOTTURF|ABILITY_USE_BUSY|ABILITY_USE_SOLIDOBJECT

/datum/action/ability/xenohybrid_psychic_whisper/action_activate()
	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner)
		return fail_activate()
	if(!can_use_action(FALSE, NONE, FALSE))
		return fail_activate()

	var/list/target_list = list()
	for(var/mob/living/possible_target in view(WORLD_VIEW, human_owner))
		if(possible_target == human_owner || !possible_target.client)
			continue
		target_list += possible_target

	if(!length(target_list))
		to_chat(human_owner, span_warning("There's nobody nearby to whisper to."))
		return fail_activate()

	var/mob/living/target = tgui_input_list(human_owner, "Target", "Send a Psychic Whisper to whom?", target_list)
	if(!target)
		return fail_activate()
	if(!(target in view(WORLD_VIEW, human_owner)))
		to_chat(human_owner, span_warning("[target] is no longer in view."))
		return fail_activate()
	if(human_owner.stat)
		to_chat(human_owner, span_warning("You cannot do this while not conscious."))
		return fail_activate()

	var/msg = tgui_input_text(human_owner, desc, name, "", MAX_MESSAGE_LEN, multiline = TRUE, encode = FALSE)
	msg = copytext_char(trim(sanitize(msg)), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return fail_activate()
	if(human_owner.stat)
		to_chat(human_owner, span_warning("You cannot do this while not conscious."))
		return fail_activate()
	if(!(target in view(WORLD_VIEW, human_owner)))
		to_chat(human_owner, span_warning("[target] is no longer in view."))
		return fail_activate()

	log_directed_talk(human_owner, target, msg, LOG_SAY, "psychic whisper")
	to_chat(target, span_psychicin("You hear a strange, alien voice in your head. <i>\"[msg]\"</i>"))
	to_chat(human_owner, span_psychicout("You said: \"[msg]\" to [target]"))
	message_admins("[human_owner] has sent [target] this psychic message: \"[msg]\" at [ADMIN_VERBOSEJMP(human_owner)].")
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xenohybrid_tail_sting
	name = "Tail Sting"
	action_icon = 'ntf_modular/icons/Xeno/actions.dmi'
	action_icon_state = "tail_attack"
	desc = "Inject a target with your selected toxin. Right click to select toxin and delivery method."
	cooldown_duration = 12 SECONDS
	target_flags = ABILITY_MOB_TARGET
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_BUCKLED|ABILITY_USE_BUSY
	/// Reagent currently loaded for the next sting.
	var/selected_reagent = /datum/reagent/toxin/xeno_neurotoxin
	/// Whether the ability uses a quick tail swing or an uninterrupted bite.
	var/selected_method = "Swing"
	/// Amount of reagent injected on a successful swing.
	var/swing_injection_amount = 5
	/// Amount of reagent injected per bite tick.
	var/bite_injection_amount = XENO_NEURO_AMOUNT_RECURRING
	/// Number of bite ticks if uninterrupted.
	var/bite_injection_count = 4
	/// Time between bite injections.
	var/bite_channel_time = XENO_NEURO_CHANNEL_TIME
	/// Tail stab style reach for the swing method.
	var/swing_range = 2
	/// Tail stab style disorientation for the swing method.
	var/swing_disorient_amount = 2

/datum/action/ability/activable/xenohybrid_tail_sting/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(A))
		if(!silent)
			A.balloon_alert(owner, "Cannot sting")
		return FALSE
	var/mob/living/carbon/human/human_target = A
	if(!human_target.can_sting())
		if(!silent)
			human_target.balloon_alert(owner, "Cannot sting")
		return FALSE
	if(selected_method == "Bite")
		if(!owner.Adjacent(human_target))
			if(!silent)
				human_target.balloon_alert(owner, "Cannot reach")
			return FALSE
		return TRUE
	if(!has_usable_tail())
		if(!silent)
			var/mob/living/carbon/human/human_owner = owner
			human_owner.balloon_alert(human_owner, "No tail")
		return FALSE
	if(get_dist(owner, human_target) > swing_range)
		if(!silent)
			human_target.balloon_alert(owner, "Cannot reach")
		return FALSE
	if(get_dist(owner, human_target) > 1 && get_turf(human_target) != check_path(owner, human_target, PASS_LOW_STRUCTURE|PASS_MOB|PASS_THROW|PASS_PROJECTILE|PASS_WALKOVER|PASS_TANK))
		if(!human_target.pixel_y && !human_target.pixel_x)
			if(!silent)
				human_target.balloon_alert(owner, "Path blocked")
			return FALSE

/datum/action/ability/activable/xenohybrid_tail_sting/use_ability(atom/A)
	var/mob/living/carbon/human/human_owner = owner
	var/mob/living/carbon/human/human_target = A
	if(!human_owner || !human_target)
		return fail_activate()

	if(selected_method == "Bite")
		if(!do_bite_injection(human_target))
			return fail_activate()
	else
		do_swing_injection(human_target)

	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xenohybrid_tail_sting/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_tail_options_radial))
	return COMSIG_KB_ACTIVATED

/datum/action/ability/activable/xenohybrid_tail_sting/proc/do_swing_injection(mob/living/carbon/human/human_target)
	var/mob/living/carbon/human/human_owner = owner
	human_target.reagents.add_reagent(selected_reagent, swing_injection_amount, no_overdose = TRUE)
	human_owner.face_atom(human_target)
	human_owner.do_attack_animation(human_target, ATTACK_EFFECT_REDSTAB)
	human_owner.visible_message(
		span_danger("[human_owner] stings [human_target] with a swift tail swing!"),
		span_danger("You sting [human_target] with a swift tail swing, injecting [get_selected_reagent_name()]!"),
		visible_message_flags = COMBAT_MESSAGE,
	)
	to_chat(human_target, span_danger("You feel a sharp sting as [human_owner]'s tail injects something into you!"))
	playsound(human_target, "alien_tail_swipe", 50, TRUE)
	playsound(human_target, 'sound/effects/spray3.ogg', 20, TRUE)
	human_target.adjust_stagger(swing_disorient_amount SECONDS)
	human_target.add_slowdown(swing_disorient_amount)
	human_target.adjust_blurriness(swing_disorient_amount)
	shake_camera(human_target, 2, 1)

/datum/action/ability/activable/xenohybrid_tail_sting/proc/do_bite_injection(mob/living/carbon/human/human_target)
	var/mob/living/carbon/human/human_owner = owner
	var/list/toxin = list(selected_reagent)
	for(var/chem in toxin)
		toxin[chem] = bite_injection_amount
	var/i = 1
	if(!do_after(human_owner, bite_channel_time, TRUE, human_target, BUSY_ICON_HOSTILE))
		return FALSE
	human_owner.visible_message(
		span_danger("[human_owner] bites into [human_target]!"),
		span_danger("You bite into [human_target], injecting [get_selected_reagent_name()]!"),
		visible_message_flags = COMBAT_MESSAGE,
	)
	to_chat(human_target, span_danger("You feel a sharp bite as [human_owner] injects something into you!"))
	playsound(human_target, "alien_bite", 35, TRUE)
	do
		human_owner.face_atom(human_target)
		human_owner.do_attack_animation(human_target)
		human_target.reagents.add_reagent_list(toxin, bite_injection_amount, no_overdose = TRUE)
		playsound(human_target, 'sound/effects/spray3.ogg', 15, TRUE)
	while(i++ < bite_injection_count && do_after(human_owner, bite_channel_time, TRUE, human_target, BUSY_ICON_HOSTILE))
	return TRUE

/datum/action/ability/activable/xenohybrid_tail_sting/proc/select_tail_options_radial()
	if(!can_use_action(FALSE, NONE, TRUE))
		return
	var/static/list/tail_options_images_list = list(
		"Neurotoxin" = image('icons/Xeno/actions/sentinel.dmi', icon_state = "neuro_sting"),
		"Aphrotoxin" = image('ntf_modular/icons/Xeno/actions.dmi', icon_state = "Aphrotoxin"),
		"Swing" = image('ntf_modular/icons/Xeno/actions.dmi', icon_state = "tail_attack"),
		"Bite" = image('icons/Xeno/actions/general.dmi', icon_state = "headbite"),
	)
	var/choice = show_radial_menu(owner, owner, tail_options_images_list, radius = 48)
	if(!choice)
		return
	switch(choice)
		if("Neurotoxin")
			set_selected_reagent(/datum/reagent/toxin/xeno_neurotoxin)
		if("Aphrotoxin")
			set_selected_reagent(/datum/reagent/toxin/xeno_aphrotoxin)
		if("Swing")
			set_selected_method("Swing")
		if("Bite")
			set_selected_method("Bite")
	var/mob/living/carbon/human/human_owner = owner
	human_owner.balloon_alert(human_owner, "[choice] selected")
	update_button_icon()
	return succeed_activate()

/datum/action/ability/activable/xenohybrid_tail_sting/proc/set_selected_reagent(new_reagent)
	selected_reagent = new_reagent

/datum/action/ability/activable/xenohybrid_tail_sting/proc/set_selected_method(new_method)
	selected_method = new_method
	switch(selected_method)
		if("Bite")
			action_icon = 'icons/Xeno/actions/general.dmi'
			action_icon_state = "headbite"
		else
			action_icon = 'ntf_modular/icons/Xeno/actions.dmi'
			action_icon_state = "tail_attack"

/datum/action/ability/activable/xenohybrid_tail_sting/proc/get_selected_reagent_name()
	switch(selected_reagent)
		if(/datum/reagent/toxin/xeno_aphrotoxin)
			return "Aphrotoxin"
		if(/datum/reagent/toxin/xeno_neurotoxin)
			return "Neurotoxin"
	return "toxin"

/datum/action/ability/activable/xenohybrid_tail_sting/proc/has_usable_tail()
	var/mob/living/carbon/human/human_owner = owner
	return human_owner?.tail && human_owner.tail != "None"
