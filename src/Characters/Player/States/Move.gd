extends "res://src/StateMachine/State.gd"
"""
State interface to use in Hierarchical State Machines.
The lowest leaf tries to handle callbacks, and if it can't, it delegates the work to its parent.
It's up to the user to call the parent state's functions, e.g. `_parent.physics_process(delta)`
Use State as a child of a StateMachine node.
"""

export var listen_anim_frames := false
export var fs_sfx_frames := []
export var speed := 2.0

var dir := Vector2.ZERO
var can_move := true

var _last_dir := Vector2.ZERO

onready var _calc_speed: float = speed * 60


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	yield(owner, 'ready')
	_parent = get_parent().get_parent()
	visible = false


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func _unhandled_input(event: InputEvent) -> void:
	if owner.is_paused: return

	if event.is_action_pressed('light_1'):
		owner.set_light_mask(1)
	elif event.is_action_pressed('light_2'):
		owner.set_light_mask(2)


func _physics_process(delta) -> void:
	if not can_move or owner.is_paused:
		return

	dir.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	dir.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	
	owner.dir = dir
	
	if dir.x != 0:
		_last_dir.x = dir.x
		_last_dir.y = 0
	elif dir.y != 0:
		_last_dir.x = 0
		_last_dir.y = dir.y
	
	if not owner.is_out:
		owner.move_and_collide(dir * _calc_speed * delta)
	else:
		owner.move_and_collide(dir * _calc_speed * 2 * delta)

	if dir != Vector2(0,0) and not owner.is_moving:
		_state_machine.transition_to_state(_state_machine.states.RUN)
		owner.update_camera_limits()
	elif dir == Vector2(0,0) and owner.is_moving:
		_state_machine.transition_to_state(_state_machine.states.IDLE)
