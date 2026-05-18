//Run stats machine
battleState()

//Cursor control
if(cursor.active)
{
	with(cursor)
	{
		//Input
		var _keyUp = keyboard_check_pressed(vk_up)
		var _keyDown = keyboard_check_pressed(vk_down)
		var _keyLeft = keyboard_check_pressed(vk_left)
		var _keyRight = keyboard_check_pressed(vk_right)
		var _keyToggle = false
		var _keyConfirm = false
		var _keyCancel = false
		confirmDelay++
		if(confirmDelay > 1)
		{
			_keyConfirm = keyboard_check_pressed(vk_enter)
			_keyCancel = keyboard_check_pressed(vk_escape)
			_keyToggle = keyboard_check_pressed(vk_shift)
		}
		var _moveH = _keyRight - _keyLeft
		var _moveV = _keyDown - _keyUp
		
		//if(_moveV == -1) targetSide = oBattle.partyUnits
		//if(_moveV == 1) targetSide = oBattle.enemyUnits
		
		//Verify target list
		//if(targetSide == oBattle.enemyUnits)
		//{
		//	targetSide = array_filter(targetSide, function(_element, _index)
		//	{
		//		return _element.hp > 0
		//	})
		//}
		//Verify target list e aplicar Formação
		var _isEnemyTargeting = false;
		
		// Descobre se estamos mirando em inimigos para aplicar a regra de grid
		if (is_array(targetSide) && array_length(targetSide) > 0) 
		{
			if (targetSide[0].object_index == oBattleUnitEnemy) _isEnemyTargeting = true;
		} 
		else if (targetSide == oBattle.enemyUnits) 
		{
			_isEnemyTargeting = true;
		}

		if (_isEnemyTargeting)
		{
			if(targetAll == false) //Single target mode
			{
				targetSide = array_filter(oBattle.enemyUnits, function(_element, _index)
				{
					// 1. O inimigo precisa estar vivo
					if (_element.hp <= 0) return false; 
				
					// 2. Regra de Cobertura: Checa se há alguém na frente dele
					var _isBlocked = false;
					for (var i = 0; i < array_length(oBattle.enemyUnits); i++) 
					{
						var _frontGuard = oBattle.enemyUnits[i];
					
						// Bloqueia SE houver um inimigo vivo, na mesma coluna, numa linha menor (mais à frente)
						if (_frontGuard.hp > 0 && _frontGuard.gridCol == _element.gridCol && _frontGuard.gridRow < _element.gridRow) 
						{
							_isBlocked = true;
							break; // Para o loop assim que encontrar o bloqueador
						}
					}
				
					return !_isBlocked; // Retorna true (alvejável) se NÃO estiver bloqueado
				});
			}
		}
		else
		{
			// Se estiver mirando em aliados (magias de cura, etc), apenas filtra os mortos
			targetSide = array_filter(oBattle.partyUnits, function(_element, _index)
			{
				return _element.hp > 0;
			});
		}
		
		//Move between targets
		if(targetAll == false) //Single target mode
		{
			if(_moveH == 1) targetIndex++
			if(_moveH == -1) targetIndex--
			
			//Wrap
			var _targets = array_length(targetSide)
			if(targetIndex < 0) targetIndex = _targets - 1
			if(targetIndex > (_targets - 1)) targetIndex = 0
			
			//Identify target
			activeTarget = targetSide[targetIndex]
			
			//Toggle all mode
			if(activeAction.targetAll == MODE.VARIES) && (_keyToggle) //Switch to all mode
			{
				targetAll = true
			}
		}
		else
		{
			//Target all mode
			activeTarget = targetSide
			if(activeAction.targetAll == MODE.VARIES) && (_keyToggle) //Switch to single mode
			{
				targetAll = false
			}
		}
		
		//Confirm Action
		if(_keyConfirm)
		{
			with(oBattle) BeginAction(cursor.activeUser, cursor.activeAction, cursor.activeTarget)
			with(oMenu) instance_destroy()
			active = false
			confirmDelay = 0
		}
		
		//Cancel & return to menu
		if(_keyCancel) && (!_keyConfirm)
		{
			with(oMenu) active = true
			active = false
			confirmDelay = 0
		}
	}
}