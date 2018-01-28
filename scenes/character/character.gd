extends RigidBody2D

signal player_death

export var player_number = 1

var speed = 10000
var jump_factor = 1.1
var has_jumped = false
var direction_left = true
var direction = 1.0
var base_gravity = get_gravity_scale()
var spawn_point
var teleport_cooldown = 1.0
var teleport_cooldown_progress = 0.0
var has_sword
var heavy
var big
var sword_pos_out
var sword_pos_sheathe
var big_scale = 2
var dash_cooldown = 5.0
var dash_cooldown_progress = 0.0
var is_dashing = false
var dashing_duration = 0.5
var dashing_vanish_progress = 0.0
var dash_speed_factor = 5.0
var transmission

func _ready():
	spawn_point = get_pos()
	set_fixed_process(true)
	set_process(true)
	get_node("foot").connect("body_enter",self,"on_foot_body_enter")
	if not Input.is_joy_known(player_number-1):
		print("ATTENTION, la manette ", player_number, " n'est pas détectée !!")
	randomize()
	if !transmission:
		has_sword = randf() > 0.5
		heavy = randf() > 0.5
		big = randf() > 0.5
	if has_sword:
		get_node("attack").set_scale(Vector2(4.0,1.0))
	else:
		get_node("attack").set_scale(Vector2(1.0,1.0))
	if heavy:
		set_gravity_scale(5)
		base_gravity = 5
	sword_pos_sheathe = Vector2(-6.0, -8.5)
	sword_pos_out = get_node("sword").get_pos()
	if big: 
		sword_pos_sheathe *= big_scale
		sword_pos_out *= big_scale
		for child in get_children():
			if child extends Node2D:
				child.set_scale(child.get_scale()*big_scale)
				child.set_pos(child.get_pos()*big_scale)

func _process(delta):
	if dash_cooldown_progress < dash_cooldown:
		dash_cooldown_progress += delta
	
	if is_dashing:
		dashing_vanish_progress += delta
		if dashing_vanish_progress >= dashing_duration:
			is_dashing = false
			dashing_vanish_progress = 0.0
	
	if Input.is_action_pressed("character_" + String(player_number) + "_respawn"):
		respawn()
	
	if Input.is_action_pressed("character_" + String(player_number) + "_attack"):
		if Input.is_action_pressed("character_" + String(player_number) + "_up"):
			var targets = get_node("attack_up").get_overlapping_bodies()
			for target in targets:
				if target != self:
					target.death()
		else:
			var targets = get_node("attack").get_overlapping_bodies()
			for target in targets:
				if target != self and target extends RigidBody2D:
					target.death()
		get_node("AnimationPlayer").play("attack")

func _fixed_process(delta):
	var velocity_x = 0
	if Input.is_action_pressed("character_" + String(player_number) + "_left"):
		direction = 1.0
		velocity_x = -speed * delta
		if not get_node("AnimationPlayer").is_playing() and !has_jumped:
			get_node("AnimationPlayer").play("run");
	elif Input.is_action_pressed("character_" + String(player_number) + "_right"):
		direction = -1.0
		velocity_x = speed * delta
		if not get_node("AnimationPlayer").is_playing() and !has_jumped:
			get_node("AnimationPlayer").play("run");
	elif get_node("AnimationPlayer").is_playing() and get_node("AnimationPlayer").get_current_animation() == "run":
		get_node("AnimationPlayer").play("stand")
	
	if has_jumped:
		if Input.is_action_pressed("character_" + String(player_number) + "_down"):
			set_gravity_scale(base_gravity*8.0)
		else:
			set_gravity_scale(base_gravity)
	set_scale(get_scale()*Vector2(direction, 1.0))
	if !is_dashing:
		set_linear_velocity(Vector2(velocity_x, get_linear_velocity().y))
	
	if Input.is_action_pressed("character_" + String(player_number) + "_jump") and !has_jumped:
		set_linear_velocity(Vector2(velocity_x, 0))
		apply_impulse(Vector2(), Vector2(0, -speed * jump_factor * delta))
		has_jumped = true
		get_node("AnimationPlayer").play("jump")
	
	if Input.is_action_pressed("character_" + String(player_number) + "_dash_left"):
		if dash_cooldown_progress >= dash_cooldown:
			velocity_x = -speed * delta * dash_speed_factor
			apply_impulse(Vector2(), Vector2(velocity_x, get_linear_velocity().y))
			dash_cooldown_progress = 0.0
			is_dashing = true
	if Input.is_action_pressed("character_" + String(player_number) + "_dash_right"):
		if dash_cooldown_progress >= dash_cooldown:
			velocity_x = speed * delta * dash_speed_factor
			apply_impulse(Vector2(), Vector2(velocity_x, get_linear_velocity().y))
			dash_cooldown_progress = 0.0
			is_dashing = true

func on_foot_body_enter(body):
	if body != self:
		has_jumped = false
		set_gravity_scale(base_gravity)
		get_node("AnimationPlayer").play("stand")

func respawn():
	set_pos(spawn_point)

func death():
	emit_signal("player_death", player_number)
	queue_free()
	
func show_sword():
	if has_sword:
		get_node("sword").set_rotd(270)
		get_node("sword").set_pos(sword_pos_out)
		get_node("sword").set_hidden(false)

func sheathe():
	if has_sword:
		get_node("sword").set_rotd(50)
		get_node("sword").set_pos(sword_pos_sheathe)
		
func hide_sword():
	if has_sword:
		get_node("sword").set_hidden(true)