/*
obj_inventory works with STATE(written in string): "wait", "selected", "drag" and "moving".
"wait" - Nothing is selected.
"selected" - A cell occupied by an item is selected.
"drag" - An item is selected and it's being dragged, following the mouse.
"moving" - A container surface is being moved.
A container is a backpack, a belt, a chest, a crate, etc... obj_inventory is the controller of ALL those containers.
Each container has cells, each cell has an index. I.E.: A 4x4 container has 16 cells. from index 0 to 15.

*/

//Coordinates of the description box
Xbox_D = 0;
Ybox_D = 0;
var ww = sprite_get_width(spr_description_box);
var hh = sprite_get_height(spr_description_box);
Surface_Description_Box = surface_create(ww, hh);

Mouseover_Con_Id = -1; //Which container mouse is over
Mouseover_Con_Cell = -1;//Which cell index mouse is over
Selected_Con_Id = -1;//Id of the selected container
Selected_Con_Cell = -1;//Container's selected cell index

Selected_Item_Id = -1;//Which item is being selected.
Selected_Item_Sprite = -1;//Its sprite.
Selected_Item_Image_Index = -1;//Its image index.
Selected_Item_Qty = -1;//Quantity of that item.

Inv_Cell_Size = TILE_SIZE; //Sprite dimension is 16. spr_inventory_box is 32)

State = "wait"; //Can be "wait", "selected", "drag" or "moving".

Moving_Con_X = 0; //Used when moving a container
Moving_Con_Y = 0;


//That list hold id of opened containers. To keep track of which container has to be drawn.
List_Draw_Container = ds_list_create();

Debug = 1;