extends Container


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	for i in $HBoxContainer.get_children():
		i.rect_pivot_offset = i.rect_size / 2.0

	WorldEvent.connect('light_changed', self, '_highlight_light')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _disable_lights(exception: int) -> void:
	$Tween.stop_all()
	for i in $HBoxContainer.get_children():
		if i.get_index() != exception and i.rect_scale == Vector2.ONE:
			i.modulate.a = 0.5
			$Tween.interpolate_property(
				i, 'rect_scale',
				i.rect_scale, Vector2.ONE * 0.7,
				0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT
			)
			$Tween.start()


func _highlight_light(idx := 0) -> void:
	_disable_lights(idx)

	$HBoxContainer.get_child(idx).modulate.a = 1.0
	$HBoxContainer.get_child(idx).rect_scale = Vector2.ONE
