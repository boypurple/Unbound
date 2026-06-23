if(Update_Description_Box != -1)
{
inv_inventory_description_box(Update_Description_Box);
Update_Description_Box = -1;
}

else if(Update_Container_Id != -1)
{		
	if(Update_Cell_Index != -1)
	{
	inv_container_surface_pos(Update_Container_Id, Update_Cell_Index);
	}
	else
	{
	inv_container_surface(Update_Container_Id);
	}		

Update_Container_Id = -1;
Update_Cell_Index = -1;
}

instance_destroy();
