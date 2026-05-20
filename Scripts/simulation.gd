extends Node2D

@export_group("Grid Settings")
@export var grid_width := 192
@export var grid_height := 108
@export var cell_size := 10

@export_group("Simulation Settings")
@export var initial_agent_count := 1000
@export var tick_rate : float = 20.0
@export var social_force := 0.0
@export var radius := 2

@onready var renderer: MultiMeshInstance2D = $"../AgentsRenderer"
@onready var grid_drawer := $"../GridDrawer"

var grid := []
var agents: Array[Agent] = []
var tick_timer := 0.0
var time_between_ticks := 0.0
var agent_color := Color8(0, 255, 255, 255)

func _ready() -> void:
	update_tick_timing()
	init_grid()           # Pre-allocate grid memory 
	setup_multimesh()     # Create the MultiMesh object once 
	rebuild_simulation()  # Initial population

func _process(delta: float):
	tick_timer += delta
	while tick_timer >= time_between_ticks:
		tick_timer -= time_between_ticks
		#tick_timer = 0.0
		simulation_step()
	update_renderer()

# --- INITIALIZATION FUNCTIONS ---

func update_tick_timing():
	time_between_ticks = 1.0 / tick_rate

func init_grid():
	grid.resize(grid_width)
	for x in range(grid_width):
		grid[x] = []
		grid[x].resize(grid_height)
		grid[x].fill(-1) # Fill once during init 

func setup_multimesh():
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	var qm := QuadMesh.new()
	qm.size = Vector2(cell_size, cell_size) 
	mm.mesh = qm
	renderer.multimesh = mm

# --- RUNTIME UPDATE FUNCTIONS ---

func clear_grid():
	# Use fast fill instead of recreating arrays 
	for x in range(grid_width):
		grid[x].fill(-1)

func rebuild_simulation():
	clear_grid()
	
	# Reuse the agents array memory [cite: 16]
	agents.resize(initial_agent_count)
	
	for i in range(initial_agent_count):
		var pos := _get_random_empty_pos()
		# Direct index assignment is faster than append() [cite: 16]
		agents[i] = Agent.new(pos, 0, 100.0)
		grid[pos.x][pos.y] = i
	
	# Only update instance count instead of recreating MultiMesh [cite: 16]
	renderer.multimesh.instance_count = agents.size()
	grid_drawer.setup(grid_width, grid_height, cell_size)
	update_renderer()

func _get_random_empty_pos() -> Vector2i:
	# Basic safety to prevent infinite loop if grid is full
	for attempt in range(100):
		var rx = randi() % grid_width
		var ry = randi() % grid_height
		if grid[rx][ry] == -1:
			return Vector2i(rx, ry)
	return Vector2i(0, 0)

# --- CORE LOGIC ---

func simulation_step():
	var size = agents.size()
	var intended_targets: Array[Vector2i] = []
	intended_targets.resize(size)
	
	# Phase 1: Decisions [cite: 17]
	for i in range(size):
		var agent = agents[i]
		var dir = agent.get_move_decision(grid, grid_width, grid_height, radius, social_force)

		intended_targets[i] = agents[i].grid_pos + dir

	# Phase 2: Resolution [cite: 18]
	for i in range(size):
		var agent = agents[i]
		var target = intended_targets[i]
		
		if is_inside_grid(target) and target != agent.grid_pos:
			if grid[target.x][target.y] == -1:
				grid[agent.grid_pos.x][agent.grid_pos.y] = -1
				grid[target.x][target.y] = i
				agent.grid_pos = target

func update_renderer():
	var mm : MultiMesh = renderer.multimesh
	var offset = Vector2.ONE * (cell_size / 2.0)
	
	# Fast loop using range() and pre-calculated transform components 
	for i in range(agents.size()):
		var agent = agents[i]
		var screen_pos = (Vector2(agent.grid_pos) * cell_size) + offset
		mm.set_instance_transform_2d(i, Transform2D(0, screen_pos))
		mm.set_instance_color(i, agent_color)

func is_inside_grid(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height
