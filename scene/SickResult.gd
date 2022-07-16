extends Sprite


func _ready():
	$AnimationPlayer.play("New Anim")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
