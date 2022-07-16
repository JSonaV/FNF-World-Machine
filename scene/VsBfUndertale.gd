extends Node2D

var glitchTime = 0
func _process(delta):
	glitchTime -= delta
	if glitchTime > 0:
		$"PressGlitch".visible = true
	else:
		$"PressGlitch".visible = false


func _on_Button_button_down():
	glitchTime = 0.5
