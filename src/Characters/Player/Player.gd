class_name Player
extends 'res://src/Characters/Actor.gd'

export var mask: NodePath
export var light: NodePath

var grabbing: bool = false
var on_ground: bool = false
var foot = 'L'
var is_paused := false
var is_out: bool = false
var is_moving = false
var dir := Vector2.ZERO

var _current_light_idx := 1
var _lights_in_inventory := 3
var _capture_target: Node2D

#onready var _light := $Light
onready var _light_mask: Light2D = get_node(mask)
onready var _crosshair: Sprite = get_node(light)
onready var _camera: Camera2D = find_node('Camera2D')
onready var _laser: RayCast2D = find_node('LaserBeam2D')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	# Conectarse a señales del universo chocofantástico
	PlayerEvent.connect('capture_started', self, '_shoot_laser', [ true ])
	PlayerEvent.connect('capture_stoped', self, '_shoot_laser', [ null, false ])
	PlayerEvent.connect('capture_done', self, '_add_to_inventory')
	HudEvent.connect('capture_screen_closed', self, '_unpause')

	update_camera_limits()
	set_light_mask()


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
			wrapi(_current_light_idx + amount, 1, _lights_in_inventory + 1)
		)
	elif event is InputEventMouseMotion:
#		_light.look_at(get_global_mouse_position())
		_crosshair.position = get_local_mouse_position()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func set_light_mask(id := 1) -> void:
	_current_light_idx = id

	match id:
		1:
			_crosshair.self_modulate = Data.LIGHT_RED
			_light_mask.range_item_cull_mask = 1
		2:
			_crosshair.self_modulate = Data.LIGHT_BLUE
			_light_mask.range_item_cull_mask = 2
		3:
			_crosshair.self_modulate = Data.LIGHT_YELLOW
			_light_mask.range_item_cull_mask = 4

	Data.set_data(Data.CURRENT_LIGHT_MASK, _light_mask.range_item_cull_mask)
	WorldEvent.emit_signal('light_changed', _current_light_idx - 1)


func update_camera_limits() -> void:
	_camera.limit_left = position.x - 1024
	_camera.limit_right = position.x + 1024
	_camera.limit_top = position.y - 438
	_camera.limit_bottom = position.y + 438
	
	if _capture_target:
		_laser.look_at(_capture_target.global_position)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _shoot_laser(target: Node2D, shoot: bool) -> void:
	if shoot:
		_capture_target = target
		_laser.look_at(_capture_target.global_position)
	else:
		_capture_target = null
	_laser.is_casting = shoot


func _add_to_inventory(target: Node2D) -> void:
	is_paused = true
	_laser.is_casting = false


func _unpause() -> void:
	is_paused = false
