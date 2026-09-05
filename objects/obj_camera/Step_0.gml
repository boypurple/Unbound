if (_in_dialogue_event) {
    // Detach from player
    camera_set_view_target(view_camera[0], noone);
    
    // Get current actual camera position (top-left)
    var _cx = camera_get_view_x(view_camera[0]);
    var _cy = camera_get_view_y(view_camera[0]);
    var _cw = camera_get_view_width(view_camera[0]);
    var _ch = camera_get_view_height(view_camera[0]);

    // Lerp towards the dialogue target
    var _tx = _dialogue_target_x - (_cw / 2);
    var _ty = _dialogue_target_y - (_ch / 2);

    if (_dialogue_returning && instance_exists(obj_player)) {
        _tx = obj_player.x - (_cw / 2);
        _ty = obj_player.y - (_ch / 2);
    }

    var _new_x = lerp(_cx, _tx, 0.05);
    var _new_y = lerp(_cy, _ty, 0.05);
    
    camera_set_view_pos(view_camera[0], _new_x, _new_y);

    // Check if we arrived
    if (point_distance(_new_x, _new_y, _tx, _ty) < 2) {
        camera_set_view_pos(view_camera[0], _tx, _ty);
        _in_dialogue_event = false;
        
        if (_dialogue_returning) {
            camera_set_view_target(view_camera[0], obj_player);
        }
        
        // Resume dialogue
        DialogueResume();
    }
} else {
    // Make sure we are tracking the player when not in a cutscene
    if (camera_get_view_target(view_camera[0]) != obj_player && instance_exists(obj_player)) {
        camera_set_view_target(view_camera[0], obj_player);
    }
}