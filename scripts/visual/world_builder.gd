class_name WorldBuilder
extends RefCounted
## Monta todo o visual do mapa a partir de data/maps/<id>.json: céu e luz,
## terreno, estrada de pedra, portal (entrada), castelo (saída), floresta,
## rochas, grama, montanhas e partículas no ar. Só visual: nada aqui afeta
## a lógica do jogo. Ver docs/art-direction.md e docs/systems/map.md.

var root: Node3D
var map_data: Dictionary
var rng := RandomNumberGenerator.new()
var _pts: Array = []          # rota em Vector2 (x, z)
var _half: Vector2            # metade da área jogável
var _road_w: float = 2.4
var _castle_pos: Vector2
var _portal_pos: Vector2


func build(p_root: Node3D, p_map: Dictionary) -> void:
	root = p_root
	map_data = p_map
	var sc: Dictionary = map_data.get("scenery", {})
	rng.seed = int(sc.get("seed", 1))
	for p in map_data.get("path", []):
		_pts.append(Vector2(float(p[0]), float(p[1])))
	var gs: Array = map_data.get("ground_size", [44, 32])
	_half = Vector2(float(gs[0]), float(gs[1])) / 2.0
	_road_w = float(map_data.get("path_width", 2.4))

	_environment()
	_terrain(sc)
	_road()
	if _pts.size() >= 2:
		_portal()
		_castle()
	_forest(sc)
	_rocks(sc)
	_grass(sc)
	_mountains(sc)
	_ambient_motes()


# --- Céu, luz e pós-processamento -------------------------------------------

func _environment() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-34, -48, 0)
	sun.light_color = Color(1.0, 0.80, 0.58)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	sun.shadow_blur = 1.5
	sun.directional_shadow_max_distance = 90.0
	root.add_child(sun)

	var moon := DirectionalLight3D.new()
	moon.name = "FillLight"
	moon.rotation_degrees = Vector3(-50, 130, 0)
	moon.light_color = Color(0.55, 0.62, 0.9)
	moon.light_energy = 0.3
	root.add_child(moon)

	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.09, 0.11, 0.24)
	sky_mat.sky_horizon_color = Color(0.66, 0.43, 0.36)
	sky_mat.sky_curve = 0.13
	sky_mat.ground_horizon_color = Color(0.30, 0.24, 0.25)
	sky_mat.ground_bottom_color = Color(0.05, 0.05, 0.07)
	sky_mat.sun_angle_max = 25.0
	var sky := Sky.new()
	sky.sky_material = sky_mat

	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.42
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.95
	e.ssao_enabled = true
	e.ssao_radius = 1.2
	e.ssao_intensity = 2.2
	e.glow_enabled = true
	e.glow_intensity = 0.9
	e.glow_bloom = 0.08
	e.glow_hdr_threshold = 0.9
	e.fog_enabled = true
	e.fog_mode = Environment.FOG_MODE_DEPTH
	e.fog_light_color = Color(0.36, 0.33, 0.45)
	e.fog_depth_begin = 45.0
	e.fog_depth_end = 150.0
	e.fog_sky_affect = 0.4
	e.adjustment_enabled = true
	e.adjustment_contrast = 1.08
	e.adjustment_saturation = 0.92
	var we := WorldEnvironment.new()
	we.environment = e
	root.add_child(we)


# --- Terreno e estrada ------------------------------------------------------

func _terrain(sc: Dictionary) -> void:
	var ts: Array = sc.get("terrain_size", [150, 120])
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	var plane := PlaneMesh.new()
	plane.size = Vector2(float(ts[0]), float(ts[1]))
	ground.mesh = plane
	ground.material_override = Art.grass()
	root.add_child(ground)


