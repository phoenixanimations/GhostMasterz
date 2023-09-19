# Note: to change the corner go to control, and use the 4 green things.
# Either put them all in the top left, right, bottom left/right
# depending on where the square is placed.
extends Node

var actor
onready var camera = $Camera

func _process(_delta):
	camera.translation.x = actor.translation.x
	camera.translation.z = actor.translation.z
	camera.rotation_degrees.y = actor.rotation_degrees.y
