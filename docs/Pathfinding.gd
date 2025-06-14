extends Spatial
#characters have randomized pathing at the start of the map, then fall into some sort of routine indefinitely until disturbed,
#	also if they have an interest that is at or above capacity, they will try to find an alternative Interactive Object to use instead
#	to complete their current interest/goal, interests also appear to be timer-based, and some may be 'indefinite until disturbed',
#	characters appear to A-star their way to their nearest interest/goal that is not fully occupied

#	all 'Interactive Objects' need to have an occupancy limit, which may even be infinite

#	some 'objectives' have a fallback, in that if an action cannot be performed by the primary performer
#		but is somehow required to 'complete' the map, someone will step in to complete that action

#	'missioned failed' states -- try to avoid any if possible

var debugMode = true
var bypass = false
var continueGame = true
var rng = RandomNumberGenerator.new()

var toilet
var sink
var mirror
var bathtub
var fridge
var television
var tree
var logs
var rock
var fireplace
var pipes
var boiler
var necronomicon
var interactive_objects := []

var ash
var cheryl
var scott
var linda
var shelly
var characters := []

var first_bathroom
var second_bathroom
var living_room
var bedroom
var basement
var kitchen
var forest
var locations := []

var bitter_cold := {}
var brief_reveal := {}
var gore := {}
var bonfire := {}
var human_torch := {}
var mania := {}
var paralyze := {}
var snake_attack := {}
var powers := []

var frosty
var bernie
var medusa
var bloody_mary
var ghosts := []

var map1

enum Tag {ADULT,AGING,AIR,BLOOD,CHILD,COLD,CORPSE,CREEPY,CREEPYCRAWLY,DARKNESS,DEATH,DIRTY,EARTH,ELECTRICAL,EMBARRASSMENT,FAILURE,FIRE,GHOST,HEIGHTS,HUNTED,HOT,ICE,INSIDE,ISOLATION,LIGHT,NEEDLES,NOISE,OUTSIDE,PLASMA,REFLECTIVE,REJECTION,SNAKES,SUFFERING,TEENAGER,TRAPPED,WATER,WEAPONS}
enum Gender {CIS_MAN, CIS_WOMAN, NON_BINARY, TRANS_MAN, TRANS_WOMAN}
enum Orientation {ASEXUAL, BISEXUAL, GAY, LESBIAN, PANSEXUAL, STRAIGHT}
enum PhysicalStatus {BURNING, COLD, COMATOSE, ELECTROCUTED, FAINTED, FROZEN, HOT, NORMAL, POSSESSED, SLEEPING, SLEEPWALKING, warm}
enum EmotionalStatus {ANGRY, CONFUSED, CURIOUS, DISGUSTED, HAPPY, INDIFFERENT, SAD, SCARED, TERRIFIED}
enum TargetType {LINE_OF_SIGHT, MAP, RADIAL, ROOM, SINGLE}
enum ObjectType {CHARACTER, GHOST, INTERACTIVE_OBJECT, LOCATION, MAP, POWER}

func create_interactive_object(_name:String, _tags:Array):
	var interactive_object := {
		object_type = ObjectType.INTERACTIVE_OBJECT,
		name = _name,
		tags = _tags
	}
	interactive_objects.push_back(interactive_object)
	return interactive_object

func create_location(_name:String, _tags:Array):
	var location := {
		object_type = ObjectType.LOCATION,
		name = _name,
		interactive_objects = [],
		characters = [],
		tags = _tags
	}
	locations.push_back(location)
	return location

#Characters will have coordinates instead of 'locations'
#Locations will not have characters
#Character locations will be dictated by a function that looks up the coordinates of the character
#	and updates their location on the fly

#func lookup_character_vector3_coordinates(coordinates:Vector3):
	#match location to coordinate values within a certain area
#	pass

func create_character(_name:String, _tags:Array, _starting_location:Dictionary, _gender:int, _orientation:int, _physical_status:Array, _emotional_status:Array, _fears:Array):
	var character := {
		object_type = ObjectType.CHARACTER,
		name = _name,
		tags = _tags,
		starting_location = _starting_location,
		gender = _gender,
		orientation = _orientation,
		physical_status = _physical_status,
		emotional_status = _emotional_status,
		fears = _fears
	}
	characters.push_back(character)
	add_character_to_starting_location(character)
	return character
	
func create_power(_name:String, _description:String, _cost:int, _duration:int, _base_stats:Array, _target_type:int, _effects:Array):
	var power := {
		name = _name,
		description = _description,
		cost = _cost,
		duration = _duration,
		base_stats = _base_stats,
		target_type = _target_type,
		effects = _effects
	}
	powers.push_back(power)
	return power

