extends Node2D

export(String, FILE, "*.tscn") var next_scene: String
export(String) var world_name = 'WORLD'

onready var _player: Player = find_node('Player')


func _ready() -> void:
	# Establecer valores por defecto
	WorldEvent.emit_signal('world_entered')
	
	yield(get_tree().create_timer(0.5), 'timeout')
	_player.show()
	_player.set_light_mask()
	$Tracks.spread_constellations(_get_shuffled_constellations())


func _get_shuffled_constellations() -> Array:
	randomize()
	var constellations := $Constellations.get_children()
	constellations.shuffle()
	
	for c in $Constellations.get_children():
		$Constellations.remove_child(c)

	return constellations
