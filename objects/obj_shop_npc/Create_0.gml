/// @desc Shop NPC — approach and press Z to open the shop (interaction/collision inherited from obj_npc).
event_inherited();

_event = { type: "shop", _function: OpenShopUI, _value: undefined };

image_blend = c_orange; // Cosmetic tint so it reads apart from the player/ATM while sharing the same sprite
