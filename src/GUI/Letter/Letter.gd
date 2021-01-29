extends Control

export var dialog_on_close := ''
export var opcl_sfx_key := ''

var _spanish_text := ''
var _english_text := ''
var _in_spanish := true

func _ready() -> void:	
	self.connect('visibility_changed', self, '_play_animation')
	$Overlay.connect('gui_input', self, '_on_gui_input')
	$EnglishButton.connect('pressed', self, '_toggle_language')


func _toggle_language() -> void:
	_in_spanish = !_in_spanish
#	$TextWrapper/Label.text = _spanish_text if _in_spanish else _english_text
	TranslationServer.set_locale('es' if _in_spanish else 'en')


func _on_gui_input(event: InputEvent) -> void:
	var mouse_event: = event as InputEventMouseButton
	if mouse_event \
		and mouse_event.button_index == BUTTON_LEFT \
		and mouse_event.pressed:
			TranslationServer.set_locale('es')
			$AnimationPlayer.play('show', -1.0, -2.0, true)
			SoundManager.play_se('ui_popup_close')
			SoundManager.play_se('sfx_' + opcl_sfx_key + '_open')
			yield($AnimationPlayer, 'animation_finished')
			hide()


func _play_animation() -> void:
	if visible:
		$AnimationPlayer.play('show')
		SoundManager.play_se('ui_popup_open')
		SoundManager.play_se('sfx_' + opcl_sfx_key + '_close')
	else:
		DialogEvent.emit_signal('dialog_requested', dialog_on_close)
