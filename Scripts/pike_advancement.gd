extends AnimationPlayer

@export var start_cd_timer: Timer

func _ready():
	randomize()
	
	var parent_area: Area2D = get_parent()
	speed_scale = parent_area.get_meta("Speed")
	
	if parent_area.get_meta("StartCD") == -1:
		start_cd_timer.start(randf_range(0, 4))
	else:
		start_cd_timer.start(parent_area.get_meta("StartCD"))

func _on_start_cd_timer_timeout():
	active = true
