extends Node

var actor
var cache

func _physics_process(_delta):
	var rb = actor.movement.get_floor_rigidbodies()

	if rb.size() > 0:
		rb = rb[0]
	else:
		rb = null

	if rb:
		cache = rb
		cache.axis_lock_angular_x = true
		cache.axis_lock_angular_y = true
		cache.axis_lock_angular_z = true

	if(not rb and cache):
		cache.axis_lock_angular_x = false
		cache.axis_lock_angular_y = false
		cache.axis_lock_angular_z = false
		cache = null
