//Data
global.coins = 0
global.volume = 100
global.volumeSE = 100

global.gamePaused = false
global.config = false
global.configAudio = false
global.configVideo = false
global.configControl = false
global.partyMenu = false
global.partySkillMenu = false

global.gameMenu = false

global.item_database = []
global.inventoryMaxColumn = 5 

global.inventoryInit = false
global.inventoryMaxSlots = 10

global.inventories = {}

global.inventory_tab_type = [
    [ITEM_TYPE.consumable, ITEM_TYPE.equipment, ITEM_TYPE.material],
    [ITEM_TYPE.key_item]
]
global.inventory_tab_name = [
    "Items",
    "Key Items"
]

global.boss = false
global.escape = false

#macro RESOLUTION_W 1280
#macro RESOLUTION_H 720

#macro TILE_SIZE 32

//Action Library
global.actionLibrary =
{
	attack:
	{
		name: "Attack",
		description: "{0} attacks!",
		subMenu: -1,
		useOverwold: false,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			var _b = 0
			var _blind = 0
			var _hit = 100
			var _nut = 0
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			var defActual = _targets[0].def
			_targets[0].def = (_targets[0].def - (_targets[0].def * _nut))
			
			if(_targets[0].def + _b + _blind >= irandom(100))
			{
				//Attack missed
				instance_create_depth
				(
					_targets[0].x,
					_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[0].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Missed!"}
				)
			}
			else
			{
				var _damage = ceil(_user.strength + random_range(-_user.strength * 0.25, _user.strength * 0.25))
				BattleChangeHP(_targets[0], -_damage)
			}
			_targets[0].def = defActual
		}
	}
	,
	stenchA:
	{
		name: "Stench A",
		description: "{0} casts Stench A!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 11,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			var defActual = _targets[0].def
			_targets[0].def = (_targets[0].def - (_targets[0].def * _nut))
			
			if(_targets[0].def + _b + _blind >= irandom(100))
			{
				//Attack missed
				instance_create_depth
				(
					_targets[0].x,
					_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[0].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Missed!"}
				)
			}
			else
			{
				var _damage = irandom_range(100, 120)
				BattleChangeHP(_targets[0], -_damage)
				// 2. Stun Logic
				// Defines a chance to stun (e.g., 10%. Change to 100 if guaranteed)
				var _stunChance = 99; 
			
				if (_stunChance >= (irandom(99) + 1)) && (_targets[0].hp > 0)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[0].stunned = true; // ou _targets[0].stunTurns = 1;
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[0].x,
						_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[0].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Stunned!"}
					)
					
					// Applies the stun variable to the target (adapt to the name you use in your project).
					//_targets[0].itchy = true; // ou _targets[0].stunTurns = 1;
				
					//// Exibe um texto flutuante amarelo avisando do Stun
					//instance_create_depth
					//(
					//	_targets[0].x,
					//	_targets[0].y - 60, // Sobe um pouco para não encavalar com o texto de dano
					//	_targets[0].depth - 1,
					//	oBattleFloatingText,
					//	{font: fnMother3, col: c_yellow, text: "Itchy!"}
					//)
					
					//if(!_targets[0].hyper)
					//{
					//	// Applies the stun variable to the target (adapt to the name you use in your project).
					//	_targets[0].hyper = true; // ou _targets[0].stunTurns = 1;
					//	_targets[0].spd += 1;
				
					//	// Exibe um texto flutuante amarelo avisando do Stun
					//	instance_create_depth
					//	(
					//		_targets[0].x,
					//		_targets[0].y - 160, // Sobe um pouco para não encavalar com o texto de dano
					//		_targets[0].depth - 1,
					//		oBattleFloatingText,
					//		{font: fnMother3, col: c_yellow, text: "Hyper!"}
					//	)
					//}
				}
			}
			_targets[0].def = defActual
		}
	}
	,
	stenchB:
	{
		name: "Stench B",
		description: "{0} casts Stench B!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 20,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			var defActual = _targets[0].def
			_targets[0].def = (_targets[0].def - (_targets[0].def * _nut))
			
			if(_targets[0].def + _b + _blind >= irandom(100))
			{
				//Attack missed
				instance_create_depth
				(
					_targets[0].x,
					_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[0].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Missed!"}
				)
			}
			else
			{
				var _damage = irandom_range(170, 200)
				BattleChangeHP(_targets[0], -_damage)
				// 2. Stun Logic
				// Defines a chance to stun (e.g., 10%. Change to 100 if guaranteed)
				var _stunChance = 10; 
			
				if (_stunChance >= (irandom(99) + 1)) && (_targets[0].hp > 0)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[0].stunned = true; // ou _targets[0].stunTurns = 1;
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[0].x,
						_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[0].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Stunned!"}
					)
				}
			}
			_targets[0].def = defActual
		}
	}
	,
	stenchY:
	{
		name: "Stench Y",
		description: "{0} casts Stench Y!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 36,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			var defActual = _targets[0].def
			_targets[0].def = (_targets[0].def - (_targets[0].def * _nut))
			
			if(_targets[0].def + _b + _blind >= irandom(100))
			{
				//Attack missed
				instance_create_depth
				(
					_targets[0].x,
					_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[0].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Missed!"}
				)
			}
			else
			{
				var _damage = irandom_range(205, 320)
				BattleChangeHP(_targets[0], -_damage)
				// 2. Stun Logic
				// Defines a chance to stun (e.g., 10%. Change to 100 if guaranteed)
				var _stunChance = 10; 
			
				if (_stunChance >= (irandom(99) + 1)) && (_targets[0].hp > 0)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[0].stunned = true; // ou _targets[0].stunTurns = 1;
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[0].x,
						_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[0].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Stunned!"}
					)
				}
			}
			_targets[0].def = defActual
		}
	}
	,
	stenchO:
	{
		name: "Stench O",
		description: "{0} casts Stench O!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 48,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			var defActual = _targets[0].def
			_targets[0].def = (_targets[0].def - (_targets[0].def * _nut))
			
			if(_targets[0].def + _b + _blind >= irandom(100))
			{
				//Attack missed
				instance_create_depth
				(
					_targets[0].x,
					_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[0].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Missed!"}
				)
			}
			else
			{
				var _damage = irandom_range(325, 450)
				BattleChangeHP(_targets[0], -_damage)
				// 2. Stun Logic
				// Defines a chance to stun (e.g., 10%. Change to 100 if guaranteed)
				var _stunChance = 10; 
			
				if (_stunChance >= (irandom(99) + 1)) && (_targets[0].hp > 0)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[0].stunned = true; // ou _targets[0].stunTurns = 1;
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[0].x,
						_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[0].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Stunned!"}
					)
				}
			}
			_targets[0].def = defActual
		}
	}
	,
	nukeA:
	{
		name: "Nuke A",
		description: "{0} casts Nuke A!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 8,
		targetRequired: false, // Pula o cursor, a skill escolhe o alvo sozinha
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sNuke,
		effectOnTarget: MODE.NEVER,
		// Omitimos o effectSprite aqui para não crashar o alvo automático
		// O efeito visual será instanciado manualmente dentro da func.
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0;
			var _blind = 0;
			var _hit = 100;
			var _nut = 0;
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2;
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4;
			}
			
			if(_user.noNut)
			{
				_nut = 0.25;
			}
			
			// Lógica de sorteio de alvo (50% de chance para inimigo, 50% para aliado)
			var _hitEnemyChance = irandom(1); // Retorna 0 ou 1
			var _possibleTargets = [];
			var _actualTarget = noone;
			var _isEnemy = false;
			
			if (_hitEnemyChance == 1)
			{
				// Tenta focar nos inimigos vivos
				_possibleTargets = array_filter(oBattle.enemyUnits, function(_unit, _index)
				{
					return (_unit.hp > 0);
				});
				_isEnemy = true;
				
				// Se todos os inimigos estiverem mortos (fallback de segurança)
				if (array_length(_possibleTargets) == 0)
				{
					_possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index)
					{
						return (_unit.hp > 0);
					});
					_isEnemy = false;
				}
			}
			else
			{
				// Tenta focar nos aliados vivos
				_possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index)
				{
					return (_unit.hp > 0);
				});
				_isEnemy = false;
			}
			
			// Escolhe um alvo aleatório dentro da lista sorteada
			_actualTarget = _possibleTargets[irandom(array_length(_possibleTargets) - 1)];
			
			// Aplica a quebra de defesa da skill
			var defActual = _actualTarget.def
			_actualTarget.def = (_actualTarget.def - (_actualTarget.def * _nut));
			
			// Checagem de Acerto/Erro
			if(_actualTarget.def + _b + _blind >= irandom(100))
			{
				// Ataque Errou
				instance_create_depth
				(
					_actualTarget.x,
					_actualTarget.y - 20,
					_actualTarget.depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Missed!"}
				);
			}
			else
			{
				if (_isEnemy)
				{
					// Aplica a quebra de defesa da skill
					if(_actualTarget.magicBarrier == true)
					{
						_actualTarget.magicBarrier = false
						
						instance_create_depth
						(
							_actualTarget.x,
							_actualTarget.y - 40, 
							_actualTarget.depth - 1,
							oBattleFloatingText,
							{font: fnMother3, col: c_aqua, text: "Barrier Broken!"}
						);
					}
					else
					{
						//_actualTarget.def = (_actualTarget.def - (_actualTarget.def * _nut));
						// Dano no Inimigo: 88 - 110
						var _damage = irandom_range(88, 110);
						BattleChangeHP(_actualTarget, -_damage);
					}
				}
				else
				{
					// Aplica a quebra de defesa da skill
					if(_actualTarget.magicBarrier == true)
					{
						_actualTarget.magicBarrier = false
						
						instance_create_depth
						(
							_actualTarget.x,
							_actualTarget.y - 40, 
							_actualTarget.depth - 1,
							oBattleFloatingText,
							{font: fnMother3, col: c_aqua, text: "Barrier Broken!"}
						);
					}
					else
					{
						// Dano no Aliado: 1 - 2
						var _damage = irandom_range(1, 2);
						BattleChangeHP(_actualTarget, -_damage);
					}
				}
			}
			_actualTarget.def = defActual
		}
	}
	,
	nukeB:
	{
		name: "Nuke B",
		description: "{0} casts Nuke B!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 16,
		targetRequired: false, 
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sNuke,
		effectOnTarget: MODE.NEVER,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			// 1. Setup de precisão e modificadores (Padrão VZI)
			var _b = 0;
			var _blind = 0;
			var _hit = 100;
			var _nut = 0;
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			if(_user.itchy) _b = _hit / 2;
			if(_user.blind) _blind = _hit / 4;
			if(_user.noNut) _nut = 0.25;

			// 2. Criar uma pool com TODOS os alvos vivos (Aliados + Inimigos)
			var _poolAlvos = [];
			
			// Adiciona aliados vivos
			var _aliadosVivos = array_filter(oBattle.partyUnits, function(_unit, _index)
			{
				return (_unit.hp > 0);
			});
			// Adiciona inimigos vivos
			var _inimigosVivos = array_filter(oBattle.enemyUnits, function(_unit, _index)
			{
				return (_unit.hp > 0);
			});
			
			// Une as duas listas
			_poolAlvos = array_concat(_aliadosVivos, _inimigosVivos);
			
			// Se por algum motivo não houver ninguém vivo, cancela
			if (array_length(_poolAlvos) == 0) exit;

			// 3. Selecionar 2 alvos aleatórios da pool
			var _alvosEscolhidos = [];
			repeat(2)
			{
				if (array_length(_poolAlvos) > 0)
				{
					var _idx = irandom(array_length(_poolAlvos) - 1);
					array_push(_alvosEscolhidos, _poolAlvos[_idx]);
					// Se você quiser que a skill NÃO atinja o mesmo alvo duas vezes, 
					// remova o comentário da linha abaixo:
					array_delete(_poolAlvos, _idx, 1); 
				}
			}

			// 4. Processar cada alvo
			for (var i = 0; i < array_length(_alvosEscolhidos); i++)
			{
				var _actualTarget = _alvosEscolhidos[i];
				
				// Aplica quebra de defesa temporária para o cálculo
				var _originalDef = _actualTarget.def;
				_actualTarget.def = (_actualTarget.def - (_actualTarget.def * _nut));
				
				// Checagem de Acerto
				if(_actualTarget.def + _b + _blind >= irandom(100))
				{
					instance_create_depth
					(
						_actualTarget.x,
						_actualTarget.y - 20,
						_actualTarget.depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					);
				}
				else
				{
					if(_actualTarget.magicBarrier == true)
					{
						_actualTarget.magicBarrier = false
						
						instance_create_depth
						(
							_actualTarget.x,
							_actualTarget.y - 40, 
							_actualTarget.depth - 1,
							oBattleFloatingText,
							{font: fnMother3, col: c_aqua, text: "Barrier Broken!"}
						);
					}
					else
					{
						// Efeito visual (instanciado para cada alvo)
						//instance_create_depth(_actualTarget.x, _actualTarget.y, _actualTarget.depth - 1, oBattleEffect, {sprite_index: sAttack1});
					
						// Verifica se o alvo é inimigo (está na lista de inimigos)
						var _isEnemy = (object_get_name(_actualTarget.object_index) == "oBattleUnitEnemy");
					
						if (_isEnemy)
						{
							// Dano Inimigo: 88 - 110
							var _damage = irandom_range(88, 110);
							BattleChangeHP(_actualTarget, -_damage);
						}
						else
						{
							// Dano Aliado: 1 - 2
							var _damage = irandom_range(1, 2);
							BattleChangeHP(_actualTarget, -_damage);
						}
					}
				}
				// Restaura a defesa original do alvo após o hit
				_actualTarget.def = _originalDef;
			}
		}
	}
	,
	nukeY:
	{
		name: "Nuke Y",
		description: "{0} casts Nuke Y!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 22,
		targetRequired: false, 
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sNuke,
		effectOnTarget: MODE.NEVER,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			// 1. Setup de precisão e modificadores (Padrão VZI)
			var _b = 0;
			var _blind = 0;
			var _hit = 100;
			var _nut = 0;
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			if(_user.itchy) _b = _hit / 2;
			if(_user.blind) _blind = _hit / 4;
			if(_user.noNut) _nut = 0.25;

			// 2. Criar uma pool com TODOS os alvos vivos (Aliados + Inimigos)
			var _poolAlvos = [];
			
			// Adiciona aliados vivos
			var _aliadosVivos = array_filter(oBattle.partyUnits, function(_unit, _index)
			{
				return (_unit.hp > 0);
			});
			// Adiciona inimigos vivos
			var _inimigosVivos = array_filter(oBattle.enemyUnits, function(_unit, _index)
			{
				return (_unit.hp > 0);
			});
			
			// Une as duas listas
			_poolAlvos = array_concat(_aliadosVivos, _inimigosVivos);
			
			// Se por algum motivo não houver ninguém vivo, cancela
			if (array_length(_poolAlvos) == 0) exit;

			// 3. Selecionar 2 alvos aleatórios da pool
			var _alvosEscolhidos = [];
			repeat(3)
			{
				if (array_length(_poolAlvos) > 0)
				{
					var _idx = irandom(array_length(_poolAlvos) - 1);
					array_push(_alvosEscolhidos, _poolAlvos[_idx]);
					// Se você quiser que a skill NÃO atinja o mesmo alvo duas vezes, 
					// remova o comentário da linha abaixo:
					array_delete(_poolAlvos, _idx, 1);
				}
			}

			// 4. Processar cada alvo
			for (var i = 0; i < array_length(_alvosEscolhidos); i++)
			{
				var _actualTarget = _alvosEscolhidos[i];
				
				// Aplica quebra de defesa temporária para o cálculo
				var _originalDef = _actualTarget.def;
				_actualTarget.def = (_actualTarget.def - (_actualTarget.def * _nut));
				
				// Checagem de Acerto
				if(_actualTarget.def + _b + _blind >= irandom(100))
				{
					instance_create_depth
					(
						_actualTarget.x,
						_actualTarget.y - 20,
						_actualTarget.depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					);
				}
				else
				{
					if(_actualTarget.magicBarrier == true)
					{
						_actualTarget.magicBarrier = false
						
						instance_create_depth
						(
							_actualTarget.x,
							_actualTarget.y - 40, 
							_actualTarget.depth - 1,
							oBattleFloatingText,
							{font: fnMother3, col: c_aqua, text: "Barrier Broken!"}
						);
					}
					else
					{
						// Efeito visual (instanciado para cada alvo)
						//instance_create_depth(_actualTarget.x, _actualTarget.y, _actualTarget.depth - 1, oBattleEffect, {sprite_index: sAttack1});
					
						// Verifica se o alvo é inimigo (está na lista de inimigos)
						var _isEnemy = (object_get_name(_actualTarget.object_index) == "oBattleUnitEnemy");
					
						if (_isEnemy)
						{
							// Dano Inimigo: 88 - 110
							var _damage = irandom_range(100, 220);
							BattleChangeHP(_actualTarget, -_damage);
						}
						else
						{
							// Dano Aliado: 1 - 2
							var _damage = irandom_range(4, 5);
							BattleChangeHP(_actualTarget, -_damage);
						}
					}
				}
				// Restaura a defesa original do alvo após o hit
				_actualTarget.def = _originalDef;
			}
		}
	}
	,
	nukeO:
	{
		name: "Nuke O",
		description: "{0} casts Nuke O!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 22,
		targetRequired: false, 
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sNuke,
		effectOnTarget: MODE.NEVER,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			// 1. Setup de precisão e modificadores (Padrão VZI)
			var _b = 0;
			var _blind = 0;
			var _hit = 100;
			var _nut = 0;
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			if(_user.itchy) _b = _hit / 2;
			if(_user.blind) _blind = _hit / 4;
			if(_user.noNut) _nut = 0.25;

			// 2. Criar uma pool com TODOS os alvos vivos (Aliados + Inimigos)
			var _poolAlvos = [];
			
			// Adiciona aliados vivos
			var _aliadosVivos = array_filter(oBattle.partyUnits, function(_unit, _index)
			{
				return (_unit.hp > 0);
			});
			// Adiciona inimigos vivos
			var _inimigosVivos = array_filter(oBattle.enemyUnits, function(_unit, _index)
			{
				return (_unit.hp > 0);
			});
			
			// Une as duas listas
			_poolAlvos = array_concat(_aliadosVivos, _inimigosVivos);
			
			// Se por algum motivo não houver ninguém vivo, cancela
			if (array_length(_poolAlvos) == 0) exit;

			// 3. Selecionar 2 alvos aleatórios da pool
			var _alvosEscolhidos = [];
			repeat(4)
			{
				if (array_length(_poolAlvos) > 0)
				{
					var _idx = irandom(array_length(_poolAlvos) - 1);
					array_push(_alvosEscolhidos, _poolAlvos[_idx]);
					// Se você quiser que a skill NÃO atinja o mesmo alvo duas vezes, 
					// remova o comentário da linha abaixo:
					array_delete(_poolAlvos, _idx, 1); 
				}
			}

			// 4. Processar cada alvo
			for (var i = 0; i < array_length(_alvosEscolhidos); i++)
			{
				var _actualTarget = _alvosEscolhidos[i];
				
				// Aplica quebra de defesa temporária para o cálculo
				var _originalDef = _actualTarget.def;
				_actualTarget.def = (_actualTarget.def - (_actualTarget.def * _nut));
				
				// Checagem de Acerto
				if(_actualTarget.def + _b + _blind >= irandom(100))
				{
					instance_create_depth
					(
						_actualTarget.x,
						_actualTarget.y - 20,
						_actualTarget.depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					);
				}
				else
				{
					if(_actualTarget.magicBarrier == true)
					{
						_actualTarget.magicBarrier = false
						
						instance_create_depth
						(
							_actualTarget.x,
							_actualTarget.y - 40, 
							_actualTarget.depth - 1,
							oBattleFloatingText,
							{font: fnMother3, col: c_aqua, text: "Barrier Broken!"}
						);
					}
					else
					{
						// Efeito visual (instanciado para cada alvo)
						//instance_create_depth(_actualTarget.x, _actualTarget.y, _actualTarget.depth - 1, oBattleEffect, {sprite_index: sAttack});
					
						// Verifica se o alvo é inimigo (está na lista de inimigos)
						var _isEnemy = (object_get_name(_actualTarget.object_index) == "oBattleUnitEnemy");
					
						if (_isEnemy)
						{
							// Dano Inimigo: 88 - 110
							var _damage = irandom_range(100, 220);
							BattleChangeHP(_actualTarget, -_damage);
						}
						else
						{
							// Dano Aliado: 1 - 2
							var _damage = irandom_range(4, 5);
							BattleChangeHP(_actualTarget, -_damage);
						}
					}
				}
				// Restaura a defesa original do alvo após o hit
				_actualTarget.def = _originalDef;
			}
		}
	}
	,
	lightningA:
	{
		name: "Lightning A",
		description: "{0} casts Lightning A!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 10,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			// 1. Setup de precisão e modificadores (Padrão VZI)
			var _b = 0;
			var _blind = 0;
			var _hit = 100;
			var _nut = 0;
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			if(_user.itchy) _b = _hit / 2;
			if(_user.blind) _blind = _hit / 4;
			if(_user.noNut) _nut = 0.25;

			// 2. Identificar a coluna do alvo principal
			var _mainTarget = _targets[0];
			var _columnTargets = [];

			// Checa se o alvo é um inimigo e tem a variável gridCol
			if (variable_instance_exists(_mainTarget, "gridCol"))
			{
				var _targetCol = _mainTarget.gridCol;
				
				// CORREÇÃO: Loop manual em vez de array_filter para evitar problemas de escopo
				for (var i = 0; i < array_length(oBattle.enemyUnits); i++)
				{
					var _unit = oBattle.enemyUnits[i];
					// Se o inimigo estiver vivo e for da mesma coluna, adiciona na lista
					if (_unit.hp > 0 && variable_instance_exists(_unit, "gridCol") && _unit.gridCol == _targetCol)
					{
						array_push(_columnTargets, _unit);
					}
				}
			}
			else
			{
				// Fallback de segurança
				array_push(_columnTargets, _mainTarget);
			}

			// 3. Processar o ataque em todos os alvos daquela coluna
			for(var i = 0; i < array_length(_columnTargets); i++)
			{
				var _actualTarget = _columnTargets[i];
				
				// Salva a defesa original e aplica a quebra de defesa da skill
				var _originalDef = _actualTarget.def;
				_actualTarget.def = (_actualTarget.def - (_actualTarget.def * _nut));
				
				// Checagem de Acerto individual para cada inimigo na coluna
				if(_actualTarget.def + _b + _blind >= irandom(100))
				{
					// Errou
					instance_create_depth
					(
						_actualTarget.x,
						_actualTarget.y - 20,
						_actualTarget.depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					);
				}
				else
				{
					// Efeito visual
					instance_create_depth(_actualTarget.x, _actualTarget.y, _actualTarget.depth - 1, oBattleEffect, {sprite_index: sAttack1});
					
					// Dano em Coluna: 60 - 70
					var _damage = irandom_range(60, 70);
					BattleChangeHP(_actualTarget, -_damage);
				}
				
				// Restaura a defesa original para não bugar o status do inimigo
				_actualTarget.def = _originalDef;
			}
		}
	}
	,
	lightningB:
	{
		name: "Lightning B",
		description: "{0} casts Lightning B!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 21,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			// 1. Setup de precisão e modificadores (Padrão VZI)
			var _b = 0;
			var _blind = 0;
			var _hit = 100;
			var _nut = 0;
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			if(_user.itchy) _b = _hit / 2;
			if(_user.blind) _blind = _hit / 4;
			if(_user.noNut) _nut = 0.25;

			// 2. Identificar a coluna do alvo principal
			var _mainTarget = _targets[0];
			var _columnTargets = [];

			// Checa se o alvo é um inimigo e tem a variável gridCol
			if (variable_instance_exists(_mainTarget, "gridCol"))
			{
				var _targetCol = _mainTarget.gridCol;
				
				// CORREÇÃO: Loop manual em vez de array_filter para evitar problemas de escopo
				for (var i = 0; i < array_length(oBattle.enemyUnits); i++)
				{
					var _unit = oBattle.enemyUnits[i];
					// Se o inimigo estiver vivo e for da mesma coluna, adiciona na lista
					if (_unit.hp > 0 && variable_instance_exists(_unit, "gridCol") && _unit.gridCol == _targetCol)
					{
						array_push(_columnTargets, _unit);
					}
				}
			}
			else
			{
				// Fallback de segurança
				array_push(_columnTargets, _mainTarget);
			}

			// 3. Processar o ataque em todos os alvos daquela coluna
			for(var i = 0; i < array_length(_columnTargets); i++)
			{
				var _actualTarget = _columnTargets[i];
				
				// Salva a defesa original e aplica a quebra de defesa da skill
				var _originalDef = _actualTarget.def;
				_actualTarget.def = (_actualTarget.def - (_actualTarget.def * _nut));
				
				// Checagem de Acerto individual para cada inimigo na coluna
				if(_actualTarget.def + _b + _blind >= irandom(100))
				{
					// Errou
					instance_create_depth
					(
						_actualTarget.x,
						_actualTarget.y - 20,
						_actualTarget.depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					);
				}
				else
				{
					// Efeito visual
					instance_create_depth(_actualTarget.x, _actualTarget.y, _actualTarget.depth - 1, oBattleEffect, {sprite_index: sAttack1});
					
					// Dano em Coluna: 60 - 70
					var _damage = irandom_range(90, 120);
					BattleChangeHP(_actualTarget, -_damage);
				}
				
				// Restaura a defesa original para não bugar o status do inimigo
				_actualTarget.def = _originalDef;
			}
		}
	}
	,
	lightningY:
	{
		name: "Lightning Y",
		description: "{0} casts Lightning Y!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 36,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			// 1. Setup de precisão e modificadores (Padrão VZI)
			var _b = 0;
			var _blind = 0;
			var _hit = 100;
			var _nut = 0;
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			if(_user.itchy) _b = _hit / 2;
			if(_user.blind) _blind = _hit / 4;
			if(_user.noNut) _nut = 0.25;

			// 2. Identificar a coluna do alvo principal
			var _mainTarget = _targets[0];
			var _columnTargets = [];

			// Checa se o alvo é um inimigo e tem a variável gridCol
			if (variable_instance_exists(_mainTarget, "gridCol"))
			{
				var _targetCol = _mainTarget.gridCol;
				
				// CORREÇÃO: Loop manual em vez de array_filter para evitar problemas de escopo
				for (var i = 0; i < array_length(oBattle.enemyUnits); i++)
				{
					var _unit = oBattle.enemyUnits[i];
					// Se o inimigo estiver vivo e for da mesma coluna, adiciona na lista
					if (_unit.hp > 0 && variable_instance_exists(_unit, "gridCol") && _unit.gridCol == _targetCol)
					{
						array_push(_columnTargets, _unit);
					}
				}
			}
			else
			{
				// Fallback de segurança
				array_push(_columnTargets, _mainTarget);
			}

			// 3. Processar o ataque em todos os alvos daquela coluna
			for(var i = 0; i < array_length(_columnTargets); i++)
			{
				var _actualTarget = _columnTargets[i];
				
				// Salva a defesa original e aplica a quebra de defesa da skill
				var _originalDef = _actualTarget.def;
				_actualTarget.def = (_actualTarget.def - (_actualTarget.def * _nut));
				
				// Checagem de Acerto individual para cada inimigo na coluna
				if(_actualTarget.def + _b + _blind >= irandom(100))
				{
					// Errou
					instance_create_depth
					(
						_actualTarget.x,
						_actualTarget.y - 20,
						_actualTarget.depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					);
				}
				else
				{
					// Efeito visual
					instance_create_depth(_actualTarget.x, _actualTarget.y, _actualTarget.depth - 1, oBattleEffect, {sprite_index: sAttack1});
					
					// Dano em Coluna: 60 - 70
					var _damage = irandom_range(170, 220);
					BattleChangeHP(_actualTarget, -_damage);
				}
				
				// Restaura a defesa original para não bugar o status do inimigo
				_actualTarget.def = _originalDef;
			}
		}
	}
	,
	lightningO:
	{
		name: "Lightning O",
		description: "{0} casts Lightning O!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 44,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			// 1. Setup de precisão e modificadores (Padrão VZI)
			var _b = 0;
			var _blind = 0;
			var _hit = 100;
			var _nut = 0;
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			if(_user.itchy) _b = _hit / 2;
			if(_user.blind) _blind = _hit / 4;
			if(_user.noNut) _nut = 0.25;

			// 2. Identificar a coluna do alvo principal
			var _mainTarget = _targets[0];
			var _columnTargets = [];

			// Checa se o alvo é um inimigo e tem a variável gridCol
			if (variable_instance_exists(_mainTarget, "gridCol"))
			{
				var _targetCol = _mainTarget.gridCol;
				
				// CORREÇÃO: Loop manual em vez de array_filter para evitar problemas de escopo
				for (var i = 0; i < array_length(oBattle.enemyUnits); i++)
				{
					var _unit = oBattle.enemyUnits[i];
					// Se o inimigo estiver vivo e for da mesma coluna, adiciona na lista
					if (_unit.hp > 0 && variable_instance_exists(_unit, "gridCol") && _unit.gridCol == _targetCol)
					{
						array_push(_columnTargets, _unit);
					}
				}
			}
			else
			{
				// Fallback de segurança
				array_push(_columnTargets, _mainTarget);
			}

			// 3. Processar o ataque em todos os alvos daquela coluna
			for(var i = 0; i < array_length(_columnTargets); i++)
			{
				var _actualTarget = _columnTargets[i];
				
				// Salva a defesa original e aplica a quebra de defesa da skill
				var _originalDef = _actualTarget.def;
				_actualTarget.def = (_actualTarget.def - (_actualTarget.def * _nut));
				
				// Checagem de Acerto individual para cada inimigo na coluna
				if(_actualTarget.def + _b + _blind >= irandom(100))
				{
					// Errou
					instance_create_depth
					(
						_actualTarget.x,
						_actualTarget.y - 20,
						_actualTarget.depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					);
				}
				else
				{
					// Efeito visual
					instance_create_depth(_actualTarget.x, _actualTarget.y, _actualTarget.depth - 1, oBattleEffect, {sprite_index: sAttack1});
					
					// Dano em Coluna: 60 - 70
					var _damage = irandom_range(240, 310);
					BattleChangeHP(_actualTarget, -_damage);
				}
				
				// Restaura a defesa original para não bugar o status do inimigo
				_actualTarget.def = _originalDef;
			}
		}
	}
	,
	poisonA:
	{
		name: "Poison A",
		description: "{0} cast Poison A!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 9,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			var _nut = 0
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			for(var i = 0; i < array_length(_targets); i++)
			{
				var defActual = _targets[i].def
				_targets[i].def = (_targets[i].def - (_targets[i].def * _nut))
				if(_targets[i].def + _b + _blind >= irandom(100))
				{
					//Attack missed
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					)
				}
				else
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].poisoned = true; // ou _targets[0].stunTurns = 1;
					_targets[i].poison = "a"
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Poisoned!"}
					)
				}
			_targets[i].def = defActual
			}
		}
	}
	,
	poisonB:
	{
		name: "Poison B",
		description: "{0} cast Poison B!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 19,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			var _nut = 0
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			for(var i = 0; i < array_length(_targets); i++)
			{
				var defActual = _targets[i].def
				_targets[i].def = (_targets[i].def - (_targets[i].def * _nut))
				if(_targets[i].def + _b + _blind >= irandom(100))
				{
					//Attack missed
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					)
				}
				else
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].poisoned = true; // ou _targets[0].stunTurns = 1;
					_targets[i].poison = "b"
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Poisoned!"}
					)
				}
			_targets[i].def = defActual
			}
		}
	}
	,
	poisonY:
	{
		name: "Poison Y",
		description: "{0} cast Poison Y!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 31,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			var _nut = 0
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			for(var i = 0; i < array_length(_targets); i++)
			{
				var defActual = _targets[i].def
				_targets[i].def = (_targets[i].def - (_targets[i].def * _nut))
				if(_targets[i].def + _b + _blind >= irandom(100))
				{
					//Attack missed
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					)
				}
				else
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].poisoned = true; // ou _targets[0].stunTurns = 1;
					_targets[i].poison = "y"
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Poisoned!"}
					)
				}
			_targets[i].def = defActual
			}
		}
	}
	,
	poisonO:
	{
		name: "Poison O",
		description: "{0} cast Poison O!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 44,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			var _nut = 0
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			for(var i = 0; i < array_length(_targets); i++)
			{
				var defActual = _targets[i].def
				_targets[i].def = (_targets[i].def - (_targets[i].def * _nut))
				if(_targets[i].def + _b + _blind >= irandom(100))
				{
					//Attack missed
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					)
				}
				else
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].poisoned = true; // ou _targets[0].stunTurns = 1;
					_targets[i].poison = "o"
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Poisoned!"}
					)
				}
			_targets[i].def = defActual
			}
		}
	}
	,
	nocturneA:
	{
		name: "Nocturne A",
		description: "{0} casts Nocturne A!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 16,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			var defActual = _targets[0].def
			_targets[0].def = (_targets[0].def - (_targets[0].def * _nut))
			
			if(_targets[0].def + _b + _blind >= irandom(100))
			{
				//Attack missed
				instance_create_depth
				(
					_targets[0].x,
					_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[0].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Missed!"}
				)
			}
			else
			{
				var _damage = irandom_range(100, 210)
				BattleChangeHP(_targets[0], -_damage)
				// 2. Stun Logic
				// Defines a chance to stun (e.g., 10%. Change to 100 if guaranteed)
				var _stunChance = 50; 
			
				if (_stunChance >= (irandom(99) + 1)) && (_targets[0].hp > 0)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[0].blind = true; // ou _targets[0].stunTurns = 1;
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[0].x,
						_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[0].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Blind!"}
					)
				}
			}
			_targets[0].def = defActual
		}
	}
	,
	nocturneB:
	{
		name: "Nocturne B",
		description: "{0} casts Nocturne B!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 32,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			var defActual = _targets[0].def
			_targets[0].def = (_targets[0].def - (_targets[0].def * _nut))
			
			if(_targets[0].def + _b + _blind >= irandom(100))
			{
				//Attack missed
				instance_create_depth
				(
					_targets[0].x,
					_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[0].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Missed!"}
				)
			}
			else
			{
				var _damage = irandom_range(300, 410)
				BattleChangeHP(_targets[0], -_damage)
				// 2. Stun Logic
				// Defines a chance to stun (e.g., 10%. Change to 100 if guaranteed)
				var _stunChance = 35; 
			
				if (_stunChance >= (irandom(99) + 1)) && (_targets[0].hp > 0)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[0].blind = true; // ou _targets[0].stunTurns = 1;
				
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[0].x,
						_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[0].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Blind!"}
					)
				}
			}
			_targets[0].def = defActual
		}
	}
	,
	nocturneY:
	{
		name: "Nocturne Y",
		description: "{0} casts Nocturne Y!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 49,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			
			for(var i = 0; i < array_length(_targets); i++)
			{
				var defActual = _targets[i].def
				_targets[i].def = (_targets[i].def - (_targets[i].def * _nut))
			
				if(_targets[i].def + _b + _blind >= irandom(100))
				{
					//Attack missed
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					)
				}
				else
				{
					var _damage = irandom_range(460, 500)
					BattleChangeHP(_targets[i], -_damage)
					// 2. Stun Logic
					// Defines a chance to stun (e.g., 10%. Change to 100 if guaranteed)
					var _stunChance = 25; 
			
					if ((_stunChance >= (irandom(99) + 1)) && (_targets[i].hp > 0)) || (_targets[i].holdingPresent)
					{
						// Applies the stun variable to the target (adapt to the name you use in your project).
						_targets[i].blind = true; // ou _targets[0].stunTurns = 1;
				
						// Exibe um texto flutuante amarelo avisando do Stun
						instance_create_depth
						(
							_targets[i].x,
							_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
							_targets[i].depth - 1,
							oBattleFloatingText,
							{font: fnMother3, col: c_yellow, text: "Blind!"}
						)
					}
				}
				_targets[i].def = defActual
			}
		}
	}
	,
	shitstormO:
	{
		name: "Shitstorm O",
		description: "{0} casts Shitstorm O!",
		subMenu: "VZI Attack Skills",
		useOverwold: false,
		ppCost: 60,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			var _b = 0
			var _blind = 0
			var _hit = 100
			
			if(_user.afo)
			{
				switch(_user.aftype)
				{
					case "a":
						_hit = (_hit + (_hit * 0.05))
						break;
					
					case "b":
						_hit = (_hit + (_hit * 0.15))
						break;
						
					case "y":
						_hit = (_hit + (_hit * 0.25))
						break;
						
					case "o":
						_hit = (_hit + (_hit * 0.40))
						break;
				}
			}
			
			if(_user.itchy)
			{
				_b = _hit / 2
			}
			else
			{
				_b = 0
			}
			
			if(_user.blind)
			{
				_blind = _hit / 4
			}
			else
			{
				_blind = 0
			}
			
			if(_user.noNut)
			{
				_nut = 0.25
			}
			else
			{
				_nut = 0
			}
			
			
			for(var i = 0; i < array_length(_targets); i++)
			{
				var defActual = _targets[i].def
				_targets[i].def = (_targets[i].def - (_targets[i].def * _nut))
			
				if(_targets[i].def + _b + _blind >= irandom(100))
				{
					//Attack missed
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Missed!"}
					)
				}
				else
				{
					var _damage = irandom_range(550, 900)
					BattleChangeHP(_targets[i], -_damage)
				}
				_targets[i].def = defActual
			}
		}
	}
	,
	fixUpA:
	{
		name: "Fix-Up A",
		description: "{0} healed!",
		subMenu: "VZI Recovery Skills",
		useOverwold: false,
		ppCost: 11,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(_targets[0].hp > 0) BattleChangeHP(_targets[0], 2)
		}
	}
	,
	fixUpB:
	{
		name: "Fix-Up B",
		description: "{0} healed!",
		subMenu: "VZI Recovery Skills",
		useOverwold: false,
		ppCost: 21,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(_targets[0].hp > 0) BattleChangeHP(_targets[0], 4)
		}
	}
	,
	fixUpY:
	{
		name: "Fix-Up Y",
		description: "{0} healed!",
		subMenu: "VZI Recovery Skills",
		useOverwold: false,
		ppCost: 30,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(_targets[0].hp > 0) BattleChangeHP(_targets[0], 10)
		}
	}
	,
	fixUpO:
	{
		name: "Fix-Up O",
		description: "{0} healed!",
		subMenu: "VZI Recovery Skills",
		useOverwold: false,
		ppCost: 50,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[0].hp > 0) BattleChangeHP(_targets[i], 6)
			}
		}
	}
	,
	cureA:
	{
		name: "Cure A",
		description: "{0} healed!",
		subMenu: "VZI Recovery Skills",
		useOverwold: false,
		ppCost: 3,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[i].hp > 0)
				{
					_targets[i].poisoned = false
					_targets[i].stunned = false
					_targets[i].mutatedHand = false
					_targets[i].itchy = false
					_targets[i].itnum = 0
					_targets[i].ponum = 0
					_targets[i].poison = ""
					_targets[i].blind = false
					_targets[i].sleep = false
					_targets[i].noNut = false
					_targets[i].soreT = false
				}
			}
		}
	}
	,
	cureO:
	{
		name: "Cure O",
		description: "{0} healed!",
		subMenu: "VZI Recovery Skills",
		useOverwold: false,
		ppCost: 6,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(_targets[0].hp <= 0) _targets[0].hp = 1
		}
	}
	,
	drainA:
	{
		name: "Drain A",
		description: "{0} drained!",
		subMenu: "VZI Recovery Skills",
		useOverwold: false,
		ppCost: 0,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			var _pp = irandom_range(2, 8)
			if(_targets[0].hp > 0) 
			{
				var _tp = _targets[0].pp
				if(_targets[0].pp > 0)
				{
					BattleChangePP(_targets[0], -_pp)
					_tp = _tp - _targets[0].pp
					instance_create_depth
					(
						_targets[0].x,
						_targets[0].y,
						_targets[0].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_purple, text: "-" + string(_tp)}
					)
					BattleChangePP(_user, _tp)
					instance_create_depth
					(
						_user.x,
						_user.y,
						_user.depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_aqua, text: "+" + string(_tp)}
					)
				}
			}
		}
	}
	,
	drainO:
	{
		name: "Drain O",
		description: "{0} drained!",
		subMenu: "VZI Recovery Skills",
		useOverwold: false,
		ppCost: 0,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			var _pp = irandom_range(2, 8)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[i].hp > 0) 
				{
					var _tp = _targets[i].pp
					if(_targets[i].pp > 0)
					{
						BattleChangePP(_targets[i], -_pp)
						_tp = _tp - _targets[i].pp
						instance_create_depth
						(
							_targets[i].x,
							_targets[i].y,
							_targets[i].depth - 1,
							oBattleFloatingText,
							{font: fnMother3, col: c_purple, text: "-" + string(_tp)}
						)
						BattleChangePP(_user, _tp)
						instance_create_depth
						(
							_user.x,
							_user.y,
							_user.depth - 1,
							oBattleFloatingText,
							{font: fnMother3, col: c_aqua, text: "+" + string(_tp)}
						)
					}
				}
			}
		}
	}
	,
	favorithingA:
	{
		name: "Favorite Thing A",
		description: "All For One!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 6,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[i].hp > 0) && (!_targets[i].afo)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].afo = true; // ou _targets[0].stunTurns = 1;
					_targets[i].aftype = "a"
				}
			}
		}
	}
	,
	favorithingB:
	{
		name: "Favorite Thing B",
		description: "All For One!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 12,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[i].hp > 0 && !_targets[i].afo)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].afo = true; // ou _targets[0].stunTurns = 1;
					_targets[i].aftype = "b"
				}
			}
		}
	}
	,
	favorithingY:
	{
		name: "Favorite Thing Y",
		description: "All For One!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 28,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[i].hp > 0 && !_targets[i].afo)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].afo = true; // ou _targets[0].stunTurns = 1;
					_targets[i].aftype = "y"
				}
			}
		}
	}
	,
	favorithingO:
	{
		name: "Favorite Thing O",
		description: "All For One!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 35,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[i].hp > 0 && !_targets[i].afo)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].afo = true; // ou _targets[0].stunTurns = 1;
					_targets[i].aftype = "o"
				}
			}
		}
	}
	,
	ftsio:
	{
		name: "F.T.S.I.O.",
		description: "{0} escaped!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 35,
		targetRequired: false,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		effectOnTarget: MODE.NEVER,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(global.boss == false)
			{
				global.escape = true
				with(oBattle) battleState = BattleStateVictoryCheck
			}
		}
	}
	,
	mutationA:
	{
		name: "Mutation A",
		description: "{0} casts Mutation A!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 4,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
		}
	}
	,
	mutationO:
	{
		name: "Mutation O",
		description: "{0} casts Mutation O!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 8,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				var _stunChance = 50; 
			
				if (_stunChance >= (irandom(99) + 1)) && (_targets[i].hp > 0)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].mutatedHand = true; // ou _targets[0].stunTurns = 1;
			
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Mutated Hand!"}
					)
				}
			}
		}
	}
	,
	weathA:
	{
		name: "Weath A",
		description: "{0} casts Weath A!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 2,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			_targets[0].jackpot = true
			
			// Exibe um texto flutuante amarelo avisando do Stun
			instance_create_depth
			(
				_targets[0].x,
				_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
				_targets[0].depth - 1,
				oBattleFloatingText,
				{font: fnMother3, col: c_yellow, text: "Jackpot!"}
			)
		}
	}
	,
	weathO:
	{
		name: "Weath O",
		description: "{0} casts Weath O!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 5,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				_targets[i].jackpot = true
				// Exibe um texto flutuante amarelo avisando do Stun
				instance_create_depth
				(
					_targets[i].x,
					_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[i].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Jackpot!"}
				)
			}
		}
	}
	,
	darknessA:
	{
		name: "Darkness A",
		description: "{0} casts Darkness A!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 4,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			_targets[0].blind = true
			
			// Exibe um texto flutuante amarelo avisando do Stun
			instance_create_depth
			(
				_targets[0].x,
				_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
				_targets[0].depth - 1,
				oBattleFloatingText,
				{font: fnMother3, col: c_yellow, text: "Blinded!"}
			)
		}
	}
	,
	darknessO:
	{
		name: "Darkness O",
		description: "{0} casts Darkness O!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 7,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				_targets[i].blind = true
				// Exibe um texto flutuante amarelo avisando do Stun
				instance_create_depth
				(
					_targets[i].x,
					_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[i].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Blinded!"}
				)
			}
		}
	}
	,
	defensedownA:
	{
		name: "Defense Down A",
		description: "Boink!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 3,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(_targets[0].hp > 0) && (!_targets[0].defdown)
			{
				// Applies the stun variable to the target (adapt to the name you use in your project).
				_targets[0].defdown = true; // ou _targets[0].stunTurns = 1;
			}
		}
	}
	,
	defensedownO:
	{
		name: "Defense Down O",
		description: "Boink!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 7,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[i].hp > 0) && (!_targets[i].defdown)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].defdown = true; // ou _targets[0].stunTurns = 1;
				}
			}
		}
	}
	,
	offenseupA:
	{
		name: "Offense Up A",
		description: "Boink!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 4,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(_targets[0].hp > 0) && (!_targets[0].offenseup)
			{
				// Applies the stun variable to the target (adapt to the name you use in your project).
				_targets[0].offenseup = true; // ou _targets[0].stunTurns = 1;
			}
		}
	}
	,
	offenseupO:
	{
		name: "Offense Up O",
		description: "Boink!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 8,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[i].hp > 0) && (!_targets[i].offenseup)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].offenseup = true; // ou _targets[0].stunTurns = 1;
				}
			}
		}
	}
	,
	hypnosisA:
	{
		name: "Hypnosis A",
		description: "{0} casts Hypnosis A!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 2,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(global.boss == false)
			{
				_targets[0].sleep = true
			
				// Exibe um texto flutuante amarelo avisando do Stun
				instance_create_depth
				(
					_targets[0].x,
					_targets[0].y - 20, // Sobe um pouco para não encavalar com o texto de dano
					_targets[0].depth - 1,
					oBattleFloatingText,
					{font: fnMother3, col: c_yellow, text: "Sleeping!"}
				)
			}
		}
	}
	,
	hypnosisO:
	{
		name: "Hypnosis O",
		description: "{0} casts Hypnosis O!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 6,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(global.boss == false)
			{
				for(var i = 0; i < array_length(_targets); i++)
				{
					_targets[i].sleep = true
					// Exibe um texto flutuante amarelo avisando do Stun
					instance_create_depth
					(
						_targets[i].x,
						_targets[i].y - 20, // Sobe um pouco para não encavalar com o texto de dano
						_targets[i].depth - 1,
						oBattleFloatingText,
						{font: fnMother3, col: c_yellow, text: "Sleeping!"}
					)
				}
			}
		}
	}
	,
	hyperA:
	{
		name: "Hyper A",
		description: "Plus Ultra!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 3,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(_targets[0].hp > 0) && (!_targets[0].hyper)
			{
				// Applies the stun variable to the target (adapt to the name you use in your project).
				_targets[0].hyper = true; // ou _targets[0].stunTurns = 1;
			}
		}
	}
	,
	hyperO:
	{
		name: "Hyper O",
		description: "Plus Ultra!",
		subMenu: "VZI Assist Skills",
		useOverwold: false,
		ppCost: 6,
		targetRequired: true,
		targetEnemyByDefault: false,
		targetAll: MODE.ALWAYS,
		userAnimation: "attack",
		effectSprite: sAttack,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			for(var i = 0; i < array_length(_targets); i++)
			{
				if(_targets[i].hp > 0) && (!_targets[i].hyper)
				{
					// Applies the stun variable to the target (adapt to the name you use in your project).
					_targets[i].hyper = true; // ou _targets[0].stunTurns = 1;
				}
			}
		}
	}
	,
	teleport:
	{
		name: "Teleportation",
		description: "{0} casts Teleportation!",
		subMenu: "VZI Assist Skills",
		useOverwold: true,
		ppCost: 1,
		targetRequired: false,
		targetEnemyByDefault: false,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sAttack1,
		effectOnTarget: MODE.NEVER,
		func: function(_user, _targets)
		{
			BattleChangePP(_user, -ppCost)
			if(!instance_exists(oBattle)) obj_player.x = irandom(100)
		}
	}
}

