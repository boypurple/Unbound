Name = "Belt";//Choose a name

//Container size
Inv_Width = 4;
Inv_Height = 1;
Inv_Cell_Size = 32;

Surface_Container = surface_create(Inv_Width*Inv_Cell_Size, Inv_Height*Inv_Cell_Size);

//Xbox are the coordinates of the inventory, by default, on the camera view.
//Edit only Xbox1 and Ybox1

Xbox1 = 256;
Ybox1 = camera_get_view_height(global.Camera)-32;
Xbox2 = Xbox1+Inv_Width*Inv_Cell_Size;
Ybox2 = Ybox1+Inv_Height*Inv_Cell_Size;


Is_Open = 1; //Belt can't be turn off
Can_Move = 0; //Belt can't move

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

//Set some restrictions
inv_container_cell_set_restriction(id, 0, "Milk");
inv_container_cell_set_restriction(id, 1, "Ink");
inv_container_cell_set_restriction(id, 2, "Slime drop");



//Create the surface, will be drawn only when Is_Open is true.
inv_update_surface(id);

//Imporant: every container that you add to the game MUST add its ID to that list when it's open and delete it when it's close
//Belt start open:
inv_container_list_add(id);




