event_inherited();
// This tells the interaction system to use our new open_chatterbox function
_npc_id = "emo";

var _db = global.dialogue_db[$ _npc_id];
_event = {
    type:      "chatterbox",
    _function: open_chatterbox,
    _value:    [_db.start_node, _npc_id],
};