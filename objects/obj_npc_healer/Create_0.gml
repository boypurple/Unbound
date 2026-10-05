event_inherited();
_npc_id = "healer";

var _db = global.dialogue_db[$ _npc_id];
_event = {
    type:      "chatterbox",
    _function: function(_args) {
        open_chatterbox(["HealerStart", "healer"]);
    },
    _value:    [],
};
