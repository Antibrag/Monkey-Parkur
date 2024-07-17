extends Node2D

signal use_tail(tail_target: StaticBody2D)
signal dash

@onready var dash_reload_bar : ProgressBar = $DashReloadBar
@onready var dash_reload_timer : Timer = $DashReloadTimer

func reload_dash():
	dash_reload_timer.stop()
	dash_reload_bar.hide()

func _process(delta):
	dash_reload_bar.value = dash_reload_timer.time_left * 100

func _input(event):
	if event.is_action_pressed("use_tail"):
		if not Data.has_tail:
			return
			
		var raycast : RayCast2D = $ItemCastRange
		var mouse_point = to_local(get_global_mouse_position())
				
		if mouse_point.x > 100 or mouse_point.y > 100 or mouse_point.x < -100 or mouse_point.y < -100:
			return
				
		raycast.target_position = mouse_point
		raycast.force_raycast_update()	
		if raycast.is_colliding():
			use_tail.emit(raycast.get_collider())
			
	elif event.is_action_pressed("dash"):
		if not Data.have_dash:
			return
		
		if not dash_reload_timer.is_stopped():
			return
			
		dash.emit()
		dash_reload_bar.show()
		dash_reload_timer.start()

func _on_use_dash_reload_timeout():
	dash_reload_bar.hide()
