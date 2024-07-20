extends CharacterBody2D

#Constants
const SPEED : float = 300.0
const JUMP_VELOCITY : float = -400.0

#State machine
enum States {ON_GROUND, ON_AIR, ON_BRANCH, ON_DEATH, ON_TAIL}
var state : States = States.ON_AIR

#Also variables
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_dir : float = 1

#Nodes
@onready var animated_sprite : AnimatedSprite2D = $Sprites/AnimatedSprite2D
@onready var sounds_player : AudioStreamPlayer2D = $SoundsPlayer
@export var respawn_node: Node2D
var level_area: Area2D
var branch_marker: Array
var local_tail_target : StaticBody2D = null
var tail_joint : PinJoint2D = null
var tail_rigid : RigidBody2D = null

func play_sound(sound_name: String):
	var sounds_path = "res://Assets/Sounds/"
	if sound_name == "running" and sounds_player.playing:
		return
	
	sounds_player.stream = load(sounds_path + sound_name + ".mp3")
	sounds_player.play()

func jump(jump_velocity = JUMP_VELOCITY) -> void:
	if state == States.ON_TAIL:
		animated_sprite.play(Data.selected_skin + "_let_go_tail")
	else:
		animated_sprite.play(Data.selected_skin + "_jump")
	velocity.y = jump_velocity
	play_sound("jump")
	state = States.ON_AIR

func change_state(delta) -> void:
	match state:
		States.ON_GROUND:
			if not is_on_floor():
				state = States.ON_AIR
				return
				
			var axis_dir : float = Input.get_axis("turn_left", "turn_right")
			if axis_dir == 0:
				animated_sprite.animation = Data.selected_skin + "_idle"
				sounds_player.stop()
			else:
				animated_sprite.animation = Data.selected_skin + "_running"
				play_sound("running")
				
			velocity.x = axis_dir * SPEED
			if last_dir != axis_dir and axis_dir != 0:
				animated_sprite.flip_h = last_dir > 0
				last_dir = axis_dir
			
			animated_sprite.play()
			respawn_node.position = position
			
			if Input.is_action_pressed("jump"):
				jump()
				
		States.ON_AIR:
			$Sprites.rotation_degrees = 0
			
			if Input.is_action_just_pressed("interact") and not branch_marker.is_empty():
				branch_marker[0].global_position = position
				state = States.ON_BRANCH
				return
					
			if is_on_floor():
				state = States.ON_GROUND
				return
				
			velocity.y += gravity * delta
			
		States.ON_BRANCH:
			animated_sprite.play(Data.selected_skin + "_idle")
			sounds_player.stop()
			
			if branch_marker.is_empty():
				printerr("branch marker null exception")
				state = States.ON_AIR
				return
				
			var branch: Area2D = branch_marker[0].get_parent()
			$Sprites.rotation_degrees = branch.rotation_degrees - 90
			position = branch_marker[0].global_position
			
			var axis_dir : float = Input.get_axis("turn_left", "turn_right")
			velocity.x = axis_dir * SPEED
			
			if Input.is_action_just_pressed("jump"):
				jump()
			elif Input.is_action_just_pressed("interact"):
				velocity.y = 0
				state = States.ON_AIR
			
		States.ON_TAIL:
			sounds_player.stop()
			$Sprites.look_at(local_tail_target.global_position)
			$Sprites/TailSprite.region_rect.size.x = move_toward($Sprites/TailSprite.region_rect.size.x, to_local(local_tail_target.global_position).length() * 2.1, delta * 600)
			
			if (Input.is_action_pressed("use_tail") or Input.is_action_just_pressed("jump")) and $Item/TailReloadTimer.is_stopped():
				del_tail()
				jump(-175)
				return
				
			var axis_dir : float = Input.get_axis("turn_left", "turn_right")
			velocity.x = axis_dir * SPEED
			
			if tail_joint != null:
				position = tail_rigid.position
				return
				
			var main = $/root/Main
		
			tail_joint = PinJoint2D.new()
			main.add_child(tail_joint)
			tail_joint.global_position = local_tail_target.global_position
			
			tail_rigid = load("res://Scenes/tail_rigid.tscn").instantiate()
			main.add_child(tail_rigid)
			tail_rigid.position = position
			
			tail_joint.node_a = local_tail_target.get_path()
			tail_joint.node_b = tail_rigid.get_path()
			
		States.ON_DEATH:
			pass
			
func del_tail():
	$Sprites/TailSprite.region_rect.size.x = 0
	animated_sprite.flip_v = false
	animated_sprite.play(Data.selected_skin + "_let_go_tail")
	animated_sprite.rotation_degrees = 0
	
	local_tail_target = null
	if tail_joint == null and tail_rigid == null:
		return
		 
	tail_joint.queue_free()
	tail_rigid.queue_free()
	tail_joint = null
	tail_rigid = null

func respawn():
	position = respawn_node.position
	del_tail()
	$Item.reload_dash()
	state = States.ON_AIR
	
func death():
	state = States.ON_DEATH
	velocity = Vector2.ZERO
	sounds_player.stop()
	$/root/Main/HUD/DeathMenu.show_death_screen()

func _physics_process(delta):
	@warning_ignore("narrowing_conversion")
	Data.distance = position.x / 100
	change_state(delta)
	move_and_slide()

func _on_interaction_area_entered(area: Area2D):
	if area.name == "ShopsArea":
		$/root/Main/HUD.hide_distance_label()
		$/root/Main/HUD.show_banana_label()
		$/root/Main/HUD/Shops/Buttons.enable()
		return
		
	if area.is_in_group("DeathZone") or area.is_in_group("DeathTile"):
		death()
	elif area.is_in_group("Branch"):
		branch_marker.append(area.get_child(2)) # !!Change idx if playerpoint has been replaced!!
	elif area.is_in_group("EndTrigger"):
		if area != level_area:
			level_area = area
			Data.current_level_idx = Data.next_level_idx

func _on_interaction_area_exited(area: Area2D):
	if area.is_in_group("Branch"):
		branch_marker.erase(area.get_child(2))
		return
		
	if area.name == "ShopsArea":
		$/root/Main/HUD.hide_banana_label()
		$/root/Main/HUD.show_distance_label()
		
		var shops_node = $/root/Main/HUD/Shops
		for i in shops_node.get_child_count()-1:
			shops_node.get_child(i).disable()

func _on_forward_trigger_area_entered(area: Area2D):
	if area.is_in_group("EndTrigger"):
		LevelLoader.add_next_level() 

func _on_backward_trigger_area_entered(area: Area2D):
	if area.is_in_group("EndTrigger"):
		print("del previous level")
		LevelLoader.del_previous_level() 

func use_tail(tail_target : StaticBody2D):
	if tail_joint != null or state == States.ON_GROUND:
		return
		
	local_tail_target = tail_target
	state = States.ON_TAIL
	animated_sprite.play(Data.selected_skin + "_take_tail")
	animated_sprite.flip_v = true
	animated_sprite.rotation_degrees = 90
	$Item/TailReloadTimer.start()

func dash():
	velocity = Input.get_vector("turn_left", "turn_right", "look_up", "look_down") * 550
	play_sound("dash")
	$DashParticles.emitting = true
