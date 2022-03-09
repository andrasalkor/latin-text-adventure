extends Node


var inventory: Array = []


func take_item(item: Item):
	inventory.append(item)


func drop_item(item: Item):
	inventory.erase(item)


func get_inventory_list() -> String:
	if inventory.size() == 0:
		return "Nihil habes."
	
	var item_string = ""
	for item in inventory:
		item_string += item.item_name + " "
	return "Inuentarium: " + Types.wrap_item_text(item_string)
