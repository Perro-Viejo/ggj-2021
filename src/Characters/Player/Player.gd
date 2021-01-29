class_name Player
extends 'res://src/Characters/Actor.gd'

var node_to_interact: Pickable = null setget _set_node_to_interact
var grabbing: bool = false
var on_ground: bool = false
var foot = 'L'
var is_paused := false
var is_out: bool = false
var is_moving = false
var dir := Vector2.ZERO

onready var _light := $Light
onready var _light_mask := $Light/Mask


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	connect('input_event', self, '_move_camera')
	
	set_light_mask()


func _process(delta):
	look_at(get_global_mouse_position())


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func set_light_mask(id := 1) -> void:
	_light_mask.range_z_min = -1 * id
	_light_mask.range_z_max = -1 * id
	
	match id:
		1:
			_light.self_modulate = Color.red
		2:
			_light.self_modulate = Color.pink
	
	_light.self_modulate.a = 0.5


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _set_node_to_interact(new_node: Pickable) -> void:
	if node_to_interact:
		node_to_interact.hide_interaction()
	if new_node and new_node.is_in_group('Pickable'):
		new_node.show_interaction()

	node_to_interact = new_node


func _set_fishing(value: bool) -> void:
	$StateMachine.state.play_animation()


func _on_object_check(clickable: Clickable):
	if clickable.is_near_to(self.global_position):
		clickable.interact()
		var emotions = ['excited','happy','normal','surprised']
		SoundManager.play_se('dx_player_' + emotions[randi() % emotions.size()])
	else:
		speak('ta lejambres')


func _movement_changed(actor: Actor) -> void:
	if .is_moving():
		$StateMachine.transition_to_key('Move')
	else:
		$StateMachine.transition_to_key('Idle')
		PlayerEvent.emit_signal('movement_finished')
