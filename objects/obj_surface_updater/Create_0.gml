/*This object update a surface in the draw event and then destroy itself.
It is created by the inv_update_* scripts.
The purpose of this object is to make sure that any surfaces are 'created/modified/sketch'
in a draw event. Inventory DB was first built on surfaces updated on step event but this is
a very bad habit! Manipulate surfaces on the draw event...always!
*/

Update_Description_Box = -1;
Update_Container_Id = -1;
Update_Cell_Index = -1;

