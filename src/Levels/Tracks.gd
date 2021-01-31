extends Node2D

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	$Tween.connect('tween_completed', self, '_stop_pawing')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func spread_constellations(constellations := []) -> void:
	for p in $Paths.get_children():
		var path_follow: PathFollow2D = p.get_child(0)
		var constellation: Constellation = constellations[p.get_index()]
		path_follow.add_child(constellation)
		constellation.is_emitting = true

		$Tween.interpolate_property(
			path_follow, 'unit_offset',
			0.0, 1.0,
			2.0, Tween.TRANS_LINEAR, Tween.EASE_IN
		)
	$Tween.start()
	constellations.clear()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _stop_pawing(obj: Object, _key: NodePath) -> void:
	(obj.get_child(0) as Constellation).is_emitting = false
