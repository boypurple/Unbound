/// @desc Buff engine: passives, wards, resist / weakness / immunity. Definitions live in global.buffLibrary.
///
/// DEFINITION  (global.buffLibrary[$ key]) - a read-only template, never modified at runtime:
///   name           display name (popup + debug tab)
///   duration       turns of the OWNER's own turns, or BUFF_PERMANENT (-1)
///   endsWithSource true  = removed when the unit that applied it dies
///   resist         Resist(TAG_X, mult, ...)   mult < 1 resists, mult > 1 is a weakness (never 0)
///   immuneTags     [TAG_X, ...]      damage with this tag is nullified
///   statusImmune   [STATUS_X, ...]   status effect is refused
///   stats          { strength: 1.2, def: 0.8, ... }  stat multipliers while the buff is active.
///                  The stat is recalculated as  unbuffed value x every active multiplier
///                  (see BuffRefreshStats), so stacking and removal stay exact.
///   hooks (all optional): onApply(inst), onRemove(inst), onTurnStart(inst), onTurnEnd(inst)
///
/// INSTANCE (unit.buffs[]) - one running copy: { key, def, source, owner, turnsLeft, removed }
///
/// A PASSIVE is simply a permanent buff the unit applies to itself when the battle starts.

/// @func Resist(tag, mult, [tag, mult, ...])
/// Builds a { tag: mult } map. Using the TAG_ macros here means a typo is a compile error.
function Resist() {
	var _map = {};
	for (var i = 0; i + 1 < argument_count; i += 2) {
		variable_struct_set(_map, argument[i], argument[i + 1]);
	}
	return _map;
}

global.buffLibrary =
{
	// ====================== PASSIVES (permanent, applied to self at battle start) ======================
	passive_stench_resist:
	{
		name: "Stench Hide",
		duration: BUFF_PERMANENT,
		endsWithSource: false,
		resist: Resist(TAG_STENCH, 0.5)
	},
	passive_nuke_resist:
	{
		name: "Nuke Plating",
		duration: BUFF_PERMANENT,
		endsWithSource: false,
		resist: Resist(TAG_NUKE, 0.5)
	},
	passive_lightning_weak:
	{
		name: "Conductive Body",
		duration: BUFF_PERMANENT,
		endsWithSource: false,
		resist: Resist(TAG_LIGHTNING, 1.5)
	},
	passive_stench_immune:
	{
		name: "Stench Proof",
		duration: BUFF_PERMANENT,
		endsWithSource: false,
		immuneTags: [TAG_STENCH],
		statusImmune: [STATUS_STUN]
	},
	passive_poison_immune:
	{
		name: "Poison Proof",
		duration: BUFF_PERMANENT,
		endsWithSource: false,
		immuneTags: [TAG_POISON],
		statusImmune: [STATUS_POISON]
	},

	// ====================== WARDS (given by support enemies, end if the giver dies) ======================
	ward_stench:
	{
		name: "Stench Ward",
		duration: 3,
		endsWithSource: true,
		resist: Resist(TAG_STENCH, 0.3)
	},
	ward_nuke:
	{
		name: "Nuke Ward",
		duration: 3,
		endsWithSource: true,
		resist: Resist(TAG_NUKE, 0.3)
	},
	ward_lightning:
	{
		name: "Lightning Ward",
		duration: 3,
		endsWithSource: true,
		resist: Resist(TAG_LIGHTNING, 0.3)
	},

	// ====================== STAT BUFFS / DEBUFFS (Offense Up / Defense Down skills) ======================
	// The same buff from different casters stacks (multiplies); from the same caster it only refreshes.
	offense_up:
	{
		name: "Offense Up",
		duration: 3,
		endsWithSource: false,
		stats: { strength: 1.2 }
	},
	defense_down:
	{
		name: "Defense Down",
		duration: 3,
		endsWithSource: false,
		stats: { def: 0.8 } // def is the dodge chance, so the target dodges less
	}

	// Example of a buff that uses hooks (not registered, for reference):
	// regen_mist:
	// {
	//     name: "Regen Mist", duration: 3, endsWithSource: false,
	//     onTurnStart: function(_inst) { BattleChangeHP(_inst.owner, 5); }
	// }
};

// =========================================================================
// ENGINE
// =========================================================================

