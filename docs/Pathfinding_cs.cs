//clear; cd ~/Desktop; csc Pathfinding.cs; mono Pathfinding.exe
//clear; cd ~/Repos/GhostMasterz/docs; csc Pathfinding.cs; mono Pathfinding.exe

/*
characters have randomized pathing at the start of the map, then fall into some sort of routine indefinitely until disturbed,
	also if they have an interest that is at or above capacity, they will try to find an alternative Interactive Object to use instead
	to complete their current interest/goal, interests also appear to be timer-based, and some may be 'indefinite until disturbed',
	characters appear to A-star their way to their nearest interest/goal that is not fully occupied

	all 'Interactive Objects' need to have an occupancy limit, which may even be infinite

	some 'objectives' have a fallback, in that if an action cannot be performed by the primary performer
		but is somehow required to 'complete' the map, someone will step in to complete that action

	'missioned failed' states -- try to avoid any if possible
*/

using System;
using System.Collections.Generic;
//using System.Linq;

public class Pathfinding {
	public static bool debugMode = true;
	public static bool bypass = false;
	public static bool continueGame = true;
	
	public static Random random = new Random();

	public static void Main(){
		Pathfinding pathfinding = new Pathfinding();

		Tag cold = new Tag("Cold");
		Tag electrical = new Tag("Electrical");
		Tag reflective = new Tag("Reflective");
		Tag air = new Tag("Air");
//		Tag plasma = new Tag("Plasma");
		Tag ice = new Tag("Ice");
		Tag water = new Tag("Water");
		Tag inside = new Tag("Inside");
		Tag outside = new Tag("Outside");
		Tag earth = new Tag("Earth");
		Tag hot = new Tag("Hot");
		Tag fire = new Tag("Fire");
		Tag blood = new Tag("Blood");
		Tag creepyCrawly = new Tag("Creepy Crawly");
		Tag snakes = new Tag("Snakes");
    	Tag light = new Tag("Light");
    	Tag darkness = new Tag("Darkness");
   		Tag hunted = new Tag("Hunted");
   		Tag weapons = new Tag("Weapons");
		Tag noise = new Tag("Noise");
		Tag trapped = new Tag("Trapped");
    	Tag dirty = new Tag("Dirty");
    	Tag needles = new Tag("Needles");
    	Tag corpse = new Tag("Corpse");
    	Tag ghost = new Tag("Ghost");
//		'intangible' Fears
//    	Tag heights = new Tag("Heights");
//    	Tag rejection = new Tag("Rejection");
//    	Tag failure = new Tag("Failure");
//    	Tag embarrassment = new Tag("Embarrassment");
//    	Tag aging = new Tag("Aging");
//    	Tag suffering = new Tag("Suffering");
//    	Tag death = new Tag("Death");
//    	Tag isolation = new Tag("Isolation");
//		on hold at present
//    	Tag child = new Tag("Child");
//    	Tag adult = new Tag("Adult");

    	Gender male = new Gender("Male");
    	Gender female = new Gender("Female");
    	Gender nonbinary = new Gender("Non-Binary");

    	Orientation asexual = new Orientation("Asexual");
    	Orientation bisexual = new Orientation("Bisexual");
    	Orientation gay = new Orientation("Gay");
    	Orientation lesbian = new Orientation("Lesbian");
    	Orientation pansexual = new Orientation("Pansexual");
    	Orientation straight = new Orientation("Straight");
    	//Physical
		Status normalStatus = new Status("Normal");
		Status hotStatus = new Status("Hot");
		Status coldStatus = new Status("Cold");
		Status warmStatus = new Status("Warm");
		Status frozenStatus = new Status("Frozen");
		Status burningStatus = new Status("Burning");
		Status electrocutedStatus = new Status("Electrocuted");
		Status sleepingStatus = new Status("Sleeping");
		Status sleepwalkingStatus = new Status("Sleepwalking");
		Status faintedStatus = new Status("Fainted");
		Status comatoseStatus = new Status("Comatose");
		Status possessedStatus = new Status("Possessed");
		//Emotions
		Status happyStatus = new Status("Happy");
		Status sadStatus = new Status("Sad");
		Status angryStatus = new Status("Angry");
		Status indifferentStatus = new Status("Indifferent");
		Status disgustedStatus = new Status("Disgusted");
		Status curiousStatus = new Status("Curious");
		Status confusedStatus = new Status("Confused");

		InteractiveObject toilet = new InteractiveObject("Toilet", new List<Tag>(){water});		
		InteractiveObject sink = new InteractiveObject("Sink", new List<Tag>(){water});
		InteractiveObject mirror = new InteractiveObject("Mirror", new List<Tag>(){reflective});
		InteractiveObject bathtub = new InteractiveObject("Bathtub", new List<Tag>(){water});
		InteractiveObject fridge = new InteractiveObject("Fridge", new List<Tag>(){cold, electrical});
		InteractiveObject television = new InteractiveObject("Television", new List<Tag>(){electrical, reflective});//divert to couch
		InteractiveObject tree = new InteractiveObject("Tree", new List<Tag>(){earth});
		InteractiveObject logs = new InteractiveObject("Logs", new List<Tag>(){earth});
		InteractiveObject rock = new InteractiveObject("Rock", new List<Tag>(){earth});
		InteractiveObject fireplace = new InteractiveObject("Fireplace", new List<Tag>(){hot, fire});
		InteractiveObject pipes = new InteractiveObject("Pipes", new List<Tag>(){water, hot, blood});
		InteractiveObject boiler = new InteractiveObject("Boiler", new List<Tag>(){water, hot, electrical});
		InteractiveObject necronomicon = new InteractiveObject("Necronomicon", new List<Tag>(){blood});
//		InteractiveObject human = new InteractiveObject("Human", new List<Tag>(){});
		
		/*
		InteractiveObject child = new InteractiveObject("Child", new List<Tag>(){});
		InteractiveObject teenager = new InteractiveObject("Teenager", new List<Tag>(){});
		InteractiveObject adult = new InteractiveObject("Adult", new List<Tag>(){});
		*/

		Location bathroom = new Location("First Bathroom", new List<InteractiveObject>(){toilet, sink, mirror, bathtub}, new List<Tag>(){inside});
		Location bathroom2 = new Location("Second Bathroom", new List<InteractiveObject>(){toilet, sink}, new List<Tag>(){inside});
		Location livingroom = new Location("Livingroom", new List<InteractiveObject>(){television, fireplace}, new List<Tag>(){inside});
		Location basement = new Location("Basement", new List<InteractiveObject>(){pipes, boiler, necronomicon}, new List<Tag>(){inside});
		Location kitchen = new Location("Kitchen", new List<InteractiveObject>(){sink, fridge}, new List<Tag>(){inside});
		Location forest = new Location("Forest", new List<InteractiveObject>(){tree, rock, logs}, new List<Tag>(){outside, cold});


		Power bitterCold = new Power("Bitter Cold", "Makes the area and surrounding objects cold.", 15, -1, new List<int>(){0, 0, 1}, TargetType.Radial);//new List<Tag>(){cold});
		Power briefScare = new Power("Brief Scare", "The ghost briefly becomes visible to their target.", 20, 5, new List<int>(){10, 0, 5}, TargetType.Single);//new List<Tag>(){ghost});
		Power bonfire = new Power("Bonfire", "Makes the area and surrounding objects hot.", 25, 15, new List<int>(){10, 5, 5,}, TargetType.Radial);//new List<Tag>(){fire,hot});
		Power gore = new Power("Gore", "Turns water into blood.", 25, 15, new List<int>(){15, 0, 10}, TargetType.Radial);//new List<Tag>(){blood});
		Power reveal = new Power("Reveal", "The ghost briefly becomes visible to all humans.", 30, 5, new List<int>(){15, 0, 10}, TargetType.LineOfSight);//new List<Tag>(){ghost});
		Power snakeAttack = new Power("Snake Attack!", "A snake briefly appears in front of the target before slithering away.", 30, 10, new List<int>(){15, 5, 10}, TargetType.LineOfSight);//new List<Tag>(){snakes});
		Power chase = new Power("Chase", "The ghost appears to chase their target.", 40, 5, new List<int>(){20, 0, 10}, TargetType.Single);//new List<Tag>(){hunted});
		Power mania = new Power("Mania", "Increases the target's Madness.", 40, 1, new List<int>(){0, 15, 10}, TargetType.Single);//new List<Tag>(){});
		Power humanTorch = new Power("Human Torch", "Target human is set on fire.", 40, 15, new List<int>(){40, 0, 20}, TargetType.Single);//new List<Tag>(){fire,hot});
		Power paralyze = new Power("Paralyze", "Target human is unable to move.", 50, 15, new List<int>(){25, 5, 15}, TargetType.Single);//new List<Tag>(){trapped});

		Map map0 = new Map("Test Map", new List<Location>(){livingroom, bathroom, kitchen, forest, basement, bathroom2});

		Character alpha = new Character("Alpha", male, gay, new List<Location>(){}, new List<InteractiveObject>(){television, toilet, sink, fridge}, new List<Tag>(){trapped}, normalStatus, happyStatus, 100, 0, 0, 0);
		Character beta = new Character("Beta", male, straight, new List<Location>(){}, new List<InteractiveObject>(){logs, fireplace}, new List<Tag>(){creepyCrawly, trapped, darkness}, coldStatus, angryStatus, 80, 20, 10, 20);
		Character gamma = new Character("Gamma", nonbinary, pansexual, new List<Location>(){}, new List<InteractiveObject>(){television, fireplace}, new List<Tag>(){outside, noise, hunted}, warmStatus, confusedStatus, 50, 10, 20, 50);
		Character delta = new Character("Delta", female, bisexual, new List<Location>(){}, new List<InteractiveObject>(){bathtub, pipes, boiler, necronomicon}, new List<Tag>(){creepyCrawly, dirty, blood, fire}, coldStatus, curiousStatus, 20, 0, 5, 80);	//Character epsilon = new Character("Epsilon", female, asexual, new List<Location>(){}, new List<InteractiveObject>(){mirror, tree}, new List<Tag>(){weapons, noise, snakes, failure}, normalStatus, indifferentStatus, 75, 20, 20, 40);
		Ghost frosty = new Ghost("Frosty", 10, new List<Power>(){bitterCold,gore,reveal}, new List<Tag>(){cold, water});
		Ghost bernie = new Ghost("Bernie", 10, new List<Power>(){bonfire,humanTorch}, new List<Tag>(){fire, hot, electrical});
		Ghost medusa = new Ghost("Medusa", 25, new List<Power>(){mania,paralyze}, new List<Tag>(){earth, reflective});
		Ghost bloodyMary = new Ghost("Bloody Mary", 20, new List<Power>(){gore,reveal,paralyze}, new List<Tag>(){reflective, blood});

		List<Character> characters = new List<Character>(){alpha, beta, gamma, delta};	//List<Character> characters = new List<Character>(){alpha, beta, gamma, delta, epsilon};
		List<Ghost> ghosts = new List<Ghost>(){frosty, bernie, medusa, bloodyMary};

		print(map0.name+": ");
		string stringify = "";
		foreach(Location location in map0.locations){
			foreach(Tag tag in location.tethers){
				stringify += tag.name + ", ";
			}
			print("\t"+location.name+" ("+stringify+")");
			stringify = "";
			foreach(InteractiveObject interactiveObject in location.interactiveObjects){
				foreach(Tag tag in interactiveObject.tethers){
					stringify += tag.name + ", ";
				}
				print("\t\t"+interactiveObject.name+" ("+stringify+")");
				stringify = "";
			}
		}

//		this search to needs to be inverted to check against the character data as opposed to the map data,
//			as that (should) dictate the order of their pathing
		foreach(Character character in characters){
			foreach(Location location in map0.locations){
				foreach(InteractiveObject interactiveObject in location.interactiveObjects){
					if((character.interests).Contains(interactiveObject)){
						print(character.name+"\tinteracted with the ["+location.name+"] " +interactiveObject.name);
					}
				}
			}
		}

		alpha.printout();
		beta.printout();
		gamma.printout();
		delta.printout();	//epsilon.printout();
		frosty.printout();
		bernie.printout();
		medusa.printout();
		bloodyMary.printout();
	}
	
