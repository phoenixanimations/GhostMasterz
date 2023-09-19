extends Node

var actor
var gravity_vec = Vector3()
var crouched = false
var can_jump = true
var current_speed = 0

var acceleration
var ground_acceleration = 10
var air_acceleration = 5
var direction = Vector3()
var movement = Vector3()
onready var land_tween = $LandTween
onready var detect_ground = $DetectGround
var camera
var mesh_instance
var collision_shape
var head
var velocity = Vector3()

func _ready_actor():
	camera = actor.get_node_or_null("Head/Camera")
	mesh_instance = actor.get_node_or_null("MeshInstance")
	collision_shape = actor.get_node_or_null("CollisionShape")
	head = actor.get_node_or_null("Head")
	
func get_floor_bodies():
	return detect_ground.get_overlapping_bodies()

func get_floor_rigidbodies():
	var result := []
	for body in get_floor_bodies():
		if body is RigidBody:
			result.push_back(body)
	return result

func _input(_event):
	direction = Vector3()

func land_animation():
	if not head:
		return
	var movement_y = clamp(actor.falling_velocity, -20, 0) / 40
	land_tween.interpolate_property(camera, "translation:y", 0, movement_y, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	land_tween.interpolate_property(camera, "translation:y", movement_y, 0, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	land_tween.start()
	
func crouch_animation(button_pressed):
	if(not (actor.can_crouch and mesh_instance and
			collision_shape and head)):
		return
	if button_pressed:
		if not crouched:
			actor.animation.play("crouch")
			crouched = true
	else:
		if crouched:
			actor.animation.play_backwards("crouch")
			crouched = false

func move():
	direction = Vector3()
	if actor.can_move:
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			direction.z += -1
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			direction.z += 1
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			direction.x += -1
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			direction.x += 1

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

func slide(delta):
	# Snaps the character on the ground and changes the gravity vector to climb
	# slopes at the same speed until 45 degrees or ~0.785398 radians
	if actor.is_on_floor():
		if actor.snapped == false:
			actor.falling_velocity = gravity_vec.y
			land_animation()
		acceleration = ground_acceleration
		movement.y = 0
		gravity_vec = -actor.get_floor_normal() * 10
		actor.snapped = true
	else:
		acceleration = air_acceleration
		if actor.snapped:
			gravity_vec = Vector3()
			actor.snapped = false
		else:
			gravity_vec += Vector3.DOWN * actor.gravity * delta

func apply_speed():
	if actor.is_on_floor():
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

		if crouched:
			current_speed = actor.crouch_speed

func check_jump():
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A)) and actor.enable_jump:
		if actor.is_on_floor() and can_jump:
			actor.snapped = false
			can_jump = false
			gravity_vec = Vector3.UP * actor.jump_height
	else:
		can_jump = true

func _physics_process(delta):
	move()
	slide(delta)
	apply_speed()
	check_jump()
	
	if actor.is_on_ceiling():
		gravity_vec.y = 0
	
	# crouch logic part 2
	if Input.is_key_pressed(KEY_CONTROL) or Input.is_key_pressed(KEY_C) or Input.is_joy_button_pressed(0, JOY_XBOX_B):
		crouch_animation(true)
	else:
		crouch_animation(false)
	# end crouch logic part 2

	velocity = velocity.linear_interpolate(direction * current_speed, acceleration * delta)
	
	movement.x = velocity.x + gravity_vec.x
	movement.z = velocity.z + gravity_vec.z
	movement.y = gravity_vec.y

	movement = actor.move_and_slide(movement, Vector3.UP, false, 4, actor.floor_max_angle, actor.infinite_inertia)
	
	actor.speed_magnitude = movement.length()
