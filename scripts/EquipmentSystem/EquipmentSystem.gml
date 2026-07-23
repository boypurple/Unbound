/// @file   EquipmentSystem.gml
/// @desc   Equipment System — Database loader, character equipment container,
///         equip/unequip helpers, and stat calculation.
///         Step 1: equipment.csv schema + LoadEquipmentDatabase()
///         Step 2: EquipItem(), UnequipItem(), CalculateCharacterStats()

// ============================================================
// EQUIPMENT SLOT MACROS
// Keep slot names centralised so UI/helpers never use raw strings.
// ============================================================

#macro EQUIP_SLOT_HAND "hand"   // Weapons, off-hand items, gloves/gauntlets
#macro EQUIP_SLOT_BODY "body"   // Armour, clothing, accessories

// ============================================================
// EQUIPMENT STAT MODIFIER KEYS
// Used to read from equipment structs in a consistent way.
// ============================================================

// Flat modifiers  (added directly to the base stat)
#macro EQUIP_STAT_OFF_FLAT    "offense_flat"
#macro EQUIP_STAT_DEF_FLAT    "defense_flat"
#macro EQUIP_STAT_WRATH_FLAT  "wrath_flat"
#macro EQUIP_STAT_LUCK_FLAT   "luck_flat"
#macro EQUIP_STAT_SPEED_FLAT  "speed_flat"

// Percentage modifiers  (0.10 == +10%; applied after all flats)
#macro EQUIP_STAT_OFF_PCT     "offense_pct"
#macro EQUIP_STAT_DEF_PCT     "defense_pct"
#macro EQUIP_STAT_WRATH_PCT   "wrath_pct"
#macro EQUIP_STAT_LUCK_PCT    "luck_pct"
#macro EQUIP_STAT_SPEED_PCT   "speed_pct"

// ============================================================
// EQUIPMENT DATABASE
//   global.equipment_database is a struct keyed by ItemID string.
//   An ItemID may appear in BOTH global.item_database AND here.
//
//   Each entry shape:
//   {
//       id           : string,
//       slot_type    : string,          // EQUIP_SLOT_HAND | EQUIP_SLOT_BODY
//       name         : string,
//       offense_flat : real,
//       defense_flat : real,
//       wrath_flat   : real,
//       luck_flat    : real,
//       speed_flat   : real,
//       offense_pct  : real,            // 0.10 = +10%
//       defense_pct  : real,
//       wrath_pct    : real,
//       luck_pct     : real,
//       speed_pct    : real,
//       is_two_handed: bool,            // Reserved for future two-handed weapon logic
//       description  : string
//   }
// ============================================================

// ============================================================
// EQUIPMENT CHARACTER CONTAINER
//
//   global.character_equipments is a struct keyed by char_id string.
//   Each value:
//   {
//       hand : undefined | string,  // item_id of equipped item, or undefined
//       body : undefined | string
//   }
// ============================================================


// ------------------------------------------------------------
/// @func   LoadEquipmentDatabase()
/// @desc   Reads equipment.csv from the Included Files bundle and
///         populates global.equipment_database.
///         Call this once during game initialisation (e.g. in oUi Create).
// ------------------------------------------------------------
function LoadEquipmentDatabase()
{
    global.equipment_database = {};

    if (!file_exists("equipment.csv"))
    {
        show_debug_message("[EquipmentSystem] ERROR: equipment.csv not found!");
        return;
    }

    var _grid        = load_csv("equipment.csv");
    var _grid_height = ds_grid_height(_grid);

    // Row 0 = column headers (human-readable names)
    // Row 1 = type hints (string / real / bool — informational only, not parsed)
    // Row 2+ = actual data
    for (var i = 2; i < _grid_height; i++)
    {
        var _id            = ds_grid_get(_grid,  0, i); // string
        var _slot_type     = ds_grid_get(_grid,  1, i); // string
        var _name          = ds_grid_get(_grid,  2, i); // string
        var _off_flat      = real(ds_grid_get(_grid,  3, i));
        var _def_flat      = real(ds_grid_get(_grid,  4, i));
        var _wrath_flat    = real(ds_grid_get(_grid,  5, i));
        var _luck_flat     = real(ds_grid_get(_grid,  6, i));
        var _speed_flat    = real(ds_grid_get(_grid,  7, i));
        var _off_pct       = real(ds_grid_get(_grid,  8, i)) / 100; // stored as 10 → 0.10
        var _def_pct       = real(ds_grid_get(_grid,  9, i)) / 100;
        var _wrath_pct     = real(ds_grid_get(_grid, 10, i)) / 100;
        var _luck_pct      = real(ds_grid_get(_grid, 11, i)) / 100;
        var _speed_pct     = real(ds_grid_get(_grid, 12, i)) / 100;
        var _is_two_handed = (string_lower(ds_grid_get(_grid, 13, i)) == "true");
        var _desc          = ds_grid_get(_grid, 14, i); // string

        var _equip_struct =
        {
            id            : _id,
            slot_type     : _slot_type,
            name          : _name,
            offense_flat  : _off_flat,
            defense_flat  : _def_flat,
            wrath_flat    : _wrath_flat,
            luck_flat     : _luck_flat,
            speed_flat    : _speed_flat,
            offense_pct   : _off_pct,
            defense_pct   : _def_pct,
            wrath_pct     : _wrath_pct,
            luck_pct      : _luck_pct,
            speed_pct     : _speed_pct,
            is_two_handed : _is_two_handed,
            description   : _desc
        };

        global.equipment_database[$ _id] = _equip_struct;

        show_debug_message("[EquipmentSystem] Loaded: " + _id
            + " | slot: " + _slot_type
            + " | OFF+" + string(_off_flat)
            + " DEF+" + string(_def_flat));
    }

    ds_grid_destroy(_grid);
    show_debug_message("[EquipmentSystem] Equipment database loaded successfully. ("
        + string(array_length(variable_struct_get_names(global.equipment_database)))
        + " entries)");
}


