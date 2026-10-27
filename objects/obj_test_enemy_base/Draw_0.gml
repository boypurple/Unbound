draw_self();

if (label_text != "") {
    draw_set_font(fnMother3);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    
    var _tx = x;
    var _ty = y - 22;
    
    // Drop shadow
    draw_set_color(c_black);
    draw_text(_tx + 1, _ty, label_text);
    draw_text(_tx - 1, _ty, label_text);
    draw_text(_tx, _ty + 1, label_text);
    draw_text(_tx, _ty - 1, label_text);
    
    // Text
    draw_set_color(c_white);
    draw_text(_tx, _ty, label_text);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
