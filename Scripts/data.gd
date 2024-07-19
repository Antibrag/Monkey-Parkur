extends Node

const LEVELS: Array = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]

var next_level_idx : int = 1
var current_level_idx : int = 1

var has_tail : bool = false
var have_dash : bool = false
var afterbuy : String = "none"

var distance : int
var max_distance: int 
var bananas : int = 3500
var rubins: int = 1

var selected_skin = "standart"
var unlocked_skins: Array = [tr("SK_STANDART")]

func _ready():
	dload()

func save():
	var save_data: Dictionary = {
		"has_tail": has_tail,
		"have_dash": have_dash,
		"skin": selected_skin,
		"skins_aviable": unlocked_skins,
		"bananas": bananas,
		"rubins": rubins,
		"max_distance": max_distance 
	}
	
	var file = FileAccess.open("user://data.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()

func dload():
	if not FileAccess.file_exists("user://data.json"):
		save()
		return

	var file = FileAccess.open("user://data.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	has_tail = data["has_tail"]
	have_dash = data["have_dash"]
	selected_skin = data["skin"]
	unlocked_skins = data["skins_aviable"]
	bananas = data["bananas"]
	max_distance = data["max_distance"]
	rubins = data["rubins"] 

func change_skin(skin_name: String = "none"):
	if skin_name == "Киборг":
		print(skin_name)
	if not unlocked_skins.has(skin_name):
		unlocked_skins.append(skin_name)
			
	match skin_name:
		"Стандартный":
			selected_skin = "standart"
		"Черныш":
			selected_skin = "black"
		"Демоненок":
			selected_skin = "devil"
		"Тень":
			selected_skin = "shadow"
		"Киборг ":
			selected_skin = "cyber"

func reset_levels_idxs():
	next_level_idx = 1
	current_level_idx = 1
