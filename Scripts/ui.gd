extends CanvasLayer

@onready var ui_array := [
	$FPS, $position, $optbutton, $optpanel/HBoxContainer, 
	$optpanel/HBoxContainer/Simulation_setting, $optpanel/HBoxContainer/Preference_setting, 
	$optpanel/HBoxContainer/Camera_setting, $panels/pref_panel/VBoxContainer, $panels/pref_panel/VBoxContainer/pref_label, 
	$panels/pref_panel/VBoxContainer/HSeparator, $panels/pref_panel/VBoxContainer/HBoxContainer, 
	$panels/pref_panel/VBoxContainer/HBoxContainer/agent_label, $panels/pref_panel/VBoxContainer/HBoxContainer/agent_ColorPickerButton, 
	$panels/pref_panel/VBoxContainer/HBoxContainer5, $panels/pref_panel/VBoxContainer/HBoxContainer5/grid_visiibility_label, 
	$panels/pref_panel/VBoxContainer/HBoxContainer5/CheckButton, $panels/pref_panel/VBoxContainer/HBoxContainer2, 
	$panels/pref_panel/VBoxContainer/HBoxContainer2/grid_label, $panels/pref_panel/VBoxContainer/HBoxContainer2/grid_ColorPickerButton, 
	$panels/pref_panel/VBoxContainer/HBoxContainer3, $panels/pref_panel/VBoxContainer/HBoxContainer3/ui_label, 
	$panels/pref_panel/VBoxContainer/HBoxContainer3/ui_ColorPickerButton, $panels/pref_panel/VBoxContainer/HBoxContainer4, 
	$panels/pref_panel/VBoxContainer/HBoxContainer4/bg_label, $panels/pref_panel/VBoxContainer/HBoxContainer4/bg_ColorPickerButton, 
	$panels/cam_panel/VBoxContainer, $panels/cam_panel/VBoxContainer/cam_label, $panels/cam_panel/VBoxContainer/HSeparator, 
	$panels/cam_panel/VBoxContainer/zoom_label, $panels/cam_panel/VBoxContainer/set_zoom_speed, $panels/cam_panel/VBoxContainer/drag_label, 
	$panels/cam_panel/VBoxContainer/set_drag_speed, 
]

@onready var separator := [
	$panels/pref_panel/VBoxContainer/HSeparator, $panels/cam_panel/VBoxContainer/HSeparator
]

@onready var boxes := [
	$optpanel/HBoxContainer/Simulation_setting, $optpanel/HBoxContainer/Preference_setting,
	$optpanel/HBoxContainer/Camera_setting
]

@onready var icons := [
	$optbutton
]

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

func _on_check_button_toggled(_toggled_on: bool) -> void:
	grid_drawer.visible = !grid_drawer.visible


func _on_agent_color_picker_button_color_changed(color: Color) -> void:
	sim.agent_color= color


func _on_grid_color_picker_button_color_changed(color: Color) -> void:
	grid_drawer.color = color
	grid_drawer.queue_redraw()


func _on_bg_color_picker_button_color_changed(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)


func _on_ui_color_picker_button_color_changed(color: Color) -> void:
	
	var normal_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	var hover_style = StyleBoxFlat.new()
	
	var line_style = StyleBoxLine.new()
	
	normal_style.draw_center = false
	normal_style.border_color = color
	
	pressed_style.draw_center = false
	pressed_style.set_border_width_all(5)
	pressed_style.border_color = color
	pressed_style.shadow_color = Color.BLACK
	pressed_style.shadow_size = 10
	
	hover_style.draw_center = false
	hover_style.set_border_width_all(3)
	hover_style.border_color = color
	
	line_style.color = color
	line_style.thickness = 3
	
	for i in range(ui_array.size()):
		ui_array[i].add_theme_color_override("font_color", color)
	
	for i in range(separator.size()):
		separator[i].add_theme_stylebox_override("separator", line_style)
	
	for i in range(boxes.size()):
		boxes[i].add_theme_stylebox_override("normal", normal_style)
		boxes[i].add_theme_stylebox_override("pressed", pressed_style)
		boxes[i].add_theme_stylebox_override("hover", hover_style)
	
	for i in range(icons.size()):
		icons[i].add_theme_color_override("icon_normal_color", color)
