extends Node2D

const MAX_LOADING_TIME = 10 # seconds

signal loading_finished

var loader = null
var resource_loaded = null

func _ready():
	set_pause_mode(PAUSE_MODE_PROCESS)
	pass

func is_loading():
	return loader != null
			
func _process(delta):
    # poll your loader
	assert(loader)
	var status = loader.poll()

	if status == ERR_FILE_EOF: # load finished
		resource_loaded = loader.get_resource()
		loader = null
		emit_signal("loading_finished", resource_loaded)
		print("[Loader]:\tInteractive load succeeded !")
		
	elif status == OK:
		print("[Loader]:\tLoading in progress...")
	else: # error
		loader = null
		print("[Loader] ERROR:\tInteractive load failed !")
		yield()


func load_interactive(path):
	set_process(true)
	connect("loading_finished", self, "_on_loading_finished")
	loader = ResourceLoader.load_interactive(path)
	
func _on_loading_finished(loaded):
	set_process(false)
	disconnect("loading_finished", self, "_on_loading_finished")
	