	public static void cwl(System.Object line){
		if(debugMode || bypass){
			Console.WriteLine(line);
		}
		bypass = false;
	}

	public static void print(System.Object line){
		cwl(line);
	}

	public static void trace(System.Object line){
		cwl(line);
	}
}

public class Tag {
	public string name;
	public Tag(string _name){
		name = _name;
	}
}

public class Character {
	public string name;
	public Gender gender;
	public Orientation orientation;
	public List<Location> pathing;
	public List<InteractiveObject> interests;
	public List<Tag> fears;
	public Status physicalStatus;//Hot, Cold, Warm, Frozen, Burning, Electrocuted, Sleeping, Sleepwalking, PassedOut/Fainted, Comatose, Possessed
	public Status emotionalStatus;//Happy, Sad, Angry, Indifferent, Disgust
	public int maximumBelief = 100;
	public int willpower;
	public int fearMeter;
	public int madnessMeter;
	public int beliefMeter;
	public Character(string _name, Gender _gender, Orientation _orientation, List<Location> _pathing, List<InteractiveObject> _interests, List<Tag> _fears, Status _physicalStatus, Status _emotionalStatus, int _willpower, int _fearMeter, int _madnessMeter, int _beliefMeter){
		name = _name;
		gender = _gender;
		orientation = _orientation;
		pathing = _pathing;
		interests = _interests;
		fears = _fears;
		physicalStatus = _physicalStatus;
		emotionalStatus = _emotionalStatus;
		willpower = _willpower;
		fearMeter = _fearMeter;
		madnessMeter = _madnessMeter;
		beliefMeter = _beliefMeter;
	}