func _road() -> void:
	var dirt_w := _road_w + 1.0
	for i in range(_pts.size() - 1):
		var a := Vector3(_pts[i].x, 0.0, _pts[i].y)
		var b := Vector3(_pts[i + 1].x, 0.0, _pts[i + 1].y)
		var mid := (a + b) / 2.0
		var length := a.distance_to(b)
		var edge := Art.part(root, Art.box(Vector3(dirt_w, 0.04, length + dirt_w)), Art.dirt(), mid + Vector3.UP * 0.01)
		edge.look_at(b + Vector3.UP * 0.01, Vector3.UP)
		var road := Art.part(root, Art.box(Vector3(_road_w, 0.06, length + _road_w)), Art.cobble(), mid + Vector3.UP * 0.03)
		road.look_at(b + Vector3.UP * 0.03, Vector3.UP)
		# Pedras soltas nas bordas
		var dir := (b - a).normalized()
		var side := dir.cross(Vector3.UP)
		var n := int(length / 1.6)
		for k in n:
			var t := rng.randf()
			var s := 1.0 if rng.randf() < 0.5 else -1.0
			var pos := a + dir * (t * length) + side * s * (dirt_w / 2.0 + rng.randf_range(-0.1, 0.25))
			var sz := rng.randf_range(0.12, 0.28)
			Art.part(root, Art.sphere(sz, sz * 1.1, 6, 3), Art.stone(), pos + Vector3.UP * sz * 0.3,
					Vector3(rng.randf() * 40, rng.randf() * 360, 0), Vector3(1.2, 0.7, 1.0))


# --- Portal (entrada dos inimigos) ------------------------------------------

func _portal() -> void:
	var start := Vector3(_pts[0].x, 0, _pts[0].y)
	var dir := Vector3(_pts[1].x - _pts[0].x, 0, _pts[1].y - _pts[0].y).normalized()
	_portal_pos = _pts[0] - Vector2(dir.x, dir.z) * 1.0
	var p := Node3D.new()
	p.name = "Portal"
	root.add_child(p)
	p.position = start - dir * 1.0
	p.rotation.y = Art.yaw_to(dir)

	# Plataforma de degraus
	Art.part(p, Art.cyl(2.9, 3.2, 0.3, 8), Art.stone_dark(), Vector3(0, 0.15, 0))
	Art.part(p, Art.cyl(2.4, 2.6, 0.25, 8), Art.stone(), Vector3(0, 0.42, 0))
	# Anel de pedra vertical (plano YZ, normal = +X local = direção da rota)
	var ring := TorusMesh.new()
	ring.inner_radius = 1.85
	ring.outer_radius = 2.35
	ring.rings = 24
	ring.ring_segments = 6
	Art.part(p, ring, Art.stone_dark(), Vector3(0, 2.6, 0), Vector3(0, 0, 90))
	# Runas brilhando no anel
	var rune_mat := Art.glow(Color(0.6, 0.25, 1.0), 4.0)
	for i in 9:
		var a := TAU * i / 9.0
		Art.part(p, Art.box(Vector3(0.12, 0.22, 0.12)), rune_mat,
				Vector3(0.28, 2.6 + sin(a) * 2.1, cos(a) * 2.1), Vector3(rad_to_deg(-a), 0, 0))
	# Pilares laterais
	for s in [-1.0, 1.0]:
		Art.part(p, Art.box(Vector3(0.9, 3.4, 0.9)), Art.stone(), Vector3(0, 1.9, s * 2.55))
		Art.part(p, Art.cyl(0.0, 0.55, 1.0, 4), Art.stone_dark(), Vector3(0, 4.1, s * 2.55), Vector3(0, 45, 0))
	# Redemoinho
	var swirl := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(4.0, 4.0)
	swirl.mesh = quad
	var sm := ShaderMaterial.new()
	sm.shader = load("res://shaders/portal.gdshader")
	swirl.material_override = sm
	swirl.position = Vector3(0, 2.6, 0)
	swirl.rotation_degrees = Vector3(0, 90, 0)
	p.add_child(swirl)
	# Luz e partículas
	var light := OmniLight3D.new()
	light.light_color = Color(0.6, 0.25, 1.0)
	light.light_energy = 3.0
	light.omni_range = 11.0
	light.position = Vector3(1.5, 2.6, 0)
	p.add_child(light)
	var fx := Art.order_particles("necromancia", Color(0.6, 0.25, 1.0), 1.8)
	fx.amount = 40
	fx.position = Vector3(0, 2.6, 0)
	p.add_child(fx)


# --- Castelo (o que o jogador defende) --------------------------------------

