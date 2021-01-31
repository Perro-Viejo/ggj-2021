extends PanelContainer

var _listening_input := false

onready var _close_btn: DefaultButton = find_node('Close')
onready var _card_texture: TextureRect = find_node('Card')


func _ready() -> void:
	# Conectarse a eventos propios y de los hijos de satanas
	connect('gui_input', self, '_check_input_type')
	_close_btn.connect('pressed', self, '_close')
	
	# Conectarse a eventos del mundo pokémon
	PlayerEvent.connect('capture_done', self, '_show_captured_sign')
	
	hide()


func _check_input_type(event: InputEvent) -> void:
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			_close()


func _show_captured_sign(constellation: Node2D) -> void:
	_card_texture.texture = (constellation as Constellation).card
	show()
	$Tween.interpolate_property(
		$CenterContainer, 'rect_position:y',
		$CenterContainer.rect_position.y + 500.0, $CenterContainer.rect_position.y,
		0.8, Tween.TRANS_BACK, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, 'tween_completed')
	_listening_input = true


func _close() -> void:
	if not _listening_input: return

	_listening_input = false
	$Tween.interpolate_property(
		$CenterContainer, 'rect_position:y',
		$CenterContainer.rect_position.y, $CenterContainer.rect_position.y + 500.0,
		0.4, Tween.TRANS_BACK, Tween.EASE_IN
	)
	$Tween.start()
	yield($Tween, 'tween_completed')

	HudEvent.emit_signal('capture_screen_closed')
	hide()
