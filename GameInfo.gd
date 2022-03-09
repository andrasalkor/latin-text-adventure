extends PanelContainer


# Preload an InputResponse scene so we have access to its functions
const INPUT_RESPONSE = preload("res://input/InputResponse.tscn")

export(NodePath) var history_rows_path
export(NodePath) var scroll_path

export(int) var max_lines_remembered := 30

var max_scroll_length := 0
var should_zebra := false

onready var scroll = get_node(scroll_path)
# Gets the vscroll of the scroll container so we can use it
onready var scrollbar = scroll.get_v_scrollbar()
onready var history_rows = get_node(history_rows_path)


func _ready():
	# Connect signal so we're measuring vscroll's changes
	scrollbar.connect("changed", self, "_handle_scrollbar_changed")
	# Declare variable for the max value of our scroll (how long it is)
	max_scroll_length = scrollbar.max_value


##### PUBLIC #####
# Add the starting message to the game when the game starts
func create_response(response_text: String):
	var response = INPUT_RESPONSE.instance()
	_add_response_to_game(response)
	response.set_text(response_text)


func create_response_with_input(response_text: String, input_text: String):
	var input_response = INPUT_RESPONSE.instance()
	_add_response_to_game(input_response)
	input_response.set_text(response_text, input_text)


##### PRIVATE #####
func _handle_scrollbar_changed():
	# If the scroll's length changed compared to the original value
	if max_scroll_length != scrollbar.max_value:
		# update the value
		max_scroll_length = scrollbar.max_value
		# jump to the end of our scroll
		scroll.scroll_vertical = scrollbar.max_value


# Delete excess history
func _delete_history_beyond_limit():
	# If the number of children exceed the max number set
	if history_rows.get_child_count() > max_lines_remembered:
		# let us see by how much
		var rows_to_forget = history_rows.get_child_count() - max_lines_remembered
		# then loop through them and get rid of them
		for i in range(rows_to_forget):
			history_rows.get_child(i).queue_free()


# Add response to the game interface, delete excess history
func _add_response_to_game(response: Control):
	# Add it to our scene tree
	history_rows.add_child(response)
	if not should_zebra:
		response.zebra.hide()
	should_zebra = !should_zebra
	_delete_history_beyond_limit()
