instance_deactivate_all(true)
instance_activate_object(obj_debug_manager) // keep the debug overlay running while the overworld is frozen for battle

image_speed = .5

units = []
turn = 0
unitTurnOrder = []
unitRenderOrder = []
allst = []
alldef = []
off = []
defd = []

turnCount = 0
roundCount = 0
battleWaitTimeFrames = 30
battleWaitTimeRemaining = 0
battleText = ""
currentUser = noone
currentAction = -1
currentTargets = noone

//Make targgeting cursor
cursor = 
{
	activeUser: noone,
	activeTarget: noone,
	activeAction: -1,
	targetSide: -1,
	targetIndex: 0,
	targetAll: false,
	confirmDelay: 0,
	active: false
}

//Make enemies
//for(var i = 0; i < array_length(enemies); i++)
//{
//	enemyUnits[i] = instance_create_depth(x + 250 + ((i mod 3) * 128), y + 180 - ((i mod 3) * 10) - ((i div 3) * 25), depth - 10, oBattleUnitEnemy, enemies[i])
//	array_push(units, enemyUnits[i])
//}
// Configurações do Grid Visual
var _startX = x + 250;
var _startY = y + 190; // Y inicial (Linha 0 ficará mais para baixo na tela)
var _colSpacing = 120; // Espaçamento horizontal entre as colunas
var _rowSpacing = 60;  // O quanto o Y diminui (sobe na tela) por linha

// Make enemies
for(var i = 0; i < array_length(enemies); i++)
{
	// Extrai os dados passados no NewEncounter
	var _eData = enemies[i].data;
	var _col = enemies[i].col;
	var _row = enemies[i].row;
	
	// Calcula a posição na tela
	var _spawnX = _startX + (_col * _colSpacing);
	var _spawnY = _startY - (_row * _rowSpacing);
	
	// Cria o inimigo injetando o _eData
	enemyUnits[i] = instance_create_depth(_spawnX, _spawnY, depth - 10, oBattleUnitEnemy, _eData);
	
	// Registra as coordenadas da matriz no objeto para o Cursor usar depois
	enemyUnits[i].gridCol = _col;
	enemyUnits[i].gridRow = _row;
	
	array_push(units, enemyUnits[i]);
}

//Make friends
for(var i = 0; i < array_length(global.party); i++)
{
	partyUnits[i] = instance_create_depth(x + COLLUMN_NAME, y + 320 + i * 20, depth - 10, oBattleUnitPC, global.party[i])
	array_push(units, partyUnits[i])
}

//Shuffle Turn order
unitTurnOrder = array_shuffle(units)

//Get render order
RefreshRenderOrder = function()
{
	unitRenderOrder = []
	array_copy(unitRenderOrder, 0, units, 0, array_length(units))
	array_sort(unitRenderOrder, function(_1, _2)
	{
		return _1.y - _2.y
	})
}
RefreshRenderOrder()

function BattleStateSelectAction()
{
	if(!instance_exists(oMenu))
	{
		//Get current unit
		var _unit = unitTurnOrder[turn]
	
		//Is the unit dead or unable to act?
		if(!instance_exists(_unit)) || (_unit.hp <= 0)
		{
			battleState = BattleStateVictoryCheck
			exit;
		}
	
		//Select an action to perform
		//If unit is player controlled
		if(_unit.object_index == oBattleUnitPC)
		{
			if(!_unit.stunned) || (!_unit.sleep)
			{
				//Compile the action Menu
				var _menuOptions = []
				var _subMenus = {}
			
				var _actionList = _unit.actions
			
				for(var i = 0; i < array_length(_actionList); i++)
				{
					var _action = _actionList[i]
					var _available = true //Later we'll check PP cost here...
					var _nameAndCount = _action.name //Later we'll modify the name to include the item count, if the action is an item.
					if(_action.subMenu == -1)
					{
						array_push(_menuOptions, [_nameAndCount, MenuSelectAction, [_unit, _action], _available])
					}
					else
					{
						//Create or add to a submenu
						if(is_undefined(_subMenus[$ _action.subMenu]))
						{
							variable_struct_set(_subMenus, _action.subMenu, [[_nameAndCount, MenuSelectAction, [_unit, _action], _available]])
						}
						else 
						{
							array_push(_subMenus[$ _action.subMenu], [_nameAndCount, MenuSelectAction, [_unit, _action], _available])
						}
					}
				}
			
				//Turn sub menus into an arrya
				var _subMenusArray = variable_struct_get_names(_subMenus)
				for(var i = 0; i < array_length(_subMenusArray); i++)
				{
					//Sort submenu if needed
					//Add back option at the end of each submenu
					array_push(_subMenus[$ _subMenusArray[i]], ["Back", MenuGoBack, -1, true])
					//Add submenu into the main menu
					array_push(_menuOptions, [_subMenusArray[i], SubMenu, [_subMenus[$ _subMenusArray[i]]], true])
				}
			
				Menu(x + 10, y + 10, _menuOptions, , , )
			}
			else
			{
				_unit.stunned = false
				battleState = BattleStateVictoryCheck
			}
		}
		else
		{
			//If unit is AI controlled:
			if(!_unit.stunned) || (!_unit.sleep)
			{
				var _enemyAction = _unit.AIscript()
				if(_enemyAction != -1) BeginAction(_unit.id, _enemyAction[0], _enemyAction[1])
			}
			else
			{
				_unit.stunned = false
				battleState = BattleStateVictoryCheck
			}
		}
	}
}

