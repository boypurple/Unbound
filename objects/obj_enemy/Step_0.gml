if(!global.gamePaused)
{
    var _xprev = x;
    var _yprev = y;
    
	x -= 1
	x = clamp(x, 0, room_width)
	
	if (x != _xprev || y != _yprev) {
	    facing_dir = point_direction(_xprev, _yprev, x, y);
	}
}