if(global.gamePaused)
{
	keyUp = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))
	keyDown = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))
	keyLeft = keyboard_check_direct(vk_left) || keyboard_check_direct(ord("A"))
	keyRight = keyboard_check_direct(vk_right) || keyboard_check_direct(ord("D"))
	keyActivate = keyboard_check_pressed(vk_space)
	keyDeactivate = keyboard_check_pressed(vk_escape)
	if(!global.config && !global.partyMenu)
	{
		pauseOptionSelected += (keyDown - keyUp)
		if(pauseOptionSelected >= array_length(pauseOption)) pauseOptionSelected = 0
		if(pauseOptionSelected < 0) pauseOptionSelected = array_length(pauseOption) - 1
	
		if(keyActivate)
		{
			switch(pauseOptionSelected)
			{
				case 0: //Continue
					global.gamePaused = false
					with(all)
					{
						gamePausedImageSpeed = image_speed
						image_speed = 0
					}
					break
				
				case 1: //Party
					global.partyMenu = true
					break
				
				case 2: //Goods
					Goods()
					break
			
				case 3: //Settings
					global.config = true
					break
				
				case 4: //Save
					SaveGame()
					break
				
				case 5: //Quit
					game_restart()
					break
			}
		}
	}
	else
	{
		if(global.config)
		{
			switch(settingsSide)
			{
				case 0: //Icons
					settingsOptionSelected += (keyDown - keyUp)
					if(settingsOptionSelected >= array_length(settingsOption)) settingsOptionSelected = 0
					if(settingsOptionSelected < 0) settingsOptionSelected = array_length(settingsOption) - 1
					if(keyActivate)
					{
						switch(settingsOptionSelected)
						{
							case 0: //Audio
								global.configAudio = true
								global.configVideo = false
								global.configControl = false
								if(keyActivate)
								{
									settingsSide = 1
								}
								break
				
							case 1: //Video
								global.configAudio = false
								global.configVideo = true
								global.configControl = false
								break
				
							case 2: //Controls
								global.configAudio = false
								global.configVideo = false
								global.configControl = true
								break
			
							case 3: //Quit
								global.configAudio = false
								global.configVideo = false
								global.configControl = false
								global.config = false
								break
						}
					}
					if(keyDeactivate)
					{
						global.configAudio = false
						global.configVideo = false
						global.configControl = false
						global.config = false
						settingsSide = 0
					}
					break
				
				case 1: //Functions
					if(global.configAudio)
					{
						audioOptionSelected += (keyDown - keyUp)
						if(audioOptionSelected >= array_length(audioOptionName)) audioOptionSelected = 0
						if(audioOptionSelected < 0) audioOptionSelected = array_length(audioOptionName) - 1
						switch(audioOptionSelected)
						{
							case 0: //Volume
								global.volume += (keyRight - keyLeft)
								global.volume = clamp(global.volume, 0, 100)
								break
							
							case 1: //SE Volume
								global.volumeSE += (keyRight - keyLeft)
								global.volumeSE = clamp(global.volumeSE, 0, 100)
								break
						}
						if(keyRight || keyLeft) audioOptionName = ["Volume: " + string(global.volume), "SE Volume: " + string(global.volumeSE)]
					}
					if(keyDeactivate)
					{
						global.configAudio = false
						global.configVideo = false
						global.configControl = false
						settingsSide = 0
					}
					break
			}
		}
		if(global.partyMenu)
		{
			switch(partySide)
			{
				case 0: //Icons
					partyOptionSelected += (keyDown - keyUp)
					if(partyOptionSelected >= array_length(global.party)) partyOptionSelected = 0
					if(partyOptionSelected < 0) partyOptionSelected = array_length(global.party) - 1
					if(keyActivate)
					{
						global.partySkillMenu = true
						if(keyActivate)
						{
							partySide = 1
						}
					}
					if(keyDeactivate)
					{
						global.partySkillMenu = false
						global.partyMenu = false

						partySide = 0
					}
					break
				
				case 1: //Functions
					if(global.partySkillMenu)
					{
						skillOptionSelected += (keyDown - keyUp)
						if(skillOptionSelected >= array_length(global.party[partyOptionSelected].actions)) skillOptionSelected = 0
						if(skillOptionSelected < 0) skillOptionSelected = array_length(global.party[partyOptionSelected].actions) - 1
						if(keyActivate)
						{
							if(global.party[partyOptionSelected].actions[skillOptionSelected].useOverwold)
							{
								global.party[partyOptionSelected].actions[skillOptionSelected].func(global.party[partyOptionSelected], global.party[partyOptionSelected])
							}
						}
					}
					if(keyDeactivate)
					{
						global.partyMenu = false
						global.partySkillMenu = false
						partySide = 0
					}
					break
			}
		}
	}
}