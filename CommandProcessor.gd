extends Node


signal room_changed(new_room)
signal room_updated(current_room)

var current_room = null
var player = null

var commands = {
	"inuentarium": "inventory",
	"i": "inventory",
	"sume": "take",
	"test": "test",
	"demitte": "drop"
}

# INITIALIZE
# we store the player in a variable and set the first room
# called from Game.gd
func initialize(starting_room, player) -> String:
	self.player = player
	return change_room(starting_room)


#################################################################
# STRING FORMATTER - formatting all player input to be consistent
#################################################################

# TEXT FORMAT
# called by command processor
func text_format(text: String) -> String:
	text = text.replace("v", "u")
	text = text.replace("U", "V")
	text = text.replacen("j", "i")
	text = text.replacen("ā", "a")
	text = text.replacen("ē", "e")
	text = text.replacen("ī", "i")
	text = text.replacen("ō", "o")
	text = text.replacen("ū", "u")
	text = text.replacen("ȳ", "y")
	text = text.replace(".", "")
	text = text.replace(",", "")
	text = text.replace(";", "")
	text = text.replace(":", "")
	text = text.replace("!", "")
	text = text.replace("?", "")
	text = text.replace("\"", "")
	text = text.replace("\'", "")
	return text


###################################################################################
# PARSE COMMANDS - this section has everything needed to make sense of player input
###################################################################################

# PROCESS COMMAND
# this function handles processing player input and figuring out what to do with it
func process_command(input: String) -> String:
	var words = input.split(" ", false)
	if words.size() == 0:
		return "Error: nihil intellectum est."
	
	var command
	var command_resource: Resource
	var syntax
	
	var i = 0
	for word in words:
		if word in commands:
			command = word
			command_resource = load("res://commands/" + commands[command] + ".tres")
			words.remove(i)
			break
		i += 1
	
	if command == null:
		return Types.wrap_system_text("Tale imperatum deest.")
	
	if command_resource.has_arguments():
#		if words.size() < 1:
#			return Types.wrap_system_text("Imperatum argumentis caret.")
		
		syntax = analyze_syntax(words, command_resource)
		return call(commands[command], syntax)
	
	return call(commands[command])


func analyze_syntax(words: PoolStringArray, command: Command) -> Dictionary:
	var syntax: Dictionary
	
	var scope = _set_scope(command.scope)
	
	if command.has_prep:
		var prep = _get_preposition(words, command, scope)
		
		syntax["prep"] = prep if prep != null else ""
		
		if words.size() < 1:
			syntax["prep"] = null
	
	if command.has_dobj:
		var dobj = _get_direct_object(words, command, scope)
	
		syntax["dobj"] = dobj if dobj != null else ""
		
		if words.size() < 1:
			syntax["dobj"] = null
	
	if command.has_iobj:
		var iobj = _get_indirect_object(words, command, scope)
		
		syntax["iobj"] = iobj if iobj != null else ""
		
		if words.size() < 1:
			syntax["iobj"] = null
	
	return syntax


func _get_preposition(words: PoolStringArray, command: Command, scope):
	if !command.has_prep:
		return
	


func _get_direct_object(words: PoolStringArray, command: Command, scope):
	if !command.has_dobj:
		return
	
	var items = scope["items"]
	var npcs = scope["npcs"]
	var exits = scope["exits"]
	
	if command.on_item:
		return _get_word_role(words, command, items, "acc")
	
	if command.on_npc:
		return _get_word_role(words, command, npcs, "acc")
	
	if command.on_loc:
		return _get_word_role(words, command, exits, "acc")

func _get_indirect_object(words: PoolStringArray, command: Command, scope):
	if !command.has_iobj:
		return
	
	var items = scope["items"]
	var npcs = scope["npcs"]
	var exits = scope["exits"]
	
	if command.on_item:
		return _get_word_role(words, command, items, "dat")
	
	if command.on_npc:
		return _get_word_role(words, command, npcs, "dat")
	
	if command.on_loc:
		return _get_word_role(words, command, exits, "dat")

