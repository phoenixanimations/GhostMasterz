extends Node

export(Array, Resource) var footstep_sounds
onready var timer = $Timer
var actor

func play_sound(volume): # To avoid the sound from clipping, we generate a new audio node each time then we delete it
	if not footstep_sounds or (footstep_sounds.size() == 0):
		return
	var audio_node = AudioStreamPlayer.new()
	var pick_sound = randi() % footstep_sounds.size() # Pick a random sound
	audio_node.stream = footstep_sounds[pick_sound]
	audio_node.volume_db = volume
	audio_node.pitch_scale = rand_range(0.95, 1.05)
	add_child(audio_node)
	audio_node.play()
	yield(get_tree().create_timer(2), "timeout")
	audio_node.queue_free()

func _process(_delta):
	if timer.is_stopped():
		if actor.is_on_floor() and actor.speed_magnitude >= 2:
			var animation_speed = 1.0 / (actor.speed_magnitude / 2)
			if round(actor.speed_magnitude) > 3:
				play_sound(-20)
			elif round(actor.speed_magnitude) == 3:
				play_sound(-30)
			else:
				play_sound(-40)
			timer.wait_time = animation_speed
			timer.start()
	
	if actor.is_on_floor() and actor.snapped == false:
		play_sound(-10)
