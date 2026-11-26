/// @desc Damage tags, status names and damage-text colors used by the resist/immunity/buff system.
/// Macros are resolved at compile time, so a typo is a compile error (not a silent new tag)
/// and load order never matters.

// ---- Damage tags: put these in an action's `tags: [...]` ----
#macro TAG_PHYSICAL  "physical"
#macro TAG_STENCH    "stench"
#macro TAG_NUKE      "nuke"
#macro TAG_LIGHTNING "lightning"
#macro TAG_POISON    "poison"
#macro TAG_NOCTURNE  "nocturne"
#macro TAG_MAGIC     "magic"

// ---- Status names: used by BattleApplyStatus() and the `statusImmune` lists ----
#macro STATUS_STUN   "stun"
#macro STATUS_BLIND  "blind"
#macro STATUS_SLEEP  "sleep"
#macro STATUS_POISON "poison"

// ---- Damage text colors (white = normal, lime = heal, yellow/aqua are already used for status text) ----
#macro DMG_COLOR_WEAK   c_orange
#macro DMG_COLOR_RESIST c_gray

// ---- Debug log: true = BattleLog() writes "[Battle] ..." lines to the Output window ----
#macro DEBUG_BATTLE_LOG false

// ---- Buff durations ----
#macro BUFF_PERMANENT -1   // never expires (passives)

/// @func BattleLog(text)
/// Debug line for the resist / immunity / buff system. Does nothing when DEBUG_BATTLE_LOG is false.
function BattleLog(_text) {
	if (DEBUG_BATTLE_LOG) show_debug_message("[Battle] " + _text);
}

/// @func BattleUnitName(unit)
/// Safe display name for log lines (handles noone / destroyed instances).
function BattleUnitName(_unit) {
	// -1 is "no target" (MenuFunctions passes it). It must be checked before instance_exists,
	// because -1 means `self` there and would print the calling object (oBattle).
	if (is_undefined(_unit) || _unit == noone || _unit == -1 || !instance_exists(_unit)) return "-";
	return variable_instance_exists(_unit, "name") ? string(_unit.name) : object_get_name(_unit.object_index);
}

/// @func BattleAllTags()
/// Every damage tag, in display order (used by the debug resist tab).
function BattleAllTags() {
	return [TAG_PHYSICAL, TAG_STENCH, TAG_NUKE, TAG_LIGHTNING, TAG_POISON, TAG_NOCTURNE, TAG_MAGIC];
}
