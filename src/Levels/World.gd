extends Node2D

export(String, FILE, "*.tscn") var next_scene: String
export(String) var world_name = 'WORLD'

onready var _player: Player = find_node('Player')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	# Establecer valores por defecto
	WorldEvent.emit_signal('world_entered')
	
	yield(get_tree().create_timer(0.5), 'timeout')
	_player.show()

	var constellations := _get_shuffled_constellations()
	_assign_starting_light(constellations)
	$Routes.spread_constellations(constellations)


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
