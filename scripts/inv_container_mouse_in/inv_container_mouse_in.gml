///@description returns true if mouse is over inventory
///@param Container_Id
function inv_container_mouse_in(argument0) {

	container = argument0;

	var vx = camera_get_view_x(global.Camera);
	var vy = camera_get_view_y(global.Camera);

	with(container)
	{
	    if(mouse_x >= Xbox1+vx && mouse_x < Xbox2+vx && mouse_y >= Ybox1+vy && mouse_y < Ybox2+vy)
	    {
	    return 1;
	    }
	    else
	    {
	    return 0;
	    }
	}


}