function BeginAction(_user, _action, _targets)
{
	currentUser = _user
	currentAction = _action
	currentTargets = _targets
	battleText = string_ext(_action.description, [_user.name])
	if(!is_array(currentTargets)) currentTargets = [currentTargets]
	battleWaitTimeRemaining = battleWaitTimeFrames
	with(_user)
	{
		acting = true
		//Play user animation if it is defined for that action, and that user
		if(!is_undefined(_action[$ "userAnimation"])) && (!is_undefined(_user.sprites[$ _action.userAnimation]))
		{
			sprite_index = sprites[$ _action.userAnimation]
			image_index = 0
		}
	}
	battleState = BattleStatePerformAction
}

function BattleStatePerformAction()
{
	//If animation etc is still playing
	if(currentUser.acting)
	{
		//When it ends, perform action effect if it exists
		if(currentUser.image_index >= currentUser.image_number - 1)
		{
			with(currentUser)
			{
				//sprite_index = sprites.idle
				image_index = 0
				acting = false
			}
			
			if(variable_struct_exists(currentAction, "effectSprite"))
			{
				if(currentAction.effectOnTarget == MODE.ALWAYS) || ((currentAction.effectOnTarget == MODE.VARIES) && (array_length(currentTargets) <= 1))
				{
					for(var i = 0; i < array_length(currentTargets); i++)
					{
						instance_create_depth(currentTargets[i].x, currentTargets[i].y, currentTargets[i].depth - 1, oBattleEffect, {sprite_index: currentAction.effectSprite})
					}
				}
				else //Play it at 0,0
				{
					var _effectSprite = currentAction.effectSprite
					if(variable_struct_exists(currentAction, "effectSpriteNoTarget")) _effectSprite = currentAction.effectSpriteNoTarget
					instance_create_depth(x, y, depth - 100, oBattleEffect, {sprite_index: _effectSprite})
				}
			}
			currentAction.func(currentUser, currentTargets)
		}
	}
	else
	{
		//Wait for delay and then end the turn
		if(!instance_exists(oBattleEffect))
		{
			battleWaitTimeRemaining--
			if(battleWaitTimeRemaining == 0)
			{
				battleState = BattleStateVictoryCheck
			}
		}
	}
}

