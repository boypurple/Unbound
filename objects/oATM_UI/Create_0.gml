/// @desc ATM — deposit/withdraw between cash on hand and the bank balance.

atm_action_index    = 0; // 0 = Deposit, 1 = Withdraw
atm_mode             = 0; // 0 = choose action, 1 = enter amount
atm_amount           = 0;
atm_step             = 10;
input_cooldown       = 0;
input_cooldown_max   = 6;
just_opened          = true; // Swallows the Space press that opened this UI so it isn't also read as a confirm

global.gamePaused = true;
