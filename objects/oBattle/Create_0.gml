instance_deactivate_all(true)
instance_activate_object(obj_debug_manager) // keep the debug overlay running while the overworld is frozen for battle
instance_activate_object(obj_encounter_transition) // keep the transition running

image_speed = .5

units = []
turn = 0
unitTurnOrder = []
unitRenderOrder = []
allst = []
alldef = []

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

// Resist / immunity / buff data: clone per-unit copies and apply passives
buffTurnStartedAt = -1 // turnCount of the last BuffTurnStart, so it fires once per turn
for(var i = 0; i < array_length(units); i++)
{
	// Battle-start stats, taken BEFORE passives are applied (unbuffed): BattleClearOnDeath restores these
	units[i].battleBaseStrength = units[i].strength
	units[i].battleBaseDef = units[i].def
	BuffInitUnit(units[i])
}

// Speed-based Turn Order (with tie-breaking)
unitTurnOrder = []
array_copy(unitTurnOrder, 0, units, 0, array_length(units))
for(var i = 0; i < array_length(unitTurnOrder); i++)
{
	unitTurnOrder[i]._turnInitiative = (variable_instance_exists(unitTurnOrder[i], "spd") ? unitTurnOrder[i].spd : 1) * 100 + irandom(99);
}
array_sort(unitTurnOrder, function(_a, _b)
{
	return _b._turnInitiative - _a._turnInitiative;
})

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

		//Start-of-turn buff hooks (once per turn, this state can run again while a menu is open)
		if(buffTurnStartedAt != turnCount)
		{
			buffTurnStartedAt = turnCount
			BuffTurnStart(_unit)
			if(_unit.hp <= 0)
			{
				battleState = BattleStateVictoryCheck
				exit;
			}
		}

		//Select an action to perform
		//If unit is player controlled
		if(_unit.object_index == oBattleUnitPC)
		{
			if (!_unit.stunned && !_unit.sleep)
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
			if (!_unit.stunned && !_unit.sleep)
			{
				var _enemyAction = _unit.AIscript()
				if (_enemyAction != -1 && instance_exists(_unit)) BeginAction(_unit, _enemyAction[0], _enemyAction[1])
			}
			else
			{
				if (variable_instance_exists(_unit, "isCharging") && _unit.isCharging)
				{
					_unit.isCharging = false;
					instance_create_depth
					(
						_unit.x,
						_unit.y - 20,
						_unit.depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Interrupted!"}
					);
				}
				_unit.stunned = false
				battleState = BattleStateVictoryCheck
			}
		}
	}
}

