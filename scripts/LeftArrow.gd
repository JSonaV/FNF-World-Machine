extends Area2D

var rang = position.y
var speed = 1
var far = 200 * Charts.scrollSpeed
var time 
var dependant = false
var offset = Charts.offset
func _ready():
	if Charts.downscroll == true:
		position.y = -far
		rang = -far
	else:
		position.y = far
		rang =far
	if not Charts.downscroll:
		far += offset
		rang += offset
	else:
		far += -offset
		rang += -offset
	#if Charts.downscroll:
	#	$Tween.interpolate_property(self, "position:y", position.y, position.y + (-rang * 2), speed * 2, Tween.TRANS_LINEAR)
	#	$Tween.start()
	#else:
	#	$Tween.interpolate_property(self, "position:y", position.y, position.y + (-far * 2), speed * 2, Tween.TRANS_LINEAR)
	#	$Tween.start()
func _process(delta):
	if Charts.downscroll == true:
		if position.y > 200:
			queue_free()
	else:
		if position.y < -200:
			queue_free()
	if not Charts.downscroll:
		position.y = ((((time+1000)/5) - ((Charts.timePosition *1000)/5)) - offset) * Charts.scrollSpeed
	else:
		position.y = -((((time+1000)/5) - ((Charts.timePosition *1000)/5)) - offset) * Charts.scrollSpeed
		


