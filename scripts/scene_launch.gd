extends Node

signal we_have_a_winner

var first_scene
var winner_heavy
var winner_big
var winner_sworded
var heavy_odd = 0.2
var big_odd = 0.2
var sworded_odd = 0.5
var heavy_modifier = 0.1
var big_modifier = 0.1
var sworded_modifier = 0.2

func _ready():
	var player_one = load("res://scenes/character/character.tscn")
	var player_two = load("res://scenes/character/character.tscn")
	var player_one_instance = player_one.instance()
	var player_two_instance = player_two.instance()
	
	if first_scene:
		winner_heavy = false
		winner_big = false
		winner_sworded = false
		player_one_instance.transmission = false
		player_two_instance.transmission = false
	else:
		player_one_instance.transmission = true
		player_two_instance.transmission = true
		if winner_heavy:
			randomize()
			player_one_instance.heavy = randf() > (heavy_odd - heavy_modifier)
			player_two_instance.heavy = randf() > (heavy_odd - heavy_modifier)
		else:
			randomize()
			player_one_instance.heavy = randf() > (heavy_odd + heavy_modifier)
			player_two_instance.heavy = randf() > (heavy_odd + heavy_modifier)
		if winner_big:
			randomize()
			player_one_instance.big = randf() > (big_odd - big_modifier)
			player_two_instance.big = randf() > (big_odd - big_modifier)
		else:
			randomize()
			player_one_instance.big = randf() > (big_odd + big_modifier)
			player_two_instance.big = randf() > (big_odd + big_modifier)
		if winner_sworded:
			randomize()
			player_one_instance.has_sword = randf() > (sworded_odd - sworded_modifier)
			player_two_instance.has_sword = randf() > (sworded_odd - sworded_modifier)
		else:
			randomize()
			player_one_instance.has_sword = randf() > (sworded_odd + sworded_modifier)
			player_two_instance.has_sword = randf() > (sworded_odd + sworded_modifier)
	
	player_one_instance.set_name("player_1")
	player_one_instance.player_number = 1
	player_two_instance.set_name("player_2")
	player_two_instance.player_number = 2
	var spawn_p1 = get_node("spawn_p1")
	var spawn_p2 = get_node("spawn_p2")
	player_one_instance.set_pos(spawn_p1.get_pos())
	player_two_instance.set_pos(spawn_p2.get_pos())
	player_one_instance.connect("player_death",self,"on_player_death")
	player_two_instance.connect("player_death",self,"on_player_death")
	add_child(player_one_instance)
	add_child(player_two_instance)

func on_player_death(var player_number):
	var winner = get_node("player_" + String(player_number))
	winner_heavy = winner.heavy
	winner_big = winner.big
	winner_sworded = winner.has_sword
	emit_signal("we_have_a_winner",self, winner_heavy,winner_big,winner_sworded)