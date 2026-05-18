switch (_intro_timer) {
	case 0:
		if (_intro_animation < 24) {
			_intro_animation += 0.4;
		}
		else {
			_intro_timer++;
			_intro_animation = 0;
		}
		break;
	case 1:
		if (_intro_animation < 9) {
			_intro_animation += 0.4;
		}
		else if (!audio_is_playing(snd_battle_start)) {
			_intro_timer++;
			_intro_animation = 0;
		}
		break;
	case 2:
		if (!audio_is_playing(snd_troublesome_guys)) {
			audio_play_sound(snd_troublesome_guys, 3, true)
		}
		if (_intro_animation < 9) {
			_intro_animation += 0.4;
		}
		else {
			_intro_timer++;
		}
		break;
}

if (_intro_timer == 3) {
	switch (_state) {
		case "menu":
			if (keyboard_check_pressed(ord("Z"))) {
				_state = _actions[_choice];
				audio_play_sound(snd_click, 3, false)
			}
			if (keyboard_check_pressed(vk_left)  && _choice > 0) {
				audio_play_sound(snd_click, 3, false)
				_choice--;
			}
			if (keyboard_check_pressed(vk_right)  && _choice < 4) {
				audio_play_sound(snd_click, 3, false)
				_choice++;
			}
			break;
		case "attack":
			if (keyboard_check_pressed(ord("X"))) {
				_state = "menu";
			}
			if (keyboard_check_pressed(ord("Z"))) {
				_action = "attack";
				if (_enemies_sorted[0]._speed < obj_player._speed) {
					_action_choose("YouAttack");
				}
				else {
					_action_choose("EnemyAttack");
				}
			}
			if (keyboard_check_pressed(vk_left) && _target > 0) {
				while (_enemies[_target-1].hp <= 0 && _target > 0) {
					_target--;
				}
				
				_target--;
				audio_play_sound(snd_click, 3, false);
			}
			if (keyboard_check_pressed(vk_right) && _target+1 < array_length(_enemies)) {
				while (_enemies[_target+1].hp <= 0 && _target+1 < array_length(_enemies)) {
					_target++;
				}
				
				while (_enemies[_target].hp <= 0) {
					_target--;
				}
				
				_target++;
				audio_play_sound(snd_click, 3, false);
			}
			break;
		case "item":
			if (keyboard_check_pressed(ord("Z"))) {
				_action = "item";
				_current_item = _items[_item_index[0]+_item_index[1]];
				_action_choose("ItemUse");
			}
			if (keyboard_check_pressed(ord("X"))) {
				_state = "menu";
			}
			if (keyboard_check_pressed(vk_left)) {
				if (_item_index[0] == 1) {
					_item_index[0] = 0;
				}
				else {
					_item_index[0] = 1;
				}
			}
			if (keyboard_check_pressed(vk_right)) {
				if (_item_index[0] == 0) {
					_item_index[0] = 1;
				}
				else {
					_item_index[0] = 0;
				}
			}
			if (keyboard_check_pressed(vk_up) && _item_index[1] > 0) {
				_item_index[1] -= 2;
				if (_item_index[1] % 4 == 0) {
					_cursor_index = 4;
					offset -= 4;
				}
			}
			if (keyboard_check_pressed(vk_down) && _item_index[0]+_item_index[1]+1 < array_length(_items)) {
				_item_index[1] += 2;
				if (_item_index[1] % 4 == 0) {
					_cursor_index = 1;
					offset += 4;
				}
			}
			break;
		case "dialog":
			if (keyboard_check_pressed(ord("Z"))) {
				if (_text_index < string_length(_text_full)) {
					_text_index = string_length(_text_full);
					_text = _text_full;
				}
				else {
					switch (_current_dialog) {
						case "YouAttack":
							_action_choose("DamageToEnemy");
							break;
						case "DamageToEnemy":
							while (_enemies[_current_enemy-1].hp <= 0 && _current_enemy <= array_length(_enemies) && !_win) {
								_current_enemy++;
								if (_enemies[_current_enemy-1].hp <= 0 && _current_enemy == array_length(_enemies)) {
									_win = true
								}
							}
							
							if (_win) {
								_action_choose("YouWin");
							}
							
							
							if (_enemies[_current_enemy-1].turn && !_win) {
								_action_choose("EnemyAttack");
							}
							
							else if (!_win) {
								for (_current_enemy = 1; _current_enemy <= array_length(_enemies); _current_enemy++) {
									_enemies[_current_enemy-1].turn = true;
								}
								
								while (_enemies[_target].hp <= 0) {
									_target++;
								}
							
								_current_enemy = 1;
							
								_your_turn = true;
								_state = "menu";
							}
							break;
						case "EnemyAttack":
							_action_choose("DamageToYou");
							break;
						case "DamageToYou":
							_enemies[_current_enemy-1].turn = false;
							while (_enemies[_current_enemy-1].hp <= 0 && !(_current_enemy == array_length(_enemies))) {
								_current_enemy++;
							}

							if (_current_enemy < array_length(_enemies)) {
								_current_enemy++;
							}
							
							if (_your_turn && _action == "attack") {
								_action_choose("YouAttack");
							}
							else if (_enemies[_current_enemy-1].turn && _enemies[_current_enemy-1].hp > 0) {
								_action_choose("EnemyAttack");
							}
							else if (!_your_turn && !_enemies[_current_enemy-1].turn) {
								
								for (_current_enemy = 1; _current_enemy <= array_length(_enemies); _current_enemy++) {
									_enemies[_current_enemy-1].turn = true;
								}
								
								while (_enemies[_target].hp <= 0) {
									if (_target+1 == array_length(_enemies)) {
										_target = 0;
										break;
									}
									else {
										show_message("aaaaa");
										_target++;
									}
								}
								
								if (_current_enemy == array_length(_enemies)) {
									_target = 0;
								}
								_current_enemy = 1;
							
								_your_turn = true;
								_state = "menu";
							}
							break;
						case "ItemUse":
							while (_enemies[_current_enemy-1].hp <= 0 && !(_current_enemy == array_length(_enemies))) {
								_current_enemy++;
							}
							_action_choose("EnemyAttack");
							break;
						case "YouDied":
							break;
						case "YouWin":
							break;
						default:
							for (_current_enemy = 1;_current_enemy <= array_length(_enemies); _current_enemy++) {
								_enemies[_current_enemy-1].turn = true;
							}
							
							while (_enemies[_target].hp <= 0) {
								_target++;
							}
							
							_current_enemy = 1;
							
							_your_turn = true;
							_state = "menu";
							break;
					}
				}
			}
			
			break;
	}
	
	if (ceil(_damage)) {
		if (_hp_timer < _hp_decrease_rate) {
			_hp_timer++;
		}
		
		else {
			if (_timer_3 != 8) {
		
				if (_damage > 0.0) {
					_hp_1 -= 0.125;
					_damage -= 0.125;
				}
			
				if (_damage < 0.0) {
					_hp_1 += 0.125;
					_damage += 0.125;
				}
				
				_timer_3++;
			}
			
			else {

				_timer_3 = 0;
				_hp_timer = 0;
			}
		}
	}
	

	
	if (!floor(_hp_1)) {
		_action_choose("YouDied");
	}

	_hp_str = string(floor(_hp_1));
	
	if (keyboard_check_pressed(ord("F"))) {
		show_message(_hp_timer);
	}
}
