extends VBoxContainer

@export var death_background: ColorRect

func show_death_screen():
	$DistanceLabel.text = tr("DEATH_SCORE") + ": " + str(Data.distance) + "м"
	$BestDistanceLabel.text = tr("MAX_DISTANCE") + ": " + str(Data.max_distance) + "м"
	
	show()
	death_background.show()
	death_background.get_child(0).text = tr("RUBINS") + ": " + str(Data.rubins)
	$AdRespawnButton.disabled = false
	$RestartButton.disabled = false

func hide_death_screen():
	hide()
	death_background.hide()
	$AdRespawnButton.disabled = true
	$RestartButton.disabled = true

func _on_ad_respawn_button_pressed():
	if Data.rubins <= 0:
		return
	
	Data.rubins -= 1
	$/root/Main/Player.respawn()
	hide_death_screen()

func _on_restart_button_pressed():
	LevelLoader.restart()
	$/root/Main/Player.respawn()
	hide_death_screen()
