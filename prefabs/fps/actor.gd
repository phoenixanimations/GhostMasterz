extends KinematicBody

export var can_move = true
export var can_crouch = true
export var enable_jump = true

export var default_run = true
# Running speed in m/s
export var run_speed = 6
export var walk_speed = 3
export var crouch_speed = 2

export var jump_height = 6
export var gravity = 9.8

export var mouse_sensitivity = 2
export var joystick_sensitivity = 2
export var joystick_deadzone = 0.2

export var floor_max_angle := 0.785398
export var infinite_inertia := false

var speed_magnitude
var falling_velocity = 0
var snapped = false
var movement
onready var animation = $AnimationPlayer

func get_movement():
	var result = get_node_or_null("Movement")
	if(result and not result.has_method("get_floor_bodies")):
		result = null
	return result

func _ready():
	movement = get_movement()

	for child in Util.get_children_recursive(self):
		if "actor" in child:
			child.actor = self

		if child.has_method("_ready_actor"):
			child._ready_actor()

func is_on_floor_slide(rigidbody):
	for i in get_slide_count():
		var col = get_slide_collision(i).collider
		if((col is RigidBody) and col == rigidbody):
			return true
	return false

func is_on_floor_detect_ground(rigidbody):
	if not movement:
		return false
	for node in movement.get_floor_bodies():
		if node == rigidbody:
			return true
	return false

func is_on_rigidbody(rigidbody):
	if movement:
		return is_on_floor_detect_ground(rigidbody)
	else:
		return is_on_floor_slide(rigidbody)
	
