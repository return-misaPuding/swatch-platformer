extends CharacterBody2D
var HP = 9
var enemy_sprites: Array = [] #2D array of colors>damage states
var dir: int = 1
var target_velocity_x = 100
const grav = 100
const FULL_MASK = 0b11111
var sprite: Sprite2D
var parent: Node2D
var frozen_move: bool = true
var mask_color: int = 1


func enemy_die():
	collision_layer = 0
	collision_mask = 0
	$SqHitbox.set_deferred("monitorable",false)
	$SqHitbox.set_deferred("monitoring", false)
	print("enemy death")
	print(global_position)
	$CollisionShape2D.set_deferred("disabled",true)
	call_deferred("queue_free")

func inv_col_mask(no_collide: int) -> int:
	var full = FULL_MASK
	var res = full-2**(no_collide-1)
	return res

func hit_by_player_above(_body: Node2D):
	if HP > 1:
		sprite.texture = enemy_sprites[parent.enemy_color][HP-2]
	else:
		enemy_die()
		return null
	HP -= 1
	print("enemy hit, "+str(HP)+" HP remaining")
func hit_by_player(_body: Node2D):
	pass
	
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
	sprite = $Sprite2D
	parent = get_parent()
	mask_color = parent.enemy_color+1
	if parent:
		frozen_move = parent.freeze_move
	else:
		print("parent property frozen_move not found")
	enemy_sprites.append(load_folder('res://images/light/normal/'))
	enemy_sprites.append(load_folder('res://images/light/yellow/'))
	enemy_sprites.append(load_folder('res://images/light/red/'))
	enemy_sprites.append(load_folder('res://images/light/blue/'))
	print("color "+str(parent.enemy_color)+" "+str(int(parent.enemy_color)))
	sprite.texture = enemy_sprites[parent.enemy_color][-1]
	if mask_color > 1:
		collision_mask = inv_col_mask(mask_color)
		$WallCheck.collision_mask = collision_mask
		$FloorCheck.collision_mask = collision_mask
		collision_layer = FULL_MASK-collision_mask
	$WallCheck.target_position = Vector2(32,0)
	$FloorCheck.target_position = Vector2(45,40)
	velocity.x = target_velocity_x
	#TODO: add dark variant
	#(4 lives, different attacks once they attack)
	#different color collision properties
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not frozen_move:
		if not is_on_floor():
			velocity.y = _delta*grav
		velocity.x = target_velocity_x #fix for collisions affecting velocity
		if $WallCheck.is_colliding() or (not $FloorCheck.is_colliding()):
			dir *= -1
			$WallCheck.target_position.x *= -1
			$FloorCheck.target_position.x *= -1
			velocity.x *= -1
			target_velocity_x *= -1
			#print("switched dir to "+str(dir))
		move_and_slide()
