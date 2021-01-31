extends MarginContainer

export var active := true
export(String, 'Forward', 'Backwards') var direction := 'Backwards'
export var time_left := 0

var min_time
var elapsed_time := 0

onready var _timer := $Timer
onready var _tween := $Tween
onready var _time_label := $PanelContainer/TimeLeft
onready var _timer_title := $PanelContainer/Title


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	_timer.connect('timeout', self, 'set_current_time')

	GuiEvent.connect('Paused', self, '_toggle_timer')
	WorldEvent.connect('timer_requested', self, 'start_timer')
	WorldEvent.connect('timer_stop_requested', self, 'stop_timer')

	_setup_timer()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func set_current_time():
	if direction == 'Backwards':
		time_left -= 1
		_time_label.set_text("%02d:%02d" % [time_left / 60, time_left % 60])
		Data.set_data(Data.TIME_LEFT, time_left)
		if visible:
			if time_left <= min_time:
				_tween.interpolate_property(
					_time_label,
					'self_modulate:a',
					1, 0.5,
					Tween.TRANS_SINE,
					Tween.EASE_IN_OUT
				)
			_tween.set_repeat(true)
			_tween.start()
		if time_left < 0:
			WorldEvent.emit_signal('timer_finished')
			if visible:
				_tween.stop_all()
			stop_timer()
	else:
		elapsed_time += 1
		Data.set_data('ElapsedTime', elapsed_time)
		_time_label.set_text("%02d:%02d" % [elapsed_time / 60,elapsed_time % 60])


func start_timer(new_time_left := 0):
	if new_time_left > 0:
		time_left = new_time_left
		_setup_timer()
	_timer.start()


func stop_timer():
	if not _timer.is_stopped():
		_timer.stop()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _toggle_timer(pause: bool) -> void:
	_timer.paused = pause


func _setup_timer() -> void:
	if direction == 'Backwards':
		Data.set_data(Data.TIME_LEFT, time_left)
		if visible:
			_time_label.set_text("%02d:%02d" % [time_left / 60,time_left % 60])
			_timer_title.set_text('GUI_TIME_LEFT')
		min_time = time_left * 0.2
	else:
		Data.set_data('ElapsedTime', 0)
		_time_label.set_text("%02d:%02d" % [00,00])
		_timer_title.set_text('GUI_TIME_ELAPSED')

	if active:
		start_timer()
