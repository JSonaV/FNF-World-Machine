extends Node2D
var score = 0
var totalNote = 0
var time
var BPM = 240
var BPMCount = (60.0 / 130) * 2
onready var LeftArrow = load("res://scene/LeftArrow.tscn")
onready var RightArrow = load("res://scene/RightArrow.tscn")
onready var DownArrow = load("res://scene/DownArrow.tscn")
onready var UpArrow = load("res://scene/UpArrow.tscn")
onready var SpecialDownArrow = load("res://scene/DSpecial.tscn")
onready var SpecialUpArrow = load("res://scene/USpecial.tscn")
onready var SickResult = load("res://scene/SickResult.tscn")
onready var GoodResult = load("res://scene/GoodResult.tscn")
onready var BadResult = load("res://scene/BadResult.tscn")
onready var music = load("res://assets/musics/Resolve.ogg")
var playing = false
var readIt = false
var animation = "horizontalMove"
var losing = false
var cameraBumpRotation = 1
var combo = 0

func _ready():
	Charts.pausable = true
	var file = File.new()
	file.open("res://assets/charts/lastBreath.json", file.READ)
	var text = file.get_as_text()
	Charts.dict = JSON.parse(text).result
	file.close()
	
	var fileBump = File.new()
	fileBump.open("res://assets/charts/lastBreath-bump.json", fileBump.READ)
	var textBump = fileBump.get_as_text()
	Charts.dictBump = JSON.parse(textBump).result
	fileBump.close()
	
	var fileSpecial = File.new()
	fileSpecial.open("res://assets/charts/lastBreath-special.json", fileSpecial.READ)
	var textSpecial = fileSpecial.get_as_text()
	Charts.dictSpecial = JSON.parse(textSpecial).result
	file.close()
	
	var fileCamera = File.new()
	fileCamera.open("res://assets/charts/lastBreath-camera.json", fileCamera.READ)
	var textCamera = fileCamera.get_as_text()
	Charts.dictCamera = JSON.parse(textCamera).result
	file.close()
	start()

func _input(event):
	
	if losing:
		Charts.pausable = false
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
		if Input.is_action_just_pressed("back"):
			get_tree().change_scene("res://scene/Main Menu.tscn")
	
	if event.is_action_pressed(Charts.leftInput) and not event.is_echo():
		$BFArrow/Left/Left.frame = 2
		var x = false
		for i in $BFArrow/Left.get_overlapping_areas():
			if x == false:
				judge(i)
				get_parent().get_parent().sing("bf", "left")
				$BFArrow/Left/Left.frame = 4
				x = true
		
	elif event.is_action_released(Charts.leftInput):
		$BFArrow/Left/Left.frame = 0
		
	if event.is_action_pressed(Charts.downInput)  and not event.is_echo():
		$BFArrow/Down/Down.frame = 2
		var x = false
		for i in $BFArrow/Down.get_overlapping_areas():
			if x == false:
				if (i.name[0] == "D" and i.name[1] == "S") or (i.name[1] == "D" and i.name[2] == "S") or (i.get_parent().name[0] == "D" and i.get_parent().name[1] == "S") or (i.get_parent().name[1] == "D" and i.get_parent().name[2] == "S"):
					var instancedScene = load("res://scene/SonaTeleport.tscn").instance()
					get_parent().get_parent().get_node("Player").add_child(instancedScene)
					
				judge(i)
				get_parent().get_parent().sing("bf", "down")
				$BFArrow/Down/Down.frame = 4
				x = true
	elif event.is_action_released(Charts.downInput):
		$BFArrow/Down/Down.frame = 0
		
	if event.is_action_pressed(Charts.upInput) and not event.is_echo():
		$BFArrow/Up/Up.frame = 2
		var x = false
		for i in $BFArrow/Up.get_overlapping_areas():
			if x == false:
				if (i.name[0] == "U" and i.name[1] == "S") or (i.name[1] == "U" and i.name[2] == "S") or (i.get_parent().name[0] == "U" and i.get_parent().name[1] == "S") or (i.get_parent().name[1] == "U" and i.get_parent().name[2] == "S"):
					var instancedScene = load("res://scene/Bubble.tscn").instance()
					instancedScene.position.x -= 30
					get_parent().get_parent().get_node("Player").add_child(instancedScene)
				judge(i)
				get_parent().get_parent().sing("bf", "up")
				$BFArrow/Up/Up.frame = 4
				x = true
	elif event.is_action_released(Charts.upInput):
		$BFArrow/Up/Up.frame = 0
		$BFArrow/Up.scale = Vector2(4,4)
		
	if event.is_action_pressed(Charts.rightInput) and not event.is_echo():
		$BFArrow/Right/Right.frame = 2
		var x = false
		for i in $BFArrow/Right.get_overlapping_areas():
			if x == false:
				judge(i)
				get_parent().get_parent().sing("bf", "right")
				$BFArrow/Right/Right.frame = 4
				x = true
	elif event.is_action_released(Charts.rightInput):
		$BFArrow/Right/Right.frame = 0
