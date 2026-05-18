randomize();

_sorting = function(_elm1, _elm2) {
	return _elm1._speed >= _elm2._speed
}

_action_choose = function(_dialog) {
	_text_index = 0;
	_text = "";
	_current_dialog = _dialog;
	_state = "dialog";
	
	switch (_current_dialog) {
		case "YouAttack":
			_text_full = "You attacked!";
			_sound = snd_you_attack
			audio_play_sound(_sound, 3, false);
			break;
		case "EnemyAttack":
			_text_full = $"{_enemies[_current_enemy-1]._name} attacked!";
			_sound = snd_enemy_attack
			audio_play_sound(_sound, 3, false);
			break;
		case "DamageToYou":
			var _enemy_added_damage = _enemies[_current_enemy-1]._attack / 10;
			var _enemy_random_damage = random_range(-(_enemy_added_damage), _enemy_added_damage);
			var _enemy_total_damage = int64(_enemies[_current_enemy-1]._attack + _enemy_random_damage);
			_damage += _enemy_total_damage;
			_text_full = $"{_enemy_total_damage} damage to you!";
			_sound = snd_you_damage;
			audio_play_sound(_sound, 3, false);
			break;
		case "DamageToEnemy":
			var _your_added_damage = obj_player._attack / 10;
			var _your_random_damage = random_range(-(_your_added_damage), _your_added_damage);
			var _your_total_damage = int64(obj_player._attack + _your_random_damage);
			_text_full = $"{_your_total_damage} damage to {_enemies[_target]._name}!";
			_enemies[_target].hp -= _your_total_damage;
			_sound = snd_enemy_damage;
			_your_turn = false;
			audio_play_sound(_sound, 3, false);
			break;
		case "ItemUse":
			_text_full = $"You used the {_current_item._name}!";
			_your_turn = false;
			break;
		case "YouDied":
			_text_full = "lol you died";
			break;
		case "YouWin":
			audio_stop_sound(snd_troublesome_guys);
			if (!audio_is_playing(snd_you_win)) {
				audio_play_sound(snd_you_win, 3, true);
			}
			_text_full = "YOU WIN!";
			break;
		default:
			break;
	}
}

_item_use = function(_item) {
	
}

_item_text_index = 0;

offset = 0;

_current_item = {};

_win = false;

_hp_1 = 110.0;
_hp_2 = 0.0;
_hp_3 = 0.0;
_hp_str = _hp_1;

_hp_decrease_rate = 60;
_hp_timer = 0;

_digits_a = 0;
_digits_b = 0;
_digits_c = 0;

_timer_1 = 0;
_timer_2 = 0;
_timer_3 = 0;


_copy_a_1 = 0;
_copy_a_2 = 0;

_copy_b_1 = 0;
_copy_b_2 = 0;

_healing = false;

_digit_sprites[0] = spr_0;
_digit_sprites[1] = spr_1;
_digit_sprites[2] = spr_2;
_digit_sprites[3] = spr_3;
_digit_sprites[4] = spr_4;
_digit_sprites[5] = spr_5;
_digit_sprites[6] = spr_6;
_digit_sprites[7] = spr_7;
_digit_sprites[8] = spr_8;
_digit_sprites[9] = spr_9;

_action = "";


draw_set_font(fnMother3);
image_speed = 0.25

_layer = layer_get_id("Background");
_background = layer_background_get_id(_layer);
layer_background_blend(_background, c_grey);

audio_play_sound(snd_battle_start, 1, false);
obj_player._status = "battle";

_intro_timer = 0;
_effect = noone;
_effect_timer = 0;
_state = "dialog";
_actions = ["attack", "item", "psi", "guard", "run"];

_items = [{_name: "cookie1", effect: "heal", target: "playerOne", heal: 5},
			{_name: "cookie2", effect: "heal", target: "playerOne", heal: 5},
			{_name: "cookie3", effect: "heal", target: "playerOne", heal: 5},
			{_name: "cookie4", effect: "heal", target: "playerOne", heal: 5},
			{_name: "cookie5", effect: "heal", target: "playerOne", heal: 5}];
_item_boxes = [];
_item_box = [];
_item_box_index = 0;

for (var _i = 1; _i <= array_length(_items); _i++) {
	if (_i % 5 == 0) {
		array_copy(_item_boxes, _item_box_index, [_item_box], 0, 4);
		_item_box_index++;
		_item_box = [];
	}
	else {
		array_push(_item_box, _items[_i-1]);
	}
}

_item_box_index = 0;

_psi = [];

_bool = false;
_item_to_use = 0;
_item_index = [0,0];
_cursor_index = 1;

_current_dialog = "";

_damage = 0;

_choice = 0;
_target = 0;
_current_enemy = 1;
_your_turn = true;
_hp_loss = 0;
_mp_loss = 0;
_enemy_action = "";
_test = {};

_enemies = [{_name: "enemy", sprite: sEnemy, hp: 10, _attack: 4, _speed: 2, actions: ["attack", "nothing"], animation: 1.0, turn: true},
			{_name: "enemy", sprite: sEnemy, hp: 10, _attack: 4, _speed: 2, actions: ["attack", "nothing"], animation: 1.0, turn: true}];
_enemies_sorted = [{_name: "enemy", sprite: sEnemy, hp: 10, _attack: 2, _speed: 2, actions: ["attack", "nothing"], animation: 1.0, turn: true},
					{_name: "enemy", sprite: sEnemy, hp: 10, _attack: 2, _speed: 2, actions: ["attack", "nothing"], animation: 1.0, turn: true}];
array_sort(_enemies_sorted, _sorting);
_text_full = "an enemy appeared!";
_text = "";
_text_index = 0;
_next_act = battle_menu;

_enemy_amount = array_length(_enemies);

_sound = snd_enemy_damage;
_sound_playing = false;


_intro_animation = 0.0;
_death_animation = 1.0;

_button = 0;
_sprite = 0;
_color = c_white;

_hp_length = 0;
