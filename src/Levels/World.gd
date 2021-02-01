extends Node2D

export(String, FILE, "*.tscn") var next_scene: String
export(String) var world_name = 'WORLD'
export var ignore_fade := false

onready var _player: Player = find_node('Player')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	WorldEvent.connect('timer_finished', self, '_check_lose')
	PlayerEvent.connect('game_won', self, '_stop_perro_timer')
	PlayerEvent.connect('capture_done', self, '_add_time')
	
	# Establecer valores por defecto
	WorldEvent.emit_signal('world_entered')
	
	yield(get_tree().create_timer(0.5), 'timeout')
	_player.show()

	var constellations := _get_shuffled_constellations()
	_assign_starting_light(constellations)
	$Routes.spread_constellations(constellations)
	
	WorldEvent.emit_signal('timer_requested')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _get_shuffled_constellations() -> Array:
	randomize()
	var constellations := $Constellations.get_children()
	constellations.shuffle()
	
	for c in $Constellations.get_children():
		$Constellations.remove_child(c)

	return constellations


# Le asigna al jugador la luz con la que iniciará su aventura
func _assign_starting_light(constellations: Array) -> void:
	var light_idx := randi() % constellations.size()
	_player.add_light((constellations[light_idx] as Constellation).linked_light)


func _check_lose() -> void:
	_player.is_paused = true
	WorldEvent.emit_signal('game_lost')


func _stop_perro_timer() -> void:
	AudioEvent.emit_signal('stop_requested', 'MX', 'InGame')
	AudioEvent.emit_signal('stop_requested', 'MX', 'Sagittarius')
	AudioEvent.emit_signal('stop_requested', 'MX', 'Cancer')
	AudioEvent.emit_signal('stop_requested', 'MX', 'Piscis')
	AudioEvent.emit_signal('stop_requested', 'BG', 'Gehena')
	WorldEvent.emit_signal('timer_stop_requested')


func _add_time(_constellation: Constellation) -> void:
	WorldEvent.emit_signal('timer_stop_requested')
	Data.data_sumi(Data.TIME_LEFT, 30)
