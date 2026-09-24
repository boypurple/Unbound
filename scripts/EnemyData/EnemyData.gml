//Enemy Data
global.loot_database = 
{
	"Boar":
	[
		{ item: "healing_potion", chance: 50 },
		{ item: "red_dust", chance: 15 } // You can change these items to match your actual items in items_db.csv
	],
	"Dummy":
	[
		{ item: "slime_drop", chance: 100 },
		{ item: "healing_potion", chance: 80 },
		{ item: "red_dust", chance: 50 }
	]
}

global.enemies =
{
	dummy:
	{
		name: "Dummy",
		hp: 1,
		hpMax: 1,
		pp: 1,
		ppMax: 1,
		def: 0,
		spd: 1,
		wrath: 1,
		iq: 1,
		strength: 1,
		actions: [global.actionLibrary.attack],
		sprites: {idle: sEnemy},
		xpValue: 10,
		coin: 10,
		stunned: false,
		mutatedHand: false,
		itchy: false,
		itnum: 0,
		poisoned: false,
		ponum: 0,
		poison: "",
		jackpot: false,
		blind: false,
		sleep: false,
		noNut: false,
		afo: false,
		offenseup: false,
		defdown: false,
		aftype: "",
		anum: 0,
		hyper: false,
		hynum: 0,
		magicBarrier: false,
		holdingPresent: false,
		AIscript: function()
		{
			var _action = actions[0]
			var _targets = [oBattle.partyUnits[0]]
			return [_action, _targets]
		}
	},
	boar:
	{
		name: "Boar",
		hp: 30,
		hpMax: 30,
		pp: 1,
		ppMax: 1,
		def: 1,
		spd: 1,
		wrath: 1,
		iq: 1,
		strength: 5,
		actions: [global.actionLibrary.attack],
		sprites: {idle: sEnemy},
		xpValue: 200,
		coin: 100,
		stunned: false,
		mutatedHand: false,
		itchy: false,
		itnum: 0,
		poisoned: false,
		ponum: 0,
		poison: "",
		jackpot: false,
		blind: false,
		sleep: false,
		noNut: false,
		afo: false,
		offenseup: false,
		defdown: false,
		aftype: "",
		anum: 0,
		hyper: false,
		hynum: 0,
		magicBarrier: false,
		holdingPresent: false,
		AIscript: function()
		{
			//enemy turn ai goes here
			//Attack random party member
			var _action = actions[0]
			
			var _possibleTargets = []
			
			var _chan = 1
			var _mut = false
				
			if(mutatedHand) 
			{
				if(_chan < irandom(2)) _mut = true
				if(_mut)
				{
					_possibleTargets = array_filter(oBattle.enemyUnits, function(_unit, _index)
					{
						return (_unit.hp > 0)
					})
				}
				else
				{
					_possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index)
					{
						return (_unit.hp > 0)
					})
				}
			}
			else
			{
				_possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index)
				{
					return (_unit.hp > 0)
				})
			}
			
			var _target = _possibleTargets[irandom(array_length(_possibleTargets) - 1)]
			return [_action, _target]
		}
	}
}