func create_ghost(_name:String, _base_cost:int, _tethers:Array):
	var ghost := {
		name = _name,
		baseCost = _base_cost,
		powers = [],
		tethers = _tethers
	}
	ghosts.push_back(ghost)
	return ghost

func create_map(_name:String, _description:String, _base_plasm:int, _time_goal:int, _personal_best_time:int):
	var map := {
		name = _name,
		description = _description,
		base_plasm = _base_plasm,
		time_goal = _time_goal,
		personal_best_time = _personal_best_time,
		locations = []
	}
	return map

func add_object_to_location(object:Dictionary, location:Dictionary):
	location.interactive_objects.push_back(object)

func add_power_to_ghost(power:Dictionary, ghost:Dictionary):
	ghost.powers.push_back(power)
	
func add_location_to_map(location:Dictionary, map:Dictionary):
	map.locations.push_back(location)

func add_character_to_starting_location(character:Dictionary):
	var set_location = character.starting_location
	set_location.characters.push_back(character)

func create_all_interactive_objects():
	toilet = create_interactive_object("Toilet", [Tag.WATER])
	sink = create_interactive_object("Sink", [Tag.WATER])
	mirror = create_interactive_object("Mirror", [Tag.REFLECTIVE])
	bathtub = create_interactive_object("Bathtub", [Tag.WATER])
	fridge = create_interactive_object("Fridge", [Tag.COLD, Tag.ELECTRICAL])
	television = create_interactive_object("Television", [Tag.ELECTRICAL, Tag.REFLECTIVE])
	tree = create_interactive_object("Tree", [Tag.EARTH])
	logs = create_interactive_object("Logs", [Tag.EARTH])
	rock = create_interactive_object("Rock", [Tag.EARTH])
	fireplace = create_interactive_object("Fireplace", [Tag.FIRE, Tag.HOT])
	pipes = create_interactive_object("Pipes", [Tag.BLOOD, Tag.HOT, Tag.WATER])
	boiler = create_interactive_object("Boiler", [Tag.ELECTRICAL, Tag.HOT, Tag.WATER])
	necronomicon = create_interactive_object("Necronomicon", [Tag.BLOOD])

func create_all_characters():
	ash = create_character("Ash", [Tag.ADULT], living_room, Gender.CIS_MAN, Orientation.STRAIGHT, [PhysicalStatus.NORMAL], [EmotionalStatus.CURIOUS], [Tag.SUFFERING, Tag.REJECTION, Tag.CORPSE])
	cheryl = create_character("Cheryl", [Tag.ADULT], basement, Gender.NON_BINARY, Orientation.PANSEXUAL, [PhysicalStatus.NORMAL], [EmotionalStatus.CURIOUS, EmotionalStatus.SCARED], [Tag.CREEPYCRAWLY, Tag.CORPSE])
	linda = create_character("Linda", [Tag.ADULT], first_bathroom, Gender.CIS_WOMAN, Orientation.STRAIGHT, [PhysicalStatus.NORMAL], [EmotionalStatus.SCARED], [Tag.DARKNESS, Tag.DIRTY, Tag.CREEPYCRAWLY, Tag.CORPSE, Tag.DEATH])
	scott = create_character("Scott", [Tag.ADULT], forest, Gender.TRANS_MAN, Orientation.ASEXUAL, [PhysicalStatus.SLEEPING], [EmotionalStatus.INDIFFERENT], [Tag.DARKNESS, Tag.SUFFERING, Tag.DEATH, Tag.NEEDLES])
	shelly = create_character("Shelly", [Tag.ADULT], kitchen, Gender.TRANS_WOMAN, Orientation.BISEXUAL, [PhysicalStatus.COLD], [EmotionalStatus.CONFUSED], [Tag.BLOOD, Tag.DEATH])

func create_all_locations():
	first_bathroom = create_location("First Bathroom",[Tag.INSIDE])
	second_bathroom = create_location("Second Bathroom",[Tag.INSIDE])
	living_room = create_location("Living Room",[Tag.INSIDE])
	bedroom = create_location("Bedroom",[Tag.INSIDE])
	basement = create_location("Basement",[Tag.INSIDE, Tag.CREEPY, Tag.DARKNESS])
	kitchen = create_location("Kitchen",[Tag.INSIDE])
	forest = create_location("Forest",[Tag.OUTSIDE, Tag.COLD])

