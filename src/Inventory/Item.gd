class_name Item
extends Resource

const ITEM_TYPE = 'Item'

export var light_color := Color.white
export(int, LAYERS_2D_RENDER) var light_mask
export(int, 1, 14) var light_id := 0

var container = null


func is_type(type):
	return type == self.ITEM_TYPE or .is_type(type)


func get_type():
	return self.ITEM_TYPE


func activate() -> void:
	pass


func desactivate() -> void:
	pass
