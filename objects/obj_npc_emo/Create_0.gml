event_inherited();
// This tells the interaction system to use our new open_chatterbox function
_npc_id = "emo";

var _db = global.dialogue_db[$ _npc_id];
_event = {
    type:      "chatterbox",
    _function: function(_args) {
        var _met = DialogueGetVar("emo", "met_player", false);
        var _node = _met ? "EmoMeetsPlayer" : "Start";
        DialogueSetVar("emo", "met_player", true);
        open_chatterbox([_node, "emo"]);
    },
    _value:    [],
};