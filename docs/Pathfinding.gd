extends Spatial
#Spreadsheet: https://docs.google.com/spreadsheets/d/1SEBgNcqBGfwkRxCyWkt7A4Ibf0KvK61WBYy0zoP1Mz0
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

var bathtub
var bed
var boiler
var fireplace
var fridge
var lamp
var logs
var mirror
var necronomicon
var pipes
var rock
var sink
var television
var toilet
var tree
var interactive_objects := []

var ash
var cheryl
var linda
var scott
var shelly
var characters := []

var basement
var bedroom
var first_bathroom
var forest
var kitchen
var living_room
var second_bathroom
var locations := []

var bitter_cold := {}
var brief_reveal := {}
var bonfire := {}
var gore := {}
var human_popsicle := {}
var human_torch := {}
var mania := {}
var paralyze := {}
var snake_attack := {}
var powers := []

var bernie
var bloody_mary
var frosty
var medusa
var ghosts := []

var map1

enum Fear {AGING, AIR, BLOOD, BURNING, CORPSE, CREEPYCRAWLY, DARKNESS, DEATH, DIRTY, EMBARRASSMENT, FAILURE, FIRE, FREEZING, GHOST, HEIGHTS, HUNTED, ISOLATION, NEEDLES, NOISE, REJECTION, SNAKES, SUFFERING, TRAPPED, WEAPONS}
enum Tether {AIR, BLOOD, BURNING, COLD, CORPSE, CREEPY, DARK, DEATH, DIRTY, EARTH, ELECTRICAL, EMOTIONAL, FIRE, FROZEN, HOT, ICE, INSIDE, LIGHT, MURDER, OUTSIDE, PLASMA, REFLECTIVE, VIOLENCE, WARM, WATER, WEAPON}
enum Age {CHILD, TEENAGER, ADULT, ELDERLY}
enum Effect {BLIZZARD, BURNING, COLD, FIRE, FREEZING, FROZEN, HOT, RAIN, SNOW, SWELTERING, TEMPEST, WARM, WINDY}
enum Gender {CIS_MAN, CIS_WOMAN, NON_BINARY, TRANS_MAN, TRANS_WOMAN}
enum Orientation {ASEXUAL, BISEXUAL, GAY, LESBIAN, PANSEXUAL, STRAIGHT}
enum PhysicalStatus {BURNING, COLD, COMATOSE, ELECTROCUTED, FAINTED, FROZEN, HOT, NORMAL, POSSESSED, SLEEPING, SLEEPWALKING, WARM}
enum EmotionalStatus {ANGRY, CONFUSED, CURIOUS, DISGUSTED, HAPPY, INDIFFERENT, NORMAL, SAD, SCARED, TERRIFIED}
enum TargetType {LINE_OF_SIGHT, MAP, RADIAL, ROOM, SINGLE}
enum ObjectType {CHARACTER, GHOST, INTERACTIVE_OBJECT, LOCATION, MAP, POWER}

func create_interactive_object(_name:String, _tethers:Array):
	var interactive_object := {
		object_type = ObjectType.INTERACTIVE_OBJECT,
		name = _name,
		tethers = _tethers
	}
	interactive_objects.push_back(interactive_object)
	return interactive_object

