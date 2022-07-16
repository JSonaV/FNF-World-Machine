extends RigidBody2D

func _physics_process(delta):
	if $AnimatedSprite.animation == "Run":
		$AnimatedSprite.playing = true
	else:
		$AnimatedSprite.playing = false
