extends AnimatedSprite


func _ready():
	play("default")
	$Tween.interpolate_property(self, "modulate:a", 1, 0, 0.3)
	$Tween.start()
	
func _physics_process(delta):
	pass

func _on_Tween_tween_all_completed():
	queue_free()
