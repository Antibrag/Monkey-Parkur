extends Area2D

func _on_area_entered(area):
	$/root/Main/HUD.show_level_bar(get_meta("LevelIndex"), get_meta("Author"), get_meta("Requires"))
	queue_free()
