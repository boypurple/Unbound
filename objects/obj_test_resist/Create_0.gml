event_inherited();

label_text = "RESIST & WARD";
image_blend = c_aqua;
encounter_enemies = [
	{data: global.enemies.resister, col: 0, row: 0},
	{data: global.enemies.nullifier, col: 1, row: 0},
	{data: global.enemies.warder, col: 0, row: 1}
];
