/// @desc Equipment UI Logic & Input Handling

if (global.gamePaused)
{
    var keyUp         = keyboard_check_pressed(vk_up)     || keyboard_check_pressed(ord("W"));
    var keyDown       = keyboard_check_pressed(vk_down)   || keyboard_check_pressed(ord("S"));
    var keyLeft       = keyboard_check_pressed(vk_left)   || keyboard_check_pressed(ord("A"));
    var keyRight      = keyboard_check_pressed(vk_right)  || keyboard_check_pressed(ord("D"));
    var keyActivate   = keyboard_check_pressed(vk_space)  || keyboard_check_pressed(vk_enter);
    var keyDeactivate = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("X"));
    var isInput       = keyUp || keyDown || keyLeft || keyRight || keyActivate || keyDeactivate;

    var _char_id = global.party[playerTab].name;

    if (isInput)
    {
        // ----------------------------------------------------
        // CURSOR 0: Party Tab Switching
        // ----------------------------------------------------
        if (equipmentCursor == 0)
        {
            playerTab += (keyRight - keyLeft);
            playerTab = clamp(playerTab, 0, array_length(global.party) - 1);

            if (keyDown)
            {
                equipmentCursor = 1;
                selectedSlotIndex = 0;
            }

            if (keyDeactivate)
            {
                instance_deactivate_object(id);
                global.gameMenu = true;
                if (instance_exists(oUi)) oUi.instance_equipment = noone;
            }
        }
        // ----------------------------------------------------
        // CURSOR 1: Slot Selection (0 = Hand, 1 = Body)
        // ----------------------------------------------------
        else if (equipmentCursor == 1)
        {
            // Switch tabs with left/right
            var _oldTab = playerTab;
            playerTab += (keyRight - keyLeft);
            playerTab = clamp(playerTab, 0, array_length(global.party) - 1);

            if (keyUp)
            {
                if (selectedSlotIndex > 0)
                {
                    selectedSlotIndex--;
                }
                else
                {
                    equipmentCursor = 0; // Go back to top party tab
                }
            }
            else if (keyDown)
            {
                if (selectedSlotIndex < 1)
                {
                    selectedSlotIndex++;
                }
            }

            if (keyActivate)
            {
                equipmentCursor = 2; // Open slot action menu (Equip / Unequip)
                slotOptionSelected = 0;
            }

            if (keyDeactivate)
            {
                equipmentCursor = 0;
            }
        }
        // ----------------------------------------------------
        // CURSOR 2: Slot Action Menu (0 = Equip/Change, 1 = Unequip)
        // ----------------------------------------------------
        else if (equipmentCursor == 2)
        {
            slotOptionSelected += (keyDown - keyUp);
            slotOptionSelected = clamp(slotOptionSelected, 0, 1);

            var _slot_name = (selectedSlotIndex == 0) ? EQUIP_SLOT_HAND : EQUIP_SLOT_BODY;

            if (keyDeactivate)
            {
                equipmentCursor = 1;
            }

            if (keyActivate)
            {
                if (slotOptionSelected == 0) // Equip / Change
                {
                    equipmentCursor = 3;
                    candidateIndex = 0;
                }
                else if (slotOptionSelected == 1) // Unequip
                {
                    UnequipItem(_char_id, _slot_name);
                    equipmentCursor = 1;
                }
            }
        }
        // ----------------------------------------------------
        // CURSOR 3: Candidate Item Selection
        // ----------------------------------------------------
        else if (equipmentCursor == 3)
        {
            var _slot_name = (selectedSlotIndex == 0) ? EQUIP_SLOT_HAND : EQUIP_SLOT_BODY;
            var _inv_data = GetCharacterInventory(_char_id);
            var _candidates = [];

            if (_inv_data != undefined && variable_struct_exists(_inv_data, "items"))
            {
                for (var i = 0; i < array_length(_inv_data.items); i++)
                {
                    var _inv_item = _inv_data.items[i];
                    if (IsItemEquippable(_inv_item.id))
                    {
                        var _eq = GetEquipmentFromDatabase(_inv_item.id);
                        if (_eq != undefined && _eq.slot_type == _slot_name)
                        {
                            array_push(_candidates, _inv_item);
                        }
                    }
                }
            }

            var _candidate_count = array_length(_candidates);

            if (_candidate_count > 0)
            {
                candidateIndex += (keyDown - keyUp);
                if (candidateIndex < 0) candidateIndex = _candidate_count - 1;
                if (candidateIndex >= _candidate_count) candidateIndex = 0;

                if (keyActivate)
                {
                    var _chosen_item_id = _candidates[candidateIndex].id;

                    // Remove 1 item from character's inventory first
                    RemoveItemFromCharacterInventory(_char_id, _chosen_item_id, 1);

                    // Equip to character slot (EquipItem handles swapping old item back or spawning on ground if full)
                    EquipItem(_char_id, _chosen_item_id);

                    equipmentCursor = 1;
                }
            }

            if (keyDeactivate)
            {
                equipmentCursor = 1;
            }
        }
    }

    frame += 1;
}
