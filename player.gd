extends CharacterBody2D
signal enemy_hit
signal advance_level
@export var red_sprite: Texture2D
@export var yellow_sprite: Texture2D
@export var blue_sprite: Texture2D
@export var colorless_sprite: Texture2D
@onready var sprite_array = [colorless_sprite,yellow_sprite, red_sprite, blue_sprite]
@onready var sprite = $Sprite2D
@onready var hitbox = $Hitbox
@onready var hitboxcollide = $Hitbox/HitboxCollision
@onready var current_level = 1
const FULL_MASK = 0b1111
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

func temp_death():
	main_parent = get_parent()
	print(get_parent)
	lvl_manager_node = main_parent.get_node_or_null("LvlManager")
	if lvl_manager_node:
		spawn = lvl_manager_node.get_child(0).get_node_or_null("PlayerSpawn")
		if spawn:
			self.global_position = spawn.global_position
		else:
			print("where spawn")
	else:
		print("where LvlManager")
func inv_col_mask(no_collide: int) -> int:
	var full = FULL_MASK
	var res = full-2**(no_collide-1)
	collision_mask = res
	return res

func _physics_process(delta: float) -> void:
	if first_frame:
		pass
	if position.y >= KILL_Y:
		temp_death()
	if hitbox_disabled:
		hitboxcollide.set_deferred("disabled",false)
		print("enabling player hitbox")
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
		if color_counter == 1:
			collision_mask = 0b1111 #make all color tiles collide
		else:
			inv_col_mask(color_counter)
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
	if body.is_in_group("hit"):
		print("hittable object encountered")
		body.hit_by_player()
	hitbox_disabled = true
	hitboxcollide.set_deferred("disabled",true)
	rel = body.get_relative_transform_to_parent($Hitbox)
	print(rel) #debug position check
	rel_vec = rel.origin
	rel_ratio_x = rel_vec.x/rel_vec.length()
	rel_ratio_y = rel_vec.y/rel_vec.length()
	sign_vec = rel.origin.normalized()
	if body.is_in_group("hit"): #protect against the first collision event @onready
		schedule_vel_x += -sign_vec.x*SPEED*2*rel_ratio_x #negative of the sign pushes the player away from the enemy
		schedule_vel_y += -sign_vec.y*SPEED*1*rel_ratio_y #this ensures knockback
	print(body)
