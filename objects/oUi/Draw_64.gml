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
			draw_text(1248, 688, "Press [Esc] to go back")
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
			if(i == partyOptionSelected)
			{
				draw_set_colour(c_yellow)
				_print += global.party[i].name
				draw_sprite(sCursor, 0, 48, 96 + (i * 96))
			}
			else
			{
				draw_set_colour(c_white)
				_print += global.party[i].name
				draw_set_alpha(0.7)
			}
			draw_set_halign(fa_left)
			draw_sprite(partyOption[i], 0, 112, 120 + (i * 96))
			draw_text(96, 128 + (i * 96), global.party[i].name)
		
			draw_set_alpha(1)
			
			draw_set_halign(fa_right)
			draw_text(1248, 688, "Press [Esc] to go back")
		}
		
		if(global.partySkillMenu)
		{
			for(var i = 0; i < array_length(global.party[partyOptionSelected].actions); i++)
			{
				var _print = ""
				if(i == skillOptionSelected)
				{
					draw_set_colour(c_yellow)
					_print += global.party[partyOptionSelected].actions[i].name
				}
				else
				{
					draw_set_colour(c_white)
					_print += global.party[partyOptionSelected].actions[i].name
					draw_set_alpha(0.7)
				}
				draw_set_halign(fa_left)
				draw_text(360, 96 + (i * 32), global.party[partyOptionSelected].actions[i].name)

				draw_set_alpha(1)
			}
		}
	}
}