enum MODE
{
	NEVER = 0,
	ALWAYS = 1,
	VARIES = 2
}

//Party Data
global.party =
[
	{
		name: "Chris",
		spr: spr_player_d_run,
		lvl: 1,
		xp: 0,
		hp: 11,
		hpMax: 12,
		pp: 100,
		ppMax: 100,
		def: 1,
		spd: 1,
		wrath: 1,
		iq: 1,
		strength: 6,
		stunned: false,
		mutatedHand: false,
		itchy: false,
		itnum: 0,
		poisoned: false,
		ponum: 0,
		poison: "",
		blind: false,
		sleep: false,
		noNut: false,
		soreT: false,
		afo: false,
		offenseup: false,
		defdown: false,
		aftype: "",
		anum: 0,
		hyper: false,
		hynum: 0,
		magicBarrier: false,
		holdingPresent: false,
		sprites: { /*idle: sChrisU, down: sChrisU*/},
		actions: [global.actionLibrary.attack, global.actionLibrary.stenchA, global.actionLibrary.stenchB, 
				  global.actionLibrary.nukeA, global.actionLibrary.nukeB, global.actionLibrary.nukeO, 
				  global.actionLibrary.lightningA, global.actionLibrary.poisonA, global.actionLibrary.poisonO,
				  global.actionLibrary.nocturneY, global.actionLibrary.cureA, global.actionLibrary.fixUpA,
				  global.actionLibrary.drainA, global.actionLibrary.shitstormO, global.actionLibrary.favorithingA,
				  global.actionLibrary.ftsio, global.actionLibrary.teleport, global.actionLibrary.darknessA,
				  global.actionLibrary.defensedownA, global.actionLibrary.hyperA, global.actionLibrary.hypnosisA,
				  global.actionLibrary.mutationA, global.actionLibrary.weathA, global.actionLibrary.offenseupA]
	}
	,
	{
		name: "Michael",
		spr: sMichael,
		lvl: 1,
		xp: 0,
		hp: 10,
		hpMax: 12,
		pp: 0,
		ppMax: 0,
		def: 2,
		spd: 2,
		wrath: 2,
		iq: 2,
		strength: 4,
		stunned: false,
		mutatedHand: false,
		itchy: false,
		itnum: 0,
		poisoned: false,
		ponum: 0,
		poison: "",
		blind: false,
		sleep: false,
		noNut: false,
		soreT: false,
		afo: false,
		offenseup: false,
		defdown: false,
		aftype: "",
		anum: 0,
		hyper: false,
		hynum: 0,
		magicBarrier: false,
		holdingPresent: false,
		sprites: { /*idle: sChrisU, down: sChrisU*/},
		actions: [global.actionLibrary.attack]
	}
]

