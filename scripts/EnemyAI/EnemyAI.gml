/// @desc Modular Enemy AI Engine & Behaviors

/// @func EnemyAIRunBehaviors()
/// Core evaluator: iterates through the calling unit's behaviors array.
/// Returns [_action, _targets] from the first behavior that triggers,
/// or falls back to basic attack.
function EnemyAIRunBehaviors() {
	var _unit = self;
	if (!variable_instance_exists(_unit, "behaviors") || !is_array(_unit.behaviors)) {
		return [_unit.actions[0], EnemyAIGetRandomPartyTarget(_unit)];
	}
	
	for (var i = 0; i < array_length(_unit.behaviors); i++) {
		var _behavior = _unit.behaviors[i];
		var _decision = _behavior(_unit);
		if (is_array(_decision) && array_length(_decision) >= 2 && is_struct(_decision[0])) {
			return _decision;
		}
		if (is_array(_decision)) {
			show_debug_message("[EnemyAI] Behavior " + string(i) + " on " + string(_unit.name) + " returned a non-struct action: " + string(_decision[0]));
		}
	}
	
	// Fallback to basic attack if no conditional behavior triggered
	return [_unit.actions[0], EnemyAIGetRandomPartyTarget(_unit)];
}

/// @func ComposeAI(behaviors)
/// Helper to assign to AIscript on an enemy struct or unit.
function ComposeAI(_behaviors) {
	return EnemyAIRunBehaviors;
}

// =========================================================================
// AI TARGETING HELPERS
// =========================================================================

/// @func EnemyAIGetAliveParty()
function EnemyAIGetAliveParty() {
	if (!instance_exists(oBattle)) return [];
	return array_filter(oBattle.partyUnits, function(_u) {
		return instance_exists(_u) && (_u.hp > 0);
	});
}

/// @func EnemyAIGetAliveEnemies()
function EnemyAIGetAliveEnemies() {
	if (!instance_exists(oBattle)) return [];
	return array_filter(oBattle.enemyUnits, function(_u) {
		return instance_exists(_u) && (_u.hp > 0);
	});
}

/// @func EnemyAIGetRandomPartyTarget(_user)
function EnemyAIGetRandomPartyTarget(_user = noone) {
	// If unit has mutatedHand, random chance to target an ally instead
	if (_user != noone && variable_instance_exists(_user, "mutatedHand") && _user.mutatedHand) {
		if (irandom(2) > 1) {
			var _allies = EnemyAIGetAliveEnemies();
			if (array_length(_allies) > 0) {
				return _allies[irandom(array_length(_allies) - 1)];
			}
		}
	}
	var _party = EnemyAIGetAliveParty();
	if (array_length(_party) == 0) return noone;
	return _party[irandom(array_length(_party) - 1)];
}

/// @func EnemyAIGetLowestHPPartyTarget()
function EnemyAIGetLowestHPPartyTarget() {
	var _party = EnemyAIGetAliveParty();
	if (array_length(_party) == 0) return noone;
	var _lowest = _party[0];
	for (var i = 1; i < array_length(_party); i++) {
		if (_party[i].hp < _lowest.hp) {
			_lowest = _party[i];
		}
	}
	return _lowest;
}

/// @func EnemyAIGetLowestHPAllyTarget(_threshold)
function EnemyAIGetLowestHPAllyTarget(_threshold = 0.5) {
	var _allies = EnemyAIGetAliveEnemies();
	if (array_length(_allies) == 0) return noone;
	var _lowest = noone;
	var _lowestRatio = 1.0;
	for (var i = 0; i < array_length(_allies); i++) {
		var _ally = _allies[i];
		var _ratio = _ally.hp / max(1, _ally.hpMax);
		if (_ratio <= _threshold && _ratio < _lowestRatio) {
			_lowestRatio = _ratio;
			_lowest = _ally;
		}
	}
	return _lowest;
}

// =========================================================================
// MODULAR BEHAVIOR COMPONENTS
// =========================================================================

/// @func AI_Medic(_hpThreshold, _healAction)
/// Checks living enemy allies. If any ally is below _hpThreshold, heals the most wounded.
function AI_Medic(_hpThreshold = 0.5, _healAction = undefined) {
	var _cfg = {
		cfgThreshold: _hpThreshold,
		cfgAction: _healAction
	};
	return method(_cfg, function(_unit) {
		var _act = is_undefined(cfgAction) ? global.actionLibrary.enemyHeal : cfgAction;
		var _target = EnemyAIGetLowestHPAllyTarget(cfgThreshold);
		if (_target != noone) {
			return [_act, _target];
		}
		return undefined;
	});
}

/// @func AI_Tank(_barrierAction)
/// Protects allies (prioritizing charging allies) or self with a barrier/shield.
function AI_Tank(_barrierAction = undefined) {
	var _cfg = {
		cfgAction: _barrierAction
	};
	return method(_cfg, function(_unit) {
		var _act = is_undefined(cfgAction) ? global.actionLibrary.enemyBarrier : cfgAction;
		var _allies = EnemyAIGetAliveEnemies();
		
		// 1. Frontline priority: Always shield self first so basic attacks cannot damage the frontline!
		if (variable_instance_exists(_unit, "magicBarrier") && !_unit.magicBarrier) {
			return [_act, _unit];
		}
		
		// 2. Next, check if any ally is charging an attack and does not have a barrier
		for (var i = 0; i < array_length(_allies); i++) {
			var _ally = _allies[i];
			if (_ally != _unit && variable_instance_exists(_ally, "isCharging") && _ally.isCharging) {
				if (variable_instance_exists(_ally, "magicBarrier") && !_ally.magicBarrier) {
					return [_act, _ally];
				}
			}
		}
		
		return undefined;
	});
}

