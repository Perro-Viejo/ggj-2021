extends Node2D


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	$Tween.connect('tween_all_completed', self, '_stop_pawing')
	
	$Tween.interpolate_property(
		$Path2D/PathFollow2D, 'unit_offset',
		0.0, 1.0,
		2.0, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	$Tween.start()
	(find_node('PawPrint') as PawPrint).is_emitting = true


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _stop_pawing() -> void:
	(find_node('PawPrint') as PawPrint).is_emitting = false
