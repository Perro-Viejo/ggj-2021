extends "res://src/StateMachine/State.gd"


func _ready() -> void:
	pass


func enter(msg: Dictionary = {}) -> void:
	owner.play_animation('run')
	.enter(msg)


func exit() -> void:
	.exit()
