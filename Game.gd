extends Control


onready var game_info = $Background/MarginContainer/Columns/Rows/GameInfo
onready var command_processor = $CommandProcessor
onready var room_manager = $RoomManager
onready var player = $Player


func _ready() -> void:
	var side_panel = $Background/MarginContainer/Columns/SidePanel
	command_processor.connect("room_changed", side_panel, "handle_room_changed")
	command_processor.connect("room_updated", side_panel, "handle_room_updated")
	game_info.create_response(Types.wrap_system_text("Salue, bene in hoc, ut uulgo dicitur, 'text-adventure' uenisti! Scribe 'auxilium' ut imperata aspicias."))
	
	var starting_room_response = command_processor.initialize(room_manager.get_child(0), player)
	game_info.create_response(starting_room_response)
	


func _on_Input_text_entered(new_text: String) -> void:
	# Prevent empty strings from registering
	if new_text.empty():
		return
	
	new_text = command_processor.text_format(new_text)
	
	var response = command_processor.process_command(new_text)
	game_info.create_response_with_input(response, new_text)
