// A batalha acabou (vitória ou derrota)
instance_activate_all()
if(instance_exists(obj_slime))
{
	with(obj_slime) instance_destroy()
}
if(instance_exists(obj_dummy))
{
	with(obj_dummy) instance_destroy()
}