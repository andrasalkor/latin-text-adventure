extends MarginContainer


onready var zebra = $Zebra
onready var input_label = $Rows/InputHistory
onready var response_label = $Rows/Response


# Set the text fields of the scene
# They are passed from Game.gd/_on_Input_text_entered
func set_text(response: String, input: String = ""):
	if input == "":
		input_label.queue_free()
	else:
		input_label.text = " > " + input
	
	response_label.bbcode_text = response
