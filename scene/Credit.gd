extends Node2D

onready var scenes = [$Scene1]
var sceneCount = 0
func _ready():
	BlackScreen.get_node("Tween").interpolate_property(BlackScreen.get_node("ColorRect"), "modulate:a", 1, 0, 1.5)
	BlackScreen.get_node("Tween").start()
func _input(event):
	if event.is_action_pressed("back"):
		get_tree().change_scene("res://scene/Main Menu.tscn")
		
func _process(delta):
	for i in scenes:
		i.visible = false
	scenes[sceneCount].visible = true