// ------------------------------------------------------------
/// @func   GetEquipmentFromDatabase(_item_id)
/// @desc   Returns the equipment struct for the given ItemID, or
///         undefined if the ID is not in the equipment database.
/// @param  {string} _item_id
/// @return {struct|undefined}
// ------------------------------------------------------------
function GetEquipmentFromDatabase(_item_id)
{
    if (!variable_struct_exists(global.equipment_database, _item_id))
    {
        show_debug_message("[EquipmentSystem] WARNING: '"
            + string(_item_id) + "' not found in equipment_database.");
        return undefined;
    }
    return global.equipment_database[$ _item_id];
}


// ------------------------------------------------------------
/// @func   IsItemEquippable(_item_id)
/// @desc   Returns true if the item ID exists in the equipment database.
/// @param  {string} _item_id
/// @return {bool}
// ------------------------------------------------------------
function IsItemEquippable(_item_id)
{
    return variable_struct_exists(global.equipment_database, _item_id);
}


// ------------------------------------------------------------
/// @func   GetCharacterEquipments(_char_id)
/// @desc   Returns (and lazily initialises) the equipment container
///         for a character.  Never returns undefined.
/// @param  {string|real} _char_id
/// @return {struct}  { hand: undefined|string, body: undefined|string }
// ------------------------------------------------------------
function GetCharacterEquipments(_char_id)
{
    var _key = string(_char_id);

    if (!variable_struct_exists(global.character_equipments, _key))
    {
        global.character_equipments[$ _key] =
        {
            hand : undefined,
            body : undefined
        };
    }

    return global.character_equipments[$ _key];
}


// ------------------------------------------------------------
/// @func   InitEquipmentSystem()
/// @desc   Initialises global.character_equipments if needed.
///         Call this once during game start, before LoadEquipmentDatabase().
// ------------------------------------------------------------
function InitEquipmentSystem()
{
    if (!variable_global_exists("character_equipments")
        || !is_struct(global.character_equipments))
    {
        global.character_equipments = {};
    }
    show_debug_message("[EquipmentSystem] InitEquipmentSystem complete.");
}


// ============================================================
// STEP 2 — EQUIPMENT HELPER FUNCTIONS
// ============================================================


