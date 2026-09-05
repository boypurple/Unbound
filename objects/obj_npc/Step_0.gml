if (_in_dialogue_event) {
    // Lerp towards the dialogue target
    x = lerp(x, _dialogue_target_x, 0.1);
    y = lerp(y, _dialogue_target_y, 0.1);

    // Check if we arrived
    if (point_distance(x, y, _dialogue_target_x, _dialogue_target_y) < 1) {
        x = _dialogue_target_x;
        y = _dialogue_target_y;
        _in_dialogue_event = false;
        
        // Resume dialogue
        DialogueResume();
    }
}
