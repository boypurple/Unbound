/// @desc ATM input — pick Deposit/Withdraw, then enter an amount.

if (just_opened) {
    just_opened = false;
    exit; // The Space press that opened this UI is still "pressed" this frame — don't also read it as a confirm.
}

var _key_up     = keyboard_check_pressed(vk_up);
var _key_down   = keyboard_check_pressed(vk_down);
var _key_left   = keyboard_check(vk_left);
var _key_right  = keyboard_check(vk_right);
var _key_accept = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var _key_cancel = keyboard_check_pressed(vk_escape);

if (atm_mode == 0) {
    // --- Choose Deposit / Withdraw ---
    input_cooldown = 0;

    if (_key_up || _key_down) atm_action_index = 1 - atm_action_index;

    if (_key_accept) {
        atm_mode   = 1;
        atm_amount = 0;
    }

    if (_key_cancel) {
        global.gamePaused = false;
        instance_destroy();
    }
} else {
    // --- Enter amount ---
    var _max_amount = (atm_action_index == 0) ? global.cash : global.coins;

    if (_key_left || _key_right) {
        if (input_cooldown <= 0) {
            atm_amount = clamp(atm_amount + (_key_right ? atm_step : -atm_step), 0, _max_amount);
            input_cooldown = input_cooldown_max;
        } else {
            input_cooldown--;
        }
    } else {
        input_cooldown = 0;
    }

    if (_key_accept && atm_amount > 0) {
        if (atm_action_index == 0) {
            DepositToBank(atm_amount);
        } else {
            WithdrawFromBank(atm_amount);
        }
        atm_mode = 0;
    }

    if (_key_cancel) {
        atm_mode = 0;
    }
}
