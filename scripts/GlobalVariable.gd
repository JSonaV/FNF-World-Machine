extends Node2D


var enemySprite = 0
var playerSprite = 0

func enemyPlay():
	enemySprite = 1
	$EnemyTimer.start()
	
func playerPlay():
	playerSprite = 1
	$PlayerTimer.start()

func _on_EnemyTimer_timeout():
	enemySprite = 0


func _on_PlayerTimer_timeout():
	playerSprite = 0
