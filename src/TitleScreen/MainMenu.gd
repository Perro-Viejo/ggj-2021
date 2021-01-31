extends CanvasLayer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export (String, FILE, '*.tscn') var first_level: String
export var ignore_fade := false

var _is_credits := false

onready var _name_container: VBoxContainer = find_node('GameName')
onready var _buttons_container: VBoxContainer = find_node('ButtonsContainer')
onready var _new_game: Button = find_node('NewGame')
onready var _options: Button = find_node('Options')
onready var _credits_btn: Button = find_node('CreditsBtn')
onready var _exit: Button = find_node('Exit')
onready var _credits: MarginContainer = find_node('Credits')
onready var _credits_back: Button = _credits.find_node('Back')
onready var _devs: Label = find_node('Devs')
onready var _close_controls: Button = find_node('CloseControls')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready()->void:
	SectionEvent.MainMenu = true
	GUIManager.gui_collect_focusgroup()
	_credits.hide()
	

	if Settings.HTML5:
		_exit.visible = false

	# Conectarse a señales de los hijos
	_new_game.connect('pressed', self, '_show_controls')
	_options.connect('pressed', self, '_on_Options_pressed')
	_credits_btn.connect('pressed', self, '_on_Credits_pressed')
	_exit.connect('pressed', self, '_on_Exit_pressed')
	_close_controls.connect('pressed', self, '_go_to_world')

	# Conectarse a señales del universo pokémon
	Settings.connect('ReTranslate', self, '_retranslate') # Localización

#	_retranslate()


func _process(delta):
	$BG.visible = !SectionEvent.Options


func _exit_tree()->void:
#	AudioEvent.emit_signal("stop_requested", "MX", "Menu")
#	AudioEvent.emit_signal("play_requested", "MX", "inGame")
	SectionEvent.MainMenu = false				#switch bool for easier pause menu detection and more
	GUIManager.gui_collect_focusgroup()	#Force re-collect buttons because main meno wont be there


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _go_to_world()->void:
	$AnimationPlayer.play('go_to_world')
	AudioEvent.emit_signal('play_requested', 'MX', 'InGame')
	AudioEvent.emit_signal('play_requested', 'BG', 'Gehena')
	AudioEvent.emit_signal('play_requested', 'UI', 'Menu_Button')
	yield($AnimationPlayer, 'animation_finished')
	GuiEvent.emit_signal('NewGame')
	GuiEvent.emit_signal('ChangeScene', first_level)


func _on_Options_pressed()->void:
	SectionEvent.Options = true


func _on_Credits_pressed() -> void:
	AudioEvent.emit_signal('play_requested', 'UI', 'Gen_Button')
	_is_credits = !_is_credits
	if _is_credits:
		$AnimationPlayer.play('show_credits')
	else:
		$AnimationPlayer.play('credits_exit')
	yield($AnimationPlayer, 'animation_finished')
	if _is_credits:
		_credits_back.connect('pressed', self, '_on_Credits_pressed')
		if Data.get_data(Data.FORCE_FOCUS):
			_credits_back.grab_focus()
	else:
		_credits_back.disconnect('pressed', self, '_on_Credits_pressed')
		if Data.get_data(Data.FORCE_FOCUS):
			_credits_btn.grab_focus()


func _on_Exit_pressed()->void:
	GuiEvent.emit_signal('Exit')


func _play_sfx(key):
	pass
#	SoundManager.play_se(key)


func _start() -> void:
	yield(get_tree().create_timer(0.5), 'timeout')
	$AnimationPlayer.play('show_first_time')


func _retranslate()->void:
	_new_game.text = tr('NEW_GAME')
	_options.text = tr('OPTIONS')
	_credits_btn.text = tr('CREDITS')
	_exit.text = tr('EXIT')
	_credits_back.text = tr('BACK')


func _show_controls() -> void:
	$AnimationPlayer.play('show_controls')
