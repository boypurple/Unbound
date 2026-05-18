function LoadGame(player)
{
	if (file_exists("save.txt"))
	{
		var file = file_text_open_read("save.txt");
		
		var json = file_text_read_string(file);
		
		show_debug_message(json);
		
		var array = json_parse(json);
		
		file_text_close(file);
		
		
		global.loaded = true
		global.coins = array.player_coins
		global.current_room = array.current_room
		//global.volume = array.player_volume
		//global.volumeSE = player_volume_se
		
		
		
		player._animation = array.player_anim
		player._sprite = array.player_sprite
		player._left = array.player_left
		player._right = array.player_right
		player._speed = array.player_speed
		player._status = array.player_status
		player._attack = array.player_attack

		player._current_npc = array.player_npc
		player._npc_function = array.player_npc_func

		player._current_event = array.player_event
		player._event_function = array.player_event_func
		
		player.x = array.player_x
		player.y = array.player_y
		
		
	}
}