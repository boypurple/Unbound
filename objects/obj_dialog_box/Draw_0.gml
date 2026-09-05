if (_tray_hidden) exit;

var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);
var _cam_h = camera_get_view_height(view_camera[0]);

// Dynamic sizing for the main text box
var _box_w = _cam_w * 0.9;
var _box_h = _cam_h * 0.3;

var _scale_x = _box_w / sprite_get_width(dialog_text_tray);
var _scale_y = _box_h / sprite_get_height(dialog_text_tray);

var _box_x = _cam_x + (_cam_w / 2) - (_box_w / 2);
var _box_y = _cam_y + _cam_h - _box_h - (_cam_h * 0.05);

// Draw speaker name tray if there is a speaker
if (_speaker_name != "" && _speaker_name != undefined) {
    var _name_w = _box_w * 0.3; // 30% of the box width
    var _name_h = _box_h * 0.3; // 30% of the box height
    var _name_scale_x = _name_w / sprite_get_width(dialog_name_tray);
    var _name_scale_y = _name_h / sprite_get_height(dialog_name_tray);
    var _name_x = _box_x; // Align with the left side of the main box
    var _name_y = _box_y - _name_h + 5; // Place right above the main box, slight overlap
    
    draw_sprite_ext(dialog_name_tray, 0, _name_x, _name_y, _name_scale_x, _name_scale_y, 0, c_white, 1);
    
    // Draw speaker name text
    var _name_pad_x = _name_w * 0.1;
    var _name_pad_y = _name_h * 0.2;
    draw_text(_name_x + _name_pad_x, _name_y + _name_pad_y, _speaker_name);
}

// Draw the main text tray
draw_sprite_ext(dialog_text_tray, 0, _box_x, _box_y, _scale_x, _scale_y, 0, c_white, 1);

var _pad_x = _box_w * 0.05;
var _pad_y = _box_h * 0.15;
var _max_w = _box_w - (_pad_x * 2); // Max width for word wrapping

draw_text_ext(_box_x + _pad_x, _box_y + _pad_y, _text_current, -1, _max_w);

// Draw Chatterbox options if text is fully displayed
if (_is_chatterbox && _text_current == _text_full) {
    var _opt_count = ChatterboxGetOptionCount(_chatterbox);
    
    // Calculate how tall the wrapped text actually is, so we can draw options below it
    var _text_h = string_height_ext(_text_full, -1, _max_w);
    var _options_start_y = _box_y + _pad_y + _text_h + 10; 
    
    for (var i = 0; i < _opt_count; i++) {
        var _opt_text = ChatterboxGetOption(_chatterbox, i);
        var _prefix = (i == _option_index) ? "> " : "  ";
        draw_text_ext(_box_x + _pad_x, _options_start_y + (i * 20), _prefix + _opt_text, -1, _max_w);
    }
}
