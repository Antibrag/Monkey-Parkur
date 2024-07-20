extends Node

var loaded_levels: Array 
var aviable_levels: Array

const LEVEL_SCENE_PATH: String = "res://Scenes/Levels/level_"

func _ready():
	randomize()
	loaded_levels.append($/root/Main/Levels/StartLevel)
	fill_aviable_levels_array()

func reduce_aviable_levels_to_quantity(erase_front: int, count_back: int = aviable_levels.size()):
	for i in range(erase_front):
		aviable_levels.pop_front()
	for i in range(aviable_levels.size()-count_back):
		aviable_levels.pop_back()

func fill_aviable_levels_array(game_is_restarted: bool = true):
	aviable_levels = Data.LEVELS.duplicate()
	
	if not game_is_restarted and Data.has_tail:
		return
	
	if Data.has_tail and not Data.have_dash and Data.next_level_idx <= 20:
		reduce_aviable_levels_to_quantity(0, 20)
	elif Data.next_level_idx <= 5 and not Data.have_dash:
		reduce_aviable_levels_to_quantity(0, 10)
	elif Data.next_level_idx <= 10 and not Data.have_dash:
		reduce_aviable_levels_to_quantity(10, 10)

func restart():
	Data.bananas += Data.distance
	Data.rubins += floori(Data.distance / 50)
	
	if Data.distance > Data.max_distance:
		Data.max_distance = Data.distance
	
	Data.save()
		
	for level in loaded_levels:
		level.queue_free()
	loaded_levels.clear()
	Data.reset_levels_idxs()
	fill_aviable_levels_array()

	add_level(LEVEL_SCENE_PATH + "start.tscn", 0)
	$/root/Main/RespawnNode.position = Vector2(300, 300)

func add_level(level_scene_name: String, k_positon = Data.next_level_idx):
	var level : Node2D = load(level_scene_name).instantiate()
	$/root/Main/Levels.call_deferred("add_child", level)
	loaded_levels.append(level)
	level.position = Vector2(2570 * k_positon, 0)

func get_random_level_idx() -> String:
	if aviable_levels.is_empty():
		fill_aviable_levels_array(false)

	var result : int = aviable_levels.pick_random()
	aviable_levels.erase(result)
	return str(result)

func add_next_level():
	if Data.current_level_idx+1 == Data.next_level_idx:
		print("skip: " + str(Data.current_level_idx) + ", " + str(Data.next_level_idx))
		return
	
	var level_scene_name : String
	
	match Data.afterbuy:
		"tail":
			if Data.next_level_idx < 2:
				level_scene_name = LEVEL_SCENE_PATH + "tail.tscn"
				add_level(level_scene_name)
				Data.next_level_idx+=1
				Data.afterbuy = "none"
				return
		"dash":
			if Data.next_level_idx < 2:
				level_scene_name = LEVEL_SCENE_PATH + "dash.tscn"
				add_level(level_scene_name)
				Data.next_level_idx+=1
				Data.afterbuy = "none"
				return
	
	
	level_scene_name = LEVEL_SCENE_PATH + get_random_level_idx() + ".tscn"
	print("next level - " + level_scene_name)
	add_level(level_scene_name)
	Data.next_level_idx+=1

func del_previous_level():
	var del_level : Node2D = loaded_levels[0]
	loaded_levels.erase(del_level)
	del_level.queue_free()
