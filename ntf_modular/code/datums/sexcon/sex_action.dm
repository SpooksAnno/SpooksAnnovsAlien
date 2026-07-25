/datum/sex_action
	var/abstract_type = /datum/sex_action
	var/name = "Zodomize"
	/// Time to do the act, modified by up to 2.5x speed by the speed toggle
	var/do_time = 3.3 SECONDS
	/// Whether the act is continous and will be done on repeat
	var/continous = TRUE
	/// Stamina cost per action, modified by up to 2.5x cost by the force toggle
	var/stamina_cost = 0.5
	/// Whether the action requires both participants to be on the same tile
	var/check_same_tile = FALSE //changing this to false by request, just use it if it really needs to be in same tile -- vide
	/// Whether the action requires the user to be adjacent to their target.
	var/check_proximity = TRUE
	/// Whether the same tile check can be bypassed by an aggro grab on the person
	var/aggro_grab_instead_same_tile = TRUE
	/// Whether the action is forbidden from being done while incapacitated (stun, handcuffed)
	var/check_incapacitated = TRUE
	/// Whether the action requires an aggressive grab on the victim
	var/require_grab = FALSE
	/// If a grab is required, this is the required state of it
	var/required_grab_state = GRAB_AGGRESSIVE
	///determines if it's heal-sex, only partnered sex can heal, masturbation wont work.
	var/heal_sex = TRUE
	/// TGUI button color used when this action is listed in the mob interaction panel.
	var/menu_color = "pink"
	/// Lower values appear earlier in the mob interaction panel.
	var/menu_priority = 50
	/// Anatomy requirements checked by the controller before an action can start.
	var/require_user_penis = FALSE
	var/require_target_penis = FALSE
	var/require_user_vagina = FALSE
	var/require_target_vagina = FALSE
	var/require_user_breasts = FALSE
	var/require_target_breasts = FALSE
	var/require_user_testicles = FALSE
	var/require_target_testicles = FALSE
	var/require_user_tail = FALSE
	var/require_target_tail = FALSE
	/// Whether the matching required anatomy must also be visible/usable through clothing.
	var/require_user_penis_exposed = TRUE
	var/require_target_penis_exposed = TRUE
	var/require_user_vagina_exposed = TRUE
	var/require_target_vagina_exposed = TRUE
	var/require_user_breasts_exposed = TRUE
	var/require_target_breasts_exposed = TRUE
	var/require_user_testicles_exposed = TRUE
	var/require_target_testicles_exposed = TRUE

/datum/sex_action/proc/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	return TRUE

/datum/sex_action/proc/meets_anatomy_requirements(mob/living/carbon/user, mob/living/carbon/target)
	if(require_user_penis && !user.sexcon_has_penis(require_user_penis_exposed))
		return FALSE
	if(require_target_penis && !target.sexcon_has_penis(require_target_penis_exposed))
		return FALSE
	if(require_user_vagina && !user.sexcon_has_vagina(require_user_vagina_exposed))
		return FALSE
	if(require_target_vagina && !target.sexcon_has_vagina(require_target_vagina_exposed))
		return FALSE
	if(require_user_breasts && !user.sexcon_has_breasts(require_user_breasts_exposed))
		return FALSE
	if(require_target_breasts && !target.sexcon_has_breasts(require_target_breasts_exposed))
		return FALSE
	if(require_user_testicles && !user.sexcon_has_testicles(require_user_testicles_exposed))
		return FALSE
	if(require_target_testicles && !target.sexcon_has_testicles(require_target_testicles_exposed))
		return FALSE
	if(require_user_tail && !user.sexcon_has_tail())
		return FALSE
	if(require_target_tail && !target.sexcon_has_tail())
		return FALSE
	return TRUE

/datum/sex_action/proc/is_unavailable_due_to_parts(mob/living/carbon/user, mob/living/carbon/target)
	return !meets_anatomy_requirements(user, target)

/datum/sex_action/proc/on_start(mob/living/carbon/user, mob/living/carbon/target)

/datum/sex_action/proc/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	return

/datum/sex_action/proc/on_finish(mob/living/carbon/user, mob/living/carbon/target)

/datum/sex_action/proc/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	return FALSE

/datum/sex_action/proc/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	return TRUE

/datum/sex_action/proc/can_heal(mob/living/carbon/user, mob/living/carbon/target, mob/living/action_target)
	return heal_sex

/mob/living/proc/sexcon_has_penis(require_exposed = FALSE)
	if(ishuman(src))
		var/mob/living/carbon/human/human = src
		if(!(human.gender == MALE || !!human.cock))
			return FALSE
		return !require_exposed || human.sexcon_part_exposed("cock")
	if(isxeno(src))
		var/mob/living/carbon/xenomorph/xeno = src
		return xeno.client?.prefs?.xenogender >= 3
	return gender == MALE

