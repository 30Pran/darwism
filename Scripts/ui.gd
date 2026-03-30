extends CanvasLayer

@onready var fpslabel := $FPS
@onready var grid_drawer := $"../GridDrawer"
@onready var grid_position = $"../UI".get_child(1)
@onready var cam := $"../Camera2D"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	fpslabel.text = str(Engine.get_frames_per_second())
	grid_position.text = str("X: ", cam.mouse_to_grid().x, "  Y: ", cam.mouse_to_grid().y)
	
func _input(event: InputEvent):
	if event.is_action_pressed("ui_focus_next"): # Usually the 'Tab' key
		grid_drawer.visible = !grid_drawer.visible
