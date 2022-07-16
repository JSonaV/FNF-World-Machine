extends Node2D

var dict = {}
var dictBump = {}
var dictSpecial = {}
var dictCamera = {}
var downscroll = false
var leftInput = "left2"
var downInput = "down2"
var upInput = "up2"
var rightInput = "right2"
var nightcore = false
var scrollSpeed = 1.0
var pausable = false
var offset = 0
var inputtedKeysText = "LeftDownUpRight"
var freeplay = false
var timePosition = 0.0


func _ready():
	var file = File.new()
	file.open("res://assets/charts/livingObstacle.json", file.READ)
	var text = file.get_as_text()
	dict = JSON.parse(text).result
	file.close()
	
	var fileBump = File.new()
	fileBump.open("res://assets/charts/lastBreath-bump.json", fileBump.READ)
	var textBump = fileBump.get_as_text()
	dictBump = JSON.parse(textBump).result
	fileBump.close()
	
	var fileSpecial = File.new()
	fileSpecial.open("res://assets/charts/lastBreath-special.json", fileSpecial.READ)
	var textSpecial = fileSpecial.get_as_text()
	dictSpecial = JSON.parse(textSpecial).result
	file.close()
	
	var fileCamera = File.new()
	fileCamera.open("res://assets/charts/lastBreath-camera.json", fileCamera.READ)
	var textCamera = fileCamera.get_as_text()
	dictCamera = JSON.parse(textCamera).result
	file.close()
