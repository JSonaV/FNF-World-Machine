extends Node2D

var songs = ["First Encounter", "Living Obstacle", "Last Breath"]
onready var songsScene = ["res://scene/Map 1.tscn", "res://scene/Map 2.tscn", "res://scene/Map 3.tscn"]
var value = 0
func _input(event):
	if event.is_action_pressed("ui_left"):
		$AudioStreamPlayer.play(0.1)
		
		if value > 0:
			value -= 1
		else:
			value = songs.size()-1
	if event.is_action_pressed("ui_right"):
		$AudioStreamPlayer.play(0.1)
		if value < songs.size()-1:
			value += 1
		else:
			value = 0
	if event.is_action_pressed("ui_accept"):
		$AudioStreamPlayer.play(0.1)
		MenuTheme.stop()
		get_tree().change_scene(songsScene[value])
		Charts.freeplay = true
	if event.is_action_pressed("back"):
		get_tree().change_scene("res://scene/GamemodeMenu.tscn")
func _ready():
	BlackScreen.get_node("Tween").interpolate_property(BlackScreen.get_node("ColorRect"), "modulate:a", 1, 0, 1.5)
	BlackScreen.get_node("Tween").start()

func _process(delta):
	$Label.text = songs[value]
	$Label2.text = String(value + 1)
