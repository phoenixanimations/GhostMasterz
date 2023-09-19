extends Node

var actor
var current_speed = 0
var direction = Vector3()
var velocity = Vector3()


func _ready_actor():
	if actor.default_run:
		current_speed = actor.run_speed
	else:
		current_speed = actor.walk_speed

func move():
	if not actor.can_move:
		return

	direction = Vector3()
	
	if Input.is_action_pressed("up"):
		direction.z += -1
	if Input.is_action_pressed("down"):
		direction.z += 1
	if Input.is_action_pressed("left"):
		direction.x += -1
	if Input.is_action_pressed("right"):
		direction.x += 1
	
	if actor.enable_jump and Input.is_action_pressed("jump"):
		direction.y += 1
	if actor.can_crouch and Input.is_action_pressed("crouch"):
		direction.y -= 1
		
	direction = direction.normalized()

	# If we aren't using the keyboard, take the input from the left
	# analog of the joystick.
	if direction == Vector3():
		direction.z = Input.get_joy_axis(0, 1)
		direction.x = Input.get_joy_axis(0, 0)

		# Apply a deadzone to the joystick.
		if(direction.z < actor.joystick_deadzone and
		   direction.z > -actor.joystick_deadzone):
			direction.z = 0
		if(direction.x < actor.joystick_deadzone and
		   direction.x > -actor.joystick_deadzone):
			direction.x = 0

	# Rotates the direction from the Y axis to move forward
	direction = direction.rotated(Vector3.UP, actor.rotation.y)

func apply_speed():
	if Input.is_key_pressed(KEY_SHIFT) or Input.get_joy_axis(0, 6) >= 0.6:
		if actor.default_run:
			current_speed = actor.walk_speed
		else:
			current_speed = actor.run_speed
	else:
		if actor.default_run:
			current_speed = actor.run_speed
		else:
			current_speed = actor.walk_speed

func _physics_process(_delta):
	move()
	apply_speed()
	direction = actor.move_and_slide(direction * current_speed,
		Vector3.UP, false, 4, actor.floor_max_angle, actor.infinite_inertia)