	public void printout (){
		string pathingPrintout = "";
		string interestsPrintout = "";
		string fearsPrintout = "";

		pathing.ForEach(x => pathingPrintout += (x.name+" "));//"Character Pathing";
		interests.ForEach(x => interestsPrintout += (x.name+" "));//"Character Interests";
		fears.ForEach(x => fearsPrintout += (x.name+" "));//"Character Fears";
		
		Console.WriteLine("\nName: "+name+" ("+gender.name+", "+orientation.name+")"+/*\nPathing: "+pathingPrintout+*/"\nInterests: "+interestsPrintout+'\n'+"Fears: "+fearsPrintout+'\n'+"Physical Status: "+physicalStatus.name+'\n'+"Emotional Status: "+emotionalStatus.name+'\n'+"Willpower: "+willpower+'\n'+"Fear: "+fearMeter+'/'+willpower+'\n'+"Madness: "+madnessMeter+'/'+willpower+'\n'+"Belief: "+beliefMeter+"/100");
	}
}

public class Ghost {
	public string name;
	public int baseCost;
	public List<Power> powers;
	public List<Tag> tethers;
	public Ghost(string _name, int _baseCost, List<Power> _powers, List<Tag> _tethers){
		name = _name;
		baseCost = _baseCost;
		powers = _powers;
		tethers = _tethers;
	}

