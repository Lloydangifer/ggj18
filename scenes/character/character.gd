extends RigidBody2D

export var player_number = 1

var speed = 100

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("character_" + String(player_number) + "_left"):
		set_linear_velocity(Vector2(-1.0,0.0)*speed)
	if Input.is_action_pressed("character_" + String(player_number) + "_right"):
		set_linear_velocity(Vector2(1.0,0.0)*speed)
	if Input.is_action_pressed("character_" + String(player_number) + "_jump"):
		apply_impulse(Vector2(0.0,0.0),Vector2(0.0,1.0))
