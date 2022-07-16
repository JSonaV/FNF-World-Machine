extends Node2D
var safe
func _ready():
	$Tween1.interpolate_property(self, "modulate:a", 0, 0.9, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5)
	$Tween1.start()

func _on_Tween1_tween_all_completed():
	for i in get_children():
		if "Down" in i.name:
			$Tween2.interpolate_property(i, "position:y", i.position.y, i.position.y + 320, 0.3)
		if "Left" in i.name:
			$Tween2.interpolate_property(i, "position:x", i.position.x, i.position.x - 320, 0.3)
		if "Right" in i.name:
			$Tween2.interpolate_property(i, "position:x", i.position.x, i.position.x + 320, 0.3)
		if "Up" in i.name:
			$Tween2.interpolate_property(i, "position:y", i.position.y, i.position.y - 320, 0.3)
	$Tween2.start()

func _process(delta):
	if safe == "right":
		$Left2.visible = false
		$Right2.visible = false
		$Down3.visible = false
		$Up3.visible = false
	if safe == "left":
		$Left2.visible = false
		$Right2.visible = false
		$Down1.visible = false
		$Up1.visible = false
	if safe == "down":
		$Up2.visible = false
		$Down2.visible = false
		$Left3.visible = false
		$Right3.visible = false
	if safe == "up":
		$Up2.visible = false
		$Down2.visible = false
		$Left1.visible = false
		$Right1.visible = false

func _on_Tween2_tween_all_completed():
	$Tween3.interpolate_property(self, "modulate:a", 0.9, 0, 0.7)
	$Tween3.start()