/// @func BuffCall(inst, hookName)
/// Runs an optional hook of the buff definition (the GML equivalent of a virtual method).
function BuffCall(_inst, _hook) {
	var _fn = _inst.def[$ _hook];
	if (is_callable(_fn)) _fn(_inst);
}

/// @func BuffInitUnit(unit)
/// Call once per battle unit right after it is created. Clones the data that would otherwise be
/// shared by reference with global.enemies / global.party templates, then applies the passives.
function BuffInitUnit(_unit) {
	_unit.resist       = variable_instance_exists(_unit, "resist")       ? variable_clone(_unit.resist)       : {};
	_unit.immuneTags   = variable_instance_exists(_unit, "immuneTags")   ? variable_clone(_unit.immuneTags)   : [];
	_unit.statusImmune = variable_instance_exists(_unit, "statusImmune") ? variable_clone(_unit.statusImmune) : [];
	_unit.buffs        = [];
	_unit.buffStatMult = {}; // stat -> multiplier currently applied by buffs (see BuffRefreshStats)
	if (!variable_instance_exists(_unit, "passives")) _unit.passives = [];

	for (var i = 0; i < array_length(_unit.passives); i++) {
		var _p = BuffApply(_unit, _unit.passives[i], _unit, BUFF_PERMANENT, true);
		if (!is_undefined(_p)) _p.isPassive = true; // passives survive death (see BuffClearOnDeath)
	}
}

/// @func BuffGet(unit, key)
/// Returns the running instance of a buff (or undefined).
function BuffGet(_unit, _key) {
	if (!variable_instance_exists(_unit, "buffs")) return undefined;
	for (var i = 0; i < array_length(_unit.buffs); i++) {
		if (_unit.buffs[i].key == _key) return _unit.buffs[i];
	}
	return undefined;
}

/// @func BuffHas(unit, key)
function BuffHas(_unit, _key) {
	return !is_undefined(BuffGet(_unit, _key));
}

/// @func BuffApply(target, key, [source], [duration], [silent])
/// Adds a buff. Re-applying the same buff from the same source only refreshes its duration.
/// Durations count the OWNER's own turns. If the owner is the unit acting right now, one extra
/// turn is added because that turn's end-of-turn tick has not happened yet.
/// Returns the buff instance, or undefined when the key does not exist.
function BuffApply(_target, _key, _source = noone, _duration = undefined, _silent = false) {
	var _def = global.buffLibrary[$ _key];
	if (is_undefined(_def)) {
		show_debug_message("[Buff] Unknown buff key: " + string(_key));
		return undefined;
	}

	var _dur = is_undefined(_duration) ? _def.duration : _duration;
	if (_dur > 0 && instance_exists(oBattle)) {
		var _order = oBattle.unitTurnOrder;
		if (oBattle.turn < array_length(_order) && _order[oBattle.turn] == _target) _dur += 1;
	}

	var _inst = undefined;
	for (var i = 0; i < array_length(_target.buffs); i++) {
		if (_target.buffs[i].key == _key && _target.buffs[i].source == _source) { _inst = _target.buffs[i]; break; }
	}

	var _isNew = is_undefined(_inst);
	if (!_isNew) {
		_inst.turnsLeft = _dur; // refresh, no stacking of identical buffs from the same source
	} else {
		_inst = { key: _key, def: _def, source: _source, owner: _target, turnsLeft: _dur, removed: false, isPassive: false };
		array_push(_target.buffs, _inst);
		BuffCall(_inst, "onApply");
	}

	BattleLog(BattleUnitName(_target) + " | +" + _def.name + " from " + BattleUnitName(_source)
		+ " (" + (_dur < 0 ? "permanent" : string(_dur) + " turns") + (_def[$ "endsWithSource"] == true ? ", ends with source" : "")
		+ (_isNew ? "" : ", refreshed") + ")");
	if (_isNew) BuffRefreshStats(_target); // a refresh does not change the multipliers
	if (!_silent) BattleFloatText(_target, _def.name + "!", c_aqua);
	return _inst;
}