var timings = []
var notes = []
var holdNotes = []
var mustHit

var timingsBump = []
var notesBump = []

var timingsSpecial = []
var timingsSpecial2 = []
var notesSpecial = []

var timingsCamera = []
var notesCamera = []

var lastTime = 0

var timeDelay;



func judge(i):
	if i.name == "Good":
		i.get_parent().queue_free()
		var instancedScene = GoodResult.instance()
		$JudgementResult.add_child(instancedScene)
		score += 200
		$TextureProgress.value += 1
		combo += 1
		$Tween.interpolate_property($"ComboCounter", "rect_scale", Vector2(1.4,1.4), Vector2(1,1), 0.1)
		$Tween.start()
	elif i.name == "Bad":
		i.get_parent().queue_free()
		var instancedScene = BadResult.instance()
		$JudgementResult.add_child(instancedScene)
		score += 100
		$TextureProgress.value -= 1
		combo = 0
	else:
		i.queue_free()
		var instancedScene = SickResult.instance()
		$JudgementResult.add_child(instancedScene)
		score += 350
		$TextureProgress.value += 3
		combo += 1
		$Tween.interpolate_property($"ComboCounter", "rect_scale", Vector2(1.4,1.4), Vector2(1,1), 0.1)
		$Tween.start()
	$Score.text = "Score: " + String(score)
	var xb = (float(score)/(totalNote*350)*100)
	$Accuration.text = "Accuracy: " + String(stepify(xb,0.01)) + "%"
	GlobalVariable.playerPlay()
