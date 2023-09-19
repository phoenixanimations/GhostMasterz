extends RayCast

var actor

export var mass_limit = 50
export var throw_force = 5

var object_grabbed = null
var can_use = true

onready var grab_position = $GrabPosition
onready var crosshair = $Crosshair

func throw():
	if object_grabbed:
		object_grabbed.linear_velocity = global_transform.basis.z * -throw_force
		release()

func release():
	object_grabbed.axis_lock_angular_x = false
	object_grabbed.axis_lock_angular_y = false
	object_grabbed.axis_lock_angular_z = false
	object_grabbed = null

func _physics_process(_delta):
	var col = get_collider()
	
	crosshair.visible = false
	
	if((not object_grabbed) and
	   (col is RigidBody) and
	   (col.mass <= mass_limit)):
		crosshair.visible = true
		crosshair.dot_red()

	if object_grabbed:
		crosshair.visible = true
		crosshair.dot_dark_red()
		var vector = grab_position.global_transform.origin - object_grabbed.global_transform.origin
		object_grabbed.linear_velocity = vector * 10
		object_grabbed.axis_lock_angular_x = true
		object_grabbed.axis_lock_angular_y = true
		object_grabbed.axis_lock_angular_z = true

		if((vector.length() >= 3) or actor.is_on_rigidbody(object_grabbed)):
			object_grabbed.set_mode(0)
			release()

	if(Input.is_key_pressed(KEY_E) or
	   Input.is_joy_button_pressed(0, JOY_XBOX_Y) or 
	   Input.is_mouse_button_pressed(BUTTON_LEFT)):
		if can_use:
			can_use = false
			if not object_grabbed:
				if col is RigidBody and col.mass <= mass_limit:
					object_grabbed = col
					object_grabbed.rotation_degrees.x = 0
					object_grabbed.rotation_degrees.z = 0
			else:
				release()
	else:
		can_use = true
