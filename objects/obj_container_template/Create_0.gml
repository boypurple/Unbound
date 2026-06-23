//Use this template to create new container.

Name = "container"; //Choose a name

//Container size
Inv_Width = 8;
Inv_Height = 8;
Inv_Cell_Size = 32;

Surface_Container = surface_create(Inv_Width*Inv_Cell_Size, Inv_Height*Inv_Cell_Size);

//Xbox are the coordinates of the inventory, by default, on the view.
//Edit only Xbox1 and Ybox1

Xbox1 = 256;
Ybox1 = 256;
Xbox2 = Xbox1+Inv_Width*Inv_Cell_Size;
Ybox2 = Ybox1+Inv_Height*Inv_Cell_Size;


Is_Open = 0; //Turn it on/off using the method you need.
Can_Move = 0; //Set this to 1 if you want to enable the moving option.

var xx = 0;
var yy = 0;
var count = 0;

//Create the array that will hold all the data
repeat(Inv_Height)
{
xx = 0;

    repeat(Inv_Width)
    {
    Array_Inv[count,0] = -1; //Item id
    Array_Inv[count,1] = 0; //Quantity
    Array_Inv[count,2] = "none"; //Restriction.
    Array_Inv[count,3] = xx*Inv_Cell_Size; //X (Both x and y are coordinate on the SURFACE, not on screen or view.
    Array_Inv[count,4] = yy*Inv_Cell_Size; //Y
    xx += 1;
    count ++;
    }
    
yy += 1;
}

//Create the surface, will be drawn only when Is_Open is true.
inv_update_surface(id);

/*IMPORTANT
When you open a container, you call:
scr_container_list_add(id);

When you close a container, you call:
scr_container_list_delete(id);

The best example for this is on the obj_player_backpack
    