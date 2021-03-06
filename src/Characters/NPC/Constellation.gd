# Spawns copies of the sprite that fade out
class_name Constellation
extends Sprite

export var linked_light: Resource
export var hiding_light: Resource
export var card: Texture
export var creature: SpriteFrames
export var creature_scale := Vector2.ONE
export var spawn_rate := 0.1 setget set_spawn_rate
export var lifetime := 30.0
export var capture_time := 10.0

var is_emitting := false setget set_is_emitting

var _fading_sprite: PackedScene = preload("res://src/VFX/FadingSprite.tscn")

onready var _timer: Timer = Timer.new()
onready var _area2d: Area2D = $Area2D
onready var _capture_progress: TextureProgress = find_node('CaptureProgress')
onready var _creature: AnimatedSprite = $Creature


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	assert(linked_light)
	
	light_mask = linked_light.light_mask
	_capture_progress.hide()
	_creature.frames = creature
	_creature.light_mask = light_mask
	_creature.scale = creature_scale

	# Conectarse a señales de los hijos
	_timer.connect('timeout', self, '_spawn_ghost')
	_area2d.connect('input_event', self, '_check_input')
	_area2d.connect('mouse_entered', self, '_panic')
	_area2d.connect('mouse_exited', self, '_calm_down')
	
	# Conectarse a señales del universo
	WorldEvent.connect('game_lost', self, '_on_game_lost')

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
		self_modulate.a = 0.0

		# Eliminar la última huella
		get_child(get_child_count() - 1).queue_free()
		
		# Orientar bien el Sprite de la criatura
		_creature.rotation = get_parent().rotation * -1.0


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
	if Data.get_data(Data.CURRENT_LIGHT_MASK) != light_mask: return
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
				if not $Tween.is_connected('tween_completed', self, '_capture'):
					$Tween.connect('tween_completed', self, '_capture')
				PlayerEvent.emit_signal('capture_started', self)
				$Tween.start()
			else:
				_stop_capture()


func _panic() -> void:
	# TODO: Hacer algo que muestre que el bicho sabe que ya lo vieron
	pass


func _calm_down() -> void:
	if Data.get_data(Data.CURRENT_LIGHT_MASK) != light_mask: return
	$Tween.stop_all()	
	_capture_progress.hide()
	_stop_capture()


func _capture(_obj: Object, _key: NodePath) -> void:
	AudioEvent.emit_signal('stop_requested', 'Laser', 'Ray_Loop')
	AudioEvent.emit_signal('play_requested', 'Laser', 'Ray_Tail', global_position)
	PlayerEvent.emit_signal('capture_done', self)
	
	_area2d.disconnect('input_event', self, '_check_input')
	_area2d.disconnect('mouse_entered', self, '_panic')
	$Tween.disconnect('tween_completed', self, '_capture')

	queue_free()


func _stop_capture() -> void:
	if _capture_progress.visible:
		$Tween.disconnect('tween_completed', self, '_capture')
		$Tween.interpolate_property(
			_capture_progress, 'value',
			_capture_progress.value, 0.0,
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN
		)
		PlayerEvent.emit_signal('capture_stoped')
		$Tween.start()


func _on_game_lost() -> void:
	$Tween.remove_all()
	_stop_capture()
	_area2d.disconnect('input_event', self, '_check_input')
	_area2d.disconnect('mouse_entered', self, '_panic')
	_area2d.disconnect('mouse_exited', self, '_calm_down')
