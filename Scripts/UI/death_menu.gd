extends VBoxContainer

@export var death_background: ColorRect

func show_death_screen():
	$DistanceLabel.text = "Пройденное расстояние: " + str(Data.distance) + "м"
	$BestDistanceLabel.text = "Предыдущий лучший результат: " + str(Data.max_distance) + "м"
	
	show()
	death_background.show()
	$AdRespawnButton.disabled = false
	$RestartButton.disabled = false

func hide_death_screen():
	hide()
	death_background.hide()
	$AdRespawnButton.disabled = true
	$RestartButton.disabled = true

func _on_ad_respawn_button_pressed():
	$/root/Main/Player.respawn()
	hide_death_screen()

func _on_restart_button_pressed():
	LevelLoader.restart()
	$/root/Main/Player.respawn()
	hide_death_screen()
