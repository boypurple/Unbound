if (instance_exists(obj_player) && distance_to_object(obj_player) <= NPC_INTERACT_RANGE)
{
    draw_set_font(fnMother3);

    var _text = "Press Space to Shop";
    var _pad_x = 6;
    var _pad_y = 4;

    var _text_w = string_width(_text);
    var _text_h = string_height(_text);

    var _text_x = x;
    var _text_y = bbox_top - 16;

    var _x1 = _text_x - (_text_w / 2) - _pad_x;
    var _y1 = _text_y - _text_h - _pad_y;
    var _x2 = _text_x + (_text_w / 2) + _pad_x;
    var _y2 = _text_y + _pad_y;

    draw_set_alpha(0.6);
    draw_set_colour(c_black);
    draw_roundrect(_x1, _y1, _x2, _y2, false);

    draw_set_alpha(1.0);
    draw_set_colour(c_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_text(_text_x, _text_y, _text);

    draw_set_colour(c_white);
}
