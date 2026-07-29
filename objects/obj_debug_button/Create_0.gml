/// @description Configurable stress-spawn trigger — overridable per-instance in the room editor

enemy_to_spawn     = obj_slime; // Asset (object type) to spawn
spawn_amount       = 50;        // How many instances to spawn per trigger
spawn_width        = 1024;       // Bounding box width for random placement
spawn_height       = 1024;       // Bounding box height for random placement
spawn_clear_radius = 192;        // Keep spawns at least this far from the button/player so they don't collide instantly

triggered    = false;
cooldown     = 0;
cooldown_max = 30;