func create_all_powers():
	bitter_cold = create_power("Bitter Cold", "Makes the area and surrounding objects cold.", 15, -1, [0, 0, 1], TargetType.MAP, [Tag.COLD])
	brief_reveal = create_power("Brief Reveal", "The ghost briefly becomes visible to their target.", 30, 5, [15, 0, 10], TargetType.LINE_OF_SIGHT, [Tag.GHOST])
	gore = create_power("Gore", "Turns water into blood.", 25, 15, [15, 0, 10], TargetType.RADIAL, [Tag.BLOOD])
	bonfire = create_power("Bonfire", "Makes the area and surrounding objects hot.", 25, 15, [10, 5, 5], TargetType.RADIAL, [Tag.FIRE, Tag.HOT])
	human_torch  = create_power("Human Torch", "Target human is set on fire.", 40, 15, [40, 0, 20], TargetType.SINGLE, [Tag.FIRE, Tag.HOT])
	mania = create_power("Mania", "Increases the target's Madness.", 40, 1, [0, 15, 10], TargetType.SINGLE, [])
	paralyze = create_power("Paralyze", "Target human is unable to move.", 50, 15, [25, 5, 15], TargetType.SINGLE, [Tag.TRAPPED])
	snake_attack = create_power("Snake Attack", "A snake briefly appears in front of the target before slithering away.", 30, 10, [15, 5, 0], TargetType.LINE_OF_SIGHT, [Tag.SNAKES])

func create_all_ghosts():
	frosty = create_ghost("Frosty", 10, [Tag.COLD, Tag.WATER])
	bernie = create_ghost("Bernie", 10, [Tag.ELECTRICAL, Tag.FIRE, Tag.HOT])
	medusa = create_ghost("Medusa", 10, [Tag.EARTH, Tag.REFLECTIVE])
	bloody_mary = create_ghost("Bloody Mary", 10, [Tag.BLOOD, Tag.REFLECTIVE])
	
func add_all_objects_to_locations():
	add_object_to_location(bathtub, first_bathroom)
	add_object_to_location(mirror, first_bathroom)
	add_object_to_location(sink, first_bathroom)
	add_object_to_location(toilet, first_bathroom)
	add_object_to_location(bathtub, second_bathroom)
	add_object_to_location(mirror, second_bathroom)
	add_object_to_location(sink, second_bathroom)
	add_object_to_location(toilet, second_bathroom)
	add_object_to_location(fireplace, living_room)
	add_object_to_location(logs, living_room)
	add_object_to_location(television, living_room)
	add_object_to_location(fridge, kitchen)
	add_object_to_location(sink, kitchen)
	add_object_to_location(boiler, basement)
	add_object_to_location(necronomicon, basement)
	add_object_to_location(pipes, basement)
	add_object_to_location(logs, forest)
	add_object_to_location(rock, forest)
	add_object_to_location(tree, forest)

func add_all_locations_to_map1():
	add_location_to_map(first_bathroom, map1)
	add_location_to_map(second_bathroom, map1)
	add_location_to_map(bedroom, map1)
	add_location_to_map(living_room, map1)
	add_location_to_map(basement, map1)
	add_location_to_map(forest, map1)
	add_location_to_map(kitchen, map1)

func add_all_powers_to_ghosts():
	add_power_to_ghost(bitter_cold, frosty)
	add_power_to_ghost(brief_reveal, frosty)
	add_power_to_ghost(gore, frosty)
	
	add_power_to_ghost(bonfire, bernie)
	add_power_to_ghost(human_torch, bernie)
	
	add_power_to_ghost(mania, medusa)
	add_power_to_ghost(paralyze, medusa)
	add_power_to_ghost(snake_attack, medusa)
	
	add_power_to_ghost(mania, bloody_mary)
	add_power_to_ghost(brief_reveal, bloody_mary)
	add_power_to_ghost(gore, bloody_mary)

func _ready():
#	Map-related
	create_all_interactive_objects()
	create_all_locations()
	map1 = create_map("The Dead Evil Cabin in the Forest", "It's so evil and so dead and so cabiny and also a forest.", 100, 1200, -1)
#	Character-related (HAS TO OCCUR AFTER MAP CREATION)
	create_all_characters()
#	add_all_characters_to_starting_locations()
#	Ghost-related
	create_all_powers()
	create_all_ghosts()
#	Add all alls
	add_all_objects_to_locations()
	add_all_locations_to_map1()
	add_all_powers_to_ghosts()
	
#	for location in map1.locations:
#		for interactive_object in location.interactive_objects:
#			for tag in interactive_object.tags:
#				print("Location: %s, Object: %s, Tag: %s" % [location.name, interactive_object.name, Tag.keys()[tag]])