/// @func BuffRemove(inst, [reason])
/// `reason` is only used by the debug log (expired, source died, owner died...).
function BuffRemove(_inst, _reason = "removed") {
	if (_inst.removed) return;
	_inst.removed = true;
	BattleLog(BattleUnitName(_inst.owner) + " | -" + _inst.def.name + " (" + _reason + ")");
	BuffCall(_inst, "onRemove");
	var _owner = _inst.owner;
	if (instance_exists(_owner) && variable_instance_exists(_owner, "buffs")) {
		var _i = array_get_index(_owner.buffs, _inst);
		if (_i >= 0) array_delete(_owner.buffs, _i, 1);
		BuffRefreshStats(_owner); // undo this buff's stat multipliers
	}
}

/// @func BuffRemoveAll(unit, [reason])
/// Removes every buff, passives included (undoing their stat changes). Used when the battle ends,
/// so nothing a buff did is written back to global.party.
function BuffRemoveAll(_unit, _reason = "battle ended") {
	if (!variable_instance_exists(_unit, "buffs")) return;
	var _list = array_concat(_unit.buffs, []);
	for (var i = 0; i < array_length(_list); i++) BuffRemove(_list[i], _reason);
}

/// @func BuffRefreshStats(unit)
/// Recalculates every stat that buffs modify:  stat = unbuffed value x product of all active multipliers.
/// unit.buffStatMult remembers the multiplier currently baked into each stat, so the unbuffed value is
/// stat / old multiplier. Changes made by other code (level up, All For One...) stay in the unbuffed part.
/// Called after a buff is added or removed.
function BuffRefreshStats(_unit) {
	if (!instance_exists(_unit) || !variable_instance_exists(_unit, "buffs")) return;
	if (!variable_instance_exists(_unit, "buffStatMult")) _unit.buffStatMult = {};

	// Wanted multiplier per stat, from every active buff
	var _want = {};
	for (var i = 0; i < array_length(_unit.buffs); i++) {
		var _s = _unit.buffs[i].def[$ "stats"];
		if (!is_struct(_s)) continue;
		var _names = variable_struct_get_names(_s);
		for (var n = 0; n < array_length(_names); n++) {
			_want[$ _names[n]] = (_want[$ _names[n]] ?? 1) * _s[$ _names[n]];
		}
	}

	// Every stat that has a multiplier now, or had one before
	var _stats = variable_struct_get_names(_want);
	var _old = variable_struct_get_names(_unit.buffStatMult);
	for (var i = 0; i < array_length(_old); i++) {
		if (!array_contains(_stats, _old[i])) array_push(_stats, _old[i]);
	}

	for (var i = 0; i < array_length(_stats); i++) {
		var _stat = _stats[i];
		if (!variable_instance_exists(_unit, _stat)) continue;
		var _oldMult = _unit.buffStatMult[$ _stat] ?? 1;
		var _newMult = _want[$ _stat] ?? 1;
		if (_oldMult == _newMult) continue;
		var _before = variable_instance_get(_unit, _stat);
		var _after = round((_before / _oldMult) * _newMult * 10000) / 10000; // trims float noise
		variable_instance_set(_unit, _stat, _after);
		BattleLog(BattleUnitName(_unit) + " | " + _stat + " " + string_format(_before, 1, 2) + "->" + string_format(_after, 1, 2)
			+ " (buff x" + string_format(_newMult, 1, 2) + ")");
	}
	_unit.buffStatMult = _want;
}

/// @func BuffOwnerAlive(unit)
/// Buffs (passives included) only take effect while their owner is alive. A dead unit keeps its
/// passives attached, so they work again after a revive, but they do nothing while it is dead.
function BuffOwnerAlive(_unit) {
	return !variable_instance_exists(_unit, "hp") || _unit.hp > 0;
}

/// @func BuffClearOnDeath(unit)
/// Removes every buff except passives (runs onRemove hooks). Called by BattleClearOnDeath.
/// Returns how many buffs were removed.
function BuffClearOnDeath(_unit) {
	if (!variable_instance_exists(_unit, "buffs")) return 0;
	var _count = 0;
	var _list = array_concat(_unit.buffs, []);
	for (var i = 0; i < array_length(_list); i++) {
		if (!_list[i].isPassive) { BuffRemove(_list[i], "owner died"); _count++; }
	}
	return _count;
}

/// @func BuffTurnStart(unit)
function BuffTurnStart(_unit) {
	if (!variable_instance_exists(_unit, "buffs") || !BuffOwnerAlive(_unit)) return;
	var _list = array_concat(_unit.buffs, []);
	for (var i = 0; i < array_length(_list); i++) {
		if (!_list[i].removed) BuffCall(_list[i], "onTurnStart");
	}
}

