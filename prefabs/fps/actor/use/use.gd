extends RayCast
var actor
onready var crosshair = $Crosshair

func get_use(col):
	var result := []
	if col.has_method("_use"):
		result.push_back(col)
		for node in Util.get_children_recursive(col):
			if node.has_method("_use"):
				result.push_back(node)
	return result

func change_crosshair(col_array):
	if not crosshair:
		return
	if col_array.size() > 0:
		crosshair.visible = true
		crosshair.dot_red()
	else:
		crosshair.visible = false

func check_use(col_array):
	if(Input.is_action_just_pressed("use")):
		for col in col_array:
			col._use()

func _physics_process(_delta):
	var col = get_collider()
	if col:
		var nodes = get_use(col)
		change_crosshair(nodes)
		check_use(nodes)
			

