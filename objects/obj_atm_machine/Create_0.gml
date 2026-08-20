/// @desc ATM — approach and press Z to open it (interaction/collision inherited from obj_npc).
event_inherited();

_event = { type: "atm", _function: OpenATMUI, _value: undefined };

image_blend = c_aqua; // Cosmetic tint so it reads apart from the player/shop while sharing the same sprite
