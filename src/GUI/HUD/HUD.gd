class_name Hud
extends CanvasLayer

export (String, FILE, "*.tscn") var main_menu: String

var world_entered: bool = false

onready var _dialog: Dialog = find_node('Dialog')
onready var _win_panel: Container = find_node('WinPanel')
onready var _lose_panel: Container = find_node('LosePanel')
onready var _main_menu_btn_container: Container = find_node('MainMenuBtnContainer')
onready var _main_menu_btn: Button = find_node('MainMenuBtn')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	_setup()


	# Conectarse a eventos de los hijos
	$Tween.connect('tween_all_completed', self, '_show_main_menu_btn')
	_main_menu_btn.connect('pressed', self, '_go_to_main_menu')

	# Conectarse a los eventos del señor
	WorldEvent.connect('world_entered', self, '_on_world_entered')
	DialogEvent.connect('dialog_finished', self, '_post_dialog_action')
	PlayerEvent.connect('game_won', self, '_show_win_panel')
	WorldEvent.connect('game_lost', self, '_show_lose_panel')


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
	pass
#	SoundManager.play_se('spec_horse')
# ------------------------------------------------------------------------------


func _show_win_panel() -> void:
	_win_panel.show()
	$Tween.interpolate_property(
		_win_panel, 'modulate:a',
		0.0, 1.0,
		1.0, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	$Tween.start()


func _show_lose_panel() -> void:
	AudioEvent.emit_signal('stop_requested', 'MX', 'InGame')
	AudioEvent.emit_signal('stop_requested', 'MX', 'Sagittarius')
	AudioEvent.emit_signal('stop_requested', 'MX', 'Cancer')
	AudioEvent.emit_signal('stop_requested', 'MX', 'Piscis')
	AudioEvent.emit_signal('stop_requested', 'BG', 'Gehena')
	_lose_panel.show()
	$Tween.interpolate_property(
		_lose_panel, 'modulate:a',
		0.0, 1.0,
		0.8, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	$Tween.start()


func _show_main_menu_btn() -> void:
	_main_menu_btn_container.show()


func _go_to_main_menu() -> void:
	_setup()
	GuiEvent.emit_signal('NewGame')
	GuiEvent.emit_signal('ChangeScene', main_menu)


func _setup() -> void:
	$Control.hide()
	_win_panel.hide()
	_lose_panel.hide()
	_main_menu_btn_container.hide()
	_win_panel.modulate.a = 0.0
	_lose_panel.modulate.a = 0.0