func create_location(_name:String, _tethers:Array):
	var location := {
		object_type = ObjectType.LOCATION,
		name = _name,
		interactive_objects = [],
#		In theory, we shouldn't need this list, based on the restructure listed below
#			this also avoids self-referencial dictionaries and recursion
#		characters = [],
		tethers = _tethers
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

func create_character(_name:String, _age:int, _base_stats:Array, _maximum_stats:Array, _starting_location:Dictionary, _gender:int, _orientation:int, _physical_status:Array, _emotional_status:Array, _fears:Array):
	var character := {
		object_type = ObjectType.CHARACTER,
		name = _name,
		age = _age,
		base_stats = _base_stats,
		maximum_stats = _maximum_stats,
		base_willpower = _base_stats[0],
		base_terror = _base_stats[1],
		base_madness = _base_stats[2],
		base_belief = _base_stats[3],
		willpower = _base_stats[0],
		terror = _base_stats[1],
		madness = _base_stats[2],
		belief = _base_stats[3],
		maximum_willpower = _maximum_stats[0],
		maximum_terror = _maximum_stats[1],
		maximum_madness = _maximum_stats[2],
		maximum_belief = _maximum_stats[3],
		starting_location = _starting_location,
		gender = _gender,
		orientation = _orientation,
		physical_status = _physical_status,
		emotional_status = _emotional_status,
		fears = _fears
	}
	characters.push_back(character)
#	Grayed out since this will be removed with the restructure
#	add_character_to_starting_location(character)
	return character
	
func create_power(_name:String, _description:String, _cost:int, _duration:int, _base_stats:Array, _target_type:int, _fears:Array, _effects:Array):
	var power := {
		name = _name,
		description = _description,
		cost = _cost,
		duration = _duration,
		base_stats = _base_stats,
		target_type = _target_type,
		fears = _fears,
		effects = _effects
	}
	powers.push_back(power)
	return power

func create_ghost(_name:String, _base_cost:int, _tethers:Array):
	var ghost := {
		name = _name,
		baseCost = _base_cost,
		powers = [],
		tethers = _tethers,
		can_tether = false
	}
	ghosts.push_back(ghost)
	return ghost

func create_map(_name:String, _description:String, _base_plasm:int, _time_goal:Array, _personal_best_time:int):
	var map := {
		name = _name,
		description = _description,
		allowed_ghosts = [],
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

#Restructuring will remove this function
#func add_character_to_starting_location(character:Dictionary):
#	var set_location = character.starting_location
#	set_location.characters.push_back(character)

func create_all_interactive_objects():
	bathtub = create_interactive_object("Bathtub", [Tether.WATER])
	bed = create_interactive_object("Bed", [Tether.WARM])
	boiler = create_interactive_object("Boiler", [Tether.ELECTRICAL, Tether.HOT, Tether.WATER])
	fireplace = create_interactive_object("Fireplace", [Tether.FIRE, Tether.HOT])
	fridge = create_interactive_object("Fridge", [Tether.COLD, Tether.ELECTRICAL])
	lamp = create_interactive_object("Lamp", [Tether.LIGHT, Tether.ELECTRICAL])
	logs = create_interactive_object("Logs", [Tether.EARTH])
	mirror = create_interactive_object("Mirror", [Tether.REFLECTIVE])
	necronomicon = create_interactive_object("Necronomicon", [Tether.BLOOD])
	pipes = create_interactive_object("Pipes", [Tether.BLOOD, Tether.HOT, Tether.WATER])
	rock = create_interactive_object("Rock", [Tether.EARTH])
	sink = create_interactive_object("Sink", [Tether.WATER])
	television = create_interactive_object("Television", [Tether.ELECTRICAL, Tether.REFLECTIVE])
	toilet = create_interactive_object("Toilet", [Tether.WATER])
	tree = create_interactive_object("Tree", [Tether.EARTH])

func create_all_characters():
	#willpower, terror, madness, belief

	#willpower dictates when the character has a 'mental breakdown', causing them to stop performing certain actions and try to find safety
	#terror dictates when the character will attempt to flee the map - some things can prevent them from fleeing (such as possession)
	#madness dictates when the character will go mad (this allows them to continue performing some actions while also counting as having 'fled' the map)
	#belief dictates how easily scared the character is (this acts as a modifier to the terror and madness stats)

	#non-believer
	ash = create_character("Ash", Age.ADULT, [100, 0, 0, 20], [100, 80, 60, 100], living_room, Gender.CIS_MAN, Orientation.STRAIGHT, [PhysicalStatus.NORMAL], [EmotionalStatus.CURIOUS], [Fear.SUFFERING, Fear.REJECTION, Fear.CORPSE])
	#scaredy, believer
	cheryl = create_character("Cheryl", Age.ADULT, [80, 0, 0, 90], [100, 80, 60, 100], basement, Gender.NON_BINARY, Orientation.PANSEXUAL, [PhysicalStatus.NORMAL], [EmotionalStatus.CURIOUS, EmotionalStatus.SCARED], [Fear.CREEPYCRAWLY, Fear.CORPSE])
	#slightly mad
	linda = create_character("Linda", Age.ADULT, [100, 10, 20, 60], [100, 60, 60, 100], first_bathroom, Gender.CIS_WOMAN, Orientation.STRAIGHT, [PhysicalStatus.WARM], [EmotionalStatus.NORMAL], [Fear.DARKNESS, Fear.DIRTY, Fear.CREEPYCRAWLY, Fear.CORPSE, Fear.DEATH])
	#generic
	scott = create_character("Scott", Age.ADULT, [100, 0, 0, 30], [100, 60, 80, 100], bedroom, Gender.TRANS_MAN, Orientation.ASEXUAL, [PhysicalStatus.SLEEPING], [EmotionalStatus.INDIFFERENT], [Fear.DARKNESS, Fear.SUFFERING, Fear.DEATH, Fear.NEEDLES])
	#generic
	shelly = create_character("Shelly", Age.ADULT, [100, 0, 10, 60], [100, 60, 60, 100], kitchen, Gender.TRANS_WOMAN, Orientation.BISEXUAL, [PhysicalStatus.COLD], [EmotionalStatus.CONFUSED], [Fear.BLOOD, Fear.DEATH])

func create_all_locations():
	basement = create_location("Basement", [Tether.CREEPY, Tether.DARK, Tether.INSIDE])
	bedroom = create_location("Bedroom", [Tether.INSIDE])
	first_bathroom = create_location("First Bathroom", [Tether.INSIDE])
	forest = create_location("Forest", [Tether.OUTSIDE, Tether.COLD])
	kitchen = create_location("Kitchen", [Tether.INSIDE])
	living_room = create_location("Living Room", [Tether.INSIDE])
	second_bathroom = create_location("Second Bathroom", [Tether.INSIDE])

func create_all_powers():
	bitter_cold = create_power("Bitter Cold", "Makes the area and surrounding objects cold.", 15, -1, [0, 0, 1], TargetType.MAP, [], [Effect.COLD])
	bonfire = create_power("Bonfire", "Makes the area and surrounding objects hot.", 25, 15, [10, 5, 5], TargetType.RADIAL, [Fear.FIRE], [Effect.HOT])
	brief_reveal = create_power("Brief Reveal", "The ghost briefly becomes visible to their target.", 30, 5, [15, 0, 10], TargetType.LINE_OF_SIGHT, [Fear.GHOST], [])
	gore = create_power("Gore", "Turns water into blood.", 25, 15, [15, 0, 10], TargetType.RADIAL, [Fear.BLOOD], [])
	human_popsicle  = create_power("Human Popsicle", "Target human is frozen in a block of ice.", 40, 15, [40, 0, 20], TargetType.SINGLE, [Fear.FREEZING], [Effect.COLD, Effect.FREEZING, Effect.FROZEN])
	human_torch  = create_power("Human Torch", "Target human is set on fire.", 40, 15, [40, 0, 20], TargetType.SINGLE, [Fear.BURNING, Fear.FIRE], [Effect.BURNING, Effect.FIRE, Effect.HOT, Effect.SWELTERING])
	mania = create_power("Mania", "Increases the target's Madness.", 40, 1, [0, 15, 10], TargetType.SINGLE, [], [])
	paralyze = create_power("Paralyze", "Target human is unable to move.", 50, 15, [25, 5, 15], TargetType.SINGLE, [Fear.TRAPPED], [])
	snake_attack = create_power("Snake Attack", "A snake briefly appears in front of the target before slithering away.", 30, 10, [15, 5, 0], TargetType.LINE_OF_SIGHT, [Fear.SNAKES], [])

func create_all_ghosts():
	bernie = create_ghost("Bernie", 10, [Tether.ELECTRICAL, Tether.FIRE, Tether.HOT, Tether.WARM])
	bloody_mary = create_ghost("Bloody Mary", 25, [Tether.BLOOD, Tether.REFLECTIVE])
	frosty = create_ghost("Frosty", 15, [Tether.COLD, Tether.FROZEN, Tether.WATER])
	medusa = create_ghost("Medusa", 20, [Tether.EARTH, Tether.REFLECTIVE])
	
func add_all_objects_to_locations():
	add_object_to_location(boiler, basement)
	add_object_to_location(necronomicon, basement)
	add_object_to_location(pipes, basement)
	add_object_to_location(bed, bedroom)
	add_object_to_location(lamp, bedroom)
	add_object_to_location(bathtub, first_bathroom)
	add_object_to_location(mirror, first_bathroom)
	add_object_to_location(sink, first_bathroom)
	add_object_to_location(toilet, first_bathroom)
	add_object_to_location(logs, forest)
	add_object_to_location(rock, forest)
	add_object_to_location(tree, forest)
	add_object_to_location(fridge, kitchen)
	add_object_to_location(sink, kitchen)
	add_object_to_location(fireplace, living_room)
	add_object_to_location(logs, living_room)
	add_object_to_location(television, living_room)
	add_object_to_location(bathtub, second_bathroom)
	add_object_to_location(mirror, second_bathroom)
	add_object_to_location(sink, second_bathroom)
	add_object_to_location(toilet, second_bathroom)

func add_all_locations_to_map1():
	add_location_to_map(first_bathroom, map1)
	add_location_to_map(second_bathroom, map1)
	add_location_to_map(bedroom, map1)
	add_location_to_map(living_room, map1)
	add_location_to_map(basement, map1)
	add_location_to_map(forest, map1)
	add_location_to_map(kitchen, map1)

func add_allowed_ghost_to_map(ghost:Dictionary, map:Dictionary):
	map.allowed_ghosts.push_back(ghost)

func add_all_allowed_ghosts_to_map1():
	add_allowed_ghost_to_map(bernie, map1)
	add_allowed_ghost_to_map(bloody_mary, map1)
	add_allowed_ghost_to_map(frosty, map1)
	add_allowed_ghost_to_map(medusa, map1)

func add_all_powers_to_ghosts():
	#Bloody Mary
	add_power_to_ghost(mania, bloody_mary)
	add_power_to_ghost(brief_reveal, bloody_mary)
	add_power_to_ghost(gore, bloody_mary)
	#Bernie
	add_power_to_ghost(bonfire, bernie)
	add_power_to_ghost(human_torch, bernie)
	#Frosty
	add_power_to_ghost(bitter_cold, frosty)
	add_power_to_ghost(brief_reveal, frosty)
	add_power_to_ghost(gore, frosty)
	add_power_to_ghost(human_popsicle, frosty)
	#Medusa
	add_power_to_ghost(mania, medusa)
	add_power_to_ghost(paralyze, medusa)
	add_power_to_ghost(snake_attack, medusa)

func _ready():
#	Map-related
	create_all_interactive_objects()
	create_all_locations()
	map1 = create_map("The Dead Evil Cabin in the Forest", "It's so evil and so dead and so cabiny and also a forest.", 100, [1200, 900, 600], -1)
#	Ghost-related
	create_all_powers()
	create_all_ghosts()
#	Character-related (HAS TO OCCUR AFTER MAP CREATION)
	create_all_characters()
#	Grayed out since this will be removed in the restructure
#	add_all_characters_to_starting_locations()
#	Add all alls
	add_all_objects_to_locations()
	add_all_locations_to_map1()
	add_all_allowed_ghosts_to_map1()
	add_all_powers_to_ghosts()
	
	#For debugging if a ghost can tether to an object with a location
#	for location in map1.locations:
#		for interactive_object in location.interactive_objects:
#			for ghost in ghosts:
#				if(!map1.allowed_ghosts.has(ghost)):
#					continue
#				for tether in interactive_object.tethers:
#					if(ghost.tethers.has(tether)):
#						ghost.can_tether = true
#						if(ghost.can_tether):
#							print("%s can tether to %s (%s: %s)."% [ghost.name, location.name, interactive_object.name, Tether.keys()[tether]])
#							break
	for character in characters:
		print(character)
#	print("Location: %s, Object: %s, Tether: %s" % [location.name, interactive_object.name, Tether.keys()[tether]])
