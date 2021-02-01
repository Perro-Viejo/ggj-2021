class_name Inventory
extends Resource

# Si es -1 entonces el espacio del inventario es infinito
export var max_size := -1
export (Array, Resource) var default_items := []

var current_size := 0

var _inventory := {}

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func add_to_inventory(item) -> bool:
	if item.is_type("Item"):
		return _add_item_to_inventory(item)
	else:
		push_error("Object has to be or contain an Item to be added to an inventory") 
	return false


func remove_from_inventory(item) -> bool:
	var is_item = item.is_type("Item")
	var contains_item = item.get_node("Item") != null
	
	if is_item or contains_item:
		return _remove_item_from_inventory(item)
	else:
		push_error("Object has to be or contain an Item to be removed from an inventory") 
	return false


func on_item_added(item) -> void:
	pass


func on_item_removed(item) -> void:
	pass


func has_item(item_id: int) -> bool:
	return item_id in _inventory


func set_default_items() -> void:
	#Toca revisar que si se carga los default items no recibe la canya
	if not default_items.empty():
		for i in default_items:
			_add_item_to_inventory(i)


func get_item(id: int) -> Item:
	var item: Item = null
	if has_item(id):
		item = _inventory[id][0]
	return item


func is_full() -> bool:
	return current_size == max_size


func clean() -> void:
	_inventory = {}
	current_size = 0


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _add_item_to_inventory(item: Item) -> bool:
	if max_size < 0 or current_size + 1 <= max_size:
		if not item.light_id in _inventory:
			_inventory[item.light_id] = [item]
		item.container = self
		current_size += 1
		on_item_added(item)
		return true
	return false


func _remove_item_from_inventory(item) -> bool:
	if item.light_id in _inventory:
		_inventory[item.light_id].erase(item)
		current_size -= 1
		
		if _inventory[item.light_id].empty():
			_inventory.erase(item.light_id)
		item.container = null
		on_item_removed(item)
		return true
	return false
