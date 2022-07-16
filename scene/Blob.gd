extends Area2D

func _ready():
	$Tween.interpolate_property(self, "position:x", -700, 500, 2.7)
	$Tween.start()

func _physics_process(delta):
	pass


func _on_Tween_tween_all_completed():
	queue_free()





func _on_Blob_body_entered(body):
	if body.name == "Player":
		body.get_node("AnimationPlayer").play("Hit")
	


func _on_Blob_area_entered(area):
	if area.name == "Bubble":
		queue_free()
