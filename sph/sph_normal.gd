extends Node2D


# constants
var G = Vector2(0, 10)
var REST_DENS = 300.0
var GAS_CONST = 2000.0
var H = 16.0
var HSQ = H * H
var MASS = 10
var VISC = 200.0
var DT = 0.0007
var POLY6 = 4.0 / (PI * pow(H, 8.0))
var SPIKY_GRAD = -10.0 / (PI * pow(H, 5.0))
var VISC_LAP = 40.0 / (PI * pow(H, 5.0))
var EPS = H
var BOUND_DAMPING = -0.5
var MAX_PARTICLES = 1000
var DAM_PARTICLES = 50
var BLOCK_PARTICLES = 50
var VIEW_WIDTH = 525
var VIEW_HEIGHT = 750

# to count frames fancy
var frame_time_accum = 0.0
var frame_count = 0
var fps = 0

# pausing simulation
var paused: bool = false

# actually fked up and didn't deliver
var metaball_texture: Texture2D


class FluidParticle:
	var x: Vector2
	var v: Vector2 = Vector2.ZERO
	var f: Vector2 = Vector2.ZERO
	var rho: float = 0.0
	var p: float = 0.0
	
	func _init(_x: float, _y: float):
		x = Vector2(_x, _y)


var particles: Array[FluidParticle] = []


func _ready():
	var img = Image.new()
	var err = img.load("res://assets/dot.png")
	if err != OK:
		print("ERR: failed to load image.")
	
	img.resize(16, 16, Image.INTERPOLATE_NEAREST)
	metaball_texture = ImageTexture.create_from_image(img)
	
	init_sph()
	set_process(true)
	print("Press SPACE to add particles, R to reset, SHIFT to pause.")

func _process(_delta):
	for _i in range(5):
		update_sph()
	
	frame_time_accum += _delta
	frame_count += 1
	
	if frame_time_accum >= 1.0:
		fps = frame_count
		frame_count = 0
		frame_time_accum = 0.0
	
	queue_redraw()


func init_sph():
	particles.clear()
	var count = 0
	var y = EPS
	while y < VIEW_HEIGHT - 2.0 * EPS:
		var x = VIEW_WIDTH / 4.0
		while x < VIEW_WIDTH / 2.0:
			if count < DAM_PARTICLES:
				var jitter = randf()
				particles.append(FluidParticle.new(x + jitter, y))
				count += 1
			else:
				return
			x += H
		y += H

func compute_density_pressure():
	for pi in particles:
		pi.rho = 0.0
		for pj in particles:
			var rij = pj.x - pi.x
			var r2 = rij.length_squared()
			if r2 < HSQ:
				pi.rho += MASS * POLY6 * pow(HSQ - r2, 3.0)
		pi.p = GAS_CONST * (pi.rho - REST_DENS)

func compute_forces():
	for pi in particles:
		var fpress = Vector2.ZERO
		var fvisc = Vector2.ZERO
		for pj in particles:
			if pi == pj:
				continue
			var rij = pj.x - pi.x
			var r = rij.length()
			if r < H:
				fpress += -rij.normalized() * MASS * (pi.p + pj.p) / (2.0 * pj.rho) * SPIKY_GRAD * pow(H - r, 3.0)
				fvisc += VISC * MASS * (pj.v - pi.v) / pj.rho * VISC_LAP * (H - r)
		var fgrav = G * MASS / pi.rho
		pi.f = fpress + fvisc + fgrav

func integrate():
	for p in particles:
		p.v += DT * p.f / p.rho
		p.x += DT * p.v
	
		if p.x.x - EPS < 0.0:
			p.v.x *= BOUND_DAMPING
			p.x.x = EPS
		if p.x.x + EPS > VIEW_WIDTH:
			p.v.x *= BOUND_DAMPING
			p.x.x = VIEW_WIDTH - EPS
		if p.x.y - EPS < 0.0:
			p.v.y *= BOUND_DAMPING
			p.x.y = EPS
		if p.x.y + EPS > VIEW_HEIGHT:
			p.v.y *= BOUND_DAMPING
			p.x.y = VIEW_HEIGHT - EPS

func update_sph():
	compute_density_pressure()
	compute_forces()
	integrate()


func _draw():
	draw_rect(Rect2(Vector2(5, 5), Vector2(VIEW_WIDTH-10, VIEW_HEIGHT-10)), Color(1,1,1), false)
	
	for p in particles:
		draw_circle(p.x, H / 4.0, Color(0.2, 0.6, 1.0))
		draw_texture(metaball_texture, p.x - metaball_texture.get_size() / 2)
	
	draw_string(
		ThemeDB.fallback_font,
		Vector2(10, 20),
		"FPS: %d" % fps,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16
	)


func add_particles():
	if particles.size() >= MAX_PARTICLES:
		print("Maximum number of particles reached.")
		return
	var placed = 0
	var center_x = VIEW_WIDTH / 2.0
	var center_y = VIEW_HEIGHT / 1.5
	var extent = VIEW_HEIGHT / 5.0
	var y = center_y - extent
	while y < center_y + extent:
		var x = center_x - extent
		while x < center_x + extent:
			if placed < BLOCK_PARTICLES and particles.size() < MAX_PARTICLES:
				particles.append(FluidParticle.new(x, y))
				placed += 1
			x += H * 0.95
		y += H * 0.95

func pause_simulation():
	paused = !paused
	set_process(not paused)


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				add_particles()
			KEY_R:
				init_sph()
			KEY_SHIFT:
				pause_simulation()

func _on_window_normal_size_changed() -> void:
		var viewport_size = get_viewport_rect().size
		if viewport_size.x > 100 and viewport_size.y > 100:
			VIEW_WIDTH = viewport_size.x
			VIEW_HEIGHT = viewport_size.y