// ------------------------------------------------------------
/// @func   EquipItem(_char_id, _item_id)
/// @desc   Equips _item_id to the correct slot for _char_id.
///
///         Rules:
///           • Item MUST exist in global.equipment_database.
///           • If the target slot is already occupied, the old
///             item is swapped back into the character's inventory
///             first (using AddItemToCharacterInventory).  If the
///             inventory is full for the swap-back, the old item
///             is spawned as a ground pickup at obj_player position.
///           • The item is NOT removed from inventory here —
///             the caller (UI) is responsible for calling
///             RemoveItemFromCharacterInventory before or after,
///             depending on its flow.  This keeps the function
///             pure and side-effect-minimal.
///
/// @param  {string}  _char_id   Character name key (e.g. "Chris")
/// @param  {string}  _item_id   ItemID string (e.g. "sword")
/// @return {bool}    true on success, false on failure
// ------------------------------------------------------------
function EquipItem(_char_id, _item_id)
{
    // ── 1. Validate: item must be in the equipment database ──
    if (!IsItemEquippable(_item_id))
    {
        show_debug_message("[EquipItem] FAIL: '"
            + string(_item_id) + "' is not equippable.");
        return false;
    }

    var _equip_data = GetEquipmentFromDatabase(_item_id);
    var _slot       = _equip_data.slot_type; // "hand" or "body"

    // ── 2. Get (or create) the character's equipment container ──
    var _container = GetCharacterEquipments(_char_id);

    // ── 3. Handle slot already occupied — swap old item out ──
    var _currently_equipped = _container[$ _slot];
    if (_currently_equipped != undefined)
    {
        // Try to return old item to inventory first
        var _space = GetCharacterInventorySpaceRemaining(_char_id);
        if (_space > 0)
        {
            AddItemToCharacterInventory(_char_id, _currently_equipped, 1);
            show_debug_message("[EquipItem] Swapped out '"
                + string(_currently_equipped) + "' → inventory.");
        }
        else
        {
            // Inventory full — drop old item at player's feet
            if (instance_exists(obj_player))
            {
                SpawnItemPickup(obj_player.x, obj_player.y, _currently_equipped);
                show_debug_message("[EquipItem] Inventory full! Dropped '"
                    + string(_currently_equipped) + "' at player position.");
            }
            else
            {
                // Fallback: room centre (should rarely happen)
                SpawnItemPickup(room_width / 2, room_height / 2, _currently_equipped);
                show_debug_message("[EquipItem] WARNING: obj_player not found. Dropped '"
                    + string(_currently_equipped) + "' at room centre.");
            }
        }
    }

    // ── 4. Write the new item into the slot ──
    _container[$ _slot] = _item_id;

    show_debug_message("[EquipItem] '" + string(_char_id)
        + "' equipped '" + string(_item_id)
        + "' in slot [" + string(_slot) + "].");
    return true;
}


// ------------------------------------------------------------
/// @func   UnequipItem(_char_id, _slot)
/// @desc   Removes the item from _slot for _char_id and returns
///         it to the inventory.  If the inventory is FULL, the
///         item is spawned as an obj_item_pickup at obj_player (x, y).
///
/// @param  {string}  _char_id  Character name key (e.g. "Chris")
/// @param  {string}  _slot     Slot to clear: EQUIP_SLOT_HAND or EQUIP_SLOT_BODY
/// @return {bool}    true if an item was unequipped, false if slot was empty
// ------------------------------------------------------------
function UnequipItem(_char_id, _slot)
{
    var _container = GetCharacterEquipments(_char_id);
    var _item_id   = _container[$ _slot];

    // ── 1. Nothing equipped in this slot ──
    if (_item_id == undefined)
    {
        show_debug_message("[UnequipItem] Slot [" + string(_slot)
            + "] is already empty for '" + string(_char_id) + "'.");
        return false;
    }

    // ── 2. Clear the slot immediately ──
    _container[$ _slot] = undefined;

    // ── 3. Try to give the item back to the character's inventory ──
    var _space = GetCharacterInventorySpaceRemaining(_char_id);
    if (_space > 0)
    {
        AddItemToCharacterInventory(_char_id, _item_id, 1);
        show_debug_message("[UnequipItem] '" + string(_char_id)
            + "' unequipped '" + string(_item_id)
            + "' from [" + string(_slot) + "] → inventory.");
    }
    else
    {
        // ── 4. Inventory full — spawn at player's world position ──
        if (instance_exists(obj_player))
        {
            SpawnItemPickup(obj_player.x, obj_player.y, _item_id);
            show_debug_message("[UnequipItem] Inventory full! '"
                + string(_item_id) + "' spawned at player position.");
        }
        else
        {
            SpawnItemPickup(room_width / 2, room_height / 2, _item_id);
            show_debug_message("[UnequipItem] WARNING: obj_player not found. '"
                + string(_item_id) + "' spawned at room centre.");
        }
    }

    return true;
}


