//Simple movement
if (keyboard_check(vk_up) && tilemap_get_at_pixel(global.Layer_Wall, x, bbox_top-5) == 0)
{
y-=5;
}
if (keyboard_check(vk_down) && tilemap_get_at_pixel(global.Layer_Wall, x, bbox_bottom+5) == 0)
{
y+=5;
}
if (keyboard_check(vk_left) && tilemap_get_at_pixel(global.Layer_Wall, bbox_left-5, y) == 0)
{
x-=5;
}
if (keyboard_check(vk_right) && tilemap_get_at_pixel(global.Layer_Wall, bbox_right+5, y) == 0)
{
x+=5;
}
var gap = TILE_SIZE/2;
x = clamp(x, gap, room_width-gap);
y = clamp(y, gap, room_height-gap);
