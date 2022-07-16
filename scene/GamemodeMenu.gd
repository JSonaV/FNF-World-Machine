extends Node2D

var selecting = true
var value = 0
func _ready():
	BlackScreen.get_node("Tween").interpolate_property(BlackScreen.get_node("ColorRect"), "modulate:a", 1, 0, 1.5)
	BlackScreen.get_node("Tween").start()
func _input(event):
	if selecting:
		if event.is_action_pressed("ui_right"):
			if value % 2 == 0:
				$Tween.interpolate_property($FreeplayRect, "modulate:a", $FreeplayRect.modulate.a, 1, 0.1)
				$Tween.interpolate_property($StoryRect, "modulate:a", $StoryRect.modulate.a, 0, 0.1)
			else:
				$Tween.interpolate_property($StoryRect, "modulate:a", $StoryRect.modulate.a, 1, 0.1)
				$Tween.interpolate_property($FreeplayRect, "modulate:a", $FreeplayRect.modulate.a, 0, 0.1)
			$Tween.start()
			value += 1
		if event.is_action_pressed("ui_left"):
			if value % 2 == 0:
				$Tween.interpolate_property($FreeplayRect, "modulate:a", $FreeplayRect.modulate.a, 1, 0.1)
				$Tween.interpolate_property($StoryRect, "modulate:a", $StoryRect.modulate.a, 0, 0.1)
			else:
				$Tween.interpolate_property($StoryRect, "modulate:a", $StoryRect.modulate.a, 1, 0.1)
				$Tween.interpolate_property($FreeplayRect, "modulate:a", $FreeplayRect.modulate.a, 0, 0.1)
			$Tween.start()
			value += 1
		if event.is_action_pressed("ui_accept"):
			if value % 2 == 0:
				Charts.freeplay = false
				selecting = false
				$TransitionTween.interpolate_property(BlackScreen.get_node("ColorRect"), "modulate:a", 0, 1, 1)
				$TransitionTween.start()
				MenuTheme.stop()
			else:
				Charts.freeplay = true
				get_tree().change_scene("res://scene/Freeplay.tscn")
		if event.is_action_pressed("back"):
			get_tree().change_scene("res://scene/Main Menu.tscn")

func _process(delta):
	if value % 2 == 0:
		$Label.rect_scale = Vector2(1.2,1.2)
		$Label2.rect_scale = Vector2(1,1)
		$Label.modulate = Color(0.2,0.2,1)
		$Label2.modulate = Color(1,1,1)
	else:
		$Label.rect_scale = Vector2(1,1)
		$Label2.rect_scale = Vector2(1.2,1.2)
		$Label2.modulate = Color(1,0.5,0)
		$Label.modulate = Color(1,1,1)


func _on_TransitionTween_tween_all_completed():
	get_tree().change_scene("res://scene/Map1.tscn")
