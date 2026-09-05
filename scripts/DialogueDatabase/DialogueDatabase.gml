// Dialogue Database
// Maps NPC IDs to their configuration and dialogue state.

function DialogueDatabaseInit() {
    global.dialogue_db = {};

    // --- Register NPCs ---
    // Format: DialogueRegisterNpc(npc_id, display_name, starting_node, source_file)
    DialogueRegisterNpc("emo",   "Emo NPC",  "EmoMeetsPlayer", "Dialogue/dialogue.yarn");
    // Add more NPCs here as they are created
}

function DialogueRegisterNpc(_id, _display_name, _start_node, _source_file) {
    global.dialogue_db[$ _id] = {
        display_name: _display_name,
        start_node:   _start_node,
        source_file:  _source_file,
        variables:    {}   // Per-NPC dialogue variables (flags, counters, etc.)
    };
}

// Get and set per-NPC dialogue variables from Yarn scripts
// Usage in Yarn: <<setDialogVar("emo", "met_player", true)>>
function DialogueSetVar(_npc_id, _key, _value) {
    if (struct_exists(global.dialogue_db, _npc_id))
        global.dialogue_db[$ _npc_id].variables[$ _key] = _value;
}

function DialogueGetVar(_npc_id, _key, _default = undefined) {
    if (!struct_exists(global.dialogue_db, _npc_id)) return _default;
    return global.dialogue_db[$ _npc_id].variables[$ _key] ?? _default;
}

// Look up a live NPC instance by its ID string
function DialogueFindNpc(_npc_id) {
    var _found = noone;
    with (obj_npc) {
        if (self._npc_id == _npc_id) { _found = id; break; }
    }
    return _found;
}
