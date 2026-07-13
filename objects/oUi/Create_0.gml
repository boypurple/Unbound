click = false

pauseOption = [sContinue, sParty, sGoods, sGoods, sSettings, sSave, sQuit]
pauseOptionName = ["Continue", "Party", "Inventory", "Goods", "Settings", "Save", "Quit"]
pauseOptionSelected = 0

settingsOption = [sAudio, sVideo, sControl, sQuit]
settingsOptionName = ["Audio", "Video", "Controls", "Quit"]
settingsOptionSelected = 0
settingsSide = 0

audioOptionName = ["Volume: " + string(global.volume), "SE Volume: " + string(global.volumeSE)]
audioOptionSelected = 0

for(var i = 0; i < array_length(global.party); i++)
{
	partyOption[i] = global.party[i].spr
}
partyOptionSelected = 0
partySide = 0

skillOptionSelected = 0

Layer()
InventorySystem();
LoadItemDatabase();