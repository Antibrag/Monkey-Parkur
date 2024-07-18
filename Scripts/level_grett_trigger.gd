extends Area2D

func _on_area_entered(_area):
	$/root/Main/HUD.show_level_bar(get_meta("LevelIndex"), get_meta("Author"))
	queue_free()
