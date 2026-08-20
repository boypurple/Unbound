_animation = 0; // Current index of animation.
_sprite = spr_player_d_run; // Current sprite.
_left = 0; // Left side.
_right = 0; // Right side.
_speed = 4;
_status = "overworld";
_attack = 5; // Attack strength.
facing_dir = 270; // 0=right, 90=up, 180=left, 270=down

_current_npc = noone;
_npc_function = 0;

_current_event = 0;
_event_function = 0;

arraySize = 10000

for(var i = arraySize; i > 0; i--)
{
	posX[i] = x
	posY[i] = y
}

if(array_length(global.party) >= 2)
{
	var _follower1 = instance_create_layer(x, y, "Instances", oFollower)
	_follower1.sprite = global.party[1].spr
	_follower1.record = 16
}

gamePausedImageSpeed = 0