/mob/living/proc/sexcon_has_vagina(require_exposed = FALSE)
	if(ishuman(src))
		var/mob/living/carbon/human/human = src
		if(!(human.gender == FEMALE || !!human.vagina))
			return FALSE
		return !require_exposed || human.sexcon_part_exposed("vagina")
	if(isxeno(src))
		var/mob/living/carbon/xenomorph/xeno = src
		return xeno.client?.prefs?.xenogender == 2 || xeno.client?.prefs?.xenogender == 4
	return gender == FEMALE

/mob/living/proc/sexcon_has_breasts(require_exposed = FALSE)
	if(ishuman(src))
		var/mob/living/carbon/human/human = src
		if(!(!!human.boobs && human.boobs_size > 0))
			return FALSE
		return !require_exposed || human.sexcon_part_exposed("boobs")
	if(isxeno(src))
		var/mob/living/carbon/xenomorph/xeno = src
		return xeno.client?.prefs?.xenogender == 2 || xeno.client?.prefs?.xenogender == 4
	return gender == FEMALE

/mob/living/proc/sexcon_has_testicles(require_exposed = FALSE)
	if(ishuman(src))
		var/mob/living/carbon/human/human = src
		if(!(!!human.testicles && human.testicles_size > 0))
			return FALSE
		return !require_exposed || human.sexcon_part_exposed("testicles")
	if(isxeno(src))
		var/mob/living/carbon/xenomorph/xeno = src
		return xeno.client?.prefs?.xenogender >= 3
	return gender == MALE

/mob/living/proc/sexcon_has_tail()
	if(ishuman(src))
		var/mob/living/carbon/human/human = src
		return (human.tail && human.tail != "None") || human.has_taur_body()
	return isxeno(src)

/datum/sex_action/vaginal_sex
	require_user_penis = TRUE
	require_target_vagina = TRUE

/datum/sex_action/vaginal_ride_sex
	require_user_vagina = TRUE
	require_target_penis = TRUE

/datum/sex_action/anal_sex
	require_user_penis = TRUE

/datum/sex_action/anal_ride_sex
	require_target_penis = TRUE

/datum/sex_action/throat_sex
	require_user_penis = TRUE

/datum/sex_action/ear_sex
	require_user_penis = TRUE

/datum/sex_action/force_ear_sex
	require_target_penis = TRUE

/datum/sex_action/nipple_sex
	require_user_penis = TRUE
	require_target_breasts = TRUE

/datum/sex_action/force_nipple_sex
	require_user_breasts = TRUE
	require_target_penis = TRUE

/datum/sex_action/blowjob
	require_target_penis = TRUE

/datum/sex_action/force_blowjob
	require_user_penis = TRUE

/datum/sex_action/suck_balls
	require_target_testicles = TRUE

/datum/sex_action/force_suck_balls
	require_user_testicles = TRUE

/datum/sex_action/suck_nipples
	require_target_breasts = TRUE

/datum/sex_action/force_suck_nipples
	require_user_breasts = TRUE

/datum/sex_action/cunnilingus
	require_target_vagina = TRUE

/datum/sex_action/force_cunnilingus
	require_user_vagina = TRUE

/datum/sex_action/crotch_nuzzle
	require_target_vagina = TRUE

/datum/sex_action/force_crotch_nuzzle
	require_user_vagina = TRUE

/datum/sex_action/facesitting
	require_user_vagina = TRUE

/datum/sex_action/facesittingtwo
	require_target_vagina = TRUE

/datum/sex_action/scissoring
	require_user_vagina = TRUE
	require_target_vagina = TRUE

/datum/sex_action/masturbate_vagina
	require_user_vagina = TRUE

/datum/sex_action/masturbate_other_vagina
	require_target_vagina = TRUE

/datum/sex_action/masturbate_penis
	require_user_penis = TRUE

/datum/sex_action/masturbate_penis_over
	require_user_penis = TRUE

/datum/sex_action/masturbate_penis_other
	require_target_penis = TRUE

/datum/sex_action/masturbate_breasts
	require_user_breasts = TRUE

/datum/sex_action/masturbate_other_breasts
	require_target_breasts = TRUE

/datum/sex_action/titjob
	require_user_penis = TRUE
	require_target_breasts = TRUE

/datum/sex_action/thighjob
	require_user_penis = TRUE

/datum/sex_action/force_thighjob
	require_target_penis = TRUE

/datum/sex_action/footjob
	require_target_penis = TRUE

/datum/sex_action/force_footjob
	require_user_penis = TRUE

/datum/sex_action/frotting
	require_user_penis = TRUE
	require_target_penis = TRUE

/datum/sex_action/tailpegging_anal
	require_user_tail = TRUE

/datum/sex_action/tailpegging_vaginal
	require_user_tail = TRUE
	require_target_vagina = TRUE

/datum/sex_action/force_milk_genitals
	require_target_penis = TRUE

/datum/sex_action/force_milk_tits
	require_target_breasts = TRUE
