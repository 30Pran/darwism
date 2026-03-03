extends Node2D

@export var color := Color(0.0, 0.0, 0.0, 1.0) # Dark gray

var grid_width: int
var grid_height: int
var cell_size: int

# We call this from the Simulation script to pass the data
func setup(w: int, h: int, s: int):
	grid_width = w
	grid_height = h
	cell_size = s
	queue_redraw() # Tells Godot to run _draw()

func _draw():
	if grid_width == 0 or cell_size == 0:
		return

	# Draw Vertical Lines
	for x in range(grid_width + 1):
		var start = Vector2(x * cell_size, 0)
		var end = Vector2(x * cell_size, grid_height * cell_size)
		draw_line(start, end, color)

	# Draw Horizontal Lines
	for y in range(grid_height + 1):
		var start = Vector2(0, y * cell_size)
		var end = Vector2(grid_width * cell_size, y * cell_size)
		draw_line(start, end, color)
