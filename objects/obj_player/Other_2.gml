if file_exists("save.txt")
{
	LoadGame(self);
	if room != global.current_room
		room_goto(global.current_room)
	
}