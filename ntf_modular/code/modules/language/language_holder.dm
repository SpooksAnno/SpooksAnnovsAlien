/datum/language_holder
	shadow_languages = list(/datum/language/telepathy)

/datum/language_holder/empty
	shadow_languages = list(/datum/language/telepathy)

/datum/language_holder/xeno
	languages = list(/datum/language/xenocommon, /datum/language/telepathy)

/datum/language_holder/xeno/hybrid
	languages = list(/datum/language/common, /datum/language/xenocommon, /datum/language/telepathy)

/datum/language_holder/xeno/puppet
	languages = list(/datum/language/xenocommon, /datum/language/common, /datum/language/telepathy)
	shadow_languages = list(/datum/language/moth)

/datum/language_holder/synthetic
	shadow_languages = list(/datum/language/xenocommon, /datum/language/telepathy) // psychic whisper works on them and telepathy is basically the same

/datum/language_holder/robot
	shadow_languages = list(/datum/language/telepathy) // psychic whisper works on them and telepathy is basically the same