//Enemy Data
global.enemies =
{
	boar:
	{
		name: "Boar",
		hp: 30,
		hpMax: 30,
		pp: 1,
		ppMax: 1,
		def: 1,
		spd: 1,
		wrath: 1,
		iq: 1,
		strength: 5,
		actions: [global.actionLibrary.attack],
		sprites: {idle: sEnemy},
		xpValue: 200,
		coin: 100,
		stunned: false,
		mutatedHand: false,
		itchy: false,
		itnum: 0,
		poisoned: false,
		ponum: 0,
		poison: "",
		jackpot: false,
		blind: false,
		sleep: false,
		noNut: false,
		afo: false,
		offenseup: false,
		defdown: false,
		aftype: "",
		anum: 0,
		hyper: false,
		hynum: 0,
		magicBarrier: false,
		holdingPresent: false,
		AIscript: function()
		{
			//enemy turn ai goes here
			//Attack random party member
			var _action = actions[0]
			
			var _possibleTargets = []
			
			var _chan = 1
			var _mut = false
				
			if(mutatedHand) 
			{
				if(_chan < irandom(2)) _mut = true
				if(_mut)
				{
					_possibleTargets = array_filter(oBattle.enemyUnits, function(_unit, _index)
					{
						return (_unit.hp > 0)
					})
				}
				else
				{
					_possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index)
					{
						return (_unit.hp > 0)
					})
				}
			}
			else
			{
				_possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index)
				{
					return (_unit.hp > 0)
				})
			}
			
			var _target = _possibleTargets[irandom(array_length(_possibleTargets) - 1)]
			return [_action, _target]
		}
	}
}