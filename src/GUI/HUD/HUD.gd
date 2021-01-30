class_name Hud
extends CanvasLayer

var world_entered: bool = false

onready var _dialog: Dialog = find_node('Dialog')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	$Control.hide()

	# Conectarse a los eventos del señor
	WorldEvent.connect('world_entered', self, '_on_world_entered')
	DialogEvent.connect('dialog_finished', self, '_post_dialog_action')


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_accept'):
		HudEvent.emit_signal('hud_accept_pressed')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _on_world_entered():
	world_entered = true
	$Control.show()


func _post_dialog_action(dialog_name: String) -> void:
	pass


# Temporary function for testing the changes to the SoundManager ---------------
func _on_Button_pressed():
	SoundManager.play_se('spec_horse')
# ------------------------------------------------------------------------------
