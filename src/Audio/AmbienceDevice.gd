class_name AmbienceDevice
extends Node2D

enum AMBS {SIERRA, PINALITO, AFUERA}

export (AMBS) var ambience
export (float) var max_distance = 150
export (bool) var disabled = false

var listener
var current_amb
var active = false
var follow_player = false
var target_pos = Vector2.ZERO
var offset = Vector2.ZERO

func _ready():
	current_amb = ambience
	#Esto determina la maxima distancia en la que se va a activar el sonido
	$MaxDistance.connect('area_entered', self, '_on_area_entered')
	$MaxDistance.connect('area_exited', self, '_on_area_exited')

	#Esto determina el área donde el sonido estara centrado y con máximo volumen
	$AmbZone.connect('area_entered', self, 'position_bg', [true])
	$AmbZone.connect('area_exited', self, 'position_bg', [false])
	
	#TODO Determinar distancia de el falloff zone con respecto al AmbZone

	
func _process(delta):
	if follow_player:
#		if listener.global_position.x < $AmbZone/CollisionShape2D.shape.extents.x:
#			target_pos = listener.get_global_position()
#		else:
#			target_pos = listener.get_global_position() + Vector2(listener.global_position.distance_to($AmbZone.global_position) - $AmbZone/CollisionShape2D.shape.extents.x, 0)
		target_pos = listener.get_global_position()
		if target_pos.x > $AmbZone.global_position.x + $AmbZone/CollisionShape2D.shape.extents.x:
			offset.x = $AmbZone.global_position.x + $AmbZone/CollisionShape2D.shape.extents.x - listener.global_position.x
		elif target_pos.x < $AmbZone.global_position.x - $AmbZone/CollisionShape2D.shape.extents.x:
			offset.x = $AmbZone.global_position.x - $AmbZone/CollisionShape2D.shape.extents.x - listener.global_position.x
		if target_pos.y < $AmbZone.global_position.y - $AmbZone/CollisionShape2D.shape.extents.y:
			offset.y = $AmbZone.global_position.y - $AmbZone/CollisionShape2D.shape.extents.y - listener.global_position.y
		elif target_pos.y > $AmbZone.global_position.y + $AmbZone/CollisionShape2D.shape.extents.y:
			offset.y = $AmbZone.global_position.y + $AmbZone/CollisionShape2D.shape.extents.y - listener.global_position.y
		AudioEvent.emit_signal("position_amb", "BG", AMBS.keys()[current_amb].capitalize(), target_pos + offset, max_distance)

func _on_area_entered(other):
	if disabled:
		pass
	elif other.get_name() == 'PlayerArea':
		listener = other
		if not active:
			active = true
			AudioEvent.emit_signal("play_requested", "BG", AMBS.keys()[current_amb].capitalize())
			follow_player = true
			

func _on_area_exited(other):
	if other.get_name() == 'PlayerArea':
		follow_player = false
		listener = null
		if active:
			active = false
			AudioEvent.emit_signal("stop_requested", "BG", AMBS.keys()[current_amb].capitalize())

func position_bg(other, inside):
	if other.get_name() == 'PlayerArea':
		if inside:
#			follow_player = false
			AudioEvent.emit_signal("position_amb", "BG", AMBS.keys()[current_amb].capitalize(), $AmbZone.global_position, 1000)

