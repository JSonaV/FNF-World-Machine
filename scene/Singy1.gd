extends Node2D
var score = 0
var totalNote = 0
var time
var BPM = 178
var BPMCount = (60.0 / BPM)
var windowPos = Vector2(0,0)

var idleCooldown = 1
var bumpAllowed = false
onready var LeftArrow = load("res://scene/LeftArrow.tscn")
onready var RightArrow = load("res://scene/RightArrow.tscn")
onready var DownArrow = load("res://scene/DownArrow.tscn")
onready var UpArrow = load("res://scene/UpArrow.tscn")
onready var SpecialDownArrow = load("res://scene/DSpecial.tscn")
onready var SpecialUpArrow = load("res://scene/USpecial.tscn")
onready var SpecialLeftArrow = load("res://scene/LSpecial.tscn")
onready var SpecialRightArrow = load("res://scene/RSpecial.tscn")
onready var SickResult = load("res://scene/SickResult.tscn")
onready var GoodResult = load("res://scene/GoodResult.tscn")
onready var BadResult = load("res://scene/BadResult.tscn")
onready var music = load("res://assets/musics/Resolve.ogg")
onready var bullets = load("res://scene/BulletAttack1.tscn")
var playing = false
var readIt = false
var animation = "horizontalMove"
var losing = false
var pendingNote
var combo = 0

var cameraBumpCount = 0 #AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
var cameraBumpCount2 = 0 #AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
var cameraBumpCountTiming = []

var cameraBumpRotation = 1

var ms = 480
var beat = []
var beatCount = 0

var zx = 1
func randCam():
	$ "../../Camera2D".offset = Vector2(rand_range(-300,300), rand_range(-200,200))
func turnBump():
	if bumpAllowed == false:
		bumpAllowed = true
	else:
		bumpAllowed = false
func _ready():
	$"../../AnimationPlayer/AudioStreamPlayer".volume_db = -80
	get_tree().get_root().set_transparent_background(true)
	OS.window_size = OS.get_screen_size() - Vector2(53,1)
	OS.window_position.y = OS.get_screen_size().y - OS.window_size.y
	OS.window_position.x = 10
	var file = File.new()
	file.open("res://assets/charts/Oneshot.json", file.READ)
	var text = file.get_as_text()
	Charts.dict = JSON.parse(text).result
	file.close()
	
	BlackScreen.visible = false
	$ColorRect.modulate.a = 0
	Charts.pausable = true
	

func _input(event):
	if losing:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
			#$TextureProgress.value = 50
			#losing = false
			#start()
			#$ColorRect.modulate.a = 0
			#$"Label".modulate.a = 0
			#BlackScreen.get_node("Tween").interpolate_property(BlackScreen.get_node("ColorRect"), "modulate:a", 1, 0, 1.5)
			#BlackScreen.get_node("Tween").start()
		if Input.is_action_just_pressed("back"):
			get_tree().change_scene("res://scene/Main Menu.tscn")
	
	if event.is_action_pressed(Charts.leftInput) and not event.is_echo():
		$BFArrow/Left/Left.frame = 2
		var x = false
		for i in $BFArrow/Left.get_overlapping_areas():
			if x == false:
				if "LSpecial" in i.name:
					pass
				elif "Good" in i.name or "Bad" in i.name:
					if "LSpecial" in i.get_parent().name:
						pass
				judge(i)
				x = true
	elif event.is_action_released(Charts.leftInput):
		$BFArrow/Left/Left.frame = 0
		
	if event.is_action_pressed(Charts.downInput)  and not event.is_echo():
		$BFArrow/Down/Down.frame = 2
		var x = false
		for i in $BFArrow/Down.get_overlapping_areas():
			if x == false:
				if "DSpecial" in i.name:
					pass
				elif "Good" in i.name or "Bad" in i.name:
					if "DSpecial" in i.get_parent().name:
						pass
				judge(i)
				$BFArrow/Down/Down.frame = 4
				x = true
	elif event.is_action_released(Charts.downInput):
		$BFArrow/Down/Down.frame = 0
		
	if event.is_action_pressed(Charts.upInput) and not event.is_echo():
		$BFArrow/Up/Up.frame = 2
		var x = false
		for i in $BFArrow/Up.get_overlapping_areas():
			if x == false:
				if "USpecial" in i.name:
					pass
				elif "Good" in i.name or "Bad" in i.name:
					if "USpecial" in i.get_parent().name:
						pass
				judge(i)
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
				if "RSpecial" in i.name:
					pass
				elif "Good" in i.name or "Bad" in i.name:
					if "RSpecial" in i.get_parent().name:
						pass
				judge(i)
				$BFArrow/Right/Right.frame = 4
				x = true
	elif event.is_action_released(Charts.rightInput):
		$BFArrow/Right/Right.frame = 0
