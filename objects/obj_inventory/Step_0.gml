if(keyboard_check_pressed(vk_tab))
{
Debug = !Debug;
}

/*
This is the main core of the inventory.
The main portion is separated into 4 blocks: The 4 states: "wait", "selected", "moving" and "drag"
*/

var tmp_id = -1;
var tmp_cell = -1;
var vx = camera_get_view_x(global.Camera);
var vy = camera_get_view_y(global.Camera);

#region Select which container the mouse is on
//Cycle to all open containers, starting by the one on top of the List_Draw_Container list.
//Then set which one mouse is over.
var tmp_index = ds_list_size(List_Draw_Container)-1;

repeat(tmp_index+1)
{
    with(ds_list_find_value(List_Draw_Container, tmp_index))
    {           
        if (inv_container_mouse_in(id))
        {
        tmp_id = id;
        tmp_cell = ((mouse_x-Xbox1-vx) div Inv_Cell_Size) + ((mouse_y-Ybox1-vy) div Inv_Cell_Size)*Inv_Width;
        break;
        }
    }
    
tmp_index--;
}

Mouseover_Con_Id = tmp_id;
Mouseover_Con_Cell = tmp_cell;
#endregion

var tmp_cell_value, tmp_cell_qty;

#region THE WAIT STATE
if (State == "wait") //Nothing is selected.
{
    if (mouse_check_button_pressed(mb_left))
    {
                
        if (Mouseover_Con_Id != -1) //Click on a container cell
        {                    
        tmp_cell_value = Mouseover_Con_Id.Array_Inv[Mouseover_Con_Cell, 0]; //item value of the cell
                
            if (tmp_cell_value != -1) //Verify if there is an item. If true, it becomes our selected item.
            {
            Selected_Con_Id = Mouseover_Con_Id;
            Selected_Con_Cell = Mouseover_Con_Cell;
            Selected_Item_Id = Selected_Con_Id.Array_Inv[Selected_Con_Cell, 0];
            Selected_Item_Sprite = global.items[# I_SPRITE, Selected_Item_Id];
            Selected_Item_Image_Index = global.items[# I_IMAGE_INDEX, Selected_Item_Id];
			Selected_Item_Qty =  Selected_Con_Id.Array_Inv[Selected_Con_Cell, 1];
            State = "selected";
            }
            
        }
        
	inv_update_descrpition_box(Selected_Item_Id);
    }  
        
}
#endregion

#region THE SELECTED STATE
else if (State == "selected")
{

    if (mouse_check_button_pressed(mb_left))
    {
        if (Mouseover_Con_Id == -1) //Reset selection to -1
        {
        inv_inventory_reset_selection("wait");
        }
        else if (Mouseover_Con_Id == Selected_Con_Id && Selected_Con_Cell == Mouseover_Con_Cell) //Click on the same selected item to drag it
        {
        
            if (keyboard_check(vk_alt) && Selected_Item_Qty > 1) //Take half round down if at least 2 items on that cell.
            {
            Selected_Item_Qty = floor(Selected_Item_Qty/2);
            Selected_Con_Id.Array_Inv[Selected_Con_Cell, 1] -= Selected_Item_Qty;
            }
            else //Take all
            {
            //If no more item on the cell, we then reset/clear the cell where the item were
            inv_container_clear_cell(Selected_Con_Id, Selected_Con_Cell);
            }
        
        State = "drag";
        inv_update_surface(Selected_Con_Id);
        }
        else //select another item
        {
        tmp_cell_value = Mouseover_Con_Id.Array_Inv[Mouseover_Con_Cell, 0]; //item value of the cell
                
            if (tmp_cell_value != -1) //Verify if there is an item. If true, it becomes our selected item.
            {
            Selected_Con_Id = Mouseover_Con_Id;
            Selected_Con_Cell = Mouseover_Con_Cell;
            Selected_Item_Id = Selected_Con_Id.Array_Inv[Selected_Con_Cell, 0];
            Selected_Item_Sprite = global.items[# I_SPRITE, Selected_Item_Id];
            Selected_Item_Image_Index = global.items[# I_IMAGE_INDEX, Selected_Item_Id];
			Selected_Item_Qty = Selected_Con_Id.Array_Inv[Selected_Con_Cell, 1];
            State = "selected";
            inv_update_surface(Selected_Con_Id);
            }
            else//No item
            {
            inv_inventory_reset_selection("wait");
            }
        }
		
    inv_update_descrpition_box(Selected_Item_Id);
    }
    else if (mouse_check_button_pressed(mb_right)) //This is where you could use an item.
    {    
        if (Mouseover_Con_Id == Selected_Con_Id && Selected_Con_Cell == Mouseover_Con_Cell) //That means you can only use an item if it were previously selected.
        {        
        show_message(global.items[# 0, Selected_Item_Id]+" has been used.");//This is where you put your custom script for using that type of item.
        Selected_Item_Qty -= 1;
                
            if (Selected_Item_Qty == 0) //Clear the cell if no item left.
            {
            inv_container_clear_cell(Selected_Con_Id, Selected_Con_Cell);
            inv_update_surface(Selected_Con_Id);
            inv_inventory_reset_selection("wait");
            }
            else
            {
            Selected_Con_Id.Array_Inv[Selected_Con_Cell, 1] -= 1;
            inv_update_surface(Selected_Con_Id);
            }
        }
        else //If right-clicking on another cell than the selected, selection resets.
        {
        inv_inventory_reset_selection("wait");
        }
   
    inv_update_descrpition_box(Selected_Item_Id);
    }
    
}
#endregion

#region THE DRAG STATE
else if (State == "drag") //Note that on the drag state, we are 100% sure that an item is selected.
{
    if (mouse_check_button_pressed(mb_left))
    {
        
        if (Mouseover_Con_Id == -1) //Not over an inventory: drop all dragged items on the floor at obj_player x/y change those coordinate if needed.
        {
        inv_inventory_drop_item(Selected_Item_Id, Selected_Item_Qty, obj_player.x, obj_player.y);
        inv_inventory_reset_selection("wait");
        }
        else
        {
        tmp_cell_value = Mouseover_Con_Id.Array_Inv[Mouseover_Con_Cell, 0];
            
            if (tmp_cell_value == -1 && inv_inventory_item_restriction(Mouseover_Con_Id, Mouseover_Con_Cell, Selected_Item_Id)) //Place all dragged items on an empty cell if restriction is met
            {            
            Selected_Con_Id = Mouseover_Con_Id;
            Selected_Con_Cell = Mouseover_Con_Cell;
            inv_container_add_item_pos(Selected_Con_Id, Selected_Con_Cell, Selected_Item_Id, Selected_Item_Qty, obj_player.x, obj_player.y);
            State = "selected";
            }
            else if (tmp_cell_value == Selected_Item_Id) //Add dragged item on a cell with the same type, keep remains selected.
            {
            Selected_Con_Id = Mouseover_Con_Id;
            Selected_Con_Cell = Mouseover_Con_Cell;
            inv_container_add_item_pos_remains(Selected_Con_Id, Selected_Con_Cell, Selected_Item_Id, Selected_Item_Qty);
            }
            else if (inv_inventory_item_restriction(Mouseover_Con_Id, Mouseover_Con_Cell, Selected_Item_Id))//Swap dragged item with a new item if restriction is met.
            {
            //tmp backup of the selected item
            var t_se = Selected_Item_Id;
            var t_qt = Selected_Item_Qty;
            
            //Set target container/item to swap as selected
            Selected_Con_Id = Mouseover_Con_Id;
            Selected_Con_Cell = Mouseover_Con_Cell;
            Selected_Item_Id = tmp_cell_value;
            Selected_Item_Sprite = global.items[# I_SPRITE, Selected_Item_Id];
			Selected_Item_Image_Index = global.items[# I_IMAGE_INDEX, Selected_Item_Id];
            Selected_Item_Qty = Selected_Con_Id.Array_Inv[Selected_Con_Cell, 1];
            inv_container_clear_cell(Selected_Con_Id, Selected_Con_Cell);
            
            //Place the backup item
            inv_container_add_item_pos(Selected_Con_Id, Selected_Con_Cell, t_se, t_qt, obj_player.x, obj_player.y);
            }                               
        
        }
  
    inv_update_descrpition_box(Selected_Item_Id);   
    }  
    else if (mouse_check_button_pressed(mb_right))
    {    
        if (Mouseover_Con_Id == -1) //Drop 1 dragged item on the floor at x/y of the player
        {
        inv_inventory_drop_item(Selected_Item_Id, 1, obj_player.x, obj_player.y);
        Selected_Item_Qty -= 1;
        }
        else if (inv_inventory_item_restriction(Selected_Con_Id, Selected_Con_Cell, Selected_Item_Id)) //Drop 1 dragged item on a cell if restriction is met.
        {
        inv_container_add_item_pos(Mouseover_Con_Id, Mouseover_Con_Cell, Selected_Item_Id, 1, obj_player.x, obj_player.y);
        Selected_Item_Qty -= 1;
        }
        
        if (Selected_Item_Qty == 0) //No items left to drag. Reset!
        {
        inv_inventory_reset_selection("wait");
        }

    inv_update_descrpition_box(Selected_Item_Id);
    }

}
#endregion

#region THE MOVING STATE
else if (State == "moving")
{
    if (mouse_check_button(mb_right))
    {
    var mcx = Moving_Con_X;
    var mcy = Moving_Con_Y;
    
        with(Selected_Con_Id)
        {
        Xbox1 = mouse_x - vx - mcx;
        Ybox1 = mouse_y - vy - mcy;
        Xbox2 = Xbox1+Inv_Width*Inv_Cell_Size;
        Ybox2 = Ybox1+Inv_Height*Inv_Cell_Size;
        }
    }
    
    if (mouse_check_button_released(mb_right))
    {
        with(Selected_Con_Id)
        {
        Xbox1 = Xbox1;
        Ybox1 = Ybox1;
        
        //You should clamp the position of the inventory.
		var vw = camera_get_view_width(global.Camera);
		var vh = camera_get_view_height(global.Camera);
		
        Xbox1 = clamp(Xbox1, 0, vw-Inv_Width*Inv_Cell_Size);
        Ybox1 = clamp(Ybox1, 0, vh-Inv_Height*Inv_Cell_Size);
        
        Xbox2 = Xbox1+Inv_Width*Inv_Cell_Size;
        Ybox2 = Ybox1+Inv_Height*Inv_Cell_Size;
        }
        
    Moving_Con_X = 0;
    Moving_Con_Y = 0;
    inv_inventory_reset_selection("wait");
    }
}
#endregion


//Sort the Container where the mouse is over.
if (keyboard_check_pressed(ord("S")))
{
inv_container_sort(Mouseover_Con_Id);
}


//Drop all items on cell where mouse is over and drop it on the floor.
if (keyboard_check(vk_control) && mouse_check_button_pressed(mb_left) && (State == "wait" || State == "selected"))
{
    
    if (Mouseover_Con_Cell != -1)
    {    
    tmp_cell_value = Mouseover_Con_Id.Array_Inv[Mouseover_Con_Cell, 0];
    
        if (tmp_cell_value != -1)
        {
        tmp_cell_qty = Mouseover_Con_Id.Array_Inv[Mouseover_Con_Cell, 1];
        inv_inventory_drop_item(tmp_cell_value, tmp_cell_qty, obj_player.x, obj_player.y);
        inv_inventory_reset_selection("wait");
        inv_container_clear_cell(Mouseover_Con_Id, Mouseover_Con_Cell);
        }
    }                  
}
    
  

//That moves the inventory box.
if (keyboard_check(vk_alt) && mouse_check_button_pressed(mb_right) && Mouseover_Con_Id != -1 && State != "drag" && Mouseover_Con_Id.Can_Move)
{    
inv_inventory_reset_selection("moving");
Selected_Con_Id = Mouseover_Con_Id;
Moving_Con_X = mouse_x - Selected_Con_Id.Xbox1 - vx;
Moving_Con_Y = mouse_y - Selected_Con_Id.Ybox1 - vy;
//Switch Container id to the top of the list.
}
        


//Resize inventory. That can be run when the player gain access to a larger bag or something else.
//You probably won't let this part in the step event. With that under, player can resize any containers.
if (keyboard_check_pressed(ord("Z")))
{
    if (Mouseover_Con_Id != -1)
    {
    Selected_Con_Id = Mouseover_Con_Id;
    Selected_Con_Cell = Mouseover_Con_Cell;
    var tmp_width = irandom_range(1,16);
    var tmp_height = irandom_range(1, 16);
    inv_container_resize(Selected_Con_Id, tmp_width, tmp_height);
    inv_inventory_reset_selection("wait");
    }
}

//If any container is selected, it will be put on top of the List_Draw_Container
inv_container_list_top(Selected_Con_Id);


