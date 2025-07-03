extends Spatial

export var move_speed := 20.0
export var sprint_speed := 40.0
export var zoom_speed := 100.0
export var rise_speed := 20.0
export var rotate_sensitivity := 5.0
export var y_limit := 90.0

onready var camera_pivot:Spatial = find_node("CameraPivot")
onready var camera:Camera = find_node("Camera")
onready var camera_rotation:Spatial = find_node("CameraRotation")

var cur_move_speed:float
var rot := Vector3()
var enable_input := true

func _ready() -> void:
	assert(camera and camera_pivot)
	
	cur_move_speed = move_speed
	rotate_sensitivity = rotate_sensitivity / 1000
	y_limit = deg2rad(y_limit)
	
	rot = global_rotation
	global_rotation = Vector3()
	camera_pivot.global_rotation.y = rot.y
	camera.global_rotation.x = rot.x
	camera_rotation.global_rotation.y = rot.y
	camera_rotation.global_rotation.x = rot.x

func _process(delta):
	if not enable_input: return
	if Input.is_action_pressed("middle_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.is_action_just_released("middle_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_action_pressed("camera_sprint"):
		cur_move_speed = sprint_speed
	else:
		cur_move_speed = move_speed

	if Input.is_action_pressed("camera_pan_forward"):
		global_translation -= delta * cur_move_speed * camera_pivot.transform.basis.z

	if Input.is_action_pressed("camera_pan_backward"):
		global_translation += delta * cur_move_speed * camera_pivot.transform.basis.z

	if Input.is_action_pressed("camera_pan_left"):
		global_translation -= delta * cur_move_speed * camera_pivot.transform.basis.x

	if Input.is_action_pressed("camera_pan_right"):
		global_translation += delta * cur_move_speed * camera_pivot.transform.basis.x

	if Input.is_action_just_released("camera_zoom_in"):
		global_translation -= delta * zoom_speed * camera_rotation.transform.basis.z

	if Input.is_action_just_released("camera_zoom_out"):
		global_translation += delta * zoom_speed * camera_rotation.transform.basis.z
	
	if Input.is_action_pressed("camera_pan_up"):
		global_translation.y += delta * rise_speed

	if Input.is_action_pressed("camera_pan_down"):
		global_translation.y -= delta * rise_speed

# Going to need this when are optimizing the tiles.

#var mouse_pos = get_viewport().get_mouse_position()
#var from = project_ray_origin(mouse_pos)
#var to = from + project_ray_normal(mouse_pos) * 200
#
#var space_state = get_world_3d().direct_space_state
#var handle_query = PhysicsRayQueryParameters3D.create(from, to)
#handle_query.collide_with_areas = true
#handle_query.collide_with_bodies = false
#handle_query.collision_mask = 0b10
#var mesh_query = PhysicsRayQueryParameters3D.create(from, to)
#mesh_query.collide_with_areas = true
#mesh_query.collide_with_bodies = false
#mesh_query.collision_mask = 0b1
#print(
#	space_state.intersect_ray(mesh_query),
#	space_state.intersect_ray(handle_query)
#)
func _physics_process(_delta):
	#get_world().direct_space_state.intersect_ray
	pass

func apply_camera_rotation(mouse_axis):
	# Horizontal mouse look.
	rot.y -= mouse_axis.x * rotate_sensitivity
	# Vertical mouse look.
	rot.x = clamp(rot.x - mouse_axis.y * rotate_sensitivity, -y_limit, y_limit)
	camera_pivot.rotation.y = rot.y
	camera.rotation.x = rot.x

	camera_rotation.rotation.y = rot.y
	camera_rotation.rotation.x = rot.x

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		apply_camera_rotation(event.relative)
