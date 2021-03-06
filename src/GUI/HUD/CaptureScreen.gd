extends PanelContainer

export var player_inventory: Resource

var _listening_input := false
var _captured_constellation := ''

onready var _close_btn: DefaultButton = find_node('Close')
onready var _card_texture: TextureRect = find_node('Card')
onready var _light_texture: TextureRect = find_node('WonLight')


func _ready() -> void:
	# Conectarse a eventos propios y de los hijos de satanas
	connect('gui_input', self, '_check_input_type')
	_close_btn.connect('pressed', self, '_close')
	
	# Conectarse a eventos del mundo pokémon
	PlayerEvent.connect('capture_done', self, '_show_captured_sign')
	GuiEvent.connect('NewGame', self, '_set_default_state')
	
	$DescriptionContainer.modulate.a = 0.0
	hide()


func _check_input_type(event: InputEvent) -> void:
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			_close()


func _show_captured_sign(constellation: Constellation) -> void:
	AudioEvent.emit_signal('play_requested', 'UI', 'Card_Show')
	_captured_constellation = constellation.name
	
	_card_texture.texture = constellation.card
	_light_texture.self_modulate = (constellation.hiding_light as Item).light_color
	
	show()
	$Tween.interpolate_property(
		$CardContainer, 'rect_position:y',
		500.0, 0.0,
		0.8, Tween.TRANS_BACK, Tween.EASE_OUT
	)
	
	# Toca así porque esto ocurre antes de que el nuevo bicho se añada al inventario
	if not (player_inventory as Inventory).current_size + 1 > (player_inventory as Inventory).max_size:
		$Tween.interpolate_property(
			$DescriptionContainer, 'modulate:a',
			0.0, 1.0,
			1.0, Tween.TRANS_BACK, Tween.EASE_OUT,
			0.8
		)
	$Tween.start()
	yield($Tween, 'tween_all_completed')
	_listening_input = true


func _close() -> void:
	AudioEvent.emit_signal('play_requested', 'UI', 'Card_Hide')
	if not _listening_input: return

	_listening_input = false
	$Tween.interpolate_property(
		$CardContainer, 'rect_position:y',
		0.0, 500.0,
		0.4, Tween.TRANS_BACK, Tween.EASE_IN
	)
	if $DescriptionContainer.modulate.a == 1.0:
		$Tween.interpolate_property(
			$DescriptionContainer, 'modulate:a',
			1.0, 0.0,
			0.3, Tween.TRANS_BACK, Tween.EASE_IN
		)
	$Tween.start()
	yield($Tween, 'tween_all_completed')

	AudioEvent.emit_signal('layer_requested', 'MX', _captured_constellation)
	HudEvent.emit_signal('capture_screen_closed')
	hide()


func _set_default_state() -> void:
	_listening_input = false
	_captured_constellation = ''