func _castle() -> void:
	var n := _pts.size()
	var end := Vector3(_pts[n - 1].x, 0, _pts[n - 1].y)
	var dir := Vector3(_pts[n - 1].x - _pts[n - 2].x, 0, _pts[n - 1].y - _pts[n - 2].y).normalized()
	var c := Node3D.new()
	c.name = "Castle"
	root.add_child(c)
	var center := end + dir * 6.0
	_castle_pos = Vector2(center.x, center.z)
	c.position = center
	c.rotation.y = Art.yaw_to(dir)   # portão (lado -X local) virado para a rota

	var st := Art.stone()
	var half := 5.0
	var wall_h := 3.2
	# Muralhas (com abertura no portão)
	for side in [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0)]:
		var along_x: bool = side.x == 0
		var size := Vector3(half * 2, wall_h, 0.9) if along_x else Vector3(0.9, wall_h, half * 2)
		var pos: Vector3 = side * half + Vector3.UP * wall_h / 2
		Art.part(c, Art.box(size), st, pos)
		_merlons_line(c, pos + Vector3.UP * (wall_h / 2 + 0.2), along_x, half * 2)
	for s in [-1.0, 1.0]:   # muralha da frente, dos dois lados do portão
		var pos := Vector3(-half, wall_h / 2, s * (half + 1.6) / 2)
		Art.part(c, Art.box(Vector3(0.9, wall_h, half - 1.6)), st, pos)
		_merlons_line(c, pos + Vector3.UP * (wall_h / 2 + 0.2), false, half - 1.6)
	# Torres de canto
	for corner in [Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]:
		_round_tower(c, Vector3(corner.x * half, 0, corner.y * half), 1.3, 5.2)
	# Torre de menagem (central)
	Art.part(c, Art.box(Vector3(3.6, 7.0, 3.6)), st, Vector3(1.0, 3.5, 0))
	Art.part(c, Art.cyl(0.0, 2.9, 2.6, 4), Art.roof(), Vector3(1.0, 8.3, 0), Vector3(0, 45, 0))
	for s in [-1.0, 1.0]:
		Art.part(c, Art.box(Vector3(0.12, 0.9, 0.5)), Art.glow(Color(1.0, 0.7, 0.35), 2.5),
				Vector3(-0.82, 5.0, s * 0.8))
	# Portão: torres de guarda, arco escuro, grade levadiça
	for s in [-1.0, 1.0]:
		_round_tower(c, Vector3(-half - 0.2, 0, s * 1.9), 0.95, 4.4)
	Art.part(c, Art.box(Vector3(1.0, 1.2, 3.0)), st, Vector3(-half, wall_h + 0.1, 0))
	Art.part(c, Art.box(Vector3(0.4, 2.8, 2.6)), Art.color_mat(Color(0.03, 0.03, 0.04)), Vector3(-half + 0.1, 1.4, 0))
	var bar := Art.box(Vector3(0.08, 2.7, 0.08))
	for k in 6:
		Art.part(c, bar, Art.metal(), Vector3(-half - 0.15, 1.35, -1.1 + k * 0.44))
	# Estandartes
	var banner_mat := Art.color_mat(Color(0.42, 0.06, 0.07), 0.9)
	var trim := Art.color_mat(Color(0.75, 0.58, 0.25), 0.4, 0.7)
	for s in [-1.0, 1.0]:
		Art.part(c, Art.box(Vector3(0.05, 1.8, 0.8)), banner_mat, Vector3(-half - 0.5, 2.2, s * 3.2))
		Art.part(c, Art.box(Vector3(0.06, 0.12, 0.85)), trim, Vector3(-half - 0.51, 3.1, s * 3.2))
		_torch(c, Vector3(-half - 0.7, 2.3, s * 1.0))


func _round_tower(parent: Node3D, pos: Vector3, r: float, h: float) -> void:
	Art.part(parent, Art.cyl(r * 0.92, r, h, 12), Art.stone(), pos + Vector3.UP * h / 2)
	Art.part(parent, Art.cyl(r * 1.12, r * 1.05, 0.35, 12), Art.stone_dark(), pos + Vector3.UP * (h + 0.1))
	Art.part(parent, Art.cyl(0.0, r * 1.2, r * 2.0, 12), Art.roof(), pos + Vector3.UP * (h + 0.25 + r))
	# Bandeirola no topo
	Art.part(parent, Art.cyl(0.03, 0.03, 1.0, 4), Art.wood(), pos + Vector3.UP * (h + 0.6 + r * 2.0))
	Art.part(parent, Art.box(Vector3(0.6, 0.35, 0.03)), Art.color_mat(Color(0.5, 0.07, 0.08)),
			pos + Vector3(0.32, h + 0.9 + r * 2.0, 0))
	# Janelas iluminadas
	Art.part(parent, Art.box(Vector3(0.1, 0.5, 0.18)), Art.glow(Color(1.0, 0.65, 0.3), 2.0),
			pos + Vector3(-r * 0.95, h * 0.6, 0))