/// @func BuffTurnEnd(unit)
/// Runs onTurnEnd, then counts the duration down. Permanent buffs (turnsLeft < 0) never expire.
function BuffTurnEnd(_unit) {
	if (!variable_instance_exists(_unit, "buffs") || !BuffOwnerAlive(_unit)) return;
	var _list = array_concat(_unit.buffs, []);
	for (var i = 0; i < array_length(_list); i++) {
		var _b = _list[i];
		if (_b.removed) continue;
		BuffCall(_b, "onTurnEnd");
		if (_b.turnsLeft > 0) {
			_b.turnsLeft--;
			if (_b.turnsLeft <= 0) BuffRemove(_b, "expired");
		}
	}
}

/// @func BuffCleanupDeadSources()
/// Removes every endsWithSource buff whose giver is dead. Called after each action.
function BuffCleanupDeadSources() {
	if (!instance_exists(oBattle)) return;
	for (var u = 0; u < array_length(oBattle.units); u++) {
		var _unit = oBattle.units[u];
		if (!instance_exists(_unit) || !variable_instance_exists(_unit, "buffs")) continue;
		var _list = array_concat(_unit.buffs, []);
		for (var i = 0; i < array_length(_list); i++) {
			var _b = _list[i];
			if (_b.removed || _b.def[$ "endsWithSource"] != true) continue;
			var _s = _b.source;
			if (_s != noone && (!instance_exists(_s) || _s.hp <= 0)) BuffRemove(_b, "source " + BattleUnitName(_s) + " died");
		}
	}
}

// =========================================================================
// QUERIES (base value on the unit  x  every active buff; stacking multiplies)
// =========================================================================

/// @func BuffGetResistMult(unit, tag)  -> 1 = normal, <1 resist, >1 weakness
function BuffGetResistMult(_unit, _tag) {
	var _mult = 1;
	if (variable_instance_exists(_unit, "resist") && is_struct(_unit.resist)) {
		var _base = _unit.resist[$ _tag];
		if (!is_undefined(_base)) _mult *= _base;
	}
	if (variable_instance_exists(_unit, "buffs") && BuffOwnerAlive(_unit)) {
		for (var i = 0; i < array_length(_unit.buffs); i++) {
			var _r = _unit.buffs[i].def[$ "resist"];
			if (is_struct(_r)) {
				var _v = _r[$ _tag];
				if (!is_undefined(_v)) _mult *= _v;
			}
		}
	}
	return _mult;
}

/// @func BuffIsTagImmune(unit, tag)
function BuffIsTagImmune(_unit, _tag) {
	if (variable_instance_exists(_unit, "immuneTags") && array_contains(_unit.immuneTags, _tag)) return true;
	if (variable_instance_exists(_unit, "buffs") && BuffOwnerAlive(_unit)) {
		for (var i = 0; i < array_length(_unit.buffs); i++) {
			var _list = _unit.buffs[i].def[$ "immuneTags"];
			if (is_array(_list) && array_contains(_list, _tag)) return true;
		}
	}
	return false;
}

/// @func BuffIsStatusImmune(unit, status)
function BuffIsStatusImmune(_unit, _status) {
	if (variable_instance_exists(_unit, "statusImmune") && array_contains(_unit.statusImmune, _status)) return true;
	if (variable_instance_exists(_unit, "buffs") && BuffOwnerAlive(_unit)) {
		for (var i = 0; i < array_length(_unit.buffs); i++) {
			var _list = _unit.buffs[i].def[$ "statusImmune"];
			if (is_array(_list) && array_contains(_list, _status)) return true;
		}
	}
	return false;
}

// =========================================================================
// SUPPORT ACTION FACTORY (an active skill whose only job is to apply a buff)
// =========================================================================

/// @func EnemyBuffAction(name, description, buffKey)
/// Builds an actionLibrary-style action that applies global.buffLibrary[buffKey] to the chosen ally.
function EnemyBuffAction(_name, _description, _buffKey) {
	return {
		name: _name,
		swappable: false,
		description: _description,
		subMenu: -1,
		useOverwold: false,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		buffKey: _buffKey,
		func: function(_user, _targets)
		{
			BuffApply(_targets[0], buffKey, _user);
		}
	};
}
