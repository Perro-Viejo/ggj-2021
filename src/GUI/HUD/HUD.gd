class_name Hud
extends CanvasLayer

var world_entered: bool = false

onready var _dialog: Dialog = find_node('Dialog')
onready var _win_panel: Container = find_node('WinPanel')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	$Control.hide()
	_win_panel.modulate.a = 0.0

	# Conectarse a los eventos del señor
	WorldEvent.connect('world_entered', self, '_on_world_entered')
	DialogEvent.connect('dialog_finished', self, '_post_dialog_action')
	PlayerEvent.connect('game_won', self, '_show_win_panel')


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


func _show_win_panel() -> void:
	_win_panel.show()
	$Tween.interpolate_property(
		_win_panel, 'modulate:a',
		0.0, 1.0,
		10.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	$Tween.start()
