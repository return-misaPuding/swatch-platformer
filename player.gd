extends CharacterBody2D
signal enemy_hit
signal skip_to_level(lvl: int)
@export var red_sprite: Texture2D
@export var yellow_sprite: Texture2D
@export var blue_sprite: Texture2D
@export var colorless_sprite: Texture2D
@onready var sprite_array = [colorless_sprite,yellow_sprite, red_sprite, blue_sprite]
@onready var sprite = $Sprite2D
@onready var hitbox = $Hitbox
@onready var hitboxcollide = $Hitbox/HitboxCollision
@onready var current_level = 1
const FULL_MASK = 0b11111
const MAIN_SPEED = 350.0
var SPEED = MAIN_SPEED
const JUMP_VELOCITY = -500.0
const KILL_Y = 16*150
var double_jump = 2
var velocity_cancel_charge = 3
const COLOR_STOP = 4
var color_counter = 1
var first_frame = true
var hitbox_disabled = false
var rel: Transform2D
var rel_vec: Vector2
var rel_ratio_x: float
var rel_ratio_y: float
var sign_vec: Vector2
var schedule_vel_x: float
var schedule_vel_y: float
var target_scene_path: String
var spawn: Node2D
var main_parent: Node2D
var lvl_manager_node: Node2D
var child
var varstr: String = ""
var next_knockback: bool = true
var elev_layer = 6 #layer the player resides on
#always color_counter+5
func debug_print_child(par: Node2D,recurse:bool=false):
	for i in range(par.get_child_count()):
		child = par.get_child(i)
		if not recurse:
			varstr = "-   "
		else:
			varstr = ""
		print(varstr+"#"+str(i)+" "+str(child.name)+"("+str(child)+")")
		if recurse:
			debug_print_child(child,false)

func temp_death():
	_on_null_velocity()
	main_parent = get_parent()
	lvl_manager_node = main_parent.get_node_or_null("LvlManager")
	if lvl_manager_node:
		debug_print_child(lvl_manager_node,true)
		spawn = lvl_manager_node.get_child(0).get_node("PlayerSpawn")
		if spawn:
			self.global_position = spawn.global_position
		else:
			print("where spawn")
	else:
		print("where LvlManager")
		
func _on_null_velocity() -> void:
	velocity = Vector2.ZERO
	velocity.x = 0
	velocity.y = 0
	schedule_vel_x = 0
	schedule_vel_y = 0

func _on_cut_velocity(cut: int = 2) -> void:
	if cut == 0:
		cut = 2
	velocity.x /= cut
	velocity.y /= cut
	schedule_vel_x /= cut
	schedule_vel_y /= cut

func inv_col_mask(no_collide: int) -> int:
	var full = FULL_MASK
	var res = full-2**(no_collide-1)
	return res
	
func side_damage(_body: Node2D):
	print("side damage from "+str(_body.mask_color)+" to my "+str(color_counter))
	if (_body.mask_color != color_counter) or (_body.mask_color == 1):
		next_knockback = false #mask_color is the CLS enum+1
		temp_death()
	else:
		print("enemy "+str(_body.name)+" mask "+str(_body.collision_mask)+" layer "+str(_body.collision_layer)+" matches my mask "+str(collision_mask)+" layer "+str(collision_layer))

func _physics_process(delta: float) -> void:
	if first_frame:
		pass
	if position.y >= KILL_Y:
		temp_death()
	if hitbox_disabled:
		hitboxcollide.set_deferred("disabled",false)
		#print("enabling player hitbox")
		hitbox_disabled = false
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		double_jump = 2
		velocity_cancel_charge = 3
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or double_jump > 0):
		velocity.y = JUMP_VELOCITY
		double_jump -= 1
	if Input.is_action_just_pressed("color_forward"):
		if color_counter >= COLOR_STOP:
			color_counter = 1 #overflow behavior
		else:
			color_counter += 1
		elev_layer = color_counter+5
		if color_counter == 1:
			collision_mask = FULL_MASK #make all color tiles collide
			collision_layer = 0b100000 #layer 6
		else:
			collision_mask = inv_col_mask(color_counter)
			collision_layer = FULL_MASK-inv_col_mask(elev_layer)
		sprite.texture = sprite_array[color_counter-1]
		#print(color_counter)
		#print(collision_mask)
		
	
	if Input.is_action_just_pressed("velocity_cancel"):
		if velocity_cancel_charge > 1:
			velocity_cancel_charge -= 1
			velocity.x = 0
			velocity.y = 0
		elif velocity_cancel_charge > 0:
			velocity_cancel_charge -= 1
			velocity.x /= 4
			velocity.y /= 4 #velocity cancel loses effectiveness after the 2nd use
			#how long do you plan on staying in the air? :p
			color_counter = 1
			collision_mask = FULL_MASK
			sprite.texture = colorless_sprite #'punish' cancel spam by switching to colorless
		
	if Input.is_action_just_pressed("debug_skip_lvl"):
		skip_to_level.emit(-1)
	$Hitbox.collision_mask = collision_mask
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED*0.2)
	velocity.x += schedule_vel_x
	velocity.y += schedule_vel_y
	schedule_vel_x = 0
	schedule_vel_y = 0
	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	#enemy_hit.emit()
	#rel = body.get_relative_transform_to_parent($Hitbox)
	#print("ouchie? "+str(body))
	rel_vec = global_position - body.global_position
	if body.is_in_group("hit"):
		#print("Y rel "+str(rel_vec.y))
		print("player Y "+str(global_position.y)+" enemy Y "+str(body.global_position.y))
		if global_position.y+30 < body.global_position.y:
			body.hit_by_player_above(self)
		else:
			if body.is_in_group("side_damage"):
				side_damage(body)
		body.hit_by_player(self)
	hitbox_disabled = true
	hitboxcollide.set_deferred("disabled",true)
	print(rel_vec) #debug position check
	#print("length "+str(rel_vec.length()))
	rel_ratio_x = abs(snapped(rel_vec.x/rel_vec.length(),0.001))
	rel_ratio_y = abs(snapped(rel_vec.y/rel_vec.length(),0.001))
	sign_vec = rel_vec.normalized()
	if body.is_in_group("knockback") and next_knockback: #protect against the first collision event @onready
		schedule_vel_x += sign_vec.x*SPEED*2.5*rel_ratio_x #negative of the sign pushes the player away from the enemy
		print("x knockback "+str(schedule_vel_x)+" x ratio "+str(rel_ratio_x))
		schedule_vel_y += sign_vec.y*SPEED*0*rel_ratio_y #this ensures knockback
	if body.name == "TileMapLayer":
		#temp_death()
		pass #this triggers on any tile collision lmao
	next_knockback = true

func _on_hazardbox_entered(body: Node2D):
	if body.name == "TileMapLayer":
		temp_death()
