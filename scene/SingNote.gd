extends Sprite


func _ready():
	if name[0] == "R" or name[1] == "R":
		$Tween.interpolate_property(self, "position:x", position.x, position.x + 40, 0.5)
		$Tween.interpolate_property(self, "modulate:a", 1, 0, 0.5)
		$Tween.start()
	if name[0] == "G" or name[1] == "G":
		$Tween.interpolate_property(self, "position:y", position.y, position.y - 40, 0.5)
		$Tween.interpolate_property(self, "modulate:a", 1, 0, 0.5)
		$Tween.start()
	if name[0] == "B" or name[1] == "B":
		$Tween.interpolate_property(self, "position:y", position.y, position.y + 40, 0.5)
		$Tween.interpolate_property(self, "modulate:a", 1, 0, 0.5)
		$Tween.start()
	if name[0] == "P" or name[1] == "P":
		$Tween.interpolate_property(self, "position:x", position.x, position.x - 40, 0.5)
		$Tween.interpolate_property(self, "modulate:a", 1, 0, 0.5)
		$Tween.start()



func _on_Tween_tween_completed(object, key):
	queue_free()