func _set_scope(scope: String):
	var lists = {
		"items": [],
		"npcs": [],
		"exits": []
	}
	
	match scope:
		"room":
			lists["items"] = current_room.items
			lists["npcs"] = current_room.npcs
			lists["exits"] = current_room.exits
		"inv":
			lists["items"] = player.inventory
		"both":
			lists["items"] = current_room.items + player.inventory
			lists["npcs"] = current_room.npcs
			lists["exits"] = current_room.exits
		_:
			return
	
	return lists


func _get_word_role(words: PoolStringArray, command: Command, list: Array, case: String):
	for word in words:
		for n in list:
			if word == n.name_inflections[case]:
				return n.name_inflections[case]
			
			for i in n.name_inflections.values():
				if word == i:
					return n


###########################################################
# COMMANDS - all the funcs for all the commands in the game
###########################################################

func test(second_word: String) -> String:
	return second_word


func go(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Quo?")
	
	for exit in current_room.exits.values():
		if exit.name_inflections["nom"] == second_word:
			return Types.wrap_system_text("Voluistine ") + Types.wrap_location_text(exit.name_inflections["acc"]) + Types.wrap_system_text("?")
		if exit.name_inflections["acc"] == second_word:
			if exit.is_locked:
				return Types.wrap_location_text(exit.name_inflections["nom"]) + Types.wrap_system_text(" sub claui") + " est."
			var change_response = change_room(exit.destination)
			return PoolStringArray([exit.into_preposition.capitalize() + " " + Types.wrap_location_text(second_word) + " is.", change_response]).join("\n")
		else:
			return Types.wrap_system_text("Hinc in ") + Types.wrap_location_text(second_word) + Types.wrap_system_text(" iri non potest.")
	
	return Types.wrap_location_text(second_word) + Types.wrap_system_text(" non inuenitur.")


# TAKE
# syntax: <dobj>
func take(syntax) -> String:
	var dobj
	
	if syntax["dobj"] != null:
		dobj = syntax["dobj"]
	
	if dobj == null:
		return Types.wrap_system_text("Quid sumere uis?")
	
	if dobj is Item:
		return Types.wrap_system_text("Voluistine ") + Types.wrap_item_text(dobj.name_inflections["acc"]) + Types.wrap_system_text("?")
	elif dobj is Resource:
		return Types.wrap_system_text("Error: Non rem sumere tentasti.")
	
	for item in current_room.items:
		if dobj.to_lower() == item.name_inflections["acc"].to_lower():
			current_room.remove_item(item)
			player.take_item(item)
			emit_signal("room_updated", current_room)
			return Types.wrap_item_text(item.name_inflections["acc"].capitalize()) + " sumpsisti."
	
	if dobj == "":
		return Types.wrap_system_text("Deest.")
	else:
		return Types.wrap_item_text(dobj.capitalize()) + Types.wrap_system_text(" hic deest.")


# DROP
# syntax: <dobj>
func drop(syntax) -> String:
	var dobj = syntax["dobj"]
	
	if syntax["dobj"] != null:
		dobj = syntax["dobj"]
	
	if dobj == null:
		return Types.wrap_system_text("Quid demittere uis?")
	
	if dobj is Item:
		return Types.wrap_system_text("Voluistine ") + Types.wrap_item_text(dobj.name_inflections["acc"]) + Types.wrap_system_text("?")
	elif dobj is Resource:
		return Types.wrap_system_text("Error: Non rem sumere tentasti.")
	
	for item in player.inventory:
		if dobj.to_lower() == item.name_inflections["acc"].to_lower():
			player.drop_item(item)
			current_room.add_item(item)
			emit_signal("room_updated", current_room)
			return Types.wrap_item_text(item.name_inflections["acc"].capitalize()) + " demisisti."
	
	if dobj == "":
		return Types.wrap_system_text("Non habes.")
	else:
		return Types.wrap_item_text(dobj.capitalize()) + Types.wrap_system_text(" non habes.")


func inventory() -> String:
	return player.get_inventory_list()


func use(second_word) -> String:
	if second_word == "":
		return Types.wrap_system_text("Quo uti uis?")

	for item in player.inventory:
		if item.name_inflections["acc"].to_lower() == second_word.to_lower():
			return Types.wrap_system_text("Voluistine ") + Types.wrap_item_text(item.name_inflections["abl"]) + "?"
		if second_word.to_lower() == item.name_inflections["abl"].to_lower():
			match item.item_type:
				Types.ItemTypes.KEY:
					for exit in current_room.exits.values():
						if exit == item.use_value:
							exit.is_locked = false
							player.drop_item(item)
							# return "You use %s to unlock a door to %s." % [item.item_name, exit.get_other_room(current_room).room_name]
							return Types.wrap_item_text(item.name_inflections["abl"]) + " adhibens ad " + Types.wrap_location_text(exit.get_other_room(current_room).name_inflections["acc"]) + " uiam reperis."
					return Types.wrap_item_text(item) + Types.wrap_system_text(" nihil aperit.")
				_:
					return Types.wrap_system_text("Error - tried to use an item with an invalid type.")
	return Types.wrap_system_text("You don't have ") + Types.wrap_item_text(second_word) + Types.wrap_system_text(".")


func talk(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Quem alloqui uis?")
	
	for npc in current_room.npcs:
		if npc.name_inflections["nom"].to_lower() == second_word.to_lower():
			return Types.wrap_system_text("Voluistine ") + Types.wrap_npc_text(npc.name_inflections["acc"]) + "?"
		if npc.name_inflections["acc"].to_lower() == second_word.to_lower():
			var dialogue = npc.post_quest_dialogue if npc.has_received_quest_item else npc.initial_dialogue
			return Types.wrap_npc_text(npc.npc_name) + ": " + Types.wrap_speech_text("\"" + dialogue + "\"")
	
	return Types.wrap_system_text("Haec persona abest.")


func give(second_word: String, third_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Quid dare uis?")
	
	if third_word == "":
		return Types.wrap_item_text(second_word.capitalize()) + Types.wrap_system_text(" cui dare uis?")
	
	var has_item := false
	for item in player.inventory:
		if second_word.to_lower() == item.name_inflections["acc"].to_lower():
			has_item = true
	
	if not has_item:
		return Types.wrap_system_text("Tali re cares.")
	
	for npc in current_room.npcs:
		if npc.quest_item != null and second_word.to_lower() == npc.quest_item.name_inflections["acc"].to_lower():
			npc.has_received_quest_item = true
			if npc.quest_reward != null:
				var reward = npc.quest_reward
				if "is_locked" in reward:
					reward.is_locked = false
				else:
					printerr("Warning - tried to have a quest reward type that is not implemented.")
			
			player.drop_item(second_word)
			# return "You give the %s to the %s." % [second_word, npc.npc_name]
			# return "You give the " + Types.wrap_item_text(second_word) + " to the " + Types.wrap_npc_text(npc.npc_name) + "."
			return Types.wrap_item_text(second_word.capitalize()) + " " + Types.wrap_npc_text(npc.name_inflections["dat"]) + " dedisti."
	
	return Types.wrap_system_text("Haec res hic nemini dari potest.")


func help() -> String:
	return PoolStringArray([
		"His utere imperatis: ",
		"    in " + Types.wrap_system_text("aut") + " ad " + Types.wrap_location_text("[locum]"),
		"    sume " + Types.wrap_item_text("[rem]"),
		"    demitte " + Types.wrap_item_text("[rem]"),
		"    utere " + Types.wrap_item_text("[re]"),
		"    alloquere " + Types.wrap_system_text("aut") + " allo " + Types.wrap_npc_text("[aliquem]"),
		"    da " + Types.wrap_item_text("[rem]"),
		"    inuentarium " + Types.wrap_system_text("aut") + " inventarium",
		"    auxilium " + Types.wrap_system_text("aut") + " aux"
	]).join("\n")


#############################################
# CHANGE ROOM - func(s) to move through rooms
#############################################

func change_room(new_room: Conclave) -> String:
	if current_room != null:
		current_room.music.stop()
	current_room = new_room
	new_room.music.play()
	emit_signal("room_changed", new_room)
	return new_room.get_full_description()
