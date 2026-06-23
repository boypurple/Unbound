if(place_meeting(x, y, obj_player) && keyboard_check_pressed(vk_space))
{
var gold_qty = 0;
gold_qty = inv_inventory_check_quantity(obj_player_backpack.id, "Gold Coin");
show_message("You have "+string(gold_qty)+" gold coin.");
var nothern_warrior = inv_inventory_check_compare(obj_player_backpack.id, "Icy Axe", 1, "Icy Plate", 1);

	if(nothern_warrior)
	{
	show_message("You are a true viking!")
	}
	else
	{
	show_message("You are not a nothern warrior...\n Find an Icy Axe and an Icy Plate");
	}
}