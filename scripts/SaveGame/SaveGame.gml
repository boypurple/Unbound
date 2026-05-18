function SaveGame(player)
{
	var player_data = 
	{
		player_coins : global.coins,
		
		//These will be required later to save user volume settings.
		
		//player_volume : global.volume,
		//player_volume_se : global.volumeSE,
		
		player_anim : player._animation,
		player_sprite: player._sprite,
		player_left: player._left,
		player_right: player._right,
		player_speed: player._speed,
		player_status: player._status,
		player_attack : player._attack,

		player_npc : player._current_npc,
		player_npc_func: player._npc_function,

		player_event : player._current_event,
		player_event_func : player._event_function,
		
		player_x : player.x,
		player_y : player.y,
		
		current_room : room
	};

	
	var _string = json_stringify(player_data);
	show_debug_message(_string);
	var _file = file_text_open_write("save.txt");
	file_text_write_string(_file, _string);
	file_text_close(_file);
	
	
}