function BattleStateVictoryCheck()
{
	if(global.escape)
	{
		for(var i = 0; i < array_length(partyUnits); i++)
		{
			if(partyUnits[i].afo)
			{
				switch(partyUnits[i].aftype)
				{
					case "a":
						partyUnits[i].strength -= (allst[i] * 0.05)
						partyUnits[i].def += (alldef[i] * 0.05)
						break;
						
					case "b":
						partyUnits[i].strength -= (allst[i] * 0.15)
						partyUnits[i].def += (alldef[i] * 0.15)
						break;
					case "y":
						partyUnits[i].strength -= (allst[i] * 0.25)
						partyUnits[i].def += (alldef[i] * 0.25)
						break;
					case "o":
						partyUnits[i].strength -= (allst[i] * 0.40)
						partyUnits[i].def += (alldef[i] * 0.40)
						break;
				}
				partyUnits[i].afo = false
				partyUnits[i].aftype = ""
				partyUnits[i].anum = 0
			}
			
			if(partyUnits[i].offenseup)
			{
				partyUnits[i].strength -= (off[i] * 0.2)
				partyUnits[i].offenseup = false
			}
			
			if(partyUnits[i].defdown)
			{
				partyUnits[i].def -= (defd[i] * 0.2)
				partyUnits[i].defdown = false
			}
			
			if(partyUnits[i].hyper)
			{
				partyUnits[i].spd -= 1
				partyUnits[i].hyper = false
			}
		}
		global.escape = false
		// Dica: Aqui você também pode limpar os arrays, destruir o obj_battle,
		// tocar uma música de vitória/Game Over ou reativar o jogador no mapa.
		instance_destroy()
	}
	// 1. Checa se todos os aliados estão mortos
	var _partyDead = true;
	for(var i = 0; i < array_length(partyUnits); i++)
	{
		// Se a instância existir e o HP for maior que 0, a party não está toda morta
		if (instance_exists(partyUnits[i]) && partyUnits[i].hp > 0)
		{
			_partyDead = false;
			break; // Para o loop cedo para economizar processamento
		}
	}

	// 2. Checa se todos os inimigos estão mortos
	var _enemiesDead = true;
	for(var i = 0; i < array_length(enemyUnits); i++)
	{
		if (instance_exists(enemyUnits[i]) && enemyUnits[i].hp > 0)
		{
			_enemiesDead = false;
			break;
		}
	}

	// 3. Verifica o resultado
	if (_partyDead)
	{
		for(var i = 0; i < array_length(partyUnits); i++)
		{
			if(partyUnits[i].afo)
			{
				switch(partyUnits[i].aftype)
				{
					case "a":
						partyUnits[i].strength -= (allst[i] * 0.05)
						partyUnits[i].def += (alldef[i] * 0.05)
						break;
						
					case "b":
						partyUnits[i].strength -= (allst[i] * 0.15)
						partyUnits[i].def += (alldef[i] * 0.15)
						break;
					case "y":
						partyUnits[i].strength -= (allst[i] * 0.25)
						partyUnits[i].def += (alldef[i] * 0.25)
						break;
					case "o":
						partyUnits[i].strength -= (allst[i] * 0.40)
						partyUnits[i].def += (alldef[i] * 0.40)
						break;
				}
				partyUnits[i].afo = false
				partyUnits[i].aftype = ""
				partyUnits[i].anum = 0
			}
			
			if(partyUnits[i].offenseup)
			{
				partyUnits[i].strength -= (off[i] * 0.2)
				partyUnits[i].offenseup = false
			}
			
			if(partyUnits[i].defdown)
			{
				partyUnits[i].def -= (defd[i] * 0.2)
				partyUnits[i].defdown = false
			}
			
			if(partyUnits[i].hyper)
			{
				partyUnits[i].spd -= 1
				partyUnits[i].hyper = false
			}
		}
		// Dica: Aqui você também pode limpar os arrays, destruir o obj_battle,
		// tocar uma música de vitória/Game Over ou reativar o jogador no mapa.
		instance_destroy()
	}
	else if (_enemiesDead)
	{
	    var _totalXP = 0;
		var _totalCoin = 0
		var _multCoin = 0
		
	    // Soma o XP de todos os inimigos da batalha
	    for(var i = 0; i < array_length(enemyUnits); i++)
		{
	        _totalXP += enemyUnits[i].xpValue;
			if(enemyUnits[i].jackpot == true) _multCoin = 0.08 
	        _totalCoin += (enemyUnits[i].coin + (enemyUnits[i].coin * _multCoin));
	    }
		
	    // Distribui para cada membro da party que estiver vivo
	    for(var i = 0; i < array_length(partyUnits); i++)
		{
			if(partyUnits[i].afo)
			{
				switch(partyUnits[i].aftype)
				{
					case "a":
						partyUnits[i].strength -= (allst[i] * 0.05)
						partyUnits[i].def += (alldef[i] * 0.05)
						break;
						
					case "b":
						partyUnits[i].strength -= (allst[i] * 0.15)
						partyUnits[i].def += (alldef[i] * 0.15)
						break;
					case "y":
						partyUnits[i].strength -= (allst[i] * 0.25)
						partyUnits[i].def += (alldef[i] * 0.25)
						break;
					case "o":
						partyUnits[i].strength -= (allst[i] * 0.40)
						partyUnits[i].def += (alldef[i] * 0.40)
						break;
				}
				partyUnits[i].afo = false
				partyUnits[i].aftype = ""
				partyUnits[i].anum = 0
			}
			
			if(partyUnits[i].offenseup)
			{
				partyUnits[i].strength -= (off[i] * 0.2)
				partyUnits[i].offenseup = false
			}
			
			if(partyUnits[i].defdown)
			{
				partyUnits[i].def -= (def[i] * 0.2)
				partyUnits[i].defdown = false
			}
			
			if(partyUnits[i].hyper)
			{
				partyUnits[i].spd -= 1
				partyUnits[i].hyper = false
			}
			
			if(partyUnits[i].hp > 0)
			{
				partyUnits[i].xp += _totalXP;
				CheckLevelUp(partyUnits[i]); // Chama a função que criamos acima
	        }
	    }
		
		global.coins += _totalCoin
		
	    instance_destroy()
	}
	else
	{
		// A batalha continua, passa para o próximo turno
		battleState = BattleStateTurnProgression;
	}
}

