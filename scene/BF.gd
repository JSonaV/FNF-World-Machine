extends AnimatedSprite

var idle = true



func _on_BF_animation_finished():
	$Timer.start()


func _on_Timer_timeout():
	idle = true
