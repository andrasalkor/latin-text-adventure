extends Resource

class_name Item

export(String) var item_name := "Item Name"
export(Dictionary) var name_inflections = {
	"nom": "",
	"gen": "",
	"dat": "",
	"acc": "",
	"abl": "",
	"voc": ""
}
export(Types.ItemTypes) var item_type := Types.ItemTypes.KEY
export(String, MULTILINE) var description := "Rei descriptio."

var use_value = null
