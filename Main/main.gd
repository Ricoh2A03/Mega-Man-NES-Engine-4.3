extends Node
class_name Main

@export var first_scene: PackedScene

var fullscreen: bool = false

func _ready():
	if first_scene == null:
		return
	add_scene(first_scene, false)

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		toggle_fullscreen()

func add_scene(scene: PackedScene, need_reference: bool):
	var scene_instance = scene.instantiate()
	call_deferred("add_child", scene_instance)
	if need_reference:
		return scene_instance

func toggle_fullscreen():
	fullscreen = !fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
