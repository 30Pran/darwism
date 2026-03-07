extends Node2D

@export_group("Grid Settings")
@export var grid_width := 192
@export var grid_height := 108
@export var cell_size := 10

@export_group("Simulation Settings")
@export var initial_agent_count := 1000
@export var tick_rate := 20.0 

var grid := []
var agents: Array[Agent] = [] # Typed array for performance

var tick_timer := 0.0
var time_between_ticks := 0.0

@onready var renderer: MultiMeshInstance2D = $"../AgentsRenderer"
@onready var grid_drawer := $"../GridDrawer"

func _ready() -> void:
	time_between_ticks = 1.0 / tick_rate
	
	grid.resize(grid_width)
	for x in range(grid_width):
		var column = []
		column.resize(grid_height)
		column.fill(-1) 
		grid[x] = column
	
	#Pass the parameters to the drawer
	grid_drawer.setup(grid_width, grid_height, cell_size)

	spawn_initial_agents()
	setup_multimesh()
	update_renderer()

func _process(delta: float):
	tick_timer += delta
	if tick_timer >= time_between_ticks:
		tick_timer = 0.0
		# $"../../FPS".text = str(Engine.get_frames_per_second()) # Keep if needed
		simulation_step()
		update_renderer()

func spawn_initial_agents():
	var spawned = 0
	while spawned < min(initial_agent_count, (grid_width * grid_height)):
		var rx = randi() % grid_width
		var ry = randi() % grid_height
		
		if grid[rx][ry] == -1:
			# Create a new instance of the Agent class
			var new_agent = Agent.new(Vector2i(rx, ry), 0, 100.0)
			
			agents.append(new_agent)
			grid[rx][ry] = agents.size() - 1
			spawned += 1

func setup_multimesh():
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	var qm := QuadMesh.new()
	qm.size = Vector2(cell_size, cell_size) 
	mm.mesh = qm
	mm.instance_count = agents.size()
	renderer.multimesh = mm

func update_renderer():
	var mm : MultiMesh = renderer.multimesh
	var offset = Vector2(cell_size / 2.0, cell_size / 2.0)
	
	for i in agents.size():
		var agent = agents[i] # Accessing the class object
		var screen_pos = (Vector2(agent.grid_pos) * cell_size) + offset
		var transform2d := Transform2D(0, screen_pos)
		mm.set_instance_transform_2d(i, transform2d)

func simulation_step():
	# 1. Decision Phase: Ask all agents where they WANT to go
	# We store the results in an array of Vector2i targets
	var intended_targets: Array[Vector2i] = []
	intended_targets.resize(agents.size())
	
	for i in agents.size():
		var agent = agents[i]
		var dir = agent.get_move_decision() # [cite: 8]
		intended_targets[i] = agent.grid_pos + dir # 

	# 2. Resolution Phase: Execute moves if they are valid in the CURRENT grid
	for i in agents.size():
		var agent = agents[i]
		var current_pos = agent.grid_pos
		var target = intended_targets[i]
		
		# Boundary Check 
		if not is_inside_grid(target):
			continue
			
		# Occupancy Check 
		# Only move if the spot is empty and not the spot we are already in
		if target != current_pos and grid[target.x][target.y] == -1:
			# Update Logical Grid 
			grid[current_pos.x][current_pos.y] = -1
			grid[target.x][target.y] = i
			
			# Update Agent Data 
			agent.grid_pos = target

func is_inside_grid(p: Vector2i) -> bool:
	return p.x >= 0 and p.x < grid_width and p.y >= 0 and p.y < grid_height
