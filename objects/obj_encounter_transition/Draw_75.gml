// Frame 1 only: capture the overworld surface, then kick off the animation
if (_phase == 0) {
    if (!surface_exists(_surface_before)) {
        _surface_before = surface_create(_sw, _sh);
    }
    
    surface_set_target(_surface_before);
    draw_clear(c_black);
    draw_surface_stretched(application_surface, 0, 0, _sw, _sh);
    surface_reset_target();
    
    _phase = 1;
} 
else if (_phase == 1) {
    var _progress = _timer / _duration;           // 0.0 → 1.0
    var _cx = _sw / 2;
    var _cy = _sh / 2;
    var _max_radius = point_distance(0, 0, _cx, _cy) + 4;
    var _radius = _max_radius * (1 - _progress);  // circle shrinks as progress increases

    // 1. Draw the captured overworld as background
    if (surface_exists(_surface_before)) {
        draw_surface(_surface_before, 0, 0);
    }

    // 2. Draw cutout overlay
    if (!surface_exists(_surface_overlay)) {
        _surface_overlay = surface_create(_sw, _sh);
    }

    if (surface_exists(_surface_overlay)) {
        surface_set_target(_surface_overlay);
        draw_clear_alpha(c_black, 0); // Clear surface to fully transparent
        
        // Fill the whole screen with the advantage color
        draw_set_colour(swirl_color);
        draw_rectangle(0, 0, _sw, _sh, false);
        
        // Punch a shrinking circular hole to reveal the overworld underneath
        if (_radius > 0) {
            gpu_set_blendmode(bm_subtract);
            draw_set_colour(c_white);
            var _steps = 64;
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(_cx, _cy);
            for (var i = 0; i <= _steps; i++) {
                var _angle = (i / _steps) * 360;
                draw_vertex(
                    _cx + lengthdir_x(_radius, _angle),
                    _cy + lengthdir_y(_radius, _angle)
                );
            }
            draw_primitive_end();
            gpu_set_blendmode(bm_normal);
        }
        surface_reset_target();
        
        // Draw the overlay over the screen
        draw_surface(_surface_overlay, 0, 0);
    }
}
