extends Node2D
# crosshair should just be white- the logic/color should be handled
# by the other classes, they should 
onready var dot = $Dot

func _ready():
	position = get_viewport().size / 2
	assert(get_tree().connect("screen_resized",
							  self,
							  "_on_screen_resized") == 0)

func _on_screen_resized():
	position = get_viewport().size / 2
	
func dot_red():
	dot.modulate = Color("b23131")
	
func dot_dark_red():
	dot.modulate = Color("4a1119")
	
func dot_white():
	dot.modulate = Color(1,1,1,1)
