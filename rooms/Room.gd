tool
extends PanelContainer
class_name Conclave


export(String) var room_name = "Room Name" setget set_room_name
export(Dictionary) var name_inflections = {
	"nom": "",
	"gen": "",
	"dat": "",
	"acc": "",
	"abl": "",
	"loc": "",
	"voc": ""
}
export(String, "ad ", "apud ", "in ", "post ") var into_preposition = ""
export(String, MULTILINE) var room_description = "Haec conclauis descriptio est." setget set_room_description

onready var music = $Music

var exits: Dictionary = {}
var npcs: Array = []
var items: Array = []


func set_room_name(new_name: String):
	$MarginContainer/Rows/RoomName.text = new_name
	room_name = new_name


func set_room_description(new_description: String):
	$MarginContainer/Rows/RoomDescription.text = new_description
	room_description = new_description


func add_npc(npc: NPC):
	npcs.append(npc)


func add_item(item: Item):
	items.append(item)


func remove_item(item: Item):
	items.erase(item)


func get_full_description() -> String:
	var full_description = PoolStringArray([get_room_description()])
	
	var npc_description = get_npc_description()
	if npc_description != "":
		full_description.append(npc_description)
	
	var item_description = get_item_description()
	if item_description != "":
		full_description.append(item_description)
	
	full_description.append(get_exit_description())
	
	var full_description_string = full_description.join("\n")
	return full_description_string


func get_room_description() -> String:
	return into_preposition.capitalize() + " " + Types.wrap_location_text(get_into_preposition_case(into_preposition)) + " ades. " + room_description


func get_into_preposition_case(preposition: String) -> String:
	match preposition:
		"ad ":
			return name_inflections["acc"]
		"apud ":
			return name_inflections["acc"]
		"in ":
			return name_inflections["abl"]
		"post ":
			return name_inflections["acc"]
		_:
			return name_inflections["loc"]


func is_name_empty(name: String) -> bool:
	if name != "":
		return false
	else:
		return true


func get_npc_description() -> String:
	if npcs.size() == 0:
		return ""
	var npc_string = ""
	for npc in npcs:
		npc_string += Types.wrap_npc_text(npc.name_inflections["nom"]) + " "
	
	if npcs.size() == 1:
		return Types.wrap_system_text("Persona: ") + npc_string
	else:
		return Types.wrap_system_text("Personae: ") + npc_string


func get_item_description() -> String:
	if items.size() == 0:
		return ""
	
	var item_string = ""
	for item in items:
		item_string += Types.wrap_item_text(item.item_name) + " "
	return Types.wrap_system_text("Res: ") + item_string


func get_exit_description() -> String:
	return Types.wrap_system_text("Exitus: ") + Types.wrap_location_text(PoolStringArray(exits.keys()).join(" "))


func connect_exit_unlocked(direction: Dictionary, room, into_preposition):
	return _connect_exit(direction, room, false, into_preposition)


func connect_exit_locked(direction: Dictionary, room, into_preposition):
	return _connect_exit(direction, room, true, into_preposition)


func _connect_exit(direction: Dictionary, room, is_locked: bool = false, into_preposition: String = "in"):
	var exit = Exit.new()
	exit.destination = room
	exit.is_locked = is_locked
	exits[direction["nom"]] = exit
	exit.into_preposition = into_preposition
	exit.name_inflections = {"nom" : direction["nom"], "acc" : direction["acc"]}
	
	return exit
