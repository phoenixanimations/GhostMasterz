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
using System.Linq;

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
		Tag plasma = new Tag("Plasma");
		Tag ice = new Tag("Ice");
		Tag water = new Tag("Water");
		Tag inside = new Tag("Inside");
		Tag outside = new Tag("Outside");
		Tag earth = new Tag("Earth");
		Tag hot = new Tag("Hot");
		Tag fire = new Tag("Fire");
		Tag blood = new Tag("Blood");
		Tag bugs = new Tag("Bugs");
		Tag snakes = new Tag("Snakes");
    	Tag light = new Tag("Light");
    	Tag darkness = new Tag("Darkness");
   		Tag hunted = new Tag("Hunted");
   		Tag weapons = new Tag("Weapons");
		Tag noise = new Tag("Noise");
		Tag trapped = new Tag("Trapped");
    	Tag dirty = new Tag("Dirty");
    	Tag heights = new Tag("Heights");
    	Tag needles = new Tag("Needles");
    	Tag rejection = new Tag("Rejection");
    	Tag failure = new Tag("Failure");
    	Tag embarrassment = new Tag("Embarrassment");
    	Tag aging = new Tag("Aging");
    	Tag suffering = new Tag("Suffering");
    	Tag death = new Tag("Death");
    	Tag corpse = new Tag("Corpse");
    	Tag ghost = new Tag("Ghost");
    	Tag alienation = new Tag("Alienation");//Isolation?

    	Gender male = new Gender("Male");
    	Gender female = new Gender("Female");
    	Gender nonbinary = new Gender("Non-Binary");

    	Orientation asexual = new Orientation("Asexual");
    	Orientation bisexual = new Orientation("Bisexual");
    	Orientation gay = new Orientation("Gay");
    	Orientation lesbian = new Orientation("Lesbian");
    	Orientation pansexual = new Orientation("Pansexual");
    	Orientation straight = new Orientation("Straight");

		PhysicalStatus normalStatus = new PhysicalStatus("Normal");
		PhysicalStatus hotStatus = new PhysicalStatus("Hot");
		PhysicalStatus coldStatus = new PhysicalStatus("Cold");
		PhysicalStatus warmStatus = new PhysicalStatus("Warm");
		PhysicalStatus frozenStatus = new PhysicalStatus("Frozen");
		PhysicalStatus burningStatus = new PhysicalStatus("Burning");
		PhysicalStatus electrocutedStatus = new PhysicalStatus("Electrocuted");
		PhysicalStatus sleepingStatus = new PhysicalStatus("Sleeping");
		PhysicalStatus sleepwalkingStatus = new PhysicalStatus("Sleepwalking");
		PhysicalStatus faintedStatus = new PhysicalStatus("Fainted");
		PhysicalStatus comatoseStatus = new PhysicalStatus("Comatose");
		PhysicalStatus possessedStatus = new PhysicalStatus("Possessed");

		EmotionalStatus happyStatus = new EmotionalStatus("Happy");
		EmotionalStatus sadStatus = new EmotionalStatus("Sad");
		EmotionalStatus angryStatus = new EmotionalStatus("Angry");
		EmotionalStatus indifferentStatus = new EmotionalStatus("Indifferent");
		EmotionalStatus disgustedStatus = new EmotionalStatus("Disgusted");
		EmotionalStatus curiousStatus = new EmotionalStatus("Curious");
		EmotionalStatus confusedStatus = new EmotionalStatus("Confused");

		InteractiveObject toilet = new InteractiveObject("Toilet", new List<Tag>(){water}, new List<Tag>(){water});		
		InteractiveObject sink = new InteractiveObject("Sink", new List<Tag>(){water}, new List<Tag>(){water});
		InteractiveObject mirror = new InteractiveObject("Mirror", new List<Tag>(){reflective}, new List<Tag>(){reflective});
		InteractiveObject bathtub = new InteractiveObject("Bathtub", new List<Tag>(){water}, new List<Tag>(){water});
		InteractiveObject fridge = new InteractiveObject("Fridge", new List<Tag>(){cold, electrical}, new List<Tag>(){cold, electrical});
		InteractiveObject television = new InteractiveObject("Television", new List<Tag>(){electrical, reflective}, new List<Tag>(){electrical, reflective});//divert to couch
		InteractiveObject tree = new InteractiveObject("Tree", new List<Tag>(){earth}, new List<Tag>(){earth});
		InteractiveObject logs = new InteractiveObject("Logs", new List<Tag>(){earth}, new List<Tag>(){earth});
		InteractiveObject rock = new InteractiveObject("Rock", new List<Tag>(){earth}, new List<Tag>(){earth});
		InteractiveObject fireplace = new InteractiveObject("Fireplace", new List<Tag>(){hot, fire}, new List<Tag>(){hot, fire});
		InteractiveObject pipes = new InteractiveObject("Pipes", new List<Tag>(){water, hot, blood}, new List<Tag>(){water, hot, blood});
		InteractiveObject boiler = new InteractiveObject("Boiler", new List<Tag>(){water, hot, electrical}, new List<Tag>(){water, hot, electrical});
		InteractiveObject necronomicon = new InteractiveObject("Necronomicon", new List<Tag>(){blood}, new List<Tag>(){blood});
		
		/*
		InteractiveObject child = new InteractiveObject("Child", new List<Tag>(){}, new List<Tag>(){});
		InteractiveObject teenager = new InteractiveObject("Teenager", new List<Tag>(){}, new List<Tag>(){});
		InteractiveObject adult = new InteractiveObject("Adult", new List<Tag>(){}, new List<Tag>(){});
		*/

		Location bathroom = new Location("First Bathroom", new List<InteractiveObject>(){toilet, sink, mirror, bathtub}, new List<Tag>(){inside});
		Location bathroom2 = new Location("Second Bathroom", new List<InteractiveObject>(){toilet, sink}, new List<Tag>(){inside});
		Location livingroom = new Location("Livingroom", new List<InteractiveObject>(){television, fireplace}, new List<Tag>(){inside});
		Location basement = new Location("Basement", new List<InteractiveObject>(){pipes, boiler, necronomicon}, new List<Tag>(){inside});
		Location kitchen = new Location("Kitchen", new List<InteractiveObject>(){sink, fridge}, new List<Tag>(){inside});
		Location forest = new Location("Forest", new List<InteractiveObject>(){tree, rock, logs}, new List<Tag>(){outside, cold});

		Map map0 = new Map("Test Map", new List<Location>(){livingroom, bathroom, kitchen, forest, basement, bathroom2});

		Character alpha = new Character("Alpha", male, gay, new List<Location>(){}, new List<InteractiveObject>(){television, toilet, sink, fridge}, new List<Tag>(){trapped}, normalStatus, happyStatus, 100, 0, 0, 0);
		Character beta = new Character("Beta", male, straight, new List<Location>(){}, new List<InteractiveObject>(){logs, fireplace}, new List<Tag>(){bugs, trapped, darkness}, coldStatus, angryStatus, 80, 20, 10, 20);
		Character gamma = new Character("Gamma", nonbinary, pansexual, new List<Location>(){}, new List<InteractiveObject>(){television, fireplace}, new List<Tag>(){outside, noise, hunted}, warmStatus, confusedStatus, 50, 10, 20, 50);
		Character delta = new Character("Delta", female, bisexual, new List<Location>(){}, new List<InteractiveObject>(){bathtub, pipes, boiler, necronomicon}, new List<Tag>(){bugs, dirty, blood, fire}, coldStatus, curiousStatus, 20, 0, 5, 80);

		List<Character> characters = new List<Character>(){alpha, beta, gamma, delta};

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
		/*foreach(Character character in characters){
			foreach(Location location in map0.locations){
				foreach(InteractiveObject interactiveObject in location.interactiveObjects){
					if((character.interests).Contains(interactiveObject)){
						print(character.name+" was interested in the "+location.name+" " +interactiveObject.name);
					}
				}
			}
		}*/

		alpha.printout();
		beta.printout();
		gamma.printout();
		delta.printout();
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
	public PhysicalStatus physicalStatus;//Hot, Cold, Warm, Frozen, Burning, Electrocuted, Sleeping, Sleepwalking, PassedOut/Fainted, Comatose, Possessed
	public EmotionalStatus emotionalStatus;//Happy, Sad, Angry, Indifferent, Disgust
	public int maximumBelief = 100;
	public int willpower;
	public int fearMeter;
	public int madnessMeter;
	public int beliefMeter;
	public Character(string _name, Gender _gender, Orientation _orientation, List<Location> _pathing, List<InteractiveObject> _interests, List<Tag> _fears, PhysicalStatus _physicalStatus, EmotionalStatus _emotionalStatus, int _willpower, int _fearMeter, int _madnessMeter, int _beliefMeter){
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
		
		Console.WriteLine("\nName: "+name+" ("+gender.name+", "+orientation.name+")\nPathing: "+pathingPrintout+'\n'+"Interests: "+interestsPrintout+'\n'+"Fears: "+fearsPrintout+'\n'+"Physical Status: "+physicalStatus.name+'\n'+"Emotional Status: "+emotionalStatus.name+'\n'+"Willpower: "+willpower+'\n'+"Fear: "+fearMeter+'/'+willpower+'\n'+"Madness: "+madnessMeter+'/'+willpower+'\n'+"Belief: "+beliefMeter+"/100");
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

public class PhysicalStatus {
	public string name;
	public PhysicalStatus(string _name){
		name = _name;
	}
}

public class EmotionalStatus {
	public string name;
	public EmotionalStatus(string _name){
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
	public Location (string _name, List<InteractiveObject> _interactiveObjects, List<Tag> _tethers/*, List<Tag> _traits*/){
		name = _name;
		interactiveObjects = _interactiveObjects;
		tethers = _tethers;
//		traits = _traits;
	}
}

public class InteractiveObject {
	public string name;
	public List<Tag> tethers;
	public List<Tag> traits;
	public InteractiveObject(string _name, List<Tag> _tethers, List<Tag> _traits){
		name = _name;
		tethers = _tethers;
		traits = _traits;
	}
}
