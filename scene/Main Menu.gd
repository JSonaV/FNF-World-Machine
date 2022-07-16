extends Node2D
var value1 = 0  #Main
var value2 = 0  #Options
var menu = 0 #0 = Main, 1 = Option
var readingInput = false
var inputtedKeysText = ["Left", "Down", "Up", "Right"]
var inputtedKeysCode = []
onready var menu1 = [$Label1, $Label2, $Label3] #Main
onready var menu2 = [$"Background2/Label1", $"Background2/Label2", $"Background2/Label3", $"Background2/Label4", $"Background2/Label5"]
onready var menu2Description = ["Press Left/Right to change\n\nEnable/Disaable Downscroll", 
								"Press Left/Right to change\n\nEnable/Disable Nightcore Mode (Charts and Song goes 2x faster)", 
								"Set which button activates which (Order: Left, Down, Up, Right)", 
								"Press Left/Right to change\n\nSets your offset\n(I don't even know if it's in ms or something, but it works)",
								"Press Left/Right to change\n\nScroll speed yada yada"]


func _input(event):
	if menu == 0: #If on main
		if event.is_action_pressed("ui_down"):
			$SFXScroll.play(0.1)
			if value1 == 0: #From Start to Option
				$Tween.interpolate_property($"Background1", "modulate:a", $"Background1".modulate.a, 0, 0.3)
				$Tween.interpolate_property($"Background2", "modulate:a", $"Background2".modulate.a, 1, 0.3)
				$Tween.start()
			if value1 == 1: #From Option to Credit
				$Tween.interpolate_property($"Background2", "modulate:a", $"Background2".modulate.a, 0, 0.3)
				$Tween.start()
			if value1 == 2: #From Credit to Start
				$Tween.interpolate_property($"Background1", "modulate:a", $"Background1".modulate.a, 1, 0.3)
				$Tween.interpolate_property($"Background2", "modulate:a", $"Background2".modulate.a, 0, 0.3)
				$Tween.start()
				
			if not value1 >= 2: 
				value1 += 1
			else:
				value1 = 0
		if event.is_action_pressed("ui_up"):
			$SFXScroll.play(0.1)
			if value1 == 0: #From Start to Credit
				$Tween.interpolate_property($"Background1", "modulate:a", $"Background1".modulate.a, 0, 0.3)
				$Tween.start()
			if value1 == 1: #From Option to Start
				$Tween.interpolate_property($"Background1", "modulate:a", $"Background1".modulate.a, 1, 0.3)
				$Tween.interpolate_property($"Background2", "modulate:a", $"Background2".modulate.a, 0, 0.3)
				$Tween.start()
			if value1 == 2: #From Credit to Option
				$Tween.interpolate_property($"Background2", "modulate:a", $"Background2".modulate.a, 1, 0.3)
				$Tween.start()
			if not value1 <= 0: 
				value1 -= 1
			else:
				value1 = 2
	
	if menu == 1:
		if event.is_action_pressed("ui_down"):
			$SFXScroll.play(0.1)
			if not value2 >= menu2.size() - 1:
				value2 += 1
			else:
				value2 = 0
		if event.is_action_pressed("ui_up"):
			$SFXScroll.play(0.1)
			if not value2 <= 0:
				value2 -= 1
			else:
				value2 = menu2.size() - 1
	
	if event.is_action_pressed("ui_accept") and menu == 1:
		$SFXScroll.play(0.1)
		if value2 == 0:
			if Charts.downscroll:
				Charts.downscroll = false
				menu2[0].text = "Downscroll = Off"
			else:
				Charts.downscroll = true 
				menu2[0].text = "Downscroll = On"
		if value2 == 1:
			if Charts.nightcore:
				Charts.nightcore = false
				menu2[1].text = "Nightcore Mode = Off"
			else:
				Charts.nightcore = true 
				menu2[1].text = "Nightcore Mode = On"
	if event.is_action_pressed("ui_accept"): #Select
		$SFXScroll.play(0.1)
		if menu == 0:
			if value1 == 0: #Play The Game
				$TransitionTween.interpolate_property(BlackScreen.get_node("ColorRect"), "modulate:a", 0, 1, 0.5)
				$TransitionTween.start()
			if value1 == 1:
				menu = 1
			if value1 == 2:
				get_tree().change_scene("res://scene/Credit.tscn")
		if menu == 1:
			if value2 == 2:
				menu2[2].text = "Press 4 Keys (in order)"
				readingInput = true
				inputtedKeysText = []
				inputtedKeysCode = []
				
				
	if event.is_action_pressed("back"):
		if menu == 1:
			menu = 0
			value2 = 0
			
	if readingInput == true:
		menu = 3
		if event is InputEventKey and event.pressed and event.scancode != KEY_ENTER:
			inputtedKeysText.append(event.as_text())
			inputtedKeysCode.append(event)
			$"Background2/Label3".text = "Keybinds = " + String(inputtedKeysText)
			if inputtedKeysText.size() >= 4:
				readingInput = false
				menu = 1
				$"Background2/Label3".text = "Keybinds = " + inputtedKeysText[0] + inputtedKeysText[1] + inputtedKeysText[2] + inputtedKeysText[3]
				InputMap.action_erase_events("left2")
				InputMap.action_erase_events("down2")
				InputMap.action_erase_events("up2")
				InputMap.action_erase_events("right2")
				
				InputMap.action_add_event("left2", inputtedKeysCode[0])
				InputMap.action_add_event("down2", inputtedKeysCode[1])
				InputMap.action_add_event("up2", inputtedKeysCode[2])
				InputMap.action_add_event("right2", inputtedKeysCode[3])
				Charts.inputtedKeysText = inputtedKeysText[0] + inputtedKeysText[1] + inputtedKeysText[2] + inputtedKeysText[3]
	if event.get_action_strength("ui_right") == 1 and value2 == 3:
			$SFXScroll.play(0.1)
			Charts.offset += 1
			menu2[3].text = "Offset = " + String(Charts.offset)
	if event.get_action_strength("ui_right") == 1 and value2 == 4:
			$SFXScroll.play(0.1)
			Charts.scrollSpeed += 0.02
			menu2[4].text = "Scroll Speed = " + String(Charts.scrollSpeed) + "x"
	
	if event.get_action_strength("ui_left") == 1 and value2 == 3:
		Charts.offset -= 1
		menu2[3].text = "Offset = " + String(Charts.offset)
	if event.get_action_strength("ui_left") == 1 and value2 == 4:
				Charts.scrollSpeed -= 0.02
				menu2[4].text = "Scroll Speed = " + String(Charts.scrollSpeed) + "x"
			

