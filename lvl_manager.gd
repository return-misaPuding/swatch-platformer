extends Node2D
const max_level = 3
var current_level = 1
var target_scene_path: String
var current_scene: Node2D = null
var trigger: Signal
var spawn: Node2D
@onready var player = get_parent().get_node_or_null("Player")
signal player_null_velocity

func level_advance():
	print("entered portal")
	current_level += 1
	target_scene_path = "res://lvl"+str(current_level)+".tscn"
	if current_level > max_level:
		load_level("res://win.tscn")
	else:
		load_level(target_scene_path)
		

func _on_portal_trigger():
	print("portal trigger, current "+str(current_level))
	level_advance()
	
func load_level(path: String):
	if current_scene:
		current_scene.queue_free()
	player_null_velocity.emit()
	current_scene = load(path).instantiate()
	self.add_child(current_scene)
	await get_tree().process_frame
	spawn = current_scene.get_node_or_null("PlayerSpawn")
	await get_tree().process_frame
	player = current_scene.get_tree().get_nodes_in_group("playergroup")[0]
	if spawn and player:
		player.global_position = spawn.global_position
	else:
		print("no exist? :(")
		print(player)
		print(spawn)
	for portal: Node2D in current_scene.get_tree().get_nodes_in_group("portal"):
		trigger = portal.portal_trigger
		portal.portal_trigger.connect(_on_portal_trigger)
	

func _on_level_end_body_entered(body: Node2D) -> void:
	if body.is_in_group("playergroup"):
		level_advance()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level("res://lvl1.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