func playSong():
	time = $AudioStreamPlayer.get_playback_position() * 1000
	if readIt == false:
		for i in timings:
			if time >= i[0]:
				if i[1] == true:
					if i[2] == 0:
						spawnArrow(LeftArrow, true, i[0])
						totalNote += 1
					elif i[2] == 1:
						spawnArrow(DownArrow, true, i[0])
						totalNote += 1
					elif i[2] == 2:
						spawnArrow(UpArrow, true, i[0])
						totalNote += 1
					elif i[2] == 3:
						spawnArrow(RightArrow, true, i[0])
						totalNote += 1
					if i[2] == 4:
						spawnArrow(LeftArrow, false, i[0])
					elif i[2] == 5:
						spawnArrow(DownArrow, false, i[0])
					elif i[2] == 6:
						spawnArrow(UpArrow, false, i[0])
					elif i[2] == 7:
						spawnArrow(RightArrow, false, i[0])
						
				else:
					if i[2] == 0:
						spawnArrow(LeftArrow, false, i[0])
					elif i[2] == 1:
						spawnArrow(DownArrow, false, i[0])
					elif i[2] == 2:
						spawnArrow(UpArrow, false, i[0])
					elif i[2] == 3:
						spawnArrow(RightArrow, false, i[0])
					if i[2] == 4:
						spawnArrow(LeftArrow, true, i[0])
						totalNote += 1
					elif i[2] == 5:
						spawnArrow(DownArrow, true, i[0])
						totalNote += 1
					elif i[2] == 6:
						spawnArrow(UpArrow, true, i[0])
						totalNote += 1
					elif i[2] == 7:
						spawnArrow(RightArrow, true, i[0])
						totalNote += 1
					
				timings.erase(i)
		
		for i in timingsSpecial:
			if time > i[0]:
				if not i.size() <= 1:
					if i[1] == 1:
						spawnArrow(SpecialDownArrow, true, i[0], true)
						totalNote += 1
					if i[1] == 2:
						spawnArrow(SpecialUpArrow, true, i[0], true)
						totalNote += 1
						var instancedScene = load("res://scene/Blob.tscn").instance()
						instancedScene.position.x = -100
						get_parent().get_parent().get_node("Player").add_child(instancedScene)
				timingsSpecial.erase(i)
			
		for i in timingsCamera:
			if time > i[0]:
				if not i.size() <= 1:
					if i[1] == 0:
						
						if not cameraBumpRotation % 2 == 0:
							$TweenCamera.interpolate_property($"../../Camera2D", "rotation_degrees", -4, 0, 0.5)
						else:
							$TweenCamera.interpolate_property($"../../Camera2D", "rotation_degrees", 4, 0, 0.5)
						cameraBumpRotation += 1
						$TweenCamera.start()
				timingsCamera.erase(i)
		
		for i in timingsBump:
			if time > i[0]:
				if not i.size() <= 1:
					if i[1] == 0:
						$EnemyArrow/Left.position.y = -15
						$BFArrowBump.interpolate_property($EnemyArrow/Left, "position:y", -15, 0, 0.2)
					if i[1] == 1:
						$EnemyArrow/Down.position.y = -15
						$BFArrowBump.interpolate_property($EnemyArrow/Down, "position:y", -15, 0, 0.2)
					if i[1] == 2:
						$EnemyArrow/Up.position.y = -15
						$BFArrowBump.interpolate_property($EnemyArrow/Up, "position:y", -15, 0, 0.2)
					if i[1] == 3:
						$EnemyArrow/Right.position.y = -15
						$BFArrowBump.interpolate_property($EnemyArrow/Right, "position:y", -15, 0, 0.2)
					if i[1] == 4:
						$BFArrow/Left.position.y = -15
						$BFArrowBump.interpolate_property($BFArrow/Left, "position:y", -15, 0, 0.2)
					if i[1] == 5:
						$BFArrow/Down.position.y = -15
						$BFArrowBump.interpolate_property($BFArrow/Down, "position:y", -15, 0, 0.2)
					if i[1] == 6:
						$BFArrow/Up.position.y = -15
						$BFArrowBump.interpolate_property($BFArrow/Up, "position:y", -15, 0, 0.2)
					if i[1] == 7:
						$BFArrow/Right.position.y = -15
						$BFArrowBump.interpolate_property($BFArrow/Right, "position:y", -15, 0, 0.2)
					$BFArrowBump.start()
					timingsBump.erase(i)
	else:
		lastTime = 999999999999999
func spawnArrow(type, bf, timez, special = false):
	var instancedScene = type.instance()
	if bf == true and not special:
		if type == LeftArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$BFArrow/Left.add_child(instancedScene)
		if type == DownArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$BFArrow/Down.add_child(instancedScene)
		if type == UpArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$BFArrow/Up.add_child(instancedScene)
		if type == RightArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$BFArrow/Right.add_child(instancedScene)
	elif bf == true and special:
		if type == SpecialDownArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$BFArrow/Down.add_child(instancedScene)
		elif type == SpecialUpArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$BFArrow/Up.add_child(instancedScene)
	else:
		if type == LeftArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$EnemyArrow/Left.add_child(instancedScene)
			instancedScene.get_node("Good").queue_free()
			instancedScene.get_node("Bad").queue_free()
		if type == DownArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$EnemyArrow/Down.add_child(instancedScene)
			instancedScene.get_node("Good").queue_free()
			instancedScene.get_node("Bad").queue_free()
		if type == UpArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$EnemyArrow/Up.add_child(instancedScene)
			instancedScene.get_node("Good").queue_free()
			instancedScene.get_node("Bad").queue_free()
		if type == RightArrow:
			instancedScene.time = timez
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			$EnemyArrow/Right.add_child(instancedScene)
			instancedScene.get_node("Good").queue_free()
			instancedScene.get_node("Bad").queue_free()
	

