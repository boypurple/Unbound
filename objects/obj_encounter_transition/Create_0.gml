// --- Self-contained encounter transition (no tween library required) ---
// Custom data set by the collision event
swirl_color = c_black;
enemies_data = [];
bg = sBattle1;
// Animation state
_phase = 0;         // 0 = wait for first draw, 1 = animating in, 2 = done
_timer = 0;         // frames elapsed
_duration = 45;     // frames for the circle to close (~0.75s at 60fps)
_battle_spawned = false;
// Surfaces
_surface_before = -1;
_surface_overlay = -1;
_sw = display_get_gui_width();
_sh = display_get_gui_height();