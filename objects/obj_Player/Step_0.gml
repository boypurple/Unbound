// Character control in overworld.
var _debug_blocking = variable_global_exists("debug_ui_active") && global.debug_ui_active;

if(!global.gamePaused && !_debug_blocking)
{
	if (keyboard_check(vk_left) && !place_meeting(bbox_left, y-3, obj_block) && _status == "overworld") {
		x -= 3;
		facing_dir = 180;
	}

	if (keyboard_check(vk_right) && !place_meeting(bbox_right, y-3, obj_block) && _status == "overworld") {
		x += 3;
		facing_dir = 0;
	}

	if (keyboard_check(vk_up) && !place_meeting(x-3, bbox_top, obj_block) && _status == "overworld") {
		y -= 3;
		facing_dir = 90;
	}

	if (keyboard_check(vk_down) && !place_meeting(x-3, bbox_bottom, obj_block) && _status == "overworld") {
		y += 3;
		facing_dir = 270;
	}
	
	if(x != xprevious or y != yprevious)
	{
		for(var i = arraySize; i > 0; i--)
		{
			posX[i] = posX[i - 1]
			posY[i] = posY[i - 1]
		}
		
		posX[0] = x
		posY[0] = y
	}

	// Using animation when player is moving.
	if ((keyboard_check(vk_left) || keyboard_check(vk_right) || keyboard_check(vk_up) || keyboard_check(vk_down)) && _status == "overworld") {
		_animation = -1;
	}

	// Doesn't using animation otherwise.
	else {
		_animation = 0;
	}

	//// Enemy interaction.
	//if ((place_meeting(x+3, y+3, obj_slime) || place_meeting(x-3, y-3, obj_slime)) && _status == "overworld") {
	//	_status = "battle";
	//	_animation = 0;
	//	instance_create_depth(obj_camera._view_x, obj_camera._view_y, 0, obj_battle);
	//}

	// When you press Space (shared interact key, same as item pickups/menus)
	if (keyboard_check_pressed(vk_space)) {
		switch (_status) {
			case "overworld":
				// If there's an npc within interact range (radius check, not just touching)
				_current_npc = instance_nearest(x, y, obj_npc);
				if (instance_exists(_current_npc) && distance_to_object(_current_npc) <= NPC_INTERACT_RANGE) {
					// Talk to npc
					action(_current_npc._event);
				}
				else {
					open_dialog("No problem here.");
				}
				break;
		}
	}

	if (place_meeting(x+3, y+3, obj_event) || place_meeting(x-3, y-3, obj_event)) {
		_status = "cutscene";
		_current_event = instance_nearest(x, y, obj_event);
		_event_function = _current_event._event;
		play_cutscene(_event_function);
	}

	if (!instance_exists(obj_dialog_box) && _status != "battle") {
		_status = "overworld";
	}
}