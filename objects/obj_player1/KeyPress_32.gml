//Pressing spacebar will look for obj_item and obj_chest and activate them

var tmp_item = instance_place(x, y, obj_item);

if (tmp_item !=noone)
{
tmp_item.Is_Activated = 1;
}

var tmp_chest = instance_place(x, y, obj_chest);

if (tmp_chest !=noone)
{
tmp_chest.Is_Activated = 1;
}