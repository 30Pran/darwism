extends CanvasLayer

@onready var icons := [$optbutton, $panels/sim_panel/VBoxContainer/reload]

@onready var fps_label = $FPS
@onready var grid_position = $position

@onready var grid_drawer = $"../GridDrawer"
@onready var cam = $"../Camera2D"
@onready var sim = $"../Simulation"

@onready var opt_btn = $optbutton
@onready var opt_panel = $optpanel
@onready var panels = [$panels/sim_panel, $panels/pref_panel, $panels/cam_panel]

@onready var set_zoom_speed = $panels/cam_panel/VBoxContainer/set_zoom_speed
@onready var set_drag_speed = $panels/cam_panel/VBoxContainer/set_drag_speed
@onready var grid_visible = $panels/pref_panel/VBoxContainer/HBoxContainer5/CheckButton

var current_tab: Control = null
var opt_opened := false

func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())
	var grid = cam.mouse_to_grid()
	grid_position.text = "X: %s  Y: %s" % [grid.x, grid.y]

	$Label.text = str(sim.social_force)

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

func _on_set_zoom_speed_drag_ended(_value_changed: bool) -> void:
	cam.zoom_speed = set_zoom_speed.value

func _on_set_drag_speed_drag_ended(_value_changed: bool) -> void:
	cam.drag_sensitivity = set_drag_speed.value

func _on_check_button_toggled(toggled_on: bool) -> void:
	grid_drawer.visible = toggled_on


func _on_agent_color_picker_button_color_changed(color: Color) -> void:
	sim.agent_color= color


func _on_grid_color_picker_button_color_changed(color: Color) -> void:
	grid_drawer.color = color
	grid_drawer.queue_redraw()


func _on_bg_color_picker_button_color_changed(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)


func _on_ui_color_picker_button_color_changed(color: Color) -> void:
	
	apply_ui_color(self, color)
	
	for node in icons:
		node.add_theme_color_override("icon_normal_color", color)

func apply_ui_color(node: Node, color: Color):
	if node is Label or node is Button:
		node.add_theme_color_override("font_color", color)
	elif node is HSeparator:
		var style = node.get_theme_stylebox("separator")
		style.color = color

	for child in node.get_children():
		apply_ui_color(child, color)


func _on_agent_count_spin_box_value_changed(value: int) -> void:
	sim.initial_agent_count = value
	sim.rebuild_simulation()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_up"):
		sim.social_force += 1
	if Input.is_action_just_pressed("ui_down"):
		sim.social_force -= 1


func _on_tick_rate_spin_box_value_changed(value: int) -> void:
	sim.tick_rate = value
	sim.update_tick_timing()


func _on_grid_height_spin_box_value_changed(value: int) -> void:
	sim.grid_height = value
	sim.rebuild_simulation()

func _on_grid_width_spin_box_value_changed(value: float) -> void:
	sim.grid_width = value
	sim.rebuild_simulation()
