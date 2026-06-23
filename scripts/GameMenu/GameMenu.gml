function GameMenu(){
	if (!global.gamePaused)
	{
		global.gamePaused = true
		global.gameMenu = true
			with(all)
			{
				gamePausedImageSpeed = image_speed
				image_speed = 0;
			}
	}
	else if (global.gameMenu)
	{
		global.gamePaused = false
		global.gameMenu = false
		with(all)
		{
			//image_speed = gamePausedImageSpeed
			image_speed = 0
		}
	}
	
}