var timings = []
var notes = []
var holdNotes = []
var mustHit
var specialNotes = []

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
	
var rotat = 1
func playSong():
	time = $AudioStreamPlayer.get_playback_position() * 1000
	if readIt == false:
		for i in beat:
			if time > i:
				if bumpAllowed:
					if beatCount % 2 == 0:
						$TweenCamera.interpolate_property($"../../Camera2D", "zoom", Vector2(0.95,0.95), Vector2(1,1), 0.2)
						windowPos = Vector2(rand_range(-300,300), rand_range(-200,200))
						$TweenCamera.start()
						
					else:
						$TweenCamera.interpolate_property($"../..", "rotation_degrees", 3 * rotat, 0, 0.2)
						$TweenCamera.start()
						rotat *= -1
						
				if idleCooldown <= 0:
						$"../../Penguin".stop()
						$"../../Penguin".frame = 0
						$"../../Penguin".play("Idle")
				beatCount += 1
				beat.erase(i)
		for i in timings:
			if time >= i[0]:
				if i[1] == true:
					if i[2] == 0:
						spawnArrow(LeftArrow, true, i[0], i[4])
						timings.erase(i)
						totalNote += 1
					elif i[2] == 1:
						spawnArrow(DownArrow, true, i[0], i[4])
						timings.erase(i)
						totalNote += 1
					elif i[2] == 2:
						spawnArrow(UpArrow, true, i[0], i[4])
						timings.erase(i)
						totalNote += 1
					elif i[2] == 3:
						spawnArrow(RightArrow, true, i[0], i[4])
						timings.erase(i)
						totalNote += 1
					if i[2] == 4:
						spawnArrow(LeftArrow, false, i[0])
						timings.erase(i)
					elif i[2] == 5:
						spawnArrow(DownArrow, false, i[0])
						timings.erase(i)
					elif i[2] == 6:
						spawnArrow(UpArrow, false, i[0])
						timings.erase(i)
					elif i[2] == 7:
						spawnArrow(RightArrow, false, i[0])
						timings.erase(i)
						
				else:
					if i[2] == 0:
						spawnArrow(LeftArrow, false, i[0])
						timings.erase(i)
					elif i[2] == 1:
						spawnArrow(DownArrow, false, i[0])
						timings.erase(i)
					elif i[2] == 2:
						spawnArrow(UpArrow, false, i[0])
						timings.erase(i)
					elif i[2] == 3:
						spawnArrow(RightArrow, false, i[0])
						timings.erase(i)
					elif i[2] == 4:
						spawnArrow(LeftArrow, true, i[0], i[4])
						totalNote += 1
						timings.erase(i)
					elif i[2] == 5:
						spawnArrow(DownArrow, true, i[0], i[4])
						totalNote += 1
						timings.erase(i)
					elif i[2] == 6:
						spawnArrow(UpArrow, true, i[0], i[4])
						totalNote += 1
						timings.erase(i)
					elif i[2] == 7:
						spawnArrow(RightArrow, true, i[0], i[4])
						totalNote += 1
						timings.erase(i)
					
				
			if time >= i[0] + 1000 and i[2] == -1:
					if cameraBumpCount == 0:
						$"Camera2D".zoom = Vector2(0.6,0.6)
					elif cameraBumpCount == 1:
						$"Camera2D".zoom = Vector2(0.7,0.7)
					elif cameraBumpCount == 2:
						$"Camera2D".zoom = Vector2(0.8,0.8)
					elif cameraBumpCount == 3:
						$"Camera2D".zoom = Vector2(1,1)
					elif cameraBumpCount == 4:
						$"../../Particles2D".emitting = true
						$TweenCamera.interpolate_property($"../../Camera2D", "zoom", Vector2(0.9,0.9), Vector2(1,1), 0.35)
						$TweenCamera.interpolate_property($"../../TileMap", "position:y", $"../../TileMap".position.y, $"../../TileMap".position.y+300, 0.2)
						$"../../TileMap2/AnimationPlayer".play("Shoot")
						$"../../TileMap2/AnimationPlayer2".play("Glow")
						$TweenCamera.start()
					elif cameraBumpCount > 4:
						cameraBumpCount2 += 1
						$TweenCamera.interpolate_property($"../../Camera2D", "zoom", Vector2(0.9,0.9), Vector2(1,1), 0.35)
						$ColorRect2.color = Color(randf(), randf(), randf())
						$TweenCamera.interpolate_property($"ColorRect2", "modulate:a", 0.13 ,0, 0.3)
						for z in $"BFArrow".get_children():
							if not z is Tween:
								if zx <= 4:
									$TweenCamera.interpolate_property($"BFArrow/Left", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"BFArrow/Down", "position:y", -20, 0, 0.2)
								elif zx <= 8 and zx > 4:
									$TweenCamera.interpolate_property($"BFArrow/Up", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"BFArrow/Right", "position:y", -20, 0, 0.2)
								elif zx <= 12 and zx > 8:
									$TweenCamera.interpolate_property($"BFArrow/Left", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"BFArrow/Right", "position:y", -20, 0, 0.2)
								elif zx == 13 or zx == 15:
									$TweenCamera.interpolate_property($"BFArrow/Up", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"BFArrow/Right", "position:y", -20, 0, 0.2)
								elif zx == 14 or zx == 16:
									$TweenCamera.interpolate_property($"BFArrow/Left", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"BFArrow/Down", "position:y", -20, 0, 0.2)
									
								if zx <= 20 and zx > 16:
									$TweenCamera.interpolate_property($"EnemyArrow/Left", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"EnemyArrow/Down", "position:y", -20, 0, 0.2)
								elif zx <= 24 and zx > 20:
									$TweenCamera.interpolate_property($"EnemyArrow/Up", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"EnemyArrow/Right", "position:y", -20, 0, 0.2)
								elif zx <= 28 and zx > 24:
									$TweenCamera.interpolate_property($"EnemyArrow/Left", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"EnemyArrow/Right", "position:y", -20, 0, 0.2)
								elif zx == 29 or zx == 31:
									$TweenCamera.interpolate_property($"EnemyArrow/Up", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"EnemyArrow/Right", "position:y", -20, 0, 0.2)
								elif zx == 30 or zx == 32:
									$TweenCamera.interpolate_property($"EnemyArrow/Left", "position:y", -20, 0, 0.2)
									$TweenCamera.interpolate_property($"EnemyArrow/Down", "position:y", -20, 0, 0.2)
						zx += 1
						
						if cameraBumpCount2 == 29:
							$TweenCamera.interpolate_property($"../../Camera2D", "rotation_degrees", 5, 0, 0.2, Tween.TRANS_BOUNCE)
						if cameraBumpCount2 == 30:
							$TweenCamera.interpolate_property($"../../Camera2D", "rotation_degrees", -5, 0, 0.2, Tween.TRANS_BOUNCE)
						if cameraBumpCount2 == 31:
							$TweenCamera.interpolate_property($"../../Camera2D", "rotation_degrees", 5, 0, 0.2, Tween.TRANS_BOUNCE)
						if cameraBumpCount2 == 32:
							$TweenCamera.interpolate_property($"../../Camera2D", "rotation_degrees", -5, 0, 0.2, Tween.TRANS_BOUNCE)
							zx = 1
						if cameraBumpCount2 == 33:
							cameraBumpCount2 = 1
							$TweenCamera.interpolate_property($"../../Camera2D", "rotation_degrees", 5, 0, 0.2, Tween.TRANS_BOUNCE)
						$TweenCamera.start()
					timings.erase(i)
					var x = 0
					for z in timings:
						if z[2] == -1:
							x += 1
					if x == 0:
						$"../../Particles2D".emitting = false
						$TweenCamera.interpolate_property($"../../Camera2D", "zoom", Vector2(1,1), Vector2(0.5,0.5), 0.4, Tween.TRANS_CUBIC)
						$TweenCamera.start()
					cameraBumpCount += 1
	else:
		lastTime = 999999999999999
		
	