func startSong():
		$AudioStreamPlayer.volume_db = 0
		if Charts.nightcore:
			$AudioStreamPlayer.pitch_scale = 2
		else:
			$AudioStreamPlayer.pitch_scale = 1
		time = 0
		timings = []
		notes = []
		holdNotes = []
		mustHit = null
		timingsBump = []
		notesBump = []
		timingsSpecial = []
		timingsSpecial2 = []
		timingsCamera = []
		notesSpecial = []
		score = 0
		totalNote = 0
		$Accuration.text = "Accuracy: 0%"
		$Score.text = "Score: 0"
		$TextureProgress.value = 50 
		$BFArrowBump.interpolate_property(self, "modulate:a", 0, 1, 1)
		$BFArrowBump.start()
		timeDelay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
		$AudioStreamPlayer.play()
		for n in Charts.dict.song.notes:
			mustHit = n.mustHitSection
			if not n.sectionNotes.size() <= 0:
				for i in n.sectionNotes:
					timings.append([(i[0]-1000), mustHit])
					notes.append(i[1])
					holdNotes.append(i[2])
		var no = 0
		for i in timings:
			timings[no].append(notes[no])
			timings[no].append(holdNotes[no])
			no += 1
			
		for n in Charts.dictBump.song.notes:
			if not n.sectionNotes.size() <= 0:
				for i in n.sectionNotes:
					timingsBump.append([i[0]])
					notesBump.append(i[1])
		var noBump = 0
		for i in timingsBump:
			timingsBump[noBump].append(notesBump[noBump])
			noBump += 1
		
		for n in Charts.dictSpecial.song.notes:
			if not n.sectionNotes.size() <= 0:
				for i in n.sectionNotes:
					timingsSpecial.append([i[0]-1000])
					timingsSpecial2.append([i[0]])
					notesSpecial.append(i[1])
		var noSpecial = 0
		for i in timingsSpecial:
			timingsSpecial[noSpecial].append(notesSpecial[noSpecial])
			timingsSpecial2[noSpecial].append(notesSpecial[noSpecial])
			noSpecial += 1
			
		for n in Charts.dictCamera.song.notes:
			if not n.sectionNotes.size() <= 0:
				for i in n.sectionNotes:
					timingsCamera.append([i[0]])
					notesCamera.append(i[1])
		var noCamera = 0
		for i in timingsCamera:
			timingsCamera[noCamera].append(notesCamera[noCamera])
			noCamera += 1
		playing = true
func start():
		$AudioStreamPlayer.volume_db = -80
		if $AudioStreamPlayer.playing:
			$AudioStreamPlayer.stop()
		lastTime = $AudioStreamPlayer.get_playback_position()
		time = 0
		$AudioStreamPlayer.play()
		$Timer.start()
		
		if Charts.downscroll == true:
			$BFArrow.position.y = 530
			$EnemyArrow.position.y = 530
			$Area2D.position.y = $BFArrow.position.y + 232
			$SpecialArea2D.position.y = $BFArrow.position.y + 144
			$TextureProgress.rect_position.y = 56
			$Score.rect_position.y = 76
			$Accuration.rect_position.y = 76
			$JudgementResult.position.y = 400
var awa = 1
func lose():
	Charts.pausable = false
	if $AudioStreamPlayer.pitch_scale <= 0.1:
			$AudioStreamPlayer.stop()
	else:
		$AudioStreamPlayer.pitch_scale -= 0.007
	if not losing:
		print(awa)
		losing = true
		$AnimationPlayer.play("Lose")
	

