extends CharacterBody2D
var HP = 9
var enemy_sprites: Array = [] #2D array of colors>damage states
var dir: int = 1
var target_velocity_x = 100
const grav = 25
const FULL_MASK = 0b11111
var sprite: Sprite2D
var parent: Node2D
var frozen_move: bool = true
var mask_color: int = 1
const enemy_sprites_2 = [
	[
		preload("res://images/light/normal/enemylight-normal-dmg1.png"),
		preload("res://images/light/normal/enemylight-normal-dmg2.png"),
		preload("res://images/light/normal/enemylight-normal-dmg3.png"),
		preload("res://images/light/normal/enemylight-normal-dmg4.png"),
		preload("res://images/light/normal/enemylight-normal-dmg5.png"),
		preload("res://images/light/normal/enemylight-normal-dmg6.png"),
		preload("res://images/light/normal/enemylight-normal-dmg7.png"),
		preload("res://images/light/normal/enemylight-normal-dmg8.png"),
		preload("res://images/light/normal/enemylight-normal.png"),
	], [preload("res://images/light/yellow/enemylight-normal-dmg1.png"),
		preload("res://images/light/yellow/enemylight-normal-dmg2.png"),
		preload("res://images/light/yellow/enemylight-normal-dmg3.png"),
		preload("res://images/light/yellow/enemylight-normal-dmg4.png"),
		preload("res://images/light/yellow/enemylight-normal-dmg5.png"),
		preload("res://images/light/yellow/enemylight-normal-dmg6.png"),
		preload("res://images/light/yellow/enemylight-normal-dmg7.png"),
		preload("res://images/light/yellow/enemylight-normal-dmg8.png"),
		preload("res://images/light/yellow/enemylight-normal.png"),
	], [preload("res://images/light/red/enemylight-normal-dmg1.png"),
		preload("res://images/light/red/enemylight-normal-dmg2.png"),
		preload("res://images/light/red/enemylight-normal-dmg3.png"),
		preload("res://images/light/red/enemylight-normal-dmg4.png"),
		preload("res://images/light/red/enemylight-normal-dmg5.png"),
		preload("res://images/light/red/enemylight-normal-dmg6.png"),
		preload("res://images/light/red/enemylight-normal-dmg7.png"),
		preload("res://images/light/red/enemylight-normal-dmg8.png"),
		preload("res://images/light/red/enemylight-normal.png")
	], [preload("res://images/light/blue/enemylight-normal-dmg1.png"),
		preload("res://images/light/blue/enemylight-normal-dmg2.png"),
		preload("res://images/light/blue/enemylight-normal-dmg3.png"),
		preload("res://images/light/blue/enemylight-normal-dmg4.png"),
		preload("res://images/light/blue/enemylight-normal-dmg5.png"),
		preload("res://images/light/blue/enemylight-normal-dmg6.png"),
		preload("res://images/light/blue/enemylight-normal-dmg7.png"),
		preload("res://images/light/blue/enemylight-normal-dmg8.png"),
		preload("res://images/light/blue/enemylight-normal.png")
	],
]


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

func swap_dir():
	dir *= -1
	$WallCheck.target_position.x *= -1
	$FloorCheck.target_position.x *= -1
	velocity.x *= -1
	target_velocity_x *= -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = $Sprite2D
	parent = get_parent()
	mask_color = parent.enemy_color+1
	if parent:
		frozen_move = parent.freeze_move
	else:
		print("parent property frozen_move not found")
	if false: #load_folder() uses load() which is dynamic, this breaks all exports
		enemy_sprites.append(load_folder('res://images/light/normal/'))
		enemy_sprites.append(load_folder('res://images/light/yellow/'))
		enemy_sprites.append(load_folder('res://images/light/red/'))
		enemy_sprites.append(load_folder('res://images/light/blue/'))
	enemy_sprites = enemy_sprites_2
	#preloaded array
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
	if parent.reverse_start_dir:
		swap_dir()
	#TODO: add dark variant
	#(4 lives, different attacks once they attack)
	#different color collision properties
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not frozen_move:
		if not is_on_floor():
			velocity.y += grav*_delta
		velocity.x = target_velocity_x #fix for collisions affecting velocity
		if $WallCheck.is_colliding() or (not $FloorCheck.is_colliding()):
			swap_dir()
			#print("switched dir to "+str(dir))
		move_and_slide()