func spawnArrow(type, bf, timez, mod = "null"):
	var instancedScene = type.instance()
	if bf == true:
		if type == LeftArrow:
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			instancedScene.time = timez
			if mod == "Dodge":
				instancedScene = SpecialLeftArrow.instance()
				instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
				instancedScene.time = timez
			$BFArrow/Left/Notes.add_child(instancedScene)
		if type == DownArrow:
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			instancedScene.time = timez
			if mod == "Dodge":
				instancedScene = SpecialDownArrow.instance()
				instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
				instancedScene.time = timez
			$BFArrow/Down/Notes.add_child(instancedScene)
		if type == UpArrow:
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			instancedScene.time = timez
			if mod == "Dodge":
				instancedScene = SpecialUpArrow.instance()
				instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
				instancedScene.time = timez
			$BFArrow/Up/Notes.add_child(instancedScene)
		if type == RightArrow:
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			instancedScene.time = timez
			if mod == "Dodge":
				instancedScene = SpecialRightArrow.instance()
				instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
				instancedScene.time = timez
			$BFArrow/Right/Notes.add_child(instancedScene)
	else:
		if type == LeftArrow:
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			instancedScene.time = timez
			instancedScene.collision_layer = 2
			instancedScene.collision_mask = 2
			$EnemyArrow/Left/Notes.add_child(instancedScene)
			instancedScene.get_node("Good").queue_free()
			instancedScene.get_node("Bad").queue_free()
		if type == DownArrow:
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			instancedScene.time = timez
			instancedScene.collision_layer = 2
			instancedScene.collision_mask = 2
			$EnemyArrow/Down/Notes.add_child(instancedScene)
			instancedScene.get_node("Good").queue_free()
			instancedScene.get_node("Bad").queue_free()
		if type == UpArrow:
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			instancedScene.time = timez
			instancedScene.collision_layer = 2
			instancedScene.collision_mask = 2
			$EnemyArrow/Up/Notes.add_child(instancedScene)
			instancedScene.get_node("Good").queue_free()
			instancedScene.get_node("Bad").queue_free()
		if type == RightArrow:
			instancedScene.speed = ((timez + 1000) - ($"AudioStreamPlayer".get_playback_position() * 1000)) / 1000
			instancedScene.time = timez
			instancedScene.collision_layer = 2
			instancedScene.collision_mask = 2
			$EnemyArrow/Right/Notes.add_child(instancedScene)
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
		timingsSpecial = []
		timingsSpecial2 = []
		timingsCamera = []
		notesSpecial = []
		specialNotes = []
		score = 0
		totalNote = 0
		$Accuration.text = "Accuracy: 0%"
		$Score.text = "Score: 0"
		$TextureProgress.value = 50 
		$BFArrowBump.interpolate_property(self, "modulate:a", 0, 1, 1)
		$BFArrowBump.start()
		timeDelay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
		$AudioStreamPlayer.play()
		$"../TimeTween".interpolate_property(Charts, "timePosition", 0, $AudioStreamPlayer.stream.get_length(), $AudioStreamPlayer.stream.get_length())
		for n in Charts.dict.song.notes:
			mustHit = n.mustHitSection
			if not n.sectionNotes.size() <= 0:
				for i in n.sectionNotes:
					timings.append([(i[0]-1000), mustHit])
					notes.append(i[1])
					holdNotes.append(i[2])
					if i.size() >= 4:
						specialNotes.append(i[3])
					else:
						specialNotes.append("Null")
		var no = 0
		for i in timings:
			timings[no].append(notes[no])
			timings[no].append(holdNotes[no])
			timings[no].append(specialNotes[no])
			no += 1
			
		var mss = 0
		
		var BPM_PLACEHOLDER = 0
		while BPM_PLACEHOLDER < $AudioStreamPlayer.stream.get_length() * 1000:
			beat.append(BPM_PLACEHOLDER)
			BPM_PLACEHOLDER += BPMCount * 1000
			
	
		
		
		playing = true
		$"../../AnimationPlayer".play("New Anim")
