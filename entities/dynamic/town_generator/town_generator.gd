@icon("./TownGenerator.png")
extends Node
class_name TownGenerator

@export_subgroup("Grid Maps")
@export var BUILDING_GRID_MAP : GridMap
@export var FLOOR_GRID_MAP : GridMap
@export var PROP_GRID_MAP : GridMap
@export_subgroup("Mesh libraries")
@export var BUILDING_MESH_LIBRARY : MeshLibrary
@export var FLOOR_MESH_LIBRARY : MeshLibrary
@export var PROP_MESH_LIBRARY : MeshLibrary
@export_subgroup("Parameters")
@export var SIZE : int

func _ready() -> void:
	var positions = BUILDING_GRID_MAP.get_used_cells() + FLOOR_GRID_MAP.get_used_cells()
	BUILDING_GRID_MAP.clear()
	FLOOR_GRID_MAP.clear()
	var random = RandomNumberGenerator.new()
	var n = get_item_count()
	for position in positions:
		var index = random.randi() % n
		set_cell(position, index)

func id_to_map(id: int) -> Array:
	var nb = BUILDING_MESH_LIBRARY.get_item_count()
	if (id == GridMap.INVALID_CELL_ITEM):
		return [id, 0]
	if (id < nb):
		return [id, BUILDING_GRID_MAP]
	else:
		return [id - nb, FLOOR_GRID_MAP]
		
func map_to_id(index: int, map: GridMap) -> int:
	var nb = BUILDING_MESH_LIBRARY.get_item_count()
	if (index == GridMap.INVALID_CELL_ITEM):
		return index
	if (map == BUILDING_GRID_MAP):
		return index
	else:
		return index + nb
	
func set_cell(position: Vector3i, id: int) -> void:
	var index_map = id_to_map(id)
	index_map[1].set_cell_item(position, index_map[0])
	
func get_item_count() -> int:
	return BUILDING_MESH_LIBRARY.get_item_count() + FLOOR_MESH_LIBRARY.get_item_count()
	
