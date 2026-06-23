/*All obj_item are not realy items... They are only instance that holds 2 lists.
The first list holds item id. That id is not the id of an instance, it's the id of
the item on the global.items grid. It's the Y index. (see the inv_database_ini script).
The second list is the number of that item that obj_item is holding.
Example.
List[0] at position 2 = 0
Where 0 is the id/value of the item named: Red dust.
List[1] at position 2 = 10
So we have 10 Red dust on that obj_item.
*/

Is_Activated = 0; //Set it to 1 to activate the 'pick-up' sequence.
List[0] = ds_list_create();
List[1] = ds_list_create();

/*
This four values represent the item's : id, sprite, image_index and quantity of the LAST object on the list.
Everytime 2 obj_item ovelaps, the last obj_item created will  copy its lists to the other one
and destroy itself. (see alarm[0])
*/
Item_Value = -1;
Item_Sprite = -1;
Item_Image_Index = -1;
Item_Quantity = -1;

Info = ""; //The information you want to be displayed. In this project, info will be the description of the last object on the list.

alarm[0] = 1;