extends AnimatedSprite


func _ready():
	$Tween.interpolate_property(self, "modulate:a", 1, 0, 0.7)
	$Tween.start()
	
	



func _on_Tween_tween_all_completed():
	queue_free()
