# Spawns copies of the sprite that fade out
extends Sprite
class_name PawPrint

export var spawn_rate := 0.1 setget set_spawn_rate
export var is_emitting := false setget set_is_emitting
export var lifetime := 30.0
export var capture_time := 10.0

var _fading_sprite: PackedScene = preload("res://src/VFX/FadingSprite.tscn")

onready var _timer: Timer = Timer.new()
onready var _area2d: Area2D = $Area2D
onready var _capture_progress: TextureProgress = find_node('CaptureProgress')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	_capture_progress.hide()

	# Conectarse a señales de los hijos
	_timer.connect('timeout', self, '_spawn_ghost')
	_area2d.connect('input_event', self, '_check_input')
	_area2d.connect('mouse_entered', self, '_panic')
	_area2d.connect('mouse_exited', self, '_calm_down')

	add_child(_timer)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func set_is_emitting(value: bool) -> void:
	is_emitting = value

	if not is_inside_tree():
		yield(self, "ready")

	if is_emitting:
		_spawn_ghost()
		_timer.start()
	else:
		_timer.stop()

		# Eliminar la última huella
		get_child(get_child_count() - 1).queue_free()


func set_spawn_rate(value: float) -> void:
	spawn_rate = value
	if not _timer:
		yield(self, "ready")

	_timer.wait_time = 1.0 / spawn_rate


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _spawn_ghost() -> void:
	var ghost := _fading_sprite.instance()
	ghost.offset = offset
	ghost.texture = texture
	ghost.flip_h = flip_h
	ghost.flip_v = flip_v
	ghost.rotation = get_parent().rotation
	ghost.material = material
	ghost.light_mask = light_mask

	add_child(ghost)
	ghost.set_as_toplevel(true)

	ghost.global_position = global_position

	ghost.fade(lifetime)


func _check_input(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			$Tween.stop_all()
			if event.is_pressed():
				_capture_progress.show()
				var duration := capture_time * (1.0 - _capture_progress.value / 100.0)
				$Tween.interpolate_property(
					_capture_progress, 'value',
					_capture_progress.value, 100.0,
					duration, Tween.TRANS_LINEAR, Tween.EASE_IN
				)
				$Tween.connect('tween_completed', self, '_capture')
				PlayerEvent.emit_signal('capture_started', self)
			else:
				_capture_progress.hide()
				$Tween.disconnect('tween_completed', self, '_capture')
				$Tween.interpolate_property(
					_capture_progress, 'value',
					_capture_progress.value, 0.0,
					0.5, Tween.TRANS_LINEAR, Tween.EASE_IN
				)
				PlayerEvent.emit_signal('capture_stoped')
			$Tween.start()


func _panic() -> void:
	# TODO: Hacer algo que muestre que el bicho sabe que ya lo vieron
	pass


func _calm_down() -> void:
	pass


func _capture(_obj: Object, _key: NodePath) -> void:
	PlayerEvent.emit_signal('capture_done', self)
	
	_area2d.disconnect('input_event', self, '_check_input')
	_area2d.disconnect('mouse_entered', self, '_panic')
	$Tween.disconnect('tween_completed', self, '_capture')

	queue_free()