func _ready():
	if MenuTheme.playing == false:
		MenuTheme.playing = true
	print("bump")
	BlackScreen.get_node("Tween").interpolate_property(BlackScreen.get_node("ColorRect"), "modulate:a", 1, 0, 1.5)
	BlackScreen.get_node("Tween").start()
	menu2[3].text = "Offset = " + String(Charts.offset)
	menu2[4].text = "Scroll Speed = " + String(Charts.scrollSpeed) + "x"
	$"Background2/Label3".text = "Keybinds = " + Charts.inputtedKeysText
	if not Charts.downscroll:
		menu2[0].text = "Downscroll = Off"
	else:
		menu2[0].text = "Downscroll = On"
	if not Charts.nightcore:
		menu2[1].text = "Nightcore Mode = Off"
	else:
		menu2[1].text = "Nightcore Mode = On"
func _process(delta):
	if menu == 0:
		for i in menu1:
			i.rect_scale = Vector2(1,1)
		menu1[value1].rect_scale = Vector2(1.2,1.2)
	else:
		for i in menu1:
			i.rect_scale = Vector2(1,1)
	if menu == 1:
		for i in menu2:
			i.rect_scale = Vector2(1,1)
		menu2[value2].rect_scale = Vector2(1.2,1.2)
		$"Background2/Description".text = menu2Description[value2]
	else:
		for i in menu2:
			i.rect_scale = Vector2(1,1)
		$"Background2/Description".text = ""
	
func _on_TransitionTween_tween_completed(object, key):
	get_tree().change_scene("res://scene/VsBfUndertale.tscn")
	print("Mrrooaww")