	public void printout (){
		string powersPrintout = "";
		string tethersPrintout = "";

		powers.ForEach(x => powersPrintout += ("\n\t"+x.name+" (Cost: "+x.cost+", Description: "+x.description+")"));//"Ghost Powers";
		tethers.ForEach(x => tethersPrintout += (x.name+" "));//"Ghost Tethers";
		
		Console.WriteLine("\nName: "+name+"\nBase Cost: "+baseCost+"\nPowers: "+powersPrintout+"\nTethers: "+tethersPrintout);
	}
}

public enum TargetType {
	Single,
	LineOfSight,
	Radial,
	Room,
	Map
}

public class Power {
	public string name = "[invalid name]";
	public string description = "[invalid description]";
	public int cost = 0;
	public int duration = 1;
	public List<int> baseStats = new List<int>(){0, 0, 0};
	public Enum targets = TargetType.Single;
	//public List<Tag> effects = new List<Tag>(){};

	Power(string _name, string _description, int _cost, int _duration, List<int> _baseStats, TargetType _targets):
		base("[invalid name]", "[invalid description]", 0, 1, new List<int>(){0, 0, 0}, TargetType.Single){/*List<Tag> _effects,*/
		name = _name;
		description = _description;
		cost = _cost;
		duration = _duration;
		baseStats = _baseStats;
		targets = _targets;
//		effects = _effects;
	}

	public virtual void PowerEffects(Ghost ghost){
		//Console.WriteLine(name + " was activated.");
	}
}

public class Rain : Power {
	new string name = "Rain";

	public override void PowerEffects(Ghost ghost){
		Console.WriteLine(name + " was activated.");
	}
}

public class Gender {
	public string name;
	public Gender(string _name){
		name = _name;
	}
}

public class Orientation {
	public string name;
	public Orientation(string _name){
		name = _name;
	}
}

public class Status {
	public string name;
	public Status(string _name){
		name = _name;
	}
}

public class Map {
	public string name;
	public List<Location> locations;
	public Map (string _name, List<Location> _locations){
		name = _name;
		locations = _locations;
	}
}

public class Location {
	public string name;
	public List<InteractiveObject> interactiveObjects;
	public List<Tag> tethers;
	public List<Tag> traits;
	public Location (string _name, List<InteractiveObject> _interactiveObjects, List<Tag> _tethers){
		name = _name;
		interactiveObjects = _interactiveObjects;
		tethers = _tethers;
	}
}

public class InteractiveObject {
	public string name;
	public List<Tag> tethers;
	public InteractiveObject(string _name, List<Tag> _tethers){
		name = _name;
		tethers = _tethers;
	}
}
