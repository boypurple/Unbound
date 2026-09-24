//Data
global.coins = 10000000 // Bank balance (ATM) — battle rewards land here
global.cash = 0  // Cash on hand — spent at the Shop, halved on party wipe
global.volume = 100
global.volumeSE = 100

global.gamePaused = false
global.config = false
global.configAudio = false
global.configVideo = false
global.configControl = false
global.partyMenu = false
global.partySkillMenu = false

global.gameMenu = false

global.item_database = []
global.equipment_database = {} // Separated equipment stat database (equipment.csv)
global.character_equipments  = {} // Per-character equipment containers: { hand, body }
global.inventoryMaxColumn = 5 

global.dropRateMultiplier = 1.0 // Debug setting for tweaking drop rates

global.inventoryInit = false
global.inventoryMaxSlots = 10

global.inventories = {}

global.inventory_tab_type = [
    [ITEM_TYPE.consumable, ITEM_TYPE.equipment, ITEM_TYPE.material],
    [ITEM_TYPE.key_item]
]
global.inventory_tab_name = [
    "Items",
    "Key Items"
]

global.boss = false
global.escape = false

#macro RESOLUTION_W 1280
#macro RESOLUTION_H 720

#macro TILE_SIZE 32
#macro NPC_INTERACT_RANGE (TILE_SIZE * 1.25) // Shared by obj_player's Space-to-interact check and NPC "Press Space" prompts

