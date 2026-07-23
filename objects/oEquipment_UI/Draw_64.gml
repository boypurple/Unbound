/// @desc Draw Equipment System UI

if (global.gamePaused)
{
    draw_set_colour(c_black);
    draw_set_alpha(0.75);
    draw_rectangle(0, 0, RESOLUTION_W, RESOLUTION_H, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_font(fnMother3);
    draw_set_valign(fa_top);
    draw_set_halign(fa_center);

    // ── 1. MAIN PANEL ──
    var panel_xscale = 1.4;
    var panel_yscale = 1.4;

    var base_w = sprite_get_width(InventoryTray);
    var base_h = sprite_get_height(InventoryTray);

    var scaled_w = base_w * panel_xscale;
    var scaled_h = base_h * panel_yscale;

    var _panelX = (RESOLUTION_W - scaled_w) / 2;
    var _panelY = (RESOLUTION_H - scaled_h) / 2;

    draw_sprite_ext(InventoryTray, 0, _panelX, _panelY, panel_xscale, panel_yscale, 0, c_white, 1);

    // ── 2. PARTY MEMBER TABS ──
    draw_set_halign(fa_left);
    draw_set_valign(fa_bottom);

    var _player_tab_yoffset = -30;
    var _player_tab_spacing = 500 / max(1, array_length(global.party));

    for (var i = 0; i < array_length(global.party); i++)
    {
        var _tabX = _panelX + (_player_tab_spacing * i);
        var _tabY = _panelY + _player_tab_yoffset;

        if (playerTab == i)
        {
            draw_set_colour(c_yellow);
            draw_text(_tabX, _tabY, global.party[i].name);
            if (equipmentCursor == 0)
            {
                draw_sprite(sCursor, 0, _tabX - 24, _tabY - 18);
            }
        }
        else
        {
            draw_set_colour(c_white);
            draw_set_alpha(0.7);
            draw_text(_tabX, _tabY, global.party[i].name);
            draw_set_alpha(1);
        }
    }

    // Header Title
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    draw_set_colour(c_yellow);
    draw_text(_panelX + scaled_w - 20, _panelY - 20, "EQUIPMENT MENU");

    // Current Character
    var _party_member = global.party[playerTab];
    var _char_id = _party_member.name;
    var _equip_container = GetCharacterEquipments(_char_id);

    // ── 3. EQUIPMENT SLOTS (LEFT COLUMN) ──
    var _slotStartX = _panelX + 40;
    var _slotStartY = _panelY + 50;
    var _slotW = 280;
    var _slotH = 90;
    var _slotGapY = 20;

    var _slots = [EQUIP_SLOT_HAND, EQUIP_SLOT_BODY];
    var _slot_labels = ["HAND SLOT (Weapon/Shield)", "BODY SLOT (Armor/Acc)"];

    draw_set_valign(fa_top);

    for (var s = 0; s < 2; s++)
    {
        var _slotY = _slotStartY + (s * (_slotH + _slotGapY));
        var _slot_type = _slots[s];
        var _equipped_item_id = _equip_container[$ _slot_type];

        // Slot Frame Background
        var _is_selected = (equipmentCursor >= 1 && selectedSlotIndex == s);
        draw_set_colour(_is_selected ? c_yellow : c_white);
        draw_set_alpha(_is_selected ? 0.3 : 0.15);
        draw_rectangle(_slotStartX, _slotY, _slotStartX + _slotW, _slotY + _slotH, false);
        draw_set_alpha(1.0);
        draw_rectangle(_slotStartX, _slotY, _slotStartX + _slotW, _slotY + _slotH, true);

        // Selection Cursor
        if (_is_selected && equipmentCursor != 3)
        {
            draw_sprite(sCursor, 0, _slotStartX - 28, _slotY + 30);
        }

        // Slot Title
        draw_set_halign(fa_left);
        draw_set_colour(_is_selected ? c_yellow : c_white);
        draw_text(_slotStartX + 10, _slotY + 8, _slot_labels[s]);

        // Equipped Item Info
        if (_equipped_item_id != undefined)
        {
            var _item_info = GetItemFromDatabase(_equipped_item_id);
            var _equip_info = GetEquipmentFromDatabase(_equipped_item_id);

            var _icon = _item_info[$ "icon"];
            var _img_idx = _item_info[$ "image_index"] ?? 0;

            if (_icon != undefined && sprite_exists(_icon))
            {
                draw_sprite_ext(_icon, _img_idx, _slotStartX + 20, _slotY + 40, 1.2, 1.2, 0, c_white, 1);
            }

            draw_set_colour(c_white);
            draw_text(_slotStartX + 60, _slotY + 40, _item_info.name);

            // Short Stat Summary
            if (_equip_info != undefined)
            {
                var _stat_summary = "";
                if (_equip_info.offense_flat != 0) _stat_summary += "OFF+" + string(_equip_info.offense_flat) + " ";
                if (_equip_info.defense_flat != 0) _stat_summary += "DEF+" + string(_equip_info.defense_flat) + " ";
                if (_equip_info.wrath_flat != 0)   _stat_summary += "WRT+" + string(_equip_info.wrath_flat) + " ";
                if (_equip_info.luck_flat != 0)    _stat_summary += "LCK+" + string(_equip_info.luck_flat) + " ";
                if (_equip_info.speed_flat != 0)   _stat_summary += "SPD+" + string(_equip_info.speed_flat) + " ";

                if (_equip_info.offense_pct != 0) _stat_summary += "OFF+" + string(round(_equip_info.offense_pct * 100)) + "% ";
                if (_equip_info.defense_pct != 0) _stat_summary += "DEF+" + string(round(_equip_info.defense_pct * 100)) + "% ";
                if (_equip_info.wrath_pct != 0)   _stat_summary += "WRT+" + string(round(_equip_info.wrath_pct * 100)) + "% ";
                if (_equip_info.luck_pct != 0)    _stat_summary += "LCK+" + string(round(_equip_info.luck_pct * 100)) + "% ";
                if (_equip_info.speed_pct != 0)   _stat_summary += "SPD+" + string(round(_equip_info.speed_pct * 100)) + "% ";

                draw_set_colour(c_lime);
                draw_text(_slotStartX + 60, _slotY + 62, _stat_summary);
            }
        }
        else
        {
            draw_set_colour(c_gray);
            draw_text(_slotStartX + 60, _slotY + 42, "< Empty Slot >");
        }
    }

    // ── 4. STAT CALCULATIONS & LIVE DIFF PREVIEW ──
    var _current_stats = CalculateCharacterStats(_char_id, _party_member);

    // Build Candidate List if in state 3
    var _target_slot_name = (selectedSlotIndex == 0) ? EQUIP_SLOT_HAND : EQUIP_SLOT_BODY;
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
                if (_eq != undefined && _eq.slot_type == _target_slot_name)
                {
                    array_push(_candidates, _inv_item);
                }
            }
        }
    }

    // Preview Stats Calculation (if hovering a candidate item)
    var _preview_stats = undefined;
    var _hovered_candidate = undefined;

    if (equipmentCursor == 3 && array_length(_candidates) > 0 && candidateIndex < array_length(_candidates))
    {
        _hovered_candidate = _candidates[candidateIndex];

        // Simulate equip in slot
        var _old_item_in_slot = _equip_container[$ _target_slot_name];
        _equip_container[$ _target_slot_name] = _hovered_candidate.id;

        _preview_stats = CalculateCharacterStats(_char_id, _party_member);

        // Revert simulation
        _equip_container[$ _target_slot_name] = _old_item_in_slot;
    }

    // Draw Stats Box (Middle Column)
    var _statBoxX = _panelX + 340;
    var _statBoxY = _panelY + 50;
    var _statBoxW = 270;
    var _statBoxH = 200;

    draw_set_colour(c_white);
    draw_set_alpha(0.15);
    draw_rectangle(_statBoxX, _statBoxY, _statBoxX + _statBoxW, _statBoxY + _statBoxH, false);
    draw_set_alpha(1.0);
    draw_rectangle(_statBoxX, _statBoxY, _statBoxX + _statBoxW, _statBoxY + _statBoxH, true);

    draw_set_halign(fa_left);
    draw_set_colour(c_yellow);
    draw_text(_statBoxX + 15, _statBoxY + 10, "CHARACTER STATS");

    var _stat_names = ["Offense", "Defense", "Wrath", "Luck (IQ)", "Speed"];
    var _cur_vals   = [_current_stats.strength, _current_stats.def, _current_stats.wrath, _current_stats.iq, _current_stats.spd];
    var _pre_vals   = (_preview_stats != undefined) ? [_preview_stats.strength, _preview_stats.def, _preview_stats.wrath, _preview_stats.iq, _preview_stats.spd] : undefined;

    for (var k = 0; k < 5; k++)
    {
        var _lineY = _statBoxY + 40 + (k * 28);
        draw_set_colour(c_white);
        draw_text(_statBoxX + 15, _lineY, _stat_names[k] + ":");

        var _cur = _cur_vals[k];
        draw_text(_statBoxX + 130, _lineY, string(_cur));

        if (_pre_vals != undefined)
        {
            var _pre = _pre_vals[k];
            var _diff = _pre - _cur;

            if (_diff > 0)
            {
                draw_set_colour(c_lime);
                draw_text(_statBoxX + 175, _lineY, "-> " + string(_pre) + " (+" + string(_diff) + ")");
            }
            else if (_diff < 0)
            {
                draw_set_colour(c_red);
                draw_text(_statBoxX + 175, _lineY, "-> " + string(_pre) + " (" + string(_diff) + ")");
            }
            else
            {
                draw_set_colour(c_gray);
                draw_text(_statBoxX + 175, _lineY, "-> " + string(_pre));
            }
        }
    }

    // ── 5. SLOT ACTION MENU (CURSOR == 2) ──
    if (equipmentCursor == 2)
    {
        var _menuX = _slotStartX + _slotW + 15;
        var _menuY = _slotStartY + (selectedSlotIndex * (_slotH + _slotGapY));
        var _menuW = 160;
        var _menuH = 75;

        draw_set_colour(c_black);
        draw_set_alpha(0.9);
        draw_rectangle(_menuX, _menuY, _menuX + _menuW, _menuY + _menuH, false);
        draw_set_alpha(1.0);
        draw_set_colour(c_yellow);
        draw_rectangle(_menuX, _menuY, _menuX + _menuW, _menuY + _menuH, true);

        var _opts = ["Equip / Change", "Unequip"];
        for (var o = 0; o < 2; o++)
        {
            var _optY = _menuY + 12 + (o * 30);
            if (slotOptionSelected == o)
            {
                draw_set_colour(c_yellow);
                draw_sprite(sCursor, 0, _menuX + 6, _optY);
            }
            else
            {
                draw_set_colour(c_white);
            }
            draw_text(_menuX + 30, _optY, _opts[o]);
        }
    }

    // ── 6. CANDIDATE ITEMS LIST PANEL (CURSOR == 3) ──
    if (equipmentCursor == 3)
    {
        var _candX = _panelX + 630;
        var _candY = _panelY + 50;
        var _candW = 270;
        var _candH = 260;

        draw_set_colour(c_black);
        draw_set_alpha(0.9);
        draw_rectangle(_candX, _candY, _candX + _candW, _candY + _candH, false);
        draw_set_alpha(1.0);
        draw_set_colour(c_yellow);
        draw_rectangle(_candX, _candY, _candX + _candW, _candY + _candH, true);

        draw_set_halign(fa_left);
        draw_set_colour(c_yellow);
        draw_text(_candX + 15, _candY + 10, "SELECT EQUIPMENT");

        if (array_length(_candidates) == 0)
        {
            draw_set_colour(c_gray);
            draw_text(_candX + 15, _candY + 45, "No equippable items");
            draw_text(_candX + 15, _candY + 68, "in inventory for slot.");
        }
        else
        {
            for (var c = 0; c < array_length(_candidates); c++)
            {
                var _cItem = _candidates[c];
                var _cItemData = GetItemFromDatabase(_cItem.id);
                var _cLineY = _candY + 42 + (c * 32);

                if (candidateIndex == c)
                {
                    draw_set_colour(c_yellow);
                    draw_sprite(sCursor, 0, _candX + 8, _cLineY + 2);
                }
                else
                {
                    draw_set_colour(c_white);
                }

                draw_text(_candX + 32, _cLineY, _cItemData.name + " (x" + string(_cItem.stack) + ")");
            }
        }
    }

    // ── 7. DESCRIPTION FOOTER PANEL ──
    var _descX = _panelX + 40;
    var _descY = _panelY + scaled_h - 110;
    var _descW = scaled_w - 80;
    var _descH = 65;

    draw_set_colour(c_white);
    draw_set_alpha(0.15);
    draw_rectangle(_descX, _descY, _descX + _descW, _descY + _descH, false);
    draw_set_alpha(1.0);
    draw_rectangle(_descX, _descY, _descX + _descW, _descY + _descH, true);

    var _desc_text = "";
    if (_hovered_candidate != undefined)
    {
        var _eq_data = GetEquipmentFromDatabase(_hovered_candidate.id);
        if (_eq_data != undefined) _desc_text = _eq_data.description;
    }
    else
    {
        var _selected_slot_name = (selectedSlotIndex == 0) ? EQUIP_SLOT_HAND : EQUIP_SLOT_BODY;
        var _equipped_id = _equip_container[$ _selected_slot_name];
        if (_equipped_id != undefined)
        {
            var _eq_data = GetEquipmentFromDatabase(_equipped_id);
            if (_eq_data != undefined) _desc_text = _eq_data.description;
        }
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
    draw_text_ext(_descX + 15, _descY + 12, _desc_text, 18, _descW - 30);

    // ── 8. FOOTER CONTROLS INSTRUCTION ──
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    draw_set_colour(c_white);
    draw_text(RESOLUTION_W - 32, RESOLUTION_H - 16, "[A/D] Switch Character | [Space/Enter] Select | [Esc] Back");
}
