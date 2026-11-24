function NewEncounter(_enemies, _bg, _creator = id)
{
	instance_create_depth
	(
		camera_get_view_x(view_camera[0]),
		camera_get_view_y(view_camera[0]),
		-9999,
		oBattle,
		{enemies: _enemies, creator: _creator, battleBackground: _bg}
	)
}

function BattleChangeHP(_target, _amount, _AliveDeadOrEither = 0, _damageColor = undefined)
{
	//AliveDeadOrEither: 0 = alive only, 1 = dead only, 2 = any
	//_damageColor: optional text color for damage (used by BattleDealDamage to show weak / resist)
	var _failed = false
	if(_AliveDeadOrEither == 0) && (_target.hp <= 0) _failed = true
	if(_AliveDeadOrEither == 1) && (_target.hp > 0) _failed = true

	_target.sleep = false

	var _col = c_white
	if(_amount > 0) _col = c_lime
	if(_amount < 0) && (!is_undefined(_damageColor)) _col = _damageColor
	if(_failed)
	{
		_col = c_white
		_amount = "failed"
	}
	instance_create_depth
	(
		_target.x,
		_target.y,
		_target.depth - 1,
		oBattleFloatingText,
		{font: fnMother3, col: _col, text: string(_amount)}
	)
	if(!_failed) _target.hp = clamp(_target.hp + _amount, 0, _target.hpMax)
}

/// @func BattleFloatText(unit, text, color, [yOffset])
/// Floating popup above a battle unit.
function BattleFloatText(_unit, _text, _col = c_white, _yOffset = 20)
{
	instance_create_depth
	(
		_unit.x,
		_unit.y - _yOffset,
		_unit.depth - 1,
		oBattleFloatingText,
		{font: fnMother3, col: _col, text: _text}
	)
}

/// @func BattleDealDamage(user, target, amount, [tags])
/// Single entry point for skill damage. Applies immunity / resist / weakness from the target's tags,
/// then calls BattleChangeHP. `amount` is the positive base damage rolled by the skill.
///  - immune to any tag  -> nothing happens, "Immune!" popup, returns 0
///  - several tags       -> their multipliers multiply together (and so do buffs stacking on one tag)
///  - weak / resist      -> the damage text is orange / gray instead of white
/// Returns the damage actually dealt, so the skill can skip side effects (stun, blind...) when it is 0.
function BattleDealDamage(_user, _target, _amount, _tags = [])
{
	// Dead target: let BattleChangeHP show its usual "failed" text
	if(_target.hp <= 0)
	{
		BattleChangeHP(_target, -_amount)
		return 0
	}

	for(var i = 0; i < array_length(_tags); i++)
	{
		if(BuffIsTagImmune(_target, _tags[i]))
		{
			BattleFloatText(_target, "Immune!", c_aqua)
			return 0
		}
	}

	var _mult = 1
	for(var i = 0; i < array_length(_tags); i++)
	{
		_mult *= BuffGetResistMult(_target, _tags[i])
	}

	var _final = _amount
	if(_mult != 1) _final = max(1, round(_amount * _mult))

	var _col = undefined
	if(_mult > 1) _col = DMG_COLOR_WEAK
	if(_mult < 1) _col = DMG_COLOR_RESIST

	BattleChangeHP(_target, -_final, 0, _col)
	return _final
}

/// @func BattleApplyStatus(target, status, [tags])
/// Asks whether a status effect (STATUS_* macro) may be applied. Returns false and shows "Immune!"
/// when the target is immune to that status (or to one of `tags`, for skills that have no damage step).
/// The caller still sets the actual flag, e.g.:  if(BattleApplyStatus(t, STATUS_STUN)) t.stunned = true
function BattleApplyStatus(_target, _status, _tags = [])
{
	for(var i = 0; i < array_length(_tags); i++)
	{
		if(BuffIsTagImmune(_target, _tags[i]))
		{
			BattleFloatText(_target, "Immune!", c_aqua)
			return false
		}
	}
	if(BuffIsStatusImmune(_target, _status))
	{
		BattleFloatText(_target, "Immune!", c_aqua)
		return false
	}
	return true
}

function BattleChangePP(_user, _amount, _AliveDeadOrEither = 0)
{
	//AliveDeadOrEither: 0 = alive only, 1 = dead only, 2 = any
	var _failed = false
	
	// A checagem continua sendo no HP, pois é ele quem dita se o alvo está vivo ou morto
	if(_AliveDeadOrEither == 0) && (_user.hp <= 0) _failed = true
	if(_AliveDeadOrEither == 1) && (_user.hp > 0) _failed = true
	
	var _col = c_white
	if(_amount > 0) _col = c_aqua // Alterado para c_aqua para diferenciar do HP
	
	if(_failed)
	{
		_col = c_white
		_amount = "failed"
	}
	
	// Aplica a mudança na variável pp, limitando entre 0 e ppMax
	if(!_failed) _user.pp = clamp(_user.pp + _amount, 0, _user.ppMax)
}

function CheckLevelUp(_unit)
{
	// Define quanto XP é necessário (Exemplo: Lvl * 100)
	// Você pode mudar essa fórmula para algo mais complexo
	var _xpNeeded = _unit.lvl * 100; 
	
	if (_unit.xp >= _xpNeeded)
	{
		_unit.lvl += 1;
		_unit.xp -= _xpNeeded; // Sobra de XP vai para o próximo nível
		
		// Aumento de Status (Ajuste os valores conforme desejar)
		var _hpGain = irandom_range(2, 5);
		var _ppGain = irandom_range(1, 3);
		var _strGain = 1;
		var defGain = irandom_range(0, 1);
		
		_unit.hpMax += _hpGain;
		_unit.hp = _unit.hpMax; // Cura ao subir de nível
		_unit.ppMax += _ppGain;
		_unit.pp = _unit.ppMax;
		_unit.strength += _strGain;
		_unit.def += defGain;
		
		// Mensagem visual no log ou texto flutuante
		instance_create_depth(320, 180, 0, oBattleFloatingText, 
			{font: fnMother3, col: c_yellow, text: "LEVEL UP! Lvl " + string(_unit.lvl)});
			
		// Checa novamente caso ele tenha ganhado XP suficiente para subir 2 níveis de uma vez
		CheckLevelUp(_unit);
	}
}

/// @func CalcHitModifiers(_user)
/// Returns a struct { hit, b, blind, nut } with all accuracy modifiers applied.
function CalcHitModifiers(_user) {
    var _hit = 100;
    if (_user.afo) {
        switch(_user.aftype) {
            case "a": _hit = _hit + (_hit * 0.05); break;
            case "b": _hit = _hit + (_hit * 0.15); break;
            case "y": _hit = _hit + (_hit * 0.25); break;
            case "o": _hit = _hit + (_hit * 0.40); break;
        }
    }
    return {
        hit:   _hit,
        b:     _user.itchy ? _hit / 2 : 0,
        blind: _user.blind ? _hit / 4 : 0,
        nut:   _user.noNut ? 0.25    : 0
    };
}
