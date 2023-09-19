extends Spatial

var actor
onready var ray = $RayCast
onready var mesh = $RayCast/MeshInstance

func blink(col):
	if col:
		mesh.global_transform.origin = ray.get_collision_point()
	
	if col and Input.is_action_just_pressed("right_click"):
		actor.translation = ray.get_collision_point()
	
	if not col and Input.is_action_just_pressed("right_click"):
		actor.global_translation = mesh.global_translation

func _physics_process(_delta):
	blink(ray.get_collider())
