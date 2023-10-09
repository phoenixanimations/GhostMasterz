//clear; cd ~/Desktop; csc Pathfinding.cs; mono Pathfinding.exe
using System;
using System.Collections.Generic;
using System.Linq;

public class Pathfinding {
//	static Pathfinding pathfinding;
	public static bool debugMode = true;
	public static bool bypass = false;
	public static bool continueGame = true;
	
	public static Random random = new Random();

	public static void Main(){
		Pathfinding pathfinding = new Pathfinding();

		Tether cold = new Tether("Cold");
		Tether electrical = new Tether("Electrical");
		Tether reflective = new Tether("Reflective");
		Tether water = new Tether("Water");
		Tether inside = new Tether("Inside");
		Tether outside = new Tether("Outside");
		Tether earth = new Tether("Earth");
		Tether hot = new Tether("Hot");
		Tether fire = new Tether("Fire");

		Interest toilet = new Interest("Toilet", new List<Tether>(){water});		
		Interest sink = new Interest("Sink", new List<Tether>(){water});//, null);
		Interest mirror = new Interest("Mirror", new List<Tether>(){reflective});
		Interest bathtub = new Interest("Bathtub", new List<Tether>(){water});
		Interest fridge = new Interest("Fridge", new List<Tether>(){cold, electrical});
		Interest television = new Interest("Television", new List<Tether>(){electrical, reflective});
		Interest tree = new Interest("Tree", new List<Tether>(){earth});
		Interest rock = new Interest("Rock", new List<Tether>(){earth});
		Interest fireplace = new Interest("Fireplace", new List<Tether>(){hot, fire});

		Location bathroom = new Location("Bathroom", new List<Interest>(){toilet, sink, mirror, bathtub}, new List<Tether>(){inside});
		Location livingroom = new Location("Livingroom", new List<Interest>(){television, fireplace}, new List<Tether>(){inside});
		Location kitchen = new Location("Kitchen", new List<Interest>(){sink, fridge}, new List<Tether>(){inside});
		Location forest = new Location("Forest", new List<Interest>(){tree, rock}, new List<Tether>(){outside, cold});

		Map map0 = new Map("Test Map", new List<Location>(){livingroom, bathroom, kitchen, forest});

		Character alpha = new Character("Alpha", new List<Location>(){livingroom, bathroom, kitchen}, new List<Interest>(){television, toilet, sink, fridge});

		print(map0.name+": ");
		string stringify = "";
		foreach(Location location in map0.locations){
			//print('\t'+location.name+": ");
			foreach(Tether tether in location.tethers){
				stringify += tether.name + ", ";
			}
			print("\t"+location.name+" ("+stringify+")");
			stringify = "";
			foreach(Interest interest in location.interests){
				foreach(Tether tether in interest.tethers){
					stringify += tether.name + ", ";
				}
				print("\t\t"+interest.name+" ("+stringify+")");
				stringify = "";
			}
		}

		print("\nAlpha's Pathing");
		foreach(Location location in alpha.pathing){
			print(location.name);
		}
		print("\nAlpha's Interests");
		foreach(Interest interest in alpha.interests){
			print(interest.name);
		}
	}
	
	public static void cwl(System.Object line){
		if(debugMode || bypass){
			Console.WriteLine(line);
//			chatHistory += line;
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

public class Tether {
	public string name;
	public Tether(string _name){
		name = _name;
	}
}

public class Character {
	public string name;
	public List<Location> pathing;
	public List<Interest> interests;
	public Character(string _name, List<Location> _pathing, List<Interest> _interests){
		name = _name;
		pathing = _pathing;
		interests = _interests;
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
	public List<Interest> interests;
	public List<Tether> tethers;
	public Location (string _name, List<Interest> _interests, List<Tether> _tethers){
		name = _name;
		interests = _interests;
		tethers = _tethers;
	}
}

public class Interest {
	public string name;
	public List<Tether> tethers;
	public Interest(string _name, List<Tether> _tethers){
		name = _name;
		tethers = _tethers;
	}
}