func _merlons_line(parent: Node3D, center: Vector3, along_x: bool, length: float) -> void:
	var count := int(length / 0.8)
	var b := Art.box(Vector3(0.4, 0.45, 0.95) if not along_x else Vector3(0.4, 0.45, 0.95))
	for i in count:
		if i % 2 == 1:
			continue
		var off := -length / 2 + 0.4 + i * 0.8
		var p := center + (Vector3(off, 0, 0) if along_x else Vector3(0, 0, off))
		Art.part(parent, b, Art.stone(), p, Vector3(0, 90 if along_x else 0, 0))


func _torch(parent: Node3D, pos: Vector3) -> void:
	Art.part(parent, Art.cyl(0.05, 0.04, 0.5, 6), Art.wood(), pos)
	var fire := Art.order_particles("fogo", Color(1.0, 0.5, 0.15), 0.08)
	fire.amount = 14
	fire.lifetime = 0.7
	fire.position = pos + Vector3.UP * 0.35
	parent.add_child(fire)
	var l := OmniLight3D.new()
	l.light_color = Color(1.0, 0.6, 0.3)
	l.light_energy = 1.8
	l.omni_range = 6.0
	l.position = pos + Vector3.UP * 0.5
	parent.add_child(l)


# --- Vegetação, rochas, montanhas -------------------------------------------

## true se o ponto está fora da área jogável e longe do castelo/portal.
func _in_wild(p: Vector2, margin: float) -> bool:
	if absf(p.x) < _half.x + margin and absf(p.y) < _half.y + margin:
		return false
	if p.distance_to(_castle_pos) < 9.0 or p.distance_to(_portal_pos) < 5.0:
		return false
	return true


func _dist_to_road(p: Vector2) -> float:
	return BuildGrid._dist_to_polyline(p, _pts)


func _forest(sc: Dictionary) -> void:
	var count: int = int(sc.get("trees", 400))
	var depth: float = float(sc.get("forest_depth", 26.0))
	# Pinheiro: tronco + 3 cones, montado numa única malha de 2 superfícies
	var pine := ArrayMesh.new()
	_append(pine, Art.cyl(0.12, 0.2, 1.2, 6), Transform3D(Basis(), Vector3(0, 0.6, 0)), Art.wood())
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in 3:
		var cone := Art.cyl(0.0, 1.25 - k * 0.3, 1.6 - k * 0.2, 7)
		st.append_from(cone, 0, Transform3D(Basis(), Vector3(0, 1.6 + k * 0.85, 0)))
	st.generate_normals()
	pine.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, st.commit_to_arrays())
	pine.surface_set_material(1, _foliage_mat())

	var xforms: Array = []
	var tries := 0
	while xforms.size() < count and tries < count * 20:
		tries += 1
		var p := Vector2(rng.randf_range(-_half.x - depth, _half.x + depth),
				rng.randf_range(-_half.y - depth, _half.y + depth))
		if not _in_wild(p, 1.5):
			continue
		var s := rng.randf_range(0.8, 1.7)
		var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s, s * rng.randf_range(0.9, 1.3), s))
		xforms.append(Transform3D(b, Vector3(p.x, 0, p.y)))
	_multimesh("Forest", pine, xforms, true)


func _foliage_mat() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = false
	m.albedo_color = Color(0.09, 0.16, 0.10)
	m.roughness = 0.95
	m.albedo_texture = Art.noise_tex(61, 0.2, false, Art._ramp([
		[0.0, Color(0.6, 0.7, 0.6)], [1.0, Color(1.2, 1.25, 1.1)]]))
	return m


func _rocks(sc: Dictionary) -> void:
	var count: int = int(sc.get("rocks", 150))
	var rock := Art.sphere(0.6, 1.0, 7, 4)
	var xforms: Array = []
	var depth: float = float(sc.get("forest_depth", 26.0))
	while xforms.size() < count:
		var p := Vector2(rng.randf_range(-_half.x - depth, _half.x + depth),
				rng.randf_range(-_half.y - depth, _half.y + depth))
		if not _in_wild(p, 0.5):
			continue
		var s := rng.randf_range(0.5, 2.2)
		var b := Basis.from_euler(Vector3(rng.randf() * 0.4, rng.randf() * TAU, rng.randf() * 0.4))
		b = b.scaled(Vector3(s * rng.randf_range(0.8, 1.5), s * rng.randf_range(0.5, 0.9), s))
		xforms.append(Transform3D(b, Vector3(p.x, s * 0.15, p.y)))
	var mm_mesh := ArrayMesh.new()
	_append(mm_mesh, rock, Transform3D(), Art.stone())
	_multimesh("Rocks", mm_mesh, xforms, true)


