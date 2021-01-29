class_name State
extends Node2D
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

var _parent = null
var _last_dir := Vector2.ZERO

onready var has_animation: bool = has_node("AnimatedSprite")
onready var sprite: AnimatedSprite = $AnimatedSprite if has_animation else null
onready var _calc_speed: float = speed * 60
onready var _state_machine = _get_state_machine(self)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready() -> void:
	yield(owner, 'ready')
	_parent = get_parent().get_parent()
	visible = false
	play_animation()
	if listen_anim_frames:
		sprite.connect('frame_changed', self, '_on_frame_changed')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func unhandled_input(event: InputEvent) -> void:
	if owner.is_paused: return

	if event.is_action_pressed('light_1'):
		owner.set_light_mask(1)
	elif event.is_action_pressed('light_2'):
		owner.set_light_mask(2)


#	if event.is_action_pressed('Action'):
#		if owner.has_equiped():
#			match owner.current_tool:
#				owner.Tools.ROD:
#					# Inicia la pesca
#					_state_machine.transition_to_state(_state_machine.STATES.FISHPREPARE)
#		elif owner.node_to_interact and not owner.grabbing:
#			_state_machine.transition_to_state(_state_machine.STATES.GRAB)
#	elif event.is_action_pressed('Drop'):
#		if owner.node_to_interact:
#			if owner.grabbing:
#				_state_machine.transition_to_state(
#					_state_machine.STATES.DROP, { dir = _last_dir }
#				)
#			elif owner.node_to_interact.dialog:
#				DialogEvent.emit_signal('dialog_requested', owner.node_to_interact.dialog)
#	elif event.is_action_pressed('Equip') and not owner.grabbing:
#		if owner.has_equiped():
#			owner.current_tool = owner.Tools.NONE
#		else:
#			owner.current_tool = owner.Tools.ROD


func physics_process(delta) -> void:
	if not can_move or owner.is_paused:
		return

	dir.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	dir.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	
	owner.dir = dir
	
	if dir.x != 0:
		_last_dir.x = dir.x
		_last_dir.y = 0

#		owner.sprite.flip_h = dir.x < 0
#		owner.shadow.flip_h = owner.sprite.flip_h

	elif dir.y != 0:
		_last_dir.x = 0
		_last_dir.y = dir.y
	
	if not owner.is_out:
		owner.move_and_collide(dir * _calc_speed * delta)
	else:
		owner.move_and_collide(dir * _calc_speed * 2 * delta)
		
	if dir != Vector2(0,0) and not owner.is_moving:
		_state_machine.transition_to_state(_state_machine.STATES.WALK)
		owner.update_camera_limits()
	elif dir == Vector2(0,0) and owner.is_moving:
		_state_machine.transition_to_state(_state_machine.STATES.IDLE)


func enter(msg: Dictionary = {}) -> void:
	# print('%s enters %s' % [ owner.name, name ])
	visible = true
	play_animation()
	pass


func world_tick() -> void:
	pass


func exit() -> void:
	visible = false
	stop()


func play_animation() -> bool:
	return false


func stop() -> void:
	if has_node("AnimatedSprite"):
		sprite.stop()


func _get_state_machine(node: Node) -> Node:
	if node != null and not node.is_in_group('state_machine'):
		return _get_state_machine(node.get_parent())
	return node


func _on_frame_changed():
	pass
