extends Node
class_name WaveFunctionCollapse

var grid

func _init():
	pass
	
func initialize(size: Vector2i, prototypes: Dictionary):
	grid = []
	for _y in range(size.y):
		var x = []
		for _x in range(size.x):
			x.append(prototypes.duplicate())
		grid.append(x)
	
func load_prototypes() -> Dictionary:
	var file = FileAccess.open("res://entities//dynamic//town_generator//prototypes.json", FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var result = JSON.parse_string(text)
	return result

func solve(size: Vector2i) -> Array:
	var prototypes = match_prototypes(permutate_prototypes(load_prototypes())) 
	initialize(size, prototypes)
	
	while not is_collapsed():
		var coords = get_min_entropy_coords()
		collapse_at(coords)
		print(coords)
		#propagate(coords)
		
	return grid
	
func is_collapsed() -> bool:
	var size = Vector2i(len(grid[0]), len([grid]))
	for y in size.y:
		for x in size.x:
			if (len(grid[y][x].keys()) != 0):
				return false
	return true
	
func get_min_entropy_coords() -> Vector2i:
	var size = Vector2i(len(grid[0]), len([grid]))
	var ent_min = 10 ** 9
	var pos_min = Vector2i(0, 0)
	for y in size.y:
		for x in size.x:
			if (len(grid[y][x].keys()) < ent_min):
				ent_min = len(grid[y][x].keys())
				pos_min = Vector2i(x, y)
#			fix equal cases
	return pos_min
	
func collapse_at(position: Vector2i):
	var random = RandomNumberGenerator.new()
	var cell = grid[position.y][position.x]
	var keys = cell.keys()
	var index = random.randi() % len(keys)
	grid[position.y][position.x] = {keys[index]: cell[keys[index]]}
	
func propagate(position: Vector2i):
	var stack = [position]
	while len(stack) > 0:
		print(stack)
		var curr = stack.pop_back()
		for d in valid_dirs(curr):
			var other = curr + d
			var other_prototypes = get_possibilities(other).duplicate()
			var neighbours = get_possible_neighbours(curr, d)
			if len(neighbours) == 0:
				continue
			for other_prototype in other_prototypes:
				if not other_prototype in neighbours:
					constrain(other, other_prototype)
					if not other in stack:
						stack.append(other)
	
func valid_dirs(position: Vector2i) -> Array:
	var directions = []
	var size = Vector2i(len(grid[0]), len([grid]))
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var new = position + offset
		var border = new.x < 0 or new.x >= size.x or new.y < 0 or new.y >= size.y
		var collapsed = len(grid[new.y][new.x].values()) == 1
		if (not collapsed and not border):
			directions.append(offset)
	return directions
	
func get_possibilities(position: Vector2i):
	return grid[position.y][position.x]
	
func get_possible_neighbours(current: Vector2i, offset: Vector2i) -> Array:
	var key = null
	match offset:
		Vector2i(0, 1):
			key = "z_pos"
		Vector2i(0, -1):
			key = "z_neg"
		Vector2i(1, 0):
			key = "x_pos"
		Vector2i(-1, 0):
			key = "x_neg"
	var neighbours = []
	var cell = grid[current.y][current.x]
	for prototype in cell:
		for neighbour in cell[prototype].neighbours[key]:
			if neighbour not in neighbours:
				neighbours.append(neighbour)
	return neighbours
	
func constrain(position: Vector2i, key: String):
	grid[position.y][position.x].erase(key)
	
func match_prototypes(prototypes: Dictionary) -> Dictionary:
	var result = {}
	for this in prototypes:
		var neighbours = {"z_neg": [], "z_pos": [], "x_pos": [], "x_neg": []}
		for other in prototypes:
			if (prototypes[this].slots.z_pos == prototypes[other].slots.z_neg):
				neighbours.z_pos.append(other)
			if (prototypes[this].slots.z_neg == prototypes[other].slots.z_pos):
				neighbours.z_neg.append(other)
			if (prototypes[this].slots.x_pos == prototypes[other].slots.x_neg):
				neighbours.x_pos.append(other)
			if (prototypes[this].slots.x_neg == prototypes[other].slots.x_pos):
				neighbours.x_neg.append(other)
		result.set(this, {})
		result[this].set("rotation", prototypes[this].rotation)
		result[this].set("neighbours", neighbours)
	return result
	
func rotate_values(obj: Dictionary, shift: int) -> Dictionary:
	var keys = obj.keys()
	var values = obj.values()
	var n = keys.size()
	var result = {}
	if n == 0:
		return result
	for i in n:
		result[keys[i]] = values[(i + shift) % n]
	return result
	
func permutate_prototypes(prototypes: Dictionary) -> Dictionary:
	var result = {}
	for p in prototypes:
		var slots = prototypes[p].slots.values()
		var shifts = [0, 1, 2, 3]
		#if (slots[0] == slots[1] and slots[1] == slots[2] and slots[2] == slots[3]):
			#shifts = [0]
		#if (slots[0] == slots[2] and slots[1] == slots[3] and slots[0] != slots[1]):
			#shifts = [0, 1]
		for shift in shifts:
			var obj = prototypes[p].duplicate()
			obj.set("name", p)
			obj.set("rotation", shift)
			obj.set("slots", rotate_values(obj.slots, shift))
			result.set(p + "_" + str(shift), obj)
	return result