// ------------------------------------------------------------
/// @func   CalculateCharacterStats(_char_id, _base_stats)
/// @desc   Applies all active equipment modifiers to a copy of
///         _base_stats and returns the final computed stats.
///
///         Formula (per stat):
///           Total = (Base + ΣFlat) * (1 + ΣPct)
///
///         Mapping between party struct fields and equipment keys:
///           party.strength ↔ offense_flat / offense_pct
///           party.def      ↔ defense_flat / defense_pct
///           party.wrath    ↔ wrath_flat   / wrath_pct
///           party.iq       ↔ luck_flat    / luck_pct
///           party.spd      ↔ speed_flat   / speed_pct
///
/// @param  {string} _char_id     Character name key (e.g. "Chris")
/// @param  {struct} _base_stats  A party member struct (or any struct with
///                               the five stat fields above).
/// @return {struct}  A NEW struct with computed total values:
///                   { strength, def, wrath, iq, spd }
///                   All other fields from _base_stats are NOT included —
///                   only the five combat stats are returned.
// ------------------------------------------------------------
function CalculateCharacterStats(_char_id, _base_stats)
{
    // ── 1. Accumulate flat and percentage modifiers ──
    var _off_flat   = 0; var _off_pct   = 0;
    var _def_flat   = 0; var _def_pct   = 0;
    var _wrath_flat = 0; var _wrath_pct = 0;
    var _luck_flat  = 0; var _luck_pct  = 0;
    var _spd_flat   = 0; var _spd_pct   = 0;

    var _container = GetCharacterEquipments(_char_id);
    var _slots     = [EQUIP_SLOT_HAND, EQUIP_SLOT_BODY];

    for (var i = 0; i < array_length(_slots); i++)
    {
        var _equipped_id = _container[$ _slots[i]];
        if (_equipped_id == undefined) continue;

        var _e = GetEquipmentFromDatabase(_equipped_id);
        if (_e == undefined) continue;

        _off_flat   += _e.offense_flat;
        _def_flat   += _e.defense_flat;
        _wrath_flat += _e.wrath_flat;
        _luck_flat  += _e.luck_flat;
        _spd_flat   += _e.speed_flat;

        _off_pct    += _e.offense_pct;
        _def_pct    += _e.defense_pct;
        _wrath_pct  += _e.wrath_pct;
        _luck_pct   += _e.luck_pct;
        _spd_pct    += _e.speed_pct;
    }

    // ── 2. Apply formula: (Base + ΣFlat) × (1 + ΣPct) ──
    //    Results are floored to keep all stats as whole integers,
    //    consistent with the existing battle system.
    var _final_strength = floor((_base_stats.strength + _off_flat)   * (1 + _off_pct));
    var _final_def      = floor((_base_stats.def      + _def_flat)   * (1 + _def_pct));
    var _final_wrath    = floor((_base_stats.wrath    + _wrath_flat) * (1 + _wrath_pct));
    var _final_iq       = floor((_base_stats.iq       + _luck_flat)  * (1 + _luck_pct));
    var _final_spd      = floor((_base_stats.spd      + _spd_flat)   * (1 + _spd_pct));

    show_debug_message("[CalcStats] " + string(_char_id)
        + " | STR: " + string(_base_stats.strength) + "→" + string(_final_strength)
        + " | DEF: " + string(_base_stats.def)      + "→" + string(_final_def)
        + " | WRT: " + string(_base_stats.wrath)    + "→" + string(_final_wrath)
        + " | IQ:  " + string(_base_stats.iq)       + "→" + string(_final_iq)
        + " | SPD: " + string(_base_stats.spd)      + "→" + string(_final_spd));

    // ── 3. Return only the five computed combat stats ──
    return {
        strength : _final_strength,
        def      : _final_def,
        wrath    : _final_wrath,
        iq       : _final_iq,
        spd      : _final_spd
    };
}


// ------------------------------------------------------------
/// @func   GetEquippedItemInSlot(_char_id, _slot)
/// @desc   Convenience getter. Returns the item_id string
///         currently equipped in _slot, or undefined if empty.
/// @param  {string} _char_id
/// @param  {string} _slot    EQUIP_SLOT_HAND | EQUIP_SLOT_BODY
/// @return {string|undefined}
// ------------------------------------------------------------
function GetEquippedItemInSlot(_char_id, _slot)
{
    return GetCharacterEquipments(_char_id)[$ _slot];
}


// ------------------------------------------------------------
/// @func   IsSlotOccupied(_char_id, _slot)
/// @desc   Returns true if the character has something equipped
///         in _slot, false if the slot is empty (undefined).
/// @param  {string} _char_id
/// @param  {string} _slot    EQUIP_SLOT_HAND | EQUIP_SLOT_BODY
/// @return {bool}
// ------------------------------------------------------------
function IsSlotOccupied(_char_id, _slot)
{
    return (GetCharacterEquipments(_char_id)[$ _slot] != undefined);
}
