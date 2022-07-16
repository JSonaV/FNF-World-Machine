extends Node2D

var selecting = 0
var onMenu = true
var onOption = false
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_down") and selecting < 3:
		if selecting == 1:
			$AnimationPlayer.play("Options")
		if selecting == 2:
			$AnimationPlayer.play_backwards("Options")
		selecting += 1
		$AudioStreamPlayer.pitch_scale = 2
		$AudioStreamPlayer.play()
	if Input.is_action_just_pressed("ui_up") and selecting > 1:
		if selecting == 3:
			$AnimationPlayer.play("Options")
		if selecting == 2:
			$AnimationPlayer.play_backwards("Options")
		selecting -= 1
		$AudioStreamPlayer.pitch_scale = 2
		$AudioStreamPlayer.play()
	
	if onMenu:
		if selecting == 1:
			$Youtube.visible = false
			$Play.add_color_override("font_color", Color(0.2,0.7,1))
			$Options.add_color_override("font_color", Color(1,1,1))
			$Rawr.add_color_override("font_color", Color(1,1,1))
			$Nightcore.visible = true
			if Input.is_action_just_pressed("ui_accept"):
				$AnimationPlayer.play("Play")
			if Input.is_action_just_pressed("z"):
				if Charts.nightcore == true:
					Charts.nightcore = false
					$Nightcore.add_color_override("font_color", Color(1,0,0))
				else:
					Charts.nightcore = true
					$Nightcore.add_color_override("font_color", Color(0,1,0))
				$AudioStreamPlayer.pitch_scale = 4
				$AudioStreamPlayer.play()
		if selecting == 2:
			$Youtube.visible = false
			$Options.add_color_override("font_color", Color(0.2,0.7,1))
			$Play.add_color_override("font_color", Color(1,1,1))
			$Rawr.add_color_override("font_color", Color(1,1,1))
			$Nightcore.visible = false
			if Input.is_action_just_pressed("z"):
				if Charts.downscroll == false:
					Charts.downscroll = true
					$Downscroll.add_color_override("font_color", Color(0,1,0))
				else:
					Charts.downscroll = false
					$Downscroll.add_color_override("font_color", Color(1,0,0))
				$AudioStreamPlayer.pitch_scale = 4
				$AudioStreamPlayer.play()
			if Input.is_action_just_pressed("x"):
				if Charts.leftInput == "ui_left":
					Charts.leftInput = "left2"
					Charts.downInput = "down2"
					Charts.upInput = "up2"
					Charts.rightInput = "right2"
					$Controls.text = "Press X to change control setting\ncurrent: QWOP / SDKL / XCNM"
				else:
					Charts.leftInput = "ui_left"
					Charts.downInput = "ui_down"
					Charts.upInput = "ui_up"
					Charts.rightInput = "ui_right"
					$Controls.text = "Press X to change control setting\ncurrent: Arow Keys / WASD"
				$AudioStreamPlayer.pitch_scale = 4
				$AudioStreamPlayer.play()
		if selecting == 3:
			$Rawr.add_color_override("font_color", Color(0.2,0.7,1))
			$Options.add_color_override("font_color", Color(1,1,1))
			$Play.add_color_override("font_color", Color(1,1,1))
			$Nightcore.visible = false
			if Input.is_action_just_pressed("ui_accept"):
				OS.shell_open("www.youtube.com/c/jinggasona")
			$Youtube.visible = true

		
		

func play():
	get_tree().change_scene("res://scene/Map 3.tscn")
