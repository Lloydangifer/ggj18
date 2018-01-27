extends RigidBody2D

export var player_number = 1

var speed = 10000
var jump_factor = 1.1
var has_jumped = false
var direction_left = true
var direction = 1.0
var base_gravity = get_gravity_scale()
var spawn_point
var teleport_cooldown = 1.0
var teleport_cooldown_progress =0.0

func _ready():
	spawn_point = get_pos()
	set_fixed_process(true)
	set_process(true)
	get_node("foot").connect("body_enter",self,"on_foot_body_enter")
	if not Input.is_joy_known(player_number-1):
		print("ATTENTION, la manette ", player_number, " n'est pas détectée !!")

func _process(delta):
	if teleport_cooldown_progress < teleport_cooldown:
		teleport_cooldown_progress += delta
	elif Input.is_action_pressed("character_" + String(player_number) + "_teleport"):
		#teleport()
		teleport_cooldown_progress = 0
	
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
				if target != self:
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
		get_node("AnimationPlayer").stop()
	
	if has_jumped:
		if Input.is_action_pressed("character_" + String(player_number) + "_down"):
			set_gravity_scale(base_gravity*8.0)
		else:
			set_gravity_scale(base_gravity)
	set_scale(get_scale()*Vector2(direction, 1.0))
	set_linear_velocity(Vector2(velocity_x, get_linear_velocity().y))
	
	if Input.is_action_pressed("character_" + String(player_number) + "_jump") and !has_jumped:
		set_linear_velocity(Vector2(velocity_x, 0))
		apply_impulse(Vector2(), Vector2(0, -speed * jump_factor * delta))
		has_jumped = true
		get_node("AnimationPlayer").play("jump")

func on_foot_body_enter(body):
	if body != self:
		has_jumped = false
		set_gravity_scale(base_gravity)

func respawn():
	set_pos(spawn_point)

func teleport():
	var enemy_pos = get_tree().get_root().get_child(0).get_node("character " + String(-player_number+3)).get_global_pos()
	var enemy_size = get_tree().get_root().get_child(0).get_node("character " + String(-player_number+3)).get_node("CollisionShape2D").get_item_rect().size.x /2
	var self_size = get_node("CollisionShape2D").get_item_rect().size.x / 2
	print("enemy size:" + String(enemy_size))
	print("self size:" + String(self_size))
	set_pos(enemy_pos + Vector2(enemy_size + self_size+1.0,0.0))

func death():
	queue_free()
