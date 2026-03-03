class_name Agent extends RefCounted

var grid_pos: Vector2i
var type: int
var energy: float

func _init(p: Vector2i, t: int, e: float):
	grid_pos = p
	type = t
	energy = e

# This is the "Brain" function
func get_move_decision() -> Vector2i:
	# For now, it just wanders, but later this will 
	# call your Boids/AI logic
	return _get_random_direction()

func _get_random_direction() -> Vector2i:
	var dirs = [
		Vector2i(1,0), Vector2i(-1,0), 
		Vector2i(0,1), Vector2i(0,-1),
		Vector2i(0,0) 
	]
	return dirs[randi() % dirs.size()]
