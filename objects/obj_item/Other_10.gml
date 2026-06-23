//That part refresh the info of obj_item. Taking the last object listed on the list or destroy it if list are empty.

var size;

size = ds_list_size(List[0]);

if (size == 0)
{
ds_list_destroy(List[0]);
ds_list_destroy(List[1]);
instance_destroy();
}

else
{
Item_Value = ds_list_find_value(List[0], size-1);
Item_Sprite = global.items[# I_SPRITE, Item_Value];
Item_Image_Index = global.items[# I_IMAGE_INDEX, Item_Value];
Item_Quantity = ds_list_find_value(List[1], size-1);
Info = global.items[# I_DESCRIPTION, Item_Value];
}