function BeginAction(_user, _action, _targets)
{
	if (!instance_exists(_user))
	{
		battleState = BattleStateVictoryCheck;
		exit;
	}
	currentUser = _user
	currentAction = _action
	currentTargets = _targets
	battleText = string_ext(_action.description, [_user.name])
	if(!is_array(currentTargets)) currentTargets = [currentTargets]
	if(DEBUG_BATTLE_LOG)
	{
		var _names = []
		for(var i = 0; i < array_length(currentTargets); i++) array_push(_names, BattleUnitName(currentTargets[i]))
		//-1 = no target given (menu actions with targetRequired: false, e.g. Nuke picks a random target itself)
		var _targetText = (!is_array(_targets) && _targets == -1) ? "(skill picks its own target)" : "[" + string_join_ext(", ", _names) + "]"
		BattleLog(">> " + BattleUnitName(_user) + " uses " + _action.name + " on " + _targetText)
	}
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
	// Dead units lose all buffs (except passives), status effects and stat changes
	for(var i = 0; i < array_length(units); i++)
	{
		BattleClearOnDeath(units[i])
	}
	BuffCleanupDeadSources() // buffs that end when their giver dies

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
			
			if(partyUnits[i].hyper)
			{
				partyUnits[i].spd -= 1
				partyUnits[i].hyper = false
			}
		}

		ApplyDeathPenalty() // Lose 50% of cash on hand on a party wipe; bank balance is untouched.

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
			
			// Loot Drops
			if (variable_struct_exists(global.loot_database, enemyUnits[i].name))
			{
				var _lootTable = global.loot_database[$ enemyUnits[i].name];
				for(var j = 0; j < array_length(_lootTable); j++)
				{
					var _drop = _lootTable[j];
					var _roll = irandom_range(1, 100);
					if (_roll <= _drop.chance * global.dropRateMultiplier)
					{
						var _receiver = global.party[0].name; 
						// Find an alive member
						for(var p = 0; p < array_length(partyUnits); p++) {
							if (partyUnits[p].hp > 0) {
								_receiver = partyUnits[p].name;
								break;
							}
						}
						
						var _added = AddItemToCharacterInventory(_receiver, _drop.item, 1);
						if (_added)
						{
							// Create visual indicator on the enemy
							instance_create_depth(
								enemyUnits[i].x,
								enemyUnits[i].y - 40 - (j * 20),
								enemyUnits[i].depth - 1,
								oBattleFloatingText,
								{font: fnMother3, col: c_yellow, text: "Got Item!"}
							);
						}
					}
				}
			}
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
		
		AddBankFunds(_totalCoin)
		
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

	//End-of-turn buff hooks + duration countdown for the unit that just acted
	var _endedUnit = unitTurnOrder[turn]
	if(instance_exists(_endedUnit)) && (_endedUnit.hp > 0) BuffTurnEnd(_endedUnit)

	turnCount++
	turn++
	//Loop Turns
	if(turn > array_length(unitTurnOrder) - 1)
	{
		turn = 0
		roundCount++
		// Re-sort turn order by speed each round with fresh initiative tie-breakers
		for(var i = 0; i < array_length(unitTurnOrder); i++)
		{
			unitTurnOrder[i]._turnInitiative = (variable_instance_exists(unitTurnOrder[i], "spd") ? unitTurnOrder[i].spd : 1) * 100 + irandom(99);
		}
		array_sort(unitTurnOrder, function(_a, _b)
		{
			return _b._turnInitiative - _a._turnInitiative;
		})
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
		
		var _strBefore = _unit.strength //Debug: compared after the stat effects below
		var _defBefore = _unit.def
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
		
		//Offense Up / Defense Down are timed buffs now (global.buffLibrary.offense_up / defense_down)

		//Debug: log stat changes made by afo above
		if(_unit.strength != _strBefore) || (_unit.def != _defBefore)
		{
			BattleLog(BattleUnitName(_unit) + " | stats (afo=" + string(_unit.afo) + " " + _unit.aftype + ")"
				+ " strength " + string_format(_strBefore, 1, 2) + "->" + string_format(_unit.strength, 1, 2)
				+ " def " + string_format(_defBefore, 1, 2) + "->" + string_format(_unit.def, 1, 2))
		}
		
		//Poison immunity gained while poisoned (buff / debug toggle) cures the existing poison.
		//Queries the immunity directly (not BattleApplyStatus) so the log is not spammed every tick.
		if(_unit.poisoned) && (_unit.hp > 0) && (BuffIsTagImmune(_unit, TAG_POISON) || BuffIsStatusImmune(_unit, STATUS_POISON))
		{
			_unit.poisoned = false
			_unit.ponum = 0
			_unit.poison = ""
			BattleFloatText(_unit, "Immune!", c_aqua)
			BattleLog(BattleUnitName(_unit) + " | poison cured (now immune)")
		}

		//Poison only ticks at the end of the poisoned unit's OWN turn (also when that turn was skipped
		//by stun / sleep), like buff durations. Before, it ticked after every unit's turn.
		if(_unit.poisoned) && (_unit == _endedUnit)
		{
			if(_unit.ponum >= 1)
			{
				//Tick damage goes through BattleDealDamage so TAG_POISON resist / weakness applies
				switch(_unit.poison)
				{
					case "":
						break

					case "a":
						BattleDealDamage(noone, _unit, irandom_range(4, 8), [TAG_POISON])
						break

					case "b":
						BattleDealDamage(noone, _unit, irandom_range(20, 40), [TAG_POISON])
						break

					case "y":
						BattleDealDamage(noone, _unit, irandom_range(50, 80), [TAG_POISON])
						break

					case "o":
						BattleDealDamage(noone, _unit, irandom_range(80, 100), [TAG_POISON])
						break
				}
			}
			
			_unit.ponum += 1
			
			if(_unit.ponum >= 6)
			{
				_unit.poisoned = false
				_unit.ponum = 0
				_unit.poison = ""
				BattleLog(BattleUnitName(_unit) + " | poison wore off")
			}
		}
	}
	battleState = BattleStateSelectAction
}

battleState = BattleStateSelectAction