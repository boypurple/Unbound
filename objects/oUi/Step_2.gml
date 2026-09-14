if(global.gameMenu)
{
	keyUp = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))
	keyDown = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))
	keyLeft = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))
	keyRight = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))
	keyActivate = keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)
	keyDeactivate = keyboard_check_pressed(vk_backspace) || keyboard_check_pressed(vk_shift)

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

				case 2: //Inventory
					instance_inventory = instance_create_layer(0, 0, global.Layer_UI, oInventory_UI)
					instance_inventory.instance_inventory = instance_inventory
					instance_activate_object(instance_inventory);
					global.gameMenu = false
					break

				case 3: //Equipment
					instance_equipment = instance_create_layer(0, 0, global.Layer_UI, oEquipment_UI)
					instance_equipment.instance_equipment = instance_equipment
					instance_activate_object(instance_equipment);
					global.gameMenu = false
					break

				case 4: //Settings
					global.config = true
					break

				case 5: //Save
					SaveGame()
					break

				case 6: //Quit
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
			if(equipSwapTimer > 0) equipSwapTimer -= 1
			switch(partySide)
			{
				case 0: //Icons
					partyOptionSelected += (keyDown - keyUp)
					if(partyOptionSelected >= array_length(global.party)) partyOptionSelected = 0
					if(partyOptionSelected < 0) partyOptionSelected = array_length(global.party) - 1
					if(keyActivate)
					{
						partySide = 1
                        partyActionSelected = 0
					}
					if(keyDeactivate)
					{
						global.partyMenu = false
						partySide = 0
					}
					break

                case 1: // Action selection (Use / Equip)
                    partyActionSelected += (keyDown - keyUp)
                    var _maxAction = 1
                    if(global.party[partyOptionSelected].name == "Michael") _maxAction = 0 // Michael has no equip
                    if(partyActionSelected > _maxAction) partyActionSelected = 0
                    if(partyActionSelected < 0) partyActionSelected = _maxAction
                    
                    if(keyActivate)
                    {
                        if(partyActionSelected == 0)
                        {
                            global.partySkillMenu = true
                            partySide = 2
                            skillOptionSelected = 0
                        }
                        else
                        {
                            partySide = 3
                            equipState = 0
                            equipSlotSelected = 0
                            equipPoolSelected = 0
                        }
                    }
                    if(keyDeactivate)
                    {
                        partySide = 0
                    }
                    break

				case 2: //Use Skills
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
						global.partySkillMenu = false
						partySide = 1
					}
					break

                case 3: //Equip Skills
                    var _char = global.party[partyOptionSelected]
                    
                    // Build equipCategorySlots array (swappable skills only)
                    equipCategorySlots = []
                    var _slots = _char.actions
                    for(var i=0; i<array_length(_slots); i++) {
                        if(_slots[i].swappable) {
                            array_push(equipCategorySlots, { index: i, action: _slots[i] })
                        }
                    }
                    
                    if (equipState == 0) // Browsing slots
                    {
                        equipSlotSelected += (keyDown - keyUp)
                        if(equipSlotSelected >= array_length(equipCategorySlots)) equipSlotSelected = 0
                        if(equipSlotSelected < 0) equipSlotSelected = max(0, array_length(equipCategorySlots) - 1)
                        
                        if(keyActivate && array_length(equipCategorySlots) > 0)
                        {
                            equipCategoryFilter = equipCategorySlots[equipSlotSelected].action.subMenu
                            equipState = 1
                            equipPoolSelected = 0
                        }
                        if(keyDeactivate)
                        {
                            partySide = 1
                        }
                    }
                    else if (equipState == 1) // Browsing pool
                    {
                        // Filter pool
                        var _filteredPool = []
                        for(var i=0; i<array_length(global.vziSkillPool); i++) {
                            if(global.vziSkillPool[i].action.subMenu == equipCategoryFilter) {
                                array_push(_filteredPool, global.vziSkillPool[i])
                            }
                        }
                        
                        equipPoolSelected += (keyDown - keyUp)
                        if(equipPoolSelected >= array_length(_filteredPool)) equipPoolSelected = 0
                        if(equipPoolSelected < 0) equipPoolSelected = max(0, array_length(_filteredPool) - 1)
                        
                        if(keyActivate && array_length(_filteredPool) > 0)
                        {
                            var _selectedSkill = _filteredPool[equipPoolSelected].action
                            var _owner = VziSkillGetOwner(_selectedSkill)
                            
                            if(_owner != "") {
                                equipSwapMessage = "Already used by " + _owner + "!"
                                equipSwapTimer = 120
                            }
                            else {
                                // Swap
                                var _realIndex = equipCategorySlots[equipSlotSelected].index
                                VziSkillEquip(_char, _realIndex, _selectedSkill)
                                equipSwapMessage = "Equipped!"
                                equipSwapTimer = 60
                                equipState = 0
                            }
                        }
                        if(keyDeactivate)
                        {
                            equipState = 0
                        }
                    }
                    break
			}
		}
	}

}