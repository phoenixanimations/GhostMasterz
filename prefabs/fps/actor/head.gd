extends Spatial
var actor

func _input(event):
	# Look with the mouse
	if event is InputEventMouseMotion:
		actor.rotation_degrees.y -= event.relative.x * actor.mouse_sensitivity / 18
		rotation_degrees.x -= event.relative.y * actor.mouse_sensitivity / 18
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
	
func _process(_delta):
	# Look with the right analog of the joystick
	if (Input.get_joy_axis(0, 2) < -actor.joystick_deadzone or
		Input.get_joy_axis(0, 2) > actor.joystick_deadzone):
		rotation_degrees.y -= Input.get_joy_axis(0, 2) * (2 * actor.joystick_sensitivity)
	if (Input.get_joy_axis(0, 3) < -actor.joystick_deadzone or
		Input.get_joy_axis(0, 3) > actor.joystick_deadzone):
		rotation_degrees.x = clamp(rotation_degrees.x - Input.get_joy_axis(0, 3) * (2 * actor.joystick_sensitivity), -90, 90)
