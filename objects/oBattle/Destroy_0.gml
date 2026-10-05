// A batalha acabou (vitória ou derrota)
instance_activate_all()

// Write back stats from partyUnits to global.party so HP/PP/XP persist
if (variable_instance_exists(id, "partyUnits") && is_array(partyUnits)) {
    for(var i = 0; i < array_length(partyUnits); i++) {
        var _pu = partyUnits[i];
        if (instance_exists(_pu) && i < array_length(global.party)) {
            var _gp = global.party[i];
            _gp.hp = _pu.hp;
            _gp.hpMax = _pu.hpMax;
            _gp.pp = _pu.pp;
            _gp.ppMax = _pu.ppMax;
            _gp.xp = _pu.xp;
            _gp.lvl = _pu.lvl;
            _gp.strength = _pu.strength;
            _gp.def = _pu.def;
            _gp.poisoned = _pu.poisoned;
            _gp.ponum = _pu.ponum;
            _gp.poison = _pu.poison;
            _gp.itchy = _pu.itchy;
            _gp.itnum = _pu.itnum;
            _gp.blind = _pu.blind;
            _gp.sleep = _pu.sleep;
            _gp.stunned = _pu.stunned;
            _gp.mutatedHand = _pu.mutatedHand;
            _gp.noNut = _pu.noNut;
            _gp.soreT = _pu.soreT;
        }
    }
}

// Only destroy the specific overworld enemy (obj_slime / obj_dummy) that started this battle.
// `creator` is passed from the enemy's collision event -> obj_encounter_transition -> NewEncounter().
var _creator = variable_instance_exists(id, "creator") ? creator : noone;
show_debug_message("[oBattle] Destroy: creator=" + string(_creator)
    + " exists=" + string(instance_exists(_creator))
    + " object=" + (instance_exists(_creator) ? object_get_name(_creator.object_index) : "n/a"));

if (instance_exists(_creator) && (_creator.object_index == obj_slime || _creator.object_index == obj_dummy))
{
    instance_destroy(_creator);
    show_debug_message("[oBattle] Destroyed overworld enemy " + string(_creator));
}
else
{
    show_debug_message("[oBattle] WARNING: creator is not an overworld enemy, nothing destroyed");
}