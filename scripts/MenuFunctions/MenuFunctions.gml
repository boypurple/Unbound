// @desc Menu - Makes a menu, options provided in the form [["name", function, argument], [...]]
function Menu(_x, _y, _options, _description = -1, _width = undefined, _height = undefined)
{
	with(instance_create_depth(_x, _y, -99999, oMenu))
	{
		options = _options
		description = _description
		var _optionsCount = array_length(_options)
		visibleOptionsMax = _optionsCount
		
		//Set up size
		xmargin = 10
		ymargin = 8
		draw_set_font(fnMother3)
		heightLine = 20
		
		//Auto width
		if(_width == undefined)
		{
			_width = 1
			if(description != -1) _width = max(_width, string_width(_description))
			for(var i = 0; i < _optionsCount; i++)
			{
				_width = max(_width, string_width(_options[i][0]))
			}
			widthFull = _width + xmargin * 2
		}
		else widthFull = _width
		
		//Auto Height
		if(_height == undefined)
		{
			_height = heightLine * (_optionsCount + !(description != -1))
			heightFull = _height + ymargin * 2
		}
		else
		{
			heightFull = _height
			//Scrolling
			if(heightLine * (_optionsCount + !(description == -1)) > _height - (ymargin * 2))
			{
				scrolling = true
				visibleOptionsMax = (_height - ymargin * 2) div heightLine
			}
		}
	}
}

function SubMenu(_options)
{
	//Store old options in array and increase submenu level
	optionsAbove[subMenuLevel] = options
	subMenuLevel++
	options = _options
	hover = 0
}

function MenuGoBack()
{
	subMenuLevel--
	options = optionsAbove[subMenuLevel]
	hover = 0
}

function MenuSelectAction(_user, _action)
{
	with(oMenu) active = false
	
	
	//Activate the targetting cursor if needed, or simply begin the action
	with(oBattle) 
	{
		if(_action.targetRequired)
		{
			with(cursor)
			{
				active = true
				activeAction = _action
				targetAll = _action.targetAll
				if(targetAll == MODE.VARIES) targetAll = true //"Toggle" starts as all by Default
				activeUser = _user
				
				var _chan = 1
				var _mut = false
				
				if(_user.mutatedHand) if(_chan < irandom(2)) _mut = true
				
				//Wich side to target by default?
				if(_action.targetEnemyByDefault) //Target enemy by default
				{
					if(_mut == false)
					{
						targetIndex = 0
						targetSide = oBattle.enemyUnits
						activeTarget = oBattle.enemyUnits[targetIndex]
					}
					else
					{
						targetSide = oBattle.partyUnits
						activeTarget = activeUser
						//var _findSelf = function(_element, _user)
						//{
						//	return (_element == cursorTarget)
						//}
						//targetIndex = array_find_index(oBattle.partyUnits, _findSelf)
					}
				}
				else //Target self by default
				{
					if(_mut == false)
					{
						targetSide = oBattle.partyUnits
						activeTarget = activeUser
						//var _findSelf = function(_element, _user)
						//{
						//	return (_element == cursorTarget)
						//}
						//targetIndex = array_find_index(oBattle.partyUnits, _findSelf)
					}
					else
					{
						targetIndex = 0
						targetSide = oBattle.enemyUnits
						activeTarget = oBattle.enemyUnits[targetIndex]
					}
				}
			}
		}
		else
		{
			//If no target needed, begin the action and end the menu
			BeginAction(_user, _action, -1)
			with(oMenu) instance_destroy()
		}
	}
}