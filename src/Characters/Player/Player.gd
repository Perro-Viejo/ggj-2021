class_name Player
extends 'res://src/Characters/Actor.gd'

var grabbing: bool = false
var on_ground: bool = false
var foot = 'L'
var is_paused := false
var is_out: bool = false
var is_moving = false
var dir := Vector2.ZERO

var _current_light_idx := -1
var _lights_in_inventory := []
var _capture_target: Node2D
var _captured_constellations := 0

#onready var _light := $Light
onready var _light_mask: Light2D = find_node('LightMask')
onready var _crosshair: Sprite = find_node('Crosshair')
onready var _camera: Camera2D = find_node('Camera2D')
onready var _laser: RayCast2D = find_node('LaserBeam2D')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	# Conectarse a señales del universo chocofantástico
	PlayerEvent.connect('capture_started', self, '_shoot_laser', [ true ])
	PlayerEvent.connect('capture_stoped', self, '_shoot_laser', [ null, false ])
	PlayerEvent.connect('capture_done', self, '_add_to_inventory')
	HudEvent.connect('capture_screen_closed', self, '_unpause')
	GuiEvent.connect('NewGame', self, '_setup')

	update_camera_limits()


func _input(event: InputEvent) -> void:
	if is_paused: return
	
	if event is InputEventKey:
		return
	elif event is InputEventMouseButton and event.is_pressed():
		var amount := 0
		if event.button_index == BUTTON_WHEEL_UP:
			amount = 1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			amount = -1
		else:
			return
		set_light_mask(
			wrapi(_current_light_idx + amount, 0, _lights_in_inventory.size())
		)
	elif event is InputEventMouseMotion:
		_crosshair.position = get_local_mouse_position()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func set_light_mask(idx: int) -> void:
	var light_item: Item = inventory.get_item(_lights_in_inventory[idx])

	_current_light_idx = idx
	_crosshair.self_modulate = light_item.light_color
	_light_mask.range_item_cull_mask = light_item.light_mask
	Data.set_data(Data.CURRENT_LIGHT_MASK, _light_mask.range_item_cull_mask)
	WorldEvent.emit_signal('light_changed', _current_light_idx)


func update_camera_limits() -> void:
	_camera.limit_left = position.x - 1024
	_camera.limit_right = position.x + 1024
	_camera.limit_top = position.y - 438
	_camera.limit_bottom = position.y + 438

	if _capture_target:
		_laser.look_at(_capture_target.global_position)


func add_light(item: Item) -> void:
	_capture_target = null
	(inventory as Inventory).add_to_inventory(item)

	if not _lights_in_inventory.has(item.light_id):
		_lights_in_inventory.append(item.light_id)
		PlayerEvent.emit_signal('light_added', item, _lights_in_inventory.size() - 1)
	if _current_light_idx < 0:
		set_light_mask(_lights_in_inventory.size() - 1)


func play_animation(name: String) -> void:
	$Sprite.play(name)


func lose() -> void:
	is_paused = true
	_capture_target = null
	_laser.is_casting = false


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _shoot_laser(target: Node2D, shoot: bool) -> void:
	if shoot:
		AudioEvent.emit_signal('play_requested', 'Laser', 'Ray_Head', global_position)
		AudioEvent.emit_signal('play_requested', 'Laser', 'Ray_Loop', global_position)
		_capture_target = target
		_laser.look_at(_capture_target.global_position)
	else:
		AudioEvent.emit_signal('stop_requested', 'Laser', 'Ray_Loop')
		AudioEvent.emit_signal('play_requested', 'Laser', 'Ray_Tail', global_position)
		_capture_target = null
	_laser.is_casting = shoot


func _add_to_inventory(target: Node2D) -> void:
	is_paused = true
	_laser.is_casting = false
	_captured_constellations += 1
	add_light((target as Constellation).hiding_light)


func _unpause() -> void:
	if _captured_constellations == inventory.max_size:
		PlayerEvent.emit_signal('game_won')
	else:
		is_paused = false
		WorldEvent.emit_signal('timer_requested', Data.get_data(Data.TIME_LEFT))


func _setup() -> void:
	_current_light_idx = -1
	_lights_in_inventory = []
	_capture_target = null
	_captured_constellations = 0
	(inventory as Inventory).clean()
