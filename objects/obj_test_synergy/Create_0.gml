event_inherited();

label_text = "FULL SYNERGY";
image_blend = c_yellow;
encounter_enemies = [
	{data: global.enemies.tank, col: 0, row: 0},
	{data: global.enemies.wizard, col: 0, row: 1},
	{data: global.enemies.medic, col: 1, row: 1}
];
