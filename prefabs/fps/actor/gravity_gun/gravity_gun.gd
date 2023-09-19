extends Spatial
export(Array, String) var ignore_groups
export var rotate_beam = false

onready var ray = $RayCast
onready var mesh = $MeshInstance
onready var gravity_beam = $Gravity

func check_ignored(col):
	for string in ignore_groups:
		if col.is_in_group(string):
			ray.add_exception(col)
			return false
	return true

func gravity_beam_monitoring(value):
	for i in gravity_beam.get_children():
		if "monitoring" in i:
			i.monitoring = value

func _ready():
	mesh.visible = false
	gravity_beam.visible = false
	gravity_beam_monitoring(false)

func get_mesh(node):
	if "mesh" in node:
		return node.mesh
	for child in node.get_children():
		if "mesh" in child:
			return child.mesh
	return null

# https://www.youtube.com/watch?v=7axJJYont6Y
# causes godot to hard crash on certain geometry.
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func try_rotation():
	var normal = ray.get_collision_normal()
	gravity_beam.global_transform = align_with_y(gravity_beam.global_transform,
												 normal)

func _physics_process(_delta):
	mesh.visible = true
	
	if ray.get_collider():
		mesh.global_transform.origin = ray.get_collision_point()
	
	if(Input.is_action_pressed("right_click")):
		mesh.visible = true
	else:
		mesh.visible = false

	var col = ray.get_collider()
	if(Input.is_action_just_released("right_click") and
	   col != null and
	   check_ignored(col)):
		gravity_beam.visible = true
		if gravity_beam.get_parent() != null:
			gravity_beam.get_parent().remove_child(gravity_beam)
		var current_scene = get_tree().current_scene
		if(current_scene != gravity_beam.get_parent()):
			current_scene.add_child(gravity_beam)
		gravity_beam.global_transform.origin = ray.get_collision_point()
		gravity_beam_monitoring(true)
		if rotate_beam:
			# crashes will have to look into.
			try_rotation() 
