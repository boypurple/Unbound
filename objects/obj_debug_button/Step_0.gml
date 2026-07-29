/// @description Fire a stress-test spawn burst when the player steps on this button

if (cooldown > 0) {
    cooldown--;
}

if (!triggered && cooldown <= 0 && place_meeting(x, y, obj_player)) {
    triggered = true;
    cooldown  = cooldown_max;

    var _min_x = x - spawn_width / 2;
    var _max_x = x + spawn_width / 2;
    var _min_y = y - spawn_height / 2;
    var _max_y = y + spawn_height / 2;

    repeat (spawn_amount) {
        var _spawn_x, _spawn_y, _attempts;
        _attempts = 0;

        // Random point in the box, retried until it clears spawn_clear_radius
        // so enemies don't land on the player/button and insta-trigger a battle.
        do {
            _spawn_x = random_range(_min_x, _max_x);
            _spawn_y = random_range(_min_y, _max_y);
            _attempts++;
        } until (point_distance(x, y, _spawn_x, _spawn_y) >= spawn_clear_radius || _attempts >= 10);

        if (point_distance(x, y, _spawn_x, _spawn_y) < spawn_clear_radius) {
            var _dir = point_direction(x, y, _spawn_x, _spawn_y);
            _spawn_x = x + lengthdir_x(spawn_clear_radius, _dir);
            _spawn_y = y + lengthdir_y(spawn_clear_radius, _dir);
        }

        instance_create_layer(_spawn_x, _spawn_y, "Instances", enemy_to_spawn);
    }
}

if (triggered && !place_meeting(x, y, obj_player)) {
    triggered = false;
}
