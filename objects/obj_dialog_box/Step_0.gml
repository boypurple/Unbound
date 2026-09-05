// If an external event is running, pause all dialogue box logic
if (_is_chatterbox && _pending_chatterbox != undefined) {
    exit;
}

if (_text_current != _text_full) {
	_text_current += string_char_at(_text_full, _text_index);
	if (!audio_is_playing(snd_dialog)) {
		audio_play_sound(snd_dialog, 2, false);
	}
	_text_index++;
} else {
	// If text is done and we are using chatterbox, handle option navigation
	if (_is_chatterbox && ChatterboxGetOptionCount(_chatterbox) > 0) {
		if (keyboard_check_pressed(vk_down)) {
			_option_index++;
			if (_option_index >= ChatterboxGetOptionCount(_chatterbox)) _option_index = 0;
		}
		if (keyboard_check_pressed(vk_up)) {
			_option_index--;
			if (_option_index < 0) _option_index = ChatterboxGetOptionCount(_chatterbox) - 1;
		}
	}
}

if (keyboard_check_pressed(ord("Z"))) {
	if (_text_current != _text_full) {
		_text_current = _text_full;
	}
	else {
		if (_is_chatterbox) {
			if (ChatterboxGetOptionCount(_chatterbox) > 0) {
				ChatterboxSelect(_chatterbox, _option_index);
				_option_index = 0;
			} else {
				ChatterboxContinue(_chatterbox);
			}
			
			if (ChatterboxIsStopped(_chatterbox)) {
				with(self) instance_destroy();
			} else {
				_text_full = ChatterboxGetContentSpeech(_chatterbox, 0) ?? "";
				_speaker_name = ChatterboxGetContentSpeaker(_chatterbox, 0) ?? "";
				_text_current = "";
				_text_index = 1;
			}
		}
		else {
			if (_next_event) {
				_next_event[0](_next_event[1]);
			}
			else {
				with (self) {
					instance_destroy();
				}
			}
		}
	}
}
