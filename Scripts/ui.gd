extends CanvasLayer

@onready var opt_btn = $optbutton
@onready var opt_panel = $optpanel
@onready var panels = [$panels/sim_panel, $panels/pref_panel, $panels/cam_panel]

@onready var fps_label = $FPS
@onready var grid_position = $position
@onready var grid_drawer = $"../GridDrawer"
@onready var cam = $"../Camera2D"

var current_tab: Control = null
var opt_opened := false

func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())
	var grid = cam.mouse_to_grid()
	grid_position.text = "X: %s  Y: %s" % [grid.x, grid.y]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_grid"):
		grid_drawer.visible = !grid_drawer.visible

#Main Menu Logic

func _on_button_pressed() -> void:
	opt_opened = !opt_opened
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	
	if opt_opened:
		tween.tween_property(opt_panel, "position:y", 0, 0.15)
		tween.tween_property(opt_btn, "rotation", deg_to_rad(-90), 0.15)
	else:
		tween.tween_property(opt_panel, "position:y", -opt_panel.size.y, 0.15)
		tween.tween_property(opt_btn, "rotation", 0, 0.15)
		_close_active_tab(tween)

#Tab Management

func _on_simulation_setting_pressed() -> void: 
	_toggle_tab(panels[0])
func _on_preference_setting_pressed() -> void: 
	_toggle_tab(panels[1])
func _on_camera_setting_pressed() -> void: 
	_toggle_tab(panels[2])

func _toggle_tab(target_panel: Control) -> void:
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	
	if current_tab == target_panel:
		_close_active_tab(tween)
	else:
		_close_active_tab(tween)
		current_tab = target_panel
		tween.tween_property(current_tab, "position:x", 0, 0.15)

func _close_active_tab(tween: Tween) -> void:
	if current_tab:
		tween.tween_property(current_tab, "position:x", -current_tab.size.x, 0.15)
		current_tab = null
