class_name Util

static func get_children_recursive(node:Node) -> Array:
	if not node:
		return []

	var children := node.get_children()
	var result := []
	while(children.size() > 0):
		var child = children.pop_back()
		result.push_back(child)
		children.append_array(child.get_children())
	return result

static func set_visible(node, value):
	if "visible" in node:
		node.visible = value

static func set_physics_node(node:Node, value:bool) -> void:
	if not node:
		return
	node.set_physics_process(value)
	node.set_physics_process_internal(value)
	if "monitoring" in node:
		node.monitoring = value
	if "monitorable" in node:
		node.monitorable = value
	if "use_collision" in node:
		node.use_collision = value
	
static func set_pause_node(node:Node, pause:bool) -> void:
	if not node:
		return
	node.set_process(pause)
	node.set_process_internal(pause)
	node.set_process_input(pause)
	node.set_process_unhandled_input(pause)
	node.set_process_unhandled_key_input(pause)
	set_physics_node(node, pause)
	#set_visible(node, pause)

static func set_pause_node_recursive(node:Node, pause:bool) -> void:
	for child in get_children_recursive(node):
		set_pause_node(child, pause)
	set_pause_node(node, pause)

static func set_pause_node_rigidbody(node:Node, pause:bool) -> void:
	set_pause_node(node, pause)
	if node is RigidBody:
		if pause:
			node.mode = RigidBody.MODE_RIGID
		else:
			node.mode = RigidBody.MODE_STATIC

# scene_node is needed so it can use the get_node func.
static func paths_to_nodes(scene_node:Object, node_paths:Array):
	var result := []
	for path in node_paths:
		var node = scene_node.get_node_or_null(path)
		if node:
			result.push_back(node)
	return result
