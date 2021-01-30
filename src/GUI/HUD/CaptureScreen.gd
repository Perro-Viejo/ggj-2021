extends PanelContainer

var _listening_input := false

onready var _close_btn: DefaultButton = find_node('Close')


func _ready() -> void:
	# Conectarse a eventos propios y de los hijos de satanas
	connect('gui_input', self, '_check_input_type')
	_close_btn.connect('pressed', self, '_close')
	
	# Conectarse a eventos del mundo pokémon
	PlayerEvent.connect('capture_done', self, '_show_captured_sign')
	
	hide()


func _check_input_type(event: InputEvent) -> void:
	if not _listening_input: return
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			_close()


func _show_captured_sign(target: Node2D) -> void:
	show()
	# TODO: Disparar alguna animación que muestre la carta así bien lindo
	yield(get_tree().create_timer(2.0), 'timeout')
	_listening_input = true


func _close() -> void:
	HudEvent.emit_signal('capture_screen_closed')
	hide()
