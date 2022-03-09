extends Resource
class_name NPC


export (String) var npc_name = "NPC Name"
export(Dictionary) var name_inflections = {
	"nom": "",
	"gen": "",
	"dat": "",
	"acc": "",
	"abl": "",
	"voc": ""
}
export (String, MULTILINE) var initial_dialogue
export (String, MULTILINE) var post_quest_dialogue

export (Resource) var quest_item

var has_received_quest_item := false
var quest_reward = null
