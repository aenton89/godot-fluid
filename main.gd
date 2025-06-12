extends Node2D


var win_normal = preload("res://sph/window_normal.tscn")
var win_spatial = preload("res://sph/window_spatial_hash.tscn")

const VIEW_WIDTH = 525
const VIEW_HEIGHT = 750

enum WindowState {
	NORMAL,
	SPATIAL,
	BOTH
}

var inst_normal = null
var inst_spatial = null


func _ready():
	both_window_setup(WindowState.BOTH)
	button_setup()
	
	print("Press SPACE to add particles, R to reset, SHIFT to pause.")


func button_setup():
	var ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	var hbox = HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(300, 40)
	hbox.position = Vector2(10, 10)
	ui_layer.add_child(hbox)
	
	var btn_add = Button.new()
	btn_add.text = "Add Particles"
	btn_add.pressed.connect(_on_add_particles_pressed)
	hbox.add_child(btn_add)
	
	var btn_reset = Button.new()
	btn_reset.text = "Reset"
	btn_reset.pressed.connect(_on_reset_particles_pressed)
	hbox.add_child(btn_reset)
	
	var btn_restore = Button.new()
	btn_restore.text = "Restore Windows"
	btn_restore.pressed.connect(_on_restore_windows_pressed)
	hbox.add_child(btn_restore)
	
	var btn_hide_backgrounds = Button.new()
	btn_hide_backgrounds.text = "Hide Backgrounds"
	btn_hide_backgrounds.pressed.connect(_on_hide_backgrounds_pressed)
	hbox.add_child(btn_hide_backgrounds)
	
	var btn_pause = Button.new()
	btn_pause.text = "Pause Simulation"
	btn_pause.pressed.connect(_on_pause_simulation_pressed)
	hbox.add_child(btn_pause)


func both_window_setup(state: WindowState):
	# get_viewport().set_embedding_subwindows(false)
	
	if state == WindowState.NORMAL or state == WindowState.BOTH:
		inst_normal = win_normal.instantiate()
		add_child(inst_normal)
		inst_normal.handle_input_locally = true
		inst_normal.visible = true
		inst_normal.position = Vector2(50, 100)
		inst_normal.title = "Normal"
		inst_normal.size = Vector2(VIEW_WIDTH, VIEW_HEIGHT)
	
	if state == WindowState.SPATIAL or state == WindowState.BOTH:
		inst_spatial = win_spatial.instantiate()
		add_child(inst_spatial)
		inst_spatial.handle_input_locally = true
		inst_spatial.visible = true
		inst_spatial.position = Vector2(VIEW_WIDTH + 100, 100)
		inst_spatial.title = "Spatial Hash"
		inst_spatial.size = Vector2(VIEW_WIDTH, VIEW_HEIGHT)


func _on_add_particles_pressed():
	if inst_normal:
		var normal_child = inst_normal.get_node("SphNormal")
		if normal_child:
			normal_child.add_particles()
	if inst_spatial:
		var spatial_child = inst_spatial.get_node("SphSpatialHash")
		if spatial_child:
			spatial_child.add_particles()

func _on_reset_particles_pressed():
	if inst_normal:
		var normal_child = inst_normal.get_node("SphNormal")
		if normal_child:
			normal_child.init_sph()
	if inst_spatial:
		var spatial_child = inst_spatial.get_node("SphSpatialHash")
		if spatial_child:
			spatial_child.init_sph()

func _on_restore_windows_pressed():
	if !is_instance_valid(inst_normal):
		both_window_setup(WindowState.NORMAL)
	if !is_instance_valid(inst_spatial):
		both_window_setup(WindowState.SPATIAL)

func _on_hide_backgrounds_pressed():
	if inst_normal:
		var bg = inst_normal.get_node("Background")
		if bg:
			bg.visible = !bg.visible
	if inst_spatial:
		var bg = inst_spatial.get_node("Background")
		if bg:
			bg.visible = !bg.visible

func _on_pause_simulation_pressed():
	if inst_normal:
		var normal_child = inst_normal.get_node("SphNormal")
		if normal_child:
			normal_child.pause_simulation()
	if inst_spatial:
		var spatial_child = inst_spatial.get_node("SphSpatialHash")
		if spatial_child:
			spatial_child.pause_simulation()
