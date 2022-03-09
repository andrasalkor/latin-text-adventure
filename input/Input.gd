extends LineEdit


func _ready() -> void:
	# Grab focus on ready
	grab_focus()


# Clear the text input on enter
func _on_Input_text_entered(new_text: String) -> void:
	clear()
