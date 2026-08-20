show_debug_message("TRANSITION Step: _phase=" + string(_phase) + " _timer=" + string(_timer) + " _battle_spawned=" + string(_battle_spawned));

switch (_phase) {
    case 0:
        // Phase 0: waiting for Draw_75 to capture the overworld on the first frame.
        // Do nothing here; Draw_75 sets _phase = 1 after capturing.
        break;

    case 1:
        // Phase 1: swirl closing inward. Advance timer.
        _timer++;
        
        // Halfway through the animation, spawn the battle
        if (!_battle_spawned && _timer >= _duration / 2) {
            _battle_spawned = true;
            show_debug_message("TRANSITION Step: Spawning battle at timer=" + string(_timer));
            NewEncounter(enemies_data, bg);
        }
        
        // Animation complete
        if (_timer >= _duration) {
            _phase = 2;
            show_debug_message("TRANSITION Step: Animation done, destroying transition.");
            instance_destroy();
        }
        break;
}
