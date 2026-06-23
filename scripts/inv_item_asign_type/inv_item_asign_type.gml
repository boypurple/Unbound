///@description reads the string from the database, return value into the good type.
///@param string
///@param type can be: "string", "real" or "asset"
function inv_item_asign_type(argument0, argument1) {

	if (argument1 == "string")
	{
	return string(argument0);
	}
	else if (argument1 == "real")
	{
	return real(argument0);
	}

	else if (argument1 == "asset")
	{
	return asset_get_index(argument0);
	}


}