function BattleStateTurnProgression()
{
	battleText = "" //Reset battle text
	turnCount++
	turn++
	//Loop Turns
	if(turn > array_length(unitTurnOrder) - 1)
	{
		turn = 0
		roundCount++
	}
	
	for(var i = 0; i <= array_length(unitTurnOrder) - 1; i++)
	{
		var _unit = unitTurnOrder[i]
		if(_unit.itchy)
		{
			_unit.itnum += 1
			if(_unit.itnum >= 5)
			{
				_unit.itchy = false
				_unit.itnum = 0
			}
		}
		
		if(_unit.hyper)
		{
			_unit.hynum += 1
			if(_unit.hynum >= 3)
			{
				_unit.hyper = false
				_unit.hynum = 0
			}
		}
		
		if(_unit.afo)
		{
			if(_unit.anum <= 0)
			{
				allst[i] = _unit.strength
				alldef[i] = _unit.def
				switch(_unit.aftype)
				{
					case "a":
						_unit.strength += (_unit.strength * 0.05)
						_unit.def += (_unit.def * 0.05)
						break;
						
					case "b":
						_unit.strength += (_unit.strength * 0.15)
						_unit.def += (_unit.def * 0.15)
						break;
					case "y":
						_unit.strength += (_unit.strength * 0.25)
						_unit.def += (_unit.def * 0.25)
						break;
					case "o":
						_unit.strength += (_unit.strength * 0.40)
						_unit.def += (_unit.def * 0.40)
						break;
				}
			}
			
			_unit.anum += 1
			if(_unit.anum >= 4)
			{
				_unit.strength = allst[i]
				_unit.def = alldef[i]
				_unit.afo = false
				_unit.aftype = ""
				_unit.anum = 0
			}
		}
		
		if(_unit.offenseup)
		{
			off[i] = _unit.strength
			_unit.strength += (_unit.strength * 0.2)
		}
		
		if(_unit.defdown)
		{
			defd[i] = _unit.def
			_unit.def += (_unit.def * 0.2)
		}
		
		if(_unit.poisoned)
		{
			if(_unit.ponum >= 1)
			{
				switch(_unit.poison)
				{
					case "":
						break
				
					case "a":
						BattleChangeHP(_unit, irandom_range(-4, -8), 0)
						break
					
					case "b":
						BattleChangeHP(_unit, irandom_range(-20, -40), 0)
						break
					
					case "y":
						BattleChangeHP(_unit, irandom_range(-50, -80), 0)
						break
					
					case "o":
						BattleChangeHP(_unit, irandom_range(-80, -100), 0)
						break
				}
			}
			
			_unit.ponum += 1
			
			if(_unit.ponum >= 6)
			{
				_unit.poisoned = false
				_unit.ponum = 0
				_unit.poison = ""
			}
		}
	}
	battleState = BattleStateSelectAction
}

battleState = BattleStateSelectAction