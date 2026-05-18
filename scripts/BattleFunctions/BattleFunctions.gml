function NewEncounter(_enemies, _bg)
{
	instance_create_depth
	(
		camera_get_view_x(view_camera[0]),
		camera_get_view_y(view_camera[0]),
		-9999,
		oBattle,
		{enemies: _enemies, creator: id, battleBackground: _bg}
	)
}

function BattleChangeHP(_target, _amount, _AliveDeadOrEither = 0)
{
	//AliveDeadOrEither: 0 = alive only, 1 = dead only, 2 = any
	var _failed = false
	if(_AliveDeadOrEither == 0) && (_target.hp <= 0) _failed = true
	if(_AliveDeadOrEither == 1) && (_target.hp > 0) _failed = true
	
	_target.sleep = false
	
	var _col = c_white
	if(_amount > 0) _col = c_lime
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