class_name Agent extends RefCounted

var grid_pos: Vector2i
var type: int
var energy: float

func _init(p: Vector2i, t: int, e: float):
	grid_pos = p #[cite: 1]
	type = t #[cite: 1]
	energy = e #[cite: 1]

# --- MAIN BRAIN ---

func get_move_decision(grid: Array, w: int, h: int, radius: int, force: float) -> Vector2i:
	# 1. Get positions of everyone nearby
	var neighbors = _scan_neighbors(grid, w, h, radius)
	
	# 2. If alone or no social drive, just wander
	if neighbors.is_empty() or is_equal_approx(force, 0.0):
		return _get_random_direction()
	
	# 3. Calculate where the group is pushing/pulling us
	var social_vector = _calculate_social_vector(neighbors, force)
	
	# 4. Convert that "feeling" into a grid step
	return _vector_to_grid_step(social_vector)

# --- HELPER FUNCTIONS ---

func _scan_neighbors(grid: Array, w: int, h: int, r: int) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	# Square radius scan
	for x in range(-r, r + 1):
		for y in range(-r, r + 1):
			if x == 0 and y == 0: continue # Skip self
			
			var target = grid_pos + Vector2i(x, y)
			# Boundary check
			if target.x >= 0 and target.x < w and target.y >= 0 and target.y < h:
				if grid[target.x][target.y] != -1:
					found.append(target)
	return found

func _calculate_social_vector(neighbors: Array[Vector2i], force: float) -> Vector2:
	var total_dir := Vector2.ZERO
	for n_pos in neighbors:
		# Vector pointing toward neighbor
		var diff = Vector2(n_pos - grid_pos)
		total_dir += diff.normalized()
	
	# Average and apply strength/direction (attract vs repel)
	return (total_dir / neighbors.size()) * force

func _vector_to_grid_step(vec: Vector2) -> Vector2i:
	# Avoid jitter: if the force is too weak, stay still
	if vec.length() < 0.2: 
		return Vector2i.ZERO
	
	# Clamp to 1 grid cell in any direction (-1, 0, or 1)
	return Vector2i(
		round(clamp(vec.x, -1, 1)),
		round(clamp(vec.y, -1, 1))
	)

func _get_random_direction() -> Vector2i:
	var dirs = [
		Vector2i(1,0), Vector2i(-1,0), 
		Vector2i(0,1), Vector2i(0,-1),
		Vector2i(0,0) 
	]
	return dirs[randi() % dirs.size()]
