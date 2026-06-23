//Set Is_Activated to 1 to initialize 'pick up' sequence. It only pick up the last object on the list.

if (Is_Activated)
{
inv_container_add_item(obj_player_backpack.id, Item_Value, Item_Quantity, x, y);
var size = ds_list_size(List[0]);
ds_list_delete(List[0], size-1);
ds_list_delete(List[1], size-1);
event_user(0);
Is_Activated = 0;
}