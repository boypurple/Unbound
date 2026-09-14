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
