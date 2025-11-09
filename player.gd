extends CharacterBody2D


const SPEED = 280.0
const JUMP_VELOCITY = -400.0
var double_jump = 2
const COLOR_STOP = 4
var color_counter = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		double_jump = 2

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or double_jump > 0):
		velocity.y = JUMP_VELOCITY
		double_jump -= 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED*0.2)
	move_and_slide()
