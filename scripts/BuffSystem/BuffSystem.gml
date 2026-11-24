/// @desc Buff engine: passives, wards, resist / weakness / immunity. Definitions live in global.buffLibrary.
///
/// DEFINITION  (global.buffLibrary[$ key]) - a read-only template, never modified at runtime:
///   name           display name (popup + debug tab)
///   duration       turns of the OWNER's own turns, or BUFF_PERMANENT (-1)
///   endsWithSource true  = removed when the unit that applied it dies
///   resist         Resist(TAG_X, mult, ...)   mult < 1 resists, mult > 1 is a weakness (never 0)
///   immuneTags     [TAG_X, ...]      damage with this tag is nullified
///   statusImmune   [STATUS_X, ...]   status effect is refused
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
	if (!variable_instance_exists(_unit, "passives")) _unit.passives = [];

	for (var i = 0; i < array_length(_unit.passives); i++) {
		BuffApply(_unit, _unit.passives[i], _unit, BUFF_PERMANENT, true);
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

	if (!is_undefined(_inst)) {
		_inst.turnsLeft = _dur; // refresh, no stacking of identical buffs
	} else {
		_inst = { key: _key, def: _def, source: _source, owner: _target, turnsLeft: _dur, removed: false };
		array_push(_target.buffs, _inst);
		BuffCall(_inst, "onApply");
	}

	if (!_silent) BattleFloatText(_target, _def.name + "!", c_aqua);
	return _inst;
}

/// @func BuffRemove(inst)
function BuffRemove(_inst) {
	if (_inst.removed) return;
	_inst.removed = true;
	BuffCall(_inst, "onRemove");
	var _owner = _inst.owner;
	if (instance_exists(_owner) && variable_instance_exists(_owner, "buffs")) {
		var _i = array_get_index(_owner.buffs, _inst);
		if (_i >= 0) array_delete(_owner.buffs, _i, 1);
	}
}

/// @func BuffTurnStart(unit)
function BuffTurnStart(_unit) {
	if (!variable_instance_exists(_unit, "buffs")) return;
	var _list = array_concat(_unit.buffs, []);
	for (var i = 0; i < array_length(_list); i++) {
		if (!_list[i].removed) BuffCall(_list[i], "onTurnStart");
	}
}

/// @func BuffTurnEnd(unit)
/// Runs onTurnEnd, then counts the duration down. Permanent buffs (turnsLeft < 0) never expire.
function BuffTurnEnd(_unit) {
	if (!variable_instance_exists(_unit, "buffs")) return;
	var _list = array_concat(_unit.buffs, []);
	for (var i = 0; i < array_length(_list); i++) {
		var _b = _list[i];
		if (_b.removed) continue;
		BuffCall(_b, "onTurnEnd");
		if (_b.turnsLeft > 0) {
			_b.turnsLeft--;
			if (_b.turnsLeft <= 0) BuffRemove(_b);
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
			if (_s != noone && (!instance_exists(_s) || _s.hp <= 0)) BuffRemove(_b);
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
	if (variable_instance_exists(_unit, "buffs")) {
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
	if (variable_instance_exists(_unit, "buffs")) {
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
	if (variable_instance_exists(_unit, "buffs")) {
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
