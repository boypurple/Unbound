// Dialogue Events
// Registers and handles all in-game events triggered from Yarn scripts.

function DialogueEventsInit() {
    ChatterboxAddFunction("cameraMove",   _de_camera_move);
    ChatterboxAddFunction("cameraReset",  _de_camera_reset);
    ChatterboxAddFunction("moveNpc",      _de_move_npc);
    ChatterboxAddFunction("waitSeconds",  _de_wait_seconds);
    ChatterboxAddFunction("playMusic",    _de_play_music);
    ChatterboxAddFunction("shakeCamera",  _de_shake_camera);
    ChatterboxAddFunction("setDialogVar", DialogueSetVar);  // Instant, no wait
    ChatterboxAddFunction("hideDialog",   _de_hide_dialog);
    ChatterboxAddFunction("showDialog",   _de_show_dialog);
    ChatterboxAddFunction("restoreParty", _de_restore_party);
    ChatterboxAddFunction("partyNeedsRest", PartyNeedsRest);
}

// Resumes the dialogue box and properly updates its text variables.
// Used by external objects (like camera/npcs) when their event finishes.
function DialogueResume() {
    with (obj_dialog_box) {
        if (_pending_chatterbox != undefined) {
            ChatterboxContinue(_pending_chatterbox);
            _pending_chatterbox = undefined;
        }
        
        _tray_hidden = false;
        
        if (ChatterboxIsStopped(_chatterbox)) {
            instance_destroy();
        } else {
            // Re-fetch the text and speaker because the parser has advanced
            _text_full = ChatterboxGetContentSpeech(_chatterbox, 0) ?? "";
            _speaker_name = ChatterboxGetContentSpeaker(_chatterbox, 0) ?? "";
            _text_current = "";
            _text_index = 1;
        }
    }
}

// --------------------------------------------------------
// Event Implementations
// --------------------------------------------------------

function _de_camera_move(_tx, _ty, _hide = false) {
    // <<cameraMove(targetX, targetY, hideDialog=false)>>
    var _target_x = real(_tx);
    var _target_y = real(_ty);
    var _hide_tray = bool(_hide);

    with (obj_dialog_box) {
        ChatterboxWait(_chatterbox);
        _tray_hidden = _hide_tray;
        _pending_chatterbox = _chatterbox;
    }
    
    with (obj_camera) {
        _dialogue_target_x = _target_x;
        _dialogue_target_y = _target_y;
        _dialogue_returning = false;
        alarm[0] = 1; // Start movement alarm
    }
}

function _de_camera_reset(_hide = false) {
    // <<cameraReset(hideDialog=false)>>
    var _hide_tray = bool(_hide);

    with (obj_dialog_box) {
        ChatterboxWait(_chatterbox);
        _tray_hidden = _hide_tray;
        _pending_chatterbox = _chatterbox;
    }
    
    with (obj_camera) {
        _dialogue_returning = true; // Signals camera to return to player
        alarm[0] = 1; // Start movement alarm
    }
}

function _de_move_npc(_id, _tx, _ty, _hide = false) {
    // <<moveNpc(npcId, targetX, targetY, hideDialog=false)>>
    var _target_id = string(_id);
    var _target_x = real(_tx);
    var _target_y = real(_ty);
    var _hide_tray = bool(_hide);

    var _npc = DialogueFindNpc(_target_id);
    if (_npc != noone) {
        with (obj_dialog_box) {
            ChatterboxWait(_chatterbox);
            _tray_hidden = _hide_tray;
            _pending_chatterbox = _chatterbox;
        }
        
        with (_npc) {
            _dialogue_target_x = _target_x;
            _dialogue_target_y = _target_y;
            alarm[0] = 1; // Start NPC movement
        }
    }
}

function _de_wait_seconds(_seconds) {
    // <<waitSeconds(seconds)>>
    var _secs = real(_seconds);

    with (obj_dialog_box) {
        ChatterboxWait(_chatterbox);
        _pending_chatterbox = _chatterbox;
        alarm[0] = _secs * room_speed;
    }
}

function _de_play_music(_track_name) {
    // <<playMusic(trackName)>>
    var _track = asset_get_index(string(_track_name));
    if (_track > -1) {
        audio_stop_all(); // Or stop specific background music
        audio_play_sound(_track, 1, true);
    }
}

function _de_shake_camera(_duration, _intensity) {
    // <<shakeCamera(duration, intensity)>>
    var _dur = real(_duration);
    var _int = real(_intensity);
    // Implement screen shake here, potentially just setting variables on obj_camera
}

function _de_hide_dialog() {
    with (obj_dialog_box) _tray_hidden = true;
}

function _de_show_dialog() {
    with (obj_dialog_box) _tray_hidden = false;
}

function PartyNeedsRest() {
    for(var i = 0; i < array_length(global.party); i++) {
        var _p = global.party[i];
        if (_p.hp < _p.hpMax || _p.pp < _p.ppMax) return true;
        if (_p.poisoned || _p.itchy || _p.blind || _p.sleep || _p.stunned || _p.mutatedHand || _p.noNut || _p.soreT) return true;
    }
    return false;
}

function PartyRestoreAll() {
    for(var i = 0; i < array_length(global.party); i++) {
        var _p = global.party[i];
        _p.hp = _p.hpMax;
        _p.pp = _p.ppMax;
        
        // Cure ailments
        _p.poisoned = false;
        _p.ponum = 0;
        _p.poison = "";
        _p.itchy = false;
        _p.itnum = 0;
        _p.blind = false;
        _p.sleep = false;
        _p.stunned = false;
        _p.mutatedHand = false;
        _p.noNut = false;
        _p.soreT = false;
    }
}

function _de_restore_party() {
    PartyRestoreAll();
    // Play a healing sound, fallback to party join if no specific sound exists
    if (audio_exists(snd_party_join)) {
        audio_play_sound(snd_party_join, 1, false);
    }
}