func _process(delta):
	Charts.timePosition = $AudioStreamPlayer.get_playback_position()
	if $AudioStreamPlayer.playing:
		if $TextureProgress.value <= 0:
			Charts.pausable = false
			lose()
	
	if combo > 5:
		$"ComboCounter".text = String(combo)
	else:
		$"ComboCounter".text = ""

	if playing and not losing:
		playSong()
		
	for i in timingsSpecial2:
			if time > i[0]:
				if not i.size() <= 1:
					if i[1] == 1:
						var instancedScene = load("res://scene/Thunder.tscn").instance()
						get_parent().get_parent().get_node("Player").add_child(instancedScene)
						get_parent().get_parent().shake()
				timingsSpecial2.erase(i)
			

func gameDone():
	if Charts.freeplay:
		get_tree().change_scene("res://scene/Main Menu.tscn")
	else:
		get_tree().change_scene("res://scene/Main Menu.tscn")
	
func _on_AudioStreamPlayer_finished():
	if not losing:
		time = 0
		playing = false
		$Finish.interpolate_property($BFArrow, "modulate:a", 1, 0, 1)
		$Finish.interpolate_property($EnemyArrow, "modulate:a", 1, 0, 1)
		$Finish.interpolate_property($Accuration, "modulate:a", 1, 0, 1)
		$Finish.interpolate_property($Score, "modulate:a", 1, 0, 1)
		$Finish.start()
		timings = []
		notes = []
		holdNotes = []
		mustHit = null
		timingsBump = []
		notesBump = []


func _on_Timer_timeout():
	$TimerSong.wait_time = BPMCount
	$TimerSong.start()
	startSong()


func _on_TimerSong_timeout():
	if playing:
		$BFArrowBump.start()
		$TimerSong.start()





func _on_Area2D_area_entered(area):
	if not area.name == "Good" and not area.name == "Bad":
		area.queue_free()
		combo = 0
		if score - 100 > 0:
			score -= 100
		else:
			score -= score
		$TextureProgress.value -= 4
		if score > 0:
			var xb = (float(score)/(totalNote*350)*100)
			$Accuration.text = "Accuracy: " + String(stepify(xb,0.01)) + "%"
			$Score.text = "Score: " + String(score)


func _on_Left_area_entered(area):
	area.queue_free()
	$"../../Bulb".modulate = Color(1,0,1)
	$"../../Bulb/Tween".interpolate_property($"../../Bulb", "modulate:a", 0.7, 0, 0.6)
	$"../../Bulb/Tween".start()
	
	


func _on_Down_area_entered(area):
	area.queue_free()
	$"../../Bulb".modulate = Color(0,0.5,1)
	$"../../Bulb/Tween".interpolate_property($"../../Bulb", "modulate:a", 0.7, 0, 0.6)
	$"../../Bulb/Tween".start()
	


func _on_Up_area_entered(area):
	area.queue_free()
	$"../../Bulb".modulate = Color(0,1,0)
	$"../../Bulb/Tween".interpolate_property($"../../Bulb", "modulate:a", 0.7, 0, 0.6)
	$"../../Bulb/Tween".start()


func _on_Right_area_entered(area):
	area.queue_free()
	$"../../Bulb".modulate = Color(1,0.6,0.2)
	$"../../Bulb/Tween".interpolate_property($"../../Bulb", "modulate:a", 0.7, 0, 0.6)
	$"../../Bulb/Tween".start()

func _on_Finish_tween_all_completed():
	$AnimationPlayer.play("Finish")

func _on_SpecialArea2D_area_entered(area):
	if ((area.name[0] == "D" and area.name[1] == "S") or (area.name[1] == "D" and area.name[2] == "S") or (area.name[0] == "U" and area.name[1] == "S") or (area.name[1] == "U" and area.name[2] == "S")):
		area.queue_free()
		if score - 200 > 0:
			score -= 200
		else:
			score -= score
		$TextureProgress.value -= 12
	






