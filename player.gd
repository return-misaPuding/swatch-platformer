extends CharacterBody2D

@export var red_sprite: Texture2D
@export var yellow_sprite: Texture2D
@export var blue_sprite: Texture2D
@export var colorless_sprite: Texture2D
@onready var sprite_array = [colorless_sprite,yellow_sprite, red_sprite, blue_sprite]
@onready var sprite = $Sprite2D
const MAIN_SPEED = 280.0
var SPEED = MAIN_SPEED
const JUMP_VELOCITY = -400.0
var double_jump = 2
var velocity_cancel_charge = 3
const COLOR_STOP = 4
var color_counter = 1
var first_frame = true
func inv_col_mask(no_collide: int) -> int:
	var full = 0b1111
	var res = full-2**(no_collide-1)
	collision_mask = res
	return res

func _physics_process(delta: float) -> void:
	if first_frame:
		pass
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		double_jump = 2

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
		print(color_counter)
		print(collision_mask)
		
	
	if Input.is_action_just_pressed("velocity_cancel"):
		pass
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED*0.2)
	move_and_slide()