func _grass(sc: Dictionary) -> void:
	var count: int = int(sc.get("grass_tufts", 2000))
	var tuft := ArrayMesh.new()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in 3:
		var blade := Art.cyl(0.0, 0.05, 0.42, 3)
		var a := TAU * k / 3.0
		var b := Basis.from_euler(Vector3(0.35, a, 0))
		st.append_from(blade, 0, Transform3D(b, Vector3(cos(a) * 0.06, 0.18, sin(a) * 0.06)))
	st.generate_normals()
	tuft.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, st.commit_to_arrays())
	var gm := StandardMaterial3D.new()
	gm.vertex_color_use_as_albedo = true
	gm.roughness = 1.0
	tuft.surface_set_material(0, gm)
	var xforms: Array = []
	var colors: Array = []
	var ext := Vector2(_half.x + 18, _half.y + 18)
	while xforms.size() < count:
		var p := Vector2(rng.randf_range(-ext.x, ext.x), rng.randf_range(-ext.y, ext.y))
		if _dist_to_road(p) < _road_w / 2.0 + 0.6:
			continue
		var s := rng.randf_range(0.5, 1.2)
		xforms.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * s), Vector3(p.x, 0, p.y)))
		colors.append(Color(0.07, 0.12, 0.05).lerp(Color(0.17, 0.19, 0.08), rng.randf()))
	_multimesh("Grass", tuft, xforms, false, colors)


func _mountains(sc: Dictionary) -> void:
	var count: int = int(sc.get("mountains", 12))
	var mat := Art.color_mat(Color(0.22, 0.23, 0.29), 1.0)
	var snow := Art.color_mat(Color(0.75, 0.78, 0.85), 0.9)
	for i in count:
		var a := TAU * i / count + rng.randf_range(-0.2, 0.2)
		var d := rng.randf_range(78, 98)
		var h := rng.randf_range(18, 36)
		var r := h * rng.randf_range(0.9, 1.3)
		var pos := Vector3(cos(a) * d, 0, sin(a) * d * 0.85)
		Art.part(root, Art.cyl(0.0, r, h, 7), mat, pos + Vector3.UP * h / 2, Vector3(0, rng.randf() * 60, 0))
		Art.part(root, Art.cyl(0.0, r * 0.3, h * 0.3, 7), snow, pos + Vector3.UP * (h * 0.85 + 0.05),
				Vector3(0, rng.randf() * 60, 0))


## Partículas mágicas flutuando por cima do mapa (vagalumes / poeira arcana).
func _ambient_motes() -> void:
	var p := GPUParticles3D.new()
	p.name = "AmbientMotes"
	p.amount = 70
	p.lifetime = 7.0
	p.preprocess = 7.0
	p.visibility_aabb = AABB(Vector3(-40, -2, -30), Vector3(80, 12, 60))
	p.draw_pass_1 = Art.soft_dot_mesh()
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(_half.x + 6, 2.5, _half.y + 6)
	pm.gravity = Vector3(0, 0.05, 0)
	pm.initial_velocity_min = 0.1
	pm.initial_velocity_max = 0.35
	pm.spread = 180.0
	pm.turbulence_enabled = true
	pm.turbulence_noise_strength = 0.6
	pm.scale_min = 0.06
	pm.scale_max = 0.14
	pm.color = Color(1.0, 0.8, 0.45) * 1.2
	pm.color_ramp = Art._alpha_fade()
	p.process_material = pm
	p.position = Vector3(0, 3.0, 0)
	root.add_child(p)


# --- Auxiliares de malha ----------------------------------------------------

func _append(target: ArrayMesh, src: Mesh, xf: Transform3D, mat: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.append_from(src, 0, xf)
	target.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, st.commit_to_arrays())
	target.surface_set_material(target.get_surface_count() - 1, mat)


func _multimesh(node_name: String, mesh: Mesh, xforms: Array, shadows: bool, colors: Array = []) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = colors.size() > 0
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
		if mm.use_colors:
			mm.set_instance_color(i, colors[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.name = node_name
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows \
			else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mmi)
