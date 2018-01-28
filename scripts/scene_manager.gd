extends Node2D

var current_scene 

var last_winner_carac = {}
var first_load = true

func _ready():
	current_scene = "splashscreen"
	set_pause_mode(PAUSE_MODE_PROCESS)

func get_current_scene():
	return current_scene
	
func goto_scene(name) :
	current_scene = name
	g_loader.load_interactive("res://scenes/"+name+"/"+name+".tscn")
	g_loader.connect("loading_finished", self, "_on_loading_finished")
	
func _on_loading_finished(scene):
	g_loader.disconnect("loading_finished", self, "_on_loading_finished")
	get_tree().get_current_scene().queue_free()
	if scene.get_name() != "splashscreen" and scene.get_name() != "rules":
		scene.first_scene = first_load
		if !first_load:
			scene.winner_heavy = last_winner_carac["heavy"]
			scene.winner_big = last_winner_carac["big"]
			scene.winner_sworded = last_winner_carac["sworded"]
		first_load = false
	var scene_inst = scene.instance()
	get_tree().get_root().add_child(scene_inst)
	get_tree().set_current_scene(scene_inst);
	scene_inst.connect("we_have_a_winner",self,"on_combat_finished")

func on_combat_finished(scene, winner_heavy, winner_big, winner_sworded):
	scene.disconnect("we_have_a_winner", self, "on_combat_finished")
	last_winner_carac["heavy"] = winner_heavy
	last_winner_carac["big"] = winner_big
	last_winner_carac["sworded"] = winner_sworded
	goto_scene("level_1")