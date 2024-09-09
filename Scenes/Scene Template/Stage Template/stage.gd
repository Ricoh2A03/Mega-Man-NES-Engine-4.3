extends Scene
class_name Stage

# Signals
signal player_died()
signal boss_defeated()

var player_ref = null
var camera_ref = null

var is_scrolling: bool = false

@export_category("Room List")
##First room of the stage.
@export var start_room: Room
## Current active room
var current_room: Room
var current_room_limits: Array[int] = [0, 0, 0, 0] # left - [0], top - [1], right - [2], bottom - [3]

@export_category("Checkpoint List")
##List of all stage checkpoints. First one in this array is the start of the stage.
@export var checkpoints: Array[Checkpoint] = []
var current_checkpoint: Checkpoint

@export_category("Player and Camera")
##Path to Player node to instatiate.
@export var player_path: PackedScene
##Path to Camera node to instatiate.
@export var camera_path: PackedScene

@onready var ui = $UI

###########################################

# add support for views and checkpoints (+ -)

# add level camera and connect it to player
# add screen limits to player
# add scrolling

###########################################

# Ready
func _ready():
	AudioServer.set_bus_volume_db(0, -2)

	super._ready() # play music
	create_camera()

	current_room = start_room
	set_stage_camera_limits(current_room)
	set_stage_room_limits()

	current_checkpoint = checkpoints[0] # set current checkpoint to the first in the array
	camera_ref.global_position = current_checkpoint.global_position # set camera position to checkpoint

	flash_ready_text() # flash ready and turn health bar on

func _process(delta):
	check_scrolling_criterias()

###########################################

func check_scrolling_criterias():
	if player_ref and camera_ref:

		if !is_scrolling:
			if (player_ref.global_position.y >= (current_room_limits[3]) and player_ref.get_player_state() == 1 and player_ref.velocity.y > 0) or \
				(player_ref.global_position.y >= (current_room_limits[3]) and player_ref.get_player_state() == 2 and player_ref.velocity.y > 0):  # check bottom edge
				if current_room.exit_bottom:
					is_scrolling = true
					player_ref.scroll_player(3)
					camera_ref.camera_start_scroll(current_room.exit_bottom, 3)
				else:
					player_ref.death_proccessing(true)
					player_died.emit()

			if (player_ref.global_position.y <= current_room_limits[1] and player_ref.get_player_state() == 2 and player_ref.velocity.y < 0): # check top edge
				if current_room.exit_top:
					is_scrolling = true
					player_ref.scroll_player(1)
					camera_ref.camera_start_scroll(current_room.exit_top, 1)

			if (player_ref.global_position.x <= (current_room_limits[0] + 16)):
				if current_room.exit_left:
					is_scrolling = true
					player_ref.scroll_player(0)
					camera_ref.camera_start_scroll(current_room.exit_left, 0)

			if (player_ref.global_position.x >= (current_room_limits[2] - 16)):
				if current_room.exit_right:
					is_scrolling = true
					player_ref.scroll_player(2)
					camera_ref.camera_start_scroll(current_room.exit_right, 2)

### S C R O L L I N G ###
func start_scrolling(target_room: Room, direction: int):
	if target_room == current_room: return
	camera_ref.camera_start_scroll(target_room, direction)
	player_ref.room_limits = current_room_limits

func stage_finished_scrolling(room: Room):
	current_room = room
	set_stage_room_limits()
	is_scrolling = false
	player_ref.room_limits = current_room_limits

###########################################

func load_checkpoint(checkpoint: Checkpoint):
	pass

func spawn_player():
	if player_path == null:
		return
	var p_instance = player_path.instantiate()
	call_deferred("add_child", p_instance)
	player_ref = p_instance
	player_ref.connect("player_dead", _player_died)

	if current_checkpoint != null:
		p_instance.global_position = Vector2(current_checkpoint.global_position.x, -16)
	else:
		p_instance.global_position = Vector2(128, -16)

func set_stage_room_limits():
	current_room_limits = [current_room.global_position.x, 
	current_room.global_position.y,
	(current_room.global_position.x + current_room.size.x),
	(current_room.global_position.y + current_room.size.y)]

### C A M E R A ###

func create_camera():
	if camera_path == null or camera_ref != null:
		return
	var cam_instance = camera_path.instantiate()
	call_deferred("add_child", cam_instance)
	cam_instance.connect("finished_scrolling", stage_finished_scrolling)
	camera_ref = cam_instance

func set_stage_camera_limits(room: Room):
	if camera_ref: camera_ref.update_camera_limits(current_room)

func connect_camera_to_player():
	if camera_ref:
		camera_ref.reparent(player_ref, false)
		camera_ref.global_position = player_ref.global_position

###########################################

func _player_died():
	super.music_pause(true)

# 
func flash_ready_text(): ui.get_node("ReadyLabel/AnimationPlayer").play("flash")

func _on_animation_player_finished(anim_name):
	match anim_name:
		"flash":
			spawn_player() # spawn player
			player_ref.room_limits = current_room_limits
			connect_camera_to_player()

# ГОООООООООООЛ
