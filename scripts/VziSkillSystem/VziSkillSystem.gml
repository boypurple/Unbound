/// @func VziSkillGetOwner(action)
/// Returns the name of the party member who currently has this skill equipped,
/// or "" if no one has it.
function VziSkillGetOwner(_action)
{
    for(var i = 0; i < array_length(global.party); i++)
    {
        var _member = global.party[i]
        for(var j = 0; j < array_length(_member.actions); j++)
        {
            if(_member.actions[j] == _action && _action.swappable)
                return _member.name
        }
    }
    return ""
}

/// @func VziSkillCountInCategory(partyMember, category)
/// Returns how many swappable VZI skills the party member has in a given subMenu category.
function VziSkillCountInCategory(_member, _category)
{
    var _count = 0
    for(var i = 0; i < array_length(_member.actions); i++)
    {
        if(_member.actions[i].subMenu == _category && _member.actions[i].swappable)
            _count++
    }
    return _count
}

/// @func VziSkillEquip(partyMember, slotIndex, newAction)
/// Replaces the skill at slotIndex in partyMember.actions with newAction.
function VziSkillEquip(_member, _slotIndex, _newAction)
{
    _member.actions[_slotIndex] = _newAction
}

// Global VZI skill pool - all swappable VZI skills available in the game.
// Each entry: { action: <actionLibrary ref>, unlockedBy: "CharacterName" or "" }
// "unlockedBy" tracks which character originally earned this skill (for display).
global.vziSkillPool = [
    // Offensive
    { action: global.actionLibrary.stenchA,    unlockedBy: "Chris" },
    { action: global.actionLibrary.stenchB,    unlockedBy: "Chris" },
    { action: global.actionLibrary.stenchY,    unlockedBy: "Chris" },
    { action: global.actionLibrary.stenchO,    unlockedBy: "Chris" },
    { action: global.actionLibrary.nukeA,      unlockedBy: "Chris" },
    { action: global.actionLibrary.nukeB,      unlockedBy: "Chris" },
    { action: global.actionLibrary.nukeY,      unlockedBy: "Chris" },
    { action: global.actionLibrary.nukeO,      unlockedBy: "Chris" },
    { action: global.actionLibrary.lightningA, unlockedBy: "Chris" },
    { action: global.actionLibrary.lightningB, unlockedBy: "Chris" },
    { action: global.actionLibrary.lightningY, unlockedBy: "Chris" },
    { action: global.actionLibrary.lightningO, unlockedBy: "Chris" },
    { action: global.actionLibrary.poisonA,    unlockedBy: "Chris" },
    { action: global.actionLibrary.poisonB,    unlockedBy: "Chris" },
    { action: global.actionLibrary.poisonY,    unlockedBy: "Chris" },
    { action: global.actionLibrary.poisonO,    unlockedBy: "Chris" },
    { action: global.actionLibrary.nocturneA,  unlockedBy: "Chris" },
    { action: global.actionLibrary.nocturneB,  unlockedBy: "Chris" },
    { action: global.actionLibrary.nocturneY,  unlockedBy: "Chris" },
    { action: global.actionLibrary.shitstormO, unlockedBy: "Chris" },
    // Recovery
    { action: global.actionLibrary.fixUpA,     unlockedBy: "Chris" },
    { action: global.actionLibrary.fixUpB,     unlockedBy: "Chris" },
    { action: global.actionLibrary.fixUpY,     unlockedBy: "Chris" },
    { action: global.actionLibrary.fixUpO,     unlockedBy: "Chris" },
    { action: global.actionLibrary.cureA,      unlockedBy: "Chris" },
    { action: global.actionLibrary.cureO,      unlockedBy: "Chris" },
    { action: global.actionLibrary.drainA,     unlockedBy: "Chris" },
    { action: global.actionLibrary.drainO,     unlockedBy: "Chris" },
    // Assist
    { action: global.actionLibrary.ftsio,       unlockedBy: "Chris" },
    { action: global.actionLibrary.mutationA,   unlockedBy: "Chris" },
    { action: global.actionLibrary.mutationO,   unlockedBy: "Chris" },
    { action: global.actionLibrary.weathA,      unlockedBy: "Chris" },
    { action: global.actionLibrary.weathO,      unlockedBy: "Chris" },
    { action: global.actionLibrary.darknessA,   unlockedBy: "Chris" },
    { action: global.actionLibrary.darknessO,   unlockedBy: "Chris" },
    { action: global.actionLibrary.defensedownA, unlockedBy: "Chris" },
    { action: global.actionLibrary.defensedownO, unlockedBy: "Chris" },
    { action: global.actionLibrary.offenseupA,  unlockedBy: "Chris" },
    { action: global.actionLibrary.offenseupO,  unlockedBy: "Chris" },
    { action: global.actionLibrary.hypnosisA,   unlockedBy: "Chris" },
    { action: global.actionLibrary.hypnosisO,   unlockedBy: "Chris" },
    { action: global.actionLibrary.hyperA,      unlockedBy: "Chris" },
    { action: global.actionLibrary.hyperO,      unlockedBy: "Chris" }
]
