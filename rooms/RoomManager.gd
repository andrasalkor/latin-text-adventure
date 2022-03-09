extends Node


func _ready() -> void:
	$StartingShed.connect_exit_unlocked(exit_inflections("occidens", "occidentem"), $BackOfInn, "ad")
	$BackOfInn.connect_exit_unlocked(exit_inflections("oriens", "orientem"), $StartingShed, "ad")
	
	var sword = load_item("GuardSword")
	$BackOfInn.add_item(sword)
	var innkeeper = load_npc("Innkeeper")
	$BackOfInn.add_npc(innkeeper)
	
#	$BackOfInn.connect_exit_unlocked("semitam", $VillageSquare)
#
#	$VillageSquare.connect_exit_unlocked("orientem", $InnDoor)
#	$VillageSquare.connect_exit_unlocked("septentriones", $Gate)
#	$VillageSquare.connect_exit_unlocked("occidentem", $Field)
#
#	var sword = load_item("GuardSword")
#	# sword.use_value = exit
#	$Field.add_item(sword)
#
#	$InnDoor.connect_exit_unlocked("inside", $InnInside)
#
#	var innkeeper = load_npc("Innkeeper")
#	$InnInside.add_npc(innkeeper)
#	$InnInside.connect_exit_unlocked("meridiem", $InnKitchen)
#
#	var exit = $InnKitchen.connect_exit_locked("meridiem", $BackOfInn)
#	var key = load_item("InnKitchenKey")
#	key.use_value = exit
#	$InnKitchen.add_item(key)
#
#	exit = $Gate.connect_exit_locked("silua", $Forest, "porta")
#	var guard = load_npc("Guard")
#	$Gate.add_npc(guard)
#	guard.quest_reward = exit
	


func load_item(item_name: String):
	return load("res://items/" + item_name + ".tres")


func load_npc(npc_name: String):
	return load("res://npcs/" + npc_name + ".tres")


func exit_inflections(nom: String, acc: String) -> Dictionary:
	var dictionary = {
		"nom" : nom,
		"acc" : acc
	}
	return dictionary
