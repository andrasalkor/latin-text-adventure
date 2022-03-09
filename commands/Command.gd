extends Resource
class_name Command

export var has_dobj := false
export var has_iobj := false
export var has_inst := false # ablative case usage (includes utor, fungor, etc.)
export var has_prep := false

export var on_npc := false
export var on_pc := false
export var on_item := false
export var on_loc := false

export(Array, String) var synonyms

export(Array, String) var prepositions

export(String, "No scope", "room", "inv", "both") var scope

func has_arguments() -> bool:
	if has_dobj: return true
	if has_iobj: return true
	if has_inst: return true
	if has_prep: return true
	
	return false
