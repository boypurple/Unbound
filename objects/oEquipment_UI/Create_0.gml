/// @desc Equipment UI Initialization

click = false;

playerTab = 0;          // Index of selected party member
equipmentCursor = 0;    // 0 = Party Tab, 1 = Slot Selection, 2 = Slot Action Menu (Equip/Unequip), 3 = Candidate Item Selection

selectedSlotIndex = 0;  // 0 = Hand, 1 = Body
slotOptionSelected = 0; // 0 = Equip / Swap, 1 = Unequip
candidateIndex = 0;     // Index of candidate item being previewed/selected

instance_equipment = id;

frame = 0;
