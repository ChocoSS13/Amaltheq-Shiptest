/datum/component/art
	var/impressiveness = 0

/datum/component/art/Initialize(impress)
	impressiveness = impress
	if(isobj(parent))
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_obj_examine)
	else
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_other_examine)
	if(isstructure(parent))
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/apply_moodlet)

/datum/component/art/proc/apply_moodlet(mob/M, impress)
	SIGNAL_HANDLER

	M.visible_message(
		"<span class='notice'>[M] stops and looks intently at [parent].</span>",
		"<span class='notice'>You stop to take in [parent].</span>"
	)
	switch(impress)
		if (0 to BAD_ART)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artbad", /datum/mood_event/artbad)
		if (BAD_ART to GOOD_ART)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artok", /datum/mood_event/artok)
		if (GOOD_ART to GREAT_ART)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artgood", /datum/mood_event/artgood)
		if(GREAT_ART to INFINITY)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artgreat", /datum/mood_event/artgreat)


/datum/component/art/proc/on_other_examine(datum/source, mob/M)
	SIGNAL_HANDLER

	apply_moodlet(M, impressiveness)

/datum/component/art/proc/on_obj_examine(datum/source, mob/M)
	SIGNAL_HANDLER

	var/obj/O = parent
	apply_moodlet(M, impressiveness *(O.obj_integrity/O.max_integrity))

/datum/component/art/proc/on_attack_hand(datum/source, mob/M)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/examine, source, M)

/datum/component/art/proc/examine(datum/source, mob/M)

	to_chat(M, "<span class='notice'>You start examining [parent]...</span>")
	if(!do_after(M, 20, target = parent))
		return
	on_obj_examine(source, M)
