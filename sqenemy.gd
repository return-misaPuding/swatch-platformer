extends RigidBody2D
signal enemy_hit
var HP = 9
var enemy_sprites: Array = [] #2D array of colors>damage states
@onready var sprite = $Sprite2D
func enemy_die():
	collision_layer = 0
	collision_mask = 0
	$SqHitbox.set_deferred("monitorable",false)
	$SqHitbox.set_deferred("monitoring", false)
	print("enemy death")
	print(global_position)
	$CollisionShape2D.set_deferred("disabled",true)
	call_deferred("queue_free")

func hit_by_player():
	if HP > 1:
		sprite.texture = enemy_sprites[0][HP-2]
	else:
		enemy_die()
		return null
	HP -= 1
	print("enemy hit, "+str(HP)+" HP remaining")
	
func load_folder(path: String) -> Array[Texture2D]:
	var file_textures: Array[Texture2D] = []
	for file in DirAccess.get_files_at(path):
		if file.ends_with(".png"):
			print("loading "+path+file)
			file_textures.append(load(path+file))
	print(str(len(file_textures)))
	return file_textures

func _on_enemy_hit():
	print("hit signal")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	"""
	var player = get_tree().get_first_node_in_group("playergroup")
	print("are we even real")
	if player:
		print("i'm da playah")
		player.connect("enemy_hit", Callable(self, "_on_enemy_hit"))
	"""
	enemy_sprites.append(load_folder('res://images/light/normal/'))
	enemy_sprites.append(load_folder('res://images/light/yellow/'))
	enemy_sprites.append(load_folder('res://images/light/red/'))
	enemy_sprites.append(load_folder('res://images/light/blue/'))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
