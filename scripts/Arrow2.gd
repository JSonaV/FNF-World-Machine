extends Area2D

var rang = position.y
var speed = 1
var far = 200 * Charts.scrollSpeed
func _ready():
	if Charts.nightcore == true:
		$Tween.playback_speed = 2
	else:
		$Tween.playback_speed = 1
	if Charts.downscroll == true:
		position.y = -far
		rang = -far
	else:
		position.y = far
		rang =far
	$Tween.interpolate_property(self, "position:y", position.y, 0, speed, Tween.TRANS_LINEAR)
	$Tween.start()
func _process(delta):
	if Charts.downscroll == true:
		if position.y > 30:
			queue_free()
	else:
		if position.y < -30:
			queue_free()


func _on_Tween_tween_all_completed():
	$Tween.interpolate_property(self, "position:y", position.y, position.y - rang, speed, Tween.TRANS_LINEAR)
	$Tween.start()
