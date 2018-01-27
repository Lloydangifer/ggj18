extends RigidBody2D

export var player_number = 1

var speed = 10000
var jump_factor = 1.1
var has_jumped = false

func _ready():
	set_fixed_process(true)
	get_node("foot").connect("body_enter",self,"on_foot_body_enter")
	if not Input.is_joy_known(player_number-1):
		print("ATTENTION, la manette ", player_number, " n'est pas détectée !!")

func _fixed_process(delta):
	var velocity_x = 0
	if Input.is_action_pressed("character_" + String(player_number) + "_left"):
		velocity_x = -speed * delta
	elif Input.is_action_pressed("character_" + String(player_number) + "_right"):
		velocity_x = speed * delta
	set_linear_velocity(Vector2(velocity_x, get_linear_velocity().y))
	
	if Input.is_action_pressed("character_" + String(player_number) + "_jump") and !has_jumped:
		set_linear_velocity(Vector2(velocity_x, 0))
		apply_impulse(Vector2(), Vector2(0, -speed * jump_factor * delta))
		has_jumped = true

func on_foot_body_enter(body):
	if body != self:
		has_jumped = false
