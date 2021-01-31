extends MarginContainer

func _ready() -> void:
	$Tween.interpolate_property(
		$Deck, 'rect_position:y',
		0.0, 32.0,
		1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(
		$Deck, 'rect_position:y',
		32.0, 0.0,
		1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT,
		1.05
	)
	$Tween.start()
