extends Node2D
var deployed = true

func _ready():
	$AnimationPlayer.play("New Anim")
	
func process(delta):
	if not deployed and $Particles2D.emitting == false:
		print("cleared")
		queue_free()
func pop():
	$Particles2D.global_position = $KinematicBody2D.global_position
	$Particles2D.emitting = true
	$"KinematicBody2D".visible = false
	$"KinematicBody2D/CollisionShape2D".disabled = true
	deployed = false
	
	
	


func _on_KinematicBody2D_area_entered(area):
	$AnimationPlayer.stop(false)
	var poss = area.global_position
	$Particles2D.global_position = poss
	area.queue_free()
	$"Particles2D".emitting = true
	$"KinematicBody2D/AnimatedSprite".global_position = Vector2(-100,-100)
	$"KinematicBody2D/CollisionShape2D".global_position = Vector2(-100,-100)
	$Timer.start()
	



