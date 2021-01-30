extends Node2D

export(String, FILE, "*.tscn") var next_scene: String
export(String) var world_name = 'WORLD'

onready var _player: Player = find_node('Player')


func _ready() -> void:
	# Establecer valores por defecto
	WorldEvent.emit_signal('world_entered')
	_player.show()
	
	yield(get_tree().create_timer(0.5), 'timeout')
	_player.set_light_mask()
