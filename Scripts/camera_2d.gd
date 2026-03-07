extends Camera2D

@export_group("Zoom Settings")
@export var zoom_speed := 0.1
@export var min_zoom := 0.5
@export var max_zoom := 5.0
@export var zoom_lerp_speed := 10.0

@export_group("Pan Settings")
@export var drag_sensitivity := 1.0

# Internal state
var target_zoom := Vector2.ONE
var is_dragging := false

# Reference to simulation for bounds calculation
@onready var sim = $"../Simulation" 
@onready var grid_position = $"../UI".get_child(1)

func _ready() -> void:
	target_zoom = zoom
	_setup_bounds()

func _setup_bounds() -> void:
	# Calculate world size from simulation parameters 
	var world_w = sim.grid_width * sim.cell_size 
	var world_h = sim.grid_height * sim.cell_size 
	
	# Set camera limits to prevent seeing outside the grid 
	limit_left = -sim.cell_size
	limit_top = -sim.cell_size
	limit_right = world_w + sim.cell_size
	limit_bottom = world_h + sim.cell_size
	
	# Calculate zoom needed to fit the world
	var viewport_size = get_viewport_rect().size
	
	var zoom_x = viewport_size.x / world_w
	var zoom_y = viewport_size.y / world_h
	
	min_zoom = min(zoom_x, zoom_y)
	position_smoothing_speed = sim.cell_size

func _input(event: InputEvent) -> void:
	# 1. Zoom Logic (Scroll Wheel)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_camera(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_camera(-1)
		
		#ignored when hover over ui
		if get_viewport().gui_get_hovered_control() != null:
			return
		
		# 2. Drag Start/Stop
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed

	# 3. Pan Logic (Mouse Motion)
	if event is InputEventMouseMotion and is_dragging:
		# Adjust pan speed based on zoom level so it feels consistent
		position -= event.relative / zoom.x * drag_sensitivity

func _process(delta: float) -> void:
	# Smoothly interpolate zoom
	zoom = zoom.lerp(target_zoom, zoom_lerp_speed * delta)
	grid_position.text = str("X: ", mouse_to_grid().x, "  Y: ", mouse_to_grid().y)

func _zoom_camera(direction: int) -> void:
	var old_zoom = target_zoom
	var zoom_change = 1.0 + (zoom_speed * direction)
	
	target_zoom *= zoom_change
	target_zoom = target_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	
	# Zoom centered on mouse position
	var mouse_pos = get_local_mouse_position()
	var zoom_factor = target_zoom.x / old_zoom.x
	position += mouse_pos * (1.0 - 1.0/zoom_factor)

# Utility function for interaction
func mouse_to_grid() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	return Vector2i(floor(mouse_pos.x / sim.cell_size), floor(mouse_pos.y / sim.cell_size))
