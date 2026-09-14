/// @desc Pause Screen
if(global.gameMenu)
{
	if(!global.config && !global.partyMenu)
	{
		draw_set_colour(c_black)
		draw_set_alpha(0.75)
		draw_rectangle(0, 0, RESOLUTION_W, RESOLUTION_H, false)
		draw_set_alpha(1)
		draw_set_colour(c_white)
		draw_set_font(fnMother3)
		draw_set_valign(fa_top)
		draw_set_halign(fa_center)
	
		draw_text(96, 32, "Game Paused")
		for(var i = 0; i < array_length(pauseOption); i++)
		{
			var _print = ""
			if(i == pauseOptionSelected)
			{
				draw_set_colour(c_yellow)
				_print += pauseOptionName[i]
				draw_sprite(sCursor, 0, 48, 96 + (i * 96))
			}
			else
			{
				draw_set_colour(c_white)
				_print += pauseOptionName[i]
				draw_set_alpha(0.7)
			}
			draw_text(96, 128 + (i * 96), pauseOptionName[i])
			draw_sprite(pauseOption[i], 0, 96, 96 + (i * 96))
		
			draw_set_alpha(1)
		}
	
		draw_set_halign(fa_right)
		draw_text(1248, 688, "Bank: $" + string(global.coins) + "   Cash: $" + string(global.cash))
	}
	else if(global.config)
	{
		draw_set_colour(c_black)
		draw_set_alpha(0.75)
		draw_rectangle(0, 0, RESOLUTION_W, RESOLUTION_H, false)
		draw_set_alpha(1)
		draw_set_colour(c_white)
		draw_set_font(fnMother3)
		draw_set_valign(fa_top)
		draw_set_halign(fa_center)
	
		draw_text(96, 32, "Settings")
		for(var i = 0; i < array_length(settingsOption); i++)
		{
			var _print = ""
			if(i == settingsOptionSelected)
			{
				draw_set_colour(c_yellow)
				_print += settingsOptionName[i]
				draw_sprite(sCursor, 0, 48, 96 + (i * 96))
			}
			else
			{
				draw_set_colour(c_white)
				_print += settingsOptionName[i]
				draw_set_alpha(0.7)
			}
			draw_set_halign(fa_center)
			draw_text(96, 128 + (i * 96), settingsOptionName[i])
			draw_sprite(settingsOption[i], 0, 96, 96 + (i * 96))
		
			draw_set_alpha(1)
			
			draw_set_halign(fa_right)
			draw_text(1248, 688, "Press [Backspace] to go back")
		}
		
		if(global.configAudio)
		{
			for(var i = 0; i < array_length(audioOptionName); i++)
			{
				var _print = ""
				if(i == audioOptionSelected)
				{
					draw_set_colour(c_yellow)
					_print += audioOptionName[i]
					draw_sprite(sCursor, 0, 328, 96 + (i * 96))
				}
				else
				{
					draw_set_colour(c_white)
					_print += audioOptionName[i]
					draw_set_alpha(0.7)
				}
				draw_set_halign(fa_left)
				draw_text(360, 96 + (i * 96), audioOptionName[i])
		
				draw_set_alpha(1)
			}
		}
	}
	else if(global.partyMenu)
	{
		draw_set_colour(c_black)
		draw_set_alpha(0.75)
		draw_rectangle(0, 0, RESOLUTION_W, RESOLUTION_H, false)
		draw_set_alpha(1)
		draw_set_colour(c_white)
		draw_set_font(fnMother3)
		draw_set_valign(fa_top)
		draw_set_halign(fa_center)
	
		draw_text(96, 32, "Party")
		for(var i = 0; i < array_length(global.party); i++)
		{
			var _print = ""
			if(i == partyOptionSelected && partySide == 0)
			{
				draw_set_colour(c_yellow)
				_print += global.party[i].name
				draw_sprite(sCursor, 0, 48, 96 + (i * 96))
			}
			else
			{
				draw_set_colour(c_white)
				_print += global.party[i].name
				if (i != partyOptionSelected) draw_set_alpha(0.7)
			}
			draw_set_halign(fa_left)
			var _scale = 48 / max(48, sprite_get_height(partyOption[i]))
			draw_sprite_ext(partyOption[i], 0, 112, 120 + (i * 96), _scale, _scale, 0, c_white, 1)
			draw_text(96, 128 + (i * 96), global.party[i].name)
		
			draw_set_alpha(1)
			
			draw_set_halign(fa_right)
			draw_text(1248, 688, "Press [Backspace] to go back")
		}
		
        if (partySide == 1) // Choose Action
        {
            var _actions = ["Use Skills", "Equip Skills"]
            if (global.party[partyOptionSelected].name == "Michael") _actions = ["Use Skills"]
            for(var i = 0; i < array_length(_actions); i++)
            {
                if(i == partyActionSelected)
                {
                    draw_set_colour(c_yellow)
                    draw_sprite(sCursor, 0, 328, 96 + (i * 32))
                }
                else draw_set_colour(c_white)
                draw_set_halign(fa_left)
                draw_text(360, 96 + (i * 32), _actions[i])
            }
        }
		else if(partySide == 2) // Use Skills
		{
			for(var i = 0; i < array_length(global.party[partyOptionSelected].actions); i++)
			{
				if(i == skillOptionSelected)
				{
					draw_set_colour(c_yellow)
                    draw_sprite(sCursor, 0, 328, 96 + (i * 32))
				}
				else
				{
					draw_set_colour(c_white)
					draw_set_alpha(0.7)
				}
				draw_set_halign(fa_left)
				draw_text(360, 96 + (i * 32), global.party[partyOptionSelected].actions[i].name)

				draw_set_alpha(1)
			}
		}
        else if (partySide == 3) // Equip Skills
        {
            draw_set_halign(fa_left)
            draw_set_colour(c_white)
            draw_text(360, 32, "Equipped Skills")
            draw_text(760, 32, "Available Skills")
            
            // Left Panel (Equipped)
            for(var i = 0; i < array_length(equipCategorySlots); i++)
            {
                if(i == equipSlotSelected && equipState == 0)
                {
                    draw_set_colour(c_yellow)
                    draw_sprite(sCursor, 0, 328, 96 + (i * 32))
                }
                else if (i == equipSlotSelected && equipState == 1)
                {
                    draw_set_colour(c_aqua) // Selected for swapping
                }
                else draw_set_colour(c_white)
                
                var _slotAction = equipCategorySlots[i].action
                draw_text(360, 96 + (i * 32), _slotAction.name + " (" + _slotAction.subMenu + ")")
            }
            
            // Right Panel (Pool)
            if (equipState == 1)
            {
                var _filteredPool = []
                for(var i=0; i<array_length(global.vziSkillPool); i++) {
                    if(global.vziSkillPool[i].action.subMenu == equipCategoryFilter) {
                        array_push(_filteredPool, global.vziSkillPool[i])
                    }
                }
                
                for(var i = 0; i < array_length(_filteredPool); i++)
                {
                    var _skill = _filteredPool[i].action
                    var _owner = VziSkillGetOwner(_skill)
                    
                    if (i == equipPoolSelected)
                    {
                        draw_set_colour(c_yellow)
                        draw_sprite(sCursor, 0, 728, 96 + (i * 32))
                    }
                    else if (_owner != "" && _owner != global.party[partyOptionSelected].name)
                    {
                        draw_set_colour(c_gray)
                    }
                    else draw_set_colour(c_white)
                    
                    var _text = _skill.name
                    if (_owner != "" && _owner != global.party[partyOptionSelected].name) _text += " [" + _owner + "]"
                    
                    draw_text(760, 96 + (i * 32), _text)
                }
            }
            
            if (equipSwapTimer > 0)
            {
                draw_set_halign(fa_center)
                draw_set_colour(c_red)
                draw_text(RESOLUTION_W/2, 600, equipSwapMessage)
            }
        }
	}
}