func start():
		$AudioStreamPlayer.volume_db = -80
		if $AudioStreamPlayer.playing:
			$AudioStreamPlayer.stop()
		lastTime = $AudioStreamPlayer.get_playback_position()
		time = 0
		$AudioStreamPlayer.play()
		$"../TimeTween".interpolate_property(Charts, "timePosition", 0, $AudioStreamPlayer.stream.get_length(), $AudioStreamPlayer.stream.get_length())
		$"../TimeTween".start()
		$Timer.start()
		
		if Charts.downscroll == true:
			$BFArrow.position.y = 530
			$EnemyArrow.position.y = 530
			$Area2D.position.y = $BFArrow.position.y + 232
			$TextureProgress.rect_position.y = 56
			$Score.rect_position.y = 76
			$Accuration.rect_position.y = 76
			$JudgementResult.position.y = 400
var awa = 1
func lose():
	get_tree().quit()
	

func _process(delta):
	idleCooldown -= delta
	OS.window_size = OS.get_screen_size() 
	OS.window_position.y = OS.get_screen_size().y - OS.window_size.y
	OS.window_position.x = 10
	#Charts.timePosition = $AudioStreamPlayer.get_playback_position()
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
	get_tree().quit()
	
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


func _on_Timer_timeout():
	$TimerSong.wait_time = BPMCount
	$TimerSong.start()
	startSong()







