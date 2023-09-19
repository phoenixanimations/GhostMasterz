extends RayCast

onready var grab_position = $GrabPosition
onready var crosshair = $Crosshair

func _ready():
	crosshair.visible = true
	crosshair.dot_white()

func _physics_process(_delta):
	var col = get_collider()
	crosshair.dot_white()
	if col and not col.is_in_group("Ground"):
		crosshair.visible = true
		crosshair.dot_red()
