class_name Autofill
extends Label
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
signal fill_done

export var animation_time := 0.01
export var character_speed := 2
export var animate_on_set_text := true
export var typing := true
export var disappear_wait := 3.0
export var can_autohide := true

var center := 160

var _current_disappear: = 0.0
var _chars: = []
var _count: = 0
var _text: String
var _forced_update := false
var _is_disappearing := false
var _time_to_dissapear := 0.0
var _config := {
	default = {
		max_width = 300.0,
		center = 160,
		stylebox = preload('res://src/GUI/Dialog/TalkingBubbleNormal.tres')
	},
	mamais = {
		max_width = 360.0,
		center = 284,
		stylebox = preload('res://src/GUI/Dialog/TalkingBubbleMamais.tres')
	}
}

onready var default_position = get_position()
onready var default_size = get_size()
onready var max_width: float = _config.default.max_width
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	hide()
	
	if not can_autohide:
		_current_disappear = -1.0

	$Timer.set_wait_time(animation_time)
	$Timer.connect('timeout', self, '_write_character')


func _process(delta: float) -> void:
	if _forced_update:
		_forced_update = false
		rect_position.x = center - (rect_size.x / 2)

	if _is_disappearing:
		_time_to_dissapear -= delta
		if _time_to_dissapear < 0:
			_hide_and_emit()
	
	if rect_size.x > max_width:
		rect_size.x = max_width
		autowrap = true
		rect_position.x = center - (max_width / 2)


func start_animation():
	if not is_inside_tree(): return
	if has_node('Timer'): $Timer.start()
	typing = true


func set_text(text):
	set_defaults()

	if text != '':
		_text = text
		if animate_on_set_text:
			start_animation()
		else:
			.set_text(text)
	else:
		_text = ''
		_count = 0
		_current_disappear = 0.0
		_is_disappearing = false
		_time_to_dissapear = 0.0
		self.rect_size = default_size
		self.rect_position = default_position

		hide()


func set_defaults():
	self.text = ''
	rect_size = default_size
	_is_disappearing = false
	_time_to_dissapear = 0.0

	$Timer.stop()


func stop(auto_complete: bool = true) -> void:
	# Ignorar el skip si el texto ya está en su estado final
	if not visible: return

	if text == _text:
		_hide_and_emit()
		return

	if auto_complete:
		text = _text
		_forced_update = true

	_finish()
	_disappear()


func set_disappear_time(time := 0.0) -> void:
	_current_disappear = time


func set_text_color(color: Color) -> void:
	add_color_override("font_color", color)


func finish_and_hide() -> void:
	_finish()
	_hide()

func update_defaults(character_name := '') -> void:
	if _config.has(character_name):
		max_width = _config[character_name].max_width
		center = _config[character_name].center
		self.add_stylebox_override(
			'normal',
			_config[character_name].stylebox
		)
	else:
		max_width = _config.default.max_width
		center = _config.default.center
		self.add_stylebox_override(
			'normal',
			_config.default.stylebox
		)


func _write_character():
	SoundManager.play_se('ui_write')
	if text.length() < _text.length():
		text += _text[_count]
		_count += 1
		# Reposicionar el elemento porque el texto va creciendo
		rect_position.x = center - (rect_size.x / 2)
	else:
		# El texto ya tiene todos los caracteres
		_finish()
		_disappear()


# Detiene el temporizador y resetea el contador de caracteres escritos a cero
# pues el texto ya se está mostrando completo.
func _finish() -> void:
	_count = 0
	$Timer.stop()

	if typing:
		typing = false


func _disappear(forced_wait := 0.0) -> void:
	if _current_disappear > 0:
		_time_to_dissapear = _current_disappear
	elif _current_disappear == 0.0:
		_time_to_dissapear = disappear_wait
	else:
		# El texto no desaparecerá sólo, sino que se espera una señal que lo
		# haga desaparecer
		HudEvent.emit_signal('continue_requested')
		return

	_is_disappearing = true


func _hide() -> void:
	set_text('')


func _hide_and_emit() -> void:
	if visible and not typing:
		_hide()
		emit_signal('fill_done')
