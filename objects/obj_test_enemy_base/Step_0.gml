// Stationary test dummy: overrides obj_enemy movement so it stays in place.

// Re-arm the encounter only after the player has stepped off this object,
// so finishing a battle doesn't instantly start another one.
if (!can_trigger && !place_meeting(x, y, obj_player)) {
	can_trigger = true;
}