/// @func AI_ChargingWizard(_chargeAction, _unleashAction)
/// Turn 1: Starts charging devastating magic (can be interrupted by Stun/Sleep).
/// Turn 2: Unleashes massive attack.
function AI_ChargingWizard(_chargeAction = undefined, _unleashAction = undefined) {
	var _cfg = {
		cfgCharge: _chargeAction,
		cfgUnleash: _unleashAction
	};
	return method(_cfg, function(_unit) {
		var _charge = is_undefined(cfgCharge) ? global.actionLibrary.enemyChargeSpell : cfgCharge;
		var _unleash = is_undefined(cfgUnleash) ? global.actionLibrary.enemyMegaBlast : cfgUnleash;
		
		if (!variable_instance_exists(_unit, "isCharging")) {
			_unit.isCharging = false;
		}
		
		if (!_unit.isCharging) {
			// Start charge
			_unit.isCharging = true;
			return [_charge, _unit];
		} else {
			// Unleash attack
			_unit.isCharging = false;
			if (variable_struct_exists(_unleash, "targetAll") && _unleash.targetAll == MODE.ALWAYS) {
				var _partyTargets = EnemyAIGetAliveParty();
				if (array_length(_partyTargets) > 0) {
					return [_unleash, _partyTargets];
				}
			}
			var _target = EnemyAIGetRandomPartyTarget(_unit);
			if (_target != noone) {
				return [_unleash, _target];
			}
		}
		return undefined;
	});
}

/// @func AI_ChargingAssassin(_vanishAction, _strikeAction)
/// Turn 1: Vanishes into stealth (cannot be hit by player attacks).
/// Turn 2: Strikes from the shadows for heavy damage, breaking stealth.
function AI_ChargingAssassin(_vanishAction = undefined, _strikeAction = undefined) {
	var _cfg = {
		cfgVanish: _vanishAction,
		cfgStrike: _strikeAction
	};
	return method(_cfg, function(_unit) {
		var _vanish = is_undefined(cfgVanish) ? global.actionLibrary.enemyVanish : cfgVanish;
		var _strike = is_undefined(cfgStrike) ? global.actionLibrary.enemyAmbush : cfgStrike;
		
		if (!variable_instance_exists(_unit, "isInvisible")) {
			_unit.isInvisible = false;
		}
		
		if (!_unit.isInvisible) {
			_unit.isInvisible = true;
			_unit.image_alpha = 0.4; // Visual stealth indicator
			return [_vanish, _unit];
		} else {
			_unit.isInvisible = false;
			_unit.image_alpha = 1.0;
			var _target = EnemyAIGetLowestHPPartyTarget();
			if (_target == noone) {
				_target = EnemyAIGetRandomPartyTarget(_unit);
			}
			if (_target != noone) {
				return [_strike, _target];
			}
		}
		return undefined;
	});
}

/// @func AI_Debuffer(_debuffAction, _statusName)
/// Finds any living party member without this debuff and inflicts it.
function AI_Debuffer(_debuffAction = undefined, _statusName = "sleep") {
	var _cfg = {
		cfgAction: _debuffAction,
		cfgStatus: _statusName
	};
	return method(_cfg, function(_unit) {
		var _act = is_undefined(cfgAction) ? global.actionLibrary.enemyHypno : cfgAction;
		var _party = EnemyAIGetAliveParty();
		
		for (var i = 0; i < array_length(_party); i++) {
			var _p = _party[i];
			if (variable_instance_exists(_p, cfgStatus) && !variable_instance_get(_p, cfgStatus)) {
				return [_act, _p];
			}
		}
		return undefined;
	});
}

/// @func AI_StallerDOT(_dotAction, _stallAction)
/// Turn 1+: Poisons un-poisoned party members.
/// Once party is poisoned: stalls with defense buffs or self-defense.
function AI_StallerDOT(_dotAction = undefined, _stallAction = undefined) {
	var _cfg = {
		cfgDot: _dotAction,
		cfgStall: _stallAction
	};
	return method(_cfg, function(_unit) {
		var _dot = is_undefined(cfgDot) ? global.actionLibrary.enemyToxicSting : cfgDot;
		var _stall = is_undefined(cfgStall) ? global.actionLibrary.enemyHarden : cfgStall;
		var _party = EnemyAIGetAliveParty();
		
		// 1. Frontline defense: If the staller lacks its barrier or hardened defense, fortify first!
		if ((variable_instance_exists(_unit, "magicBarrier") && !_unit.magicBarrier) || _unit.def < 45) {
			return [_stall, _unit];
		}
		
		// 2. If any party member is not poisoned, poison them!
		for (var i = 0; i < array_length(_party); i++) {
			var _p = _party[i];
			if (variable_instance_exists(_p, "poisoned") && !_p.poisoned) {
				return [_dot, _p];
			}
		}
		
		// 3. If party is already poisoned, stall and fortify further!
		return [_stall, _unit];
	});
}

/// @func AI_BasicAttack(_attackAction)
/// Default basic attack targeting a random party member.
function AI_BasicAttack(_attackAction = undefined) {
	var _cfg = {
		cfgAction: _attackAction
	};
	return method(_cfg, function(_unit) {
		var _act = is_undefined(cfgAction) ? global.actionLibrary.attack : cfgAction;
		var _target = EnemyAIGetRandomPartyTarget(_unit);
		if (_target != noone) {
			return [_act, _target];
		}
		return -1;
	});
}