func _on_Area2D_area_entered(area):
	if not area.name == "Good" and not area.name == "Bad":
		area.queue_free()
		combo = 0
		if score - 100 > 0:
			score -= 100
		else:
			score -= score
		if "Special" in area.name:
			$TextureProgress.value -= 20
		else:
			$TextureProgress.value -= 4
		if score > 0:
			var xb = (float(score)/(totalNote*350)*100)
			$Accuration.text = "Accuracy: " + String(stepify(xb,0.01)) + "%"
			$Score.text = "Score: " + String(score)


func _on_Finish_tween_all_completed():
	$AnimationPlayer.play("Finish")
	
func _on_Left_area_entered(area):
	idleCooldown = 1
	area.queue_free()
	$"Bulb".modulate = Color(0.9,0,0.9,0.4)
	$"Bulb/Tween".interpolate_property($Bulb, "modulate:a", 0.2,0,0.3)
	$Bulb/Tween.start()
	$"../../Penguin".stop()
	$"../../Penguin".frame = 0
	$"../../Penguin".play("Left")
	


func _on_Down_area_entered(area):
	idleCooldown = 1
	area.queue_free()
	$"Bulb".modulate = Color(0,0.1,1,0.4)
	$"Bulb/Tween".interpolate_property($Bulb, "modulate:a", 0.2,0,0.3)
	$Bulb/Tween.start()
	$"../../Penguin".stop()
	$"../../Penguin".frame = 0
	$"../../Penguin".play("Down")
	


func _on_Up_area_entered(area):
	idleCooldown = 1
	area.queue_free()
	$"Bulb".modulate = Color(0,0.1,1,0.4)
	$"Bulb/Tween".interpolate_property($Bulb, "modulate:a", 0.2,0,0.3)
	$Bulb/Tween.start()
	$"../../Penguin".stop()
	$"../../Penguin".frame = 0
	$"../../Penguin".play("Up")

func _on_Right_area_entered(area):
	idleCooldown = 1
	area.queue_free()
	$"Bulb".modulate = Color(1,0.5,0,0.4)
	$"Bulb/Tween".interpolate_property($Bulb, "modulate:a", 0.2,0,0.3)
	$Bulb/Tween.start()
	$"../../Penguin".stop()
	$"../../Penguin".frame = 0
	$"../../Penguin".play("Right")



func _on_SpecialArea2D_area_entered(area):
	if (area.name[0] == "D" and area.name[1] == "S") or (area.name[1] == "D" and area.name[2] == "S") or (area.get_parent().name[0] == "D" and area.get_parent().name[1] == "S") or (area.get_parent().name[1] == "D" and area.get_parent().name[2] == "S"):
		area.queue_free()
		#$TweenThunder.interpolate_property($"BFArrow/Left", "position", Vector2($"BFArrow/Left".position.x - 100, $"BFArrow/Left".position.y - 120), $"BFArrow/Left".position, 0.3)
		#$TweenThunder.interpolate_property($"BFArrow/Down", "position", Vector2($"BFArrow/Down".position.x + 80, $"BFArrow/Down".position.y - 100), $"BFArrow/Down".position, 0.3)
		#$TweenThunder.interpolate_property($"BFArrow/Up", "position", Vector2($"BFArrow/Up".position.x - 40, $"BFArrow/Up".position.y - 159), $"BFArrow/Up".position, 0.3)
		#$TweenThunder.interpolate_property($"BFArrow/Right", "position", Vector2($"BFArrow/Right".position.x + 40, $"BFArrow/Right".position.y - 110), $"BFArrow/Right".position, 0.3)
		#$TweenThunder.start()
		if score - 200 > 0:
			score -= 200
		else:
			score -= score
		$TextureProgress.value -= 12
	if (area.name[0] == "U" and area.name[1] == "S") or (area.name[1] == "U" and area.name[2] == "S") or (area.get_parent().name[0] == "U" and area.get_parent().name[1] == "S") or (area.get_parent().name[1] == "U" and area.get_parent().name[2] == "S"):
		area.get_parent().queue_free()
		if score - 200 > 0:
			score -= 200
		else:
			score -= score
		$TextureProgress.value -= 12
	if score > 0:
		var xb = (float(score)/(totalNote*350)*100)
		$Accuration.text = "Accuracy: " + String(stepify(xb,0.01)) + "%"
		$Score.text = "Score: " + String(score)








func _on_Tween_tween_all_completed():
	#$"../../Soul/Particles2D".emitting = false
	#$"../../Soul/Tween".interpolate_property($"../../Soul", "global_position", $"../../Soul".global_position, Vector2(512,384),2)
	#$"../../Soul/Tween".start()
	pass


func _on_Countdown_timeout():
	start()
