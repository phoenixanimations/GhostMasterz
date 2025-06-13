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

var ash
var cheryl
var scott
var linda
var shelly

var first_bathroom
var second_bathroom
var living_room
var bedroom
var basement
var kitchen
var forest

var bitter_cold
var brief_reveal
var gore

var frosty

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
	return interactive_object

func create_location(_name:String, _tags:Array):
	var location := {
		object_type = ObjectType.LOCATION,
		name = _name,
		interactive_objects = [],
		characters = [],
		tags = _tags
	}
	return location

func create_map(_name:String, _locations:Array, _tags:Array):
	var map := {
		name = _name,
		locations = _locations,
		tags = _tags
	}
	return map

func create_character(_name:String, _tags:Array, _gender:int, _orientation:int, _physical_status:Array, _emotional_status:Array, _fears:Array):
	var character := {
		object_type = ObjectType.CHARACTER,
		name = _name,
		tags = _tags,
		gender = _gender,
		orientation = _orientation,
		physical_status = _physical_status,
		emotional_status = _emotional_status,
		fears = _fears
	}
	print(character)
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
	return power

func create_ghost(_name:String, _base_cost:int, _tethers:Array):
	var ghost := {
		name = _name,
		baseCost = _base_cost,
		powers = [],
		tethers = _tethers
	}
	return ghost

func add_object_to_location(object:Dictionary, location:Dictionary):
	location.interactive_objects.push_back(object)

func add_power_to_ghost(power:Dictionary, ghost:Dictionary):
	ghost.powers.push_back(power)

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
	ash = create_character("Ash", [Tag.ADULT], Gender.CIS_MAN, Orientation.STRAIGHT, [PhysicalStatus.NORMAL], [EmotionalStatus.CURIOUS], [Tag.SUFFERING, Tag.REJECTION, Tag.CORPSE])
	cheryl = create_character("Cheryl", [Tag.ADULT], Gender.NON_BINARY, Orientation.PANSEXUAL, [PhysicalStatus.NORMAL], [EmotionalStatus.CURIOUS, EmotionalStatus.SCARED], [Tag.CREEPYCRAWLY, Tag.CORPSE])
	linda = create_character("Linda", [Tag.ADULT], Gender.CIS_WOMAN, Orientation.STRAIGHT, [PhysicalStatus.NORMAL], [EmotionalStatus.SCARED], [Tag.DARKNESS, Tag.DIRTY, Tag.CREEPYCRAWLY, Tag.CORPSE, Tag.DEATH])
	scott = create_character("Scott", [Tag.ADULT], Gender.TRANS_MAN, Orientation.ASEXUAL, [PhysicalStatus.SLEEPING], [EmotionalStatus.INDIFFERENT], [Tag.DARKNESS, Tag.SUFFERING, Tag.DEATH, Tag.NEEDLES])
	shelly = create_character("Shelly", [Tag.ADULT], Gender.TRANS_WOMAN, Orientation.BISEXUAL, [PhysicalStatus.COLD], [EmotionalStatus.CONFUSED], [Tag.BLOOD, Tag.DEATH])

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

func create_all_ghosts():
	frosty = create_ghost("Frosty", 10, [Tag.COLD, Tag.WATER])

func add_all_objects_to_locations():
	pass

func add_all_powers_to_ghosts():
	add_power_to_ghost(bitter_cold, frosty)
	add_power_to_ghost(brief_reveal, frosty)
	add_power_to_ghost(gore, frosty)

func _ready():
	create_all_interactive_objects()
	create_all_characters()
	create_all_locations()
	create_all_ghosts()
	
	add_all_objects_to_locations()
	add_all_powers_to_ghosts()
