class_name Art
extends RefCounted
## Fábrica de materiais, texturas e malhas procedurais (sem arquivos de arte).
## Tudo é gerado por código com ruído (FastNoiseLite) para dar textura de
## pedra, madeira, grama e calçamento. Materiais ficam em cache.
## Ver docs/art-direction.md.

static var _cache: Dictionary = {}

## Efeito de partículas de cada Ordem: cor vem de elements.json; aqui só o
## "comportamento" visual (para onde as partículas vão, tamanho, quantidade).
const ORDER_FX := {
	"none":        {"gravity": Vector3(0, 0.3, 0),  "size": 0.10, "amount": 6},
	"sagrado":     {"gravity": Vector3(0, 0.9, 0),  "size": 0.12, "amount": 14},
	"necromancia": {"gravity": Vector3(0, 0.45, 0), "size": 0.22, "amount": 12},
	"gelo":        {"gravity": Vector3(0, -0.5, 0), "size": 0.10, "amount": 16},
	"fogo":        {"gravity": Vector3(0, 1.8, 0),  "size": 0.16, "amount": 20},
	"druidico":    {"gravity": Vector3(0, -0.35, 0), "size": 0.12, "amount": 12},
	"pedra":       {"gravity": Vector3(0, -1.2, 0), "size": 0.10, "amount": 10},
}


# --- Texturas ---------------------------------------------------------------

static func _ramp(stops: Array) -> Gradient:
	var g := Gradient.new()
	var offs := PackedFloat32Array()
	var cols := PackedColorArray()
	for s in stops:
		offs.append(float(s[0]))
		cols.append(s[1])
	g.offsets = offs
	g.colors = cols
	return g


static func _noise(seed_v: int, freq: float, cellular: bool) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = seed_v
	n.frequency = freq
	if cellular:
		n.noise_type = FastNoiseLite.TYPE_CELLULAR
		n.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
		n.cellular_jitter = 0.9
	else:
		n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		n.fractal_octaves = 5
	return n


static func noise_tex(seed_v: int, freq: float, cellular: bool, ramp: Gradient,
		as_normal: bool = false, size: int = 512, bump: float = 6.0) -> NoiseTexture2D:
	var t := NoiseTexture2D.new()
	t.width = size
	t.height = size
	t.seamless = true
	t.noise = _noise(seed_v, freq, cellular)
	if as_normal:
		t.as_normal_map = true
		t.bump_strength = bump
	elif ramp:
		t.color_ramp = ramp
	return t


# --- Materiais --------------------------------------------------------------

static func _triplanar(m: StandardMaterial3D, scale: float) -> void:
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3.ONE * scale


static func stone() -> StandardMaterial3D:
	if _cache.has("stone"):
		return _cache["stone"]
	var m := StandardMaterial3D.new()
	m.albedo_texture = noise_tex(11, 0.035, true, _ramp([
		[0.0, Color(0.09, 0.09, 0.09)], [0.07, Color(0.27, 0.27, 0.27)],
		[0.5, Color(0.33, 0.33, 0.32)], [1.0, Color(0.41, 0.40, 0.38)]]))
	m.normal_enabled = true
	m.normal_texture = noise_tex(11, 0.035, true, null, true, 512, 8.0)
	m.normal_scale = 0.9
	m.roughness = 0.92
	_triplanar(m, 0.55)
	_cache["stone"] = m
	return m


static func stone_dark() -> StandardMaterial3D:
	if _cache.has("stone_dark"):
		return _cache["stone_dark"]
	var m: StandardMaterial3D = stone().duplicate()
	m.albedo_color = Color(0.55, 0.55, 0.6)
	_cache["stone_dark"] = m
	return m


static func cobble() -> StandardMaterial3D:
	if _cache.has("cobble"):
		return _cache["cobble"]
	var m := StandardMaterial3D.new()
	m.albedo_texture = noise_tex(23, 0.09, true, _ramp([
		[0.0, Color(0.06, 0.05, 0.05)], [0.10, Color(0.24, 0.22, 0.20)],
		[0.6, Color(0.31, 0.29, 0.26)], [1.0, Color(0.38, 0.35, 0.31)]]))
	m.normal_enabled = true
	m.normal_texture = noise_tex(23, 0.09, true, null, true, 512, 10.0)
	m.roughness = 0.88
	_triplanar(m, 0.35)
	_cache["cobble"] = m
	return m


static func dirt() -> StandardMaterial3D:
	if _cache.has("dirt"):
		return _cache["dirt"]
	var m := StandardMaterial3D.new()
	m.albedo_texture = noise_tex(31, 0.02, false, _ramp([
		[0.0, Color(0.16, 0.12, 0.09)], [0.5, Color(0.26, 0.20, 0.14)], [1.0, Color(0.33, 0.27, 0.19)]]))
	m.roughness = 1.0
	_triplanar(m, 0.25)
	_cache["dirt"] = m
	return m


static func grass() -> StandardMaterial3D:
	if _cache.has("grass"):
		return _cache["grass"]
	var m := StandardMaterial3D.new()
	m.albedo_texture = noise_tex(5, 0.02, false, _ramp([
		[0.0, Color(0.05, 0.08, 0.04)], [0.3, Color(0.09, 0.14, 0.06)],
		[0.65, Color(0.13, 0.18, 0.07)], [1.0, Color(0.21, 0.20, 0.10)]]), false, 1024)
	m.normal_enabled = true
	m.normal_texture = noise_tex(6, 0.08, false, null, true, 512, 3.0)
	m.normal_scale = 0.5
	m.roughness = 1.0
	_triplanar(m, 0.06)
	_cache["grass"] = m
	return m


static func wood() -> StandardMaterial3D:
	if _cache.has("wood"):
		return _cache["wood"]
	var m := StandardMaterial3D.new()
	var n := noise_tex(41, 0.02, false, _ramp([
		[0.0, Color(0.17, 0.10, 0.06)], [0.5, Color(0.29, 0.18, 0.10)], [1.0, Color(0.36, 0.24, 0.14)]]))
	(n.noise as FastNoiseLite).domain_warp_enabled = true
	m.albedo_texture = n
	m.roughness = 0.85
	m.uv1_scale = Vector3(4, 0.4, 1)
	_cache["wood"] = m
	return m


static func roof() -> StandardMaterial3D:
	if _cache.has("roof"):
		return _cache["roof"]
	var m := StandardMaterial3D.new()
	m.albedo_texture = noise_tex(51, 0.12, true, _ramp([
		[0.0, Color(0.05, 0.06, 0.08)], [0.12, Color(0.16, 0.19, 0.26)], [1.0, Color(0.24, 0.28, 0.36)]]))
	m.roughness = 0.7
	_triplanar(m, 0.8)
	_cache["roof"] = m
	return m


static func color_mat(c: Color, rough: float = 0.8, metal: float = 0.0) -> StandardMaterial3D:
	var key := "c_%s_%.2f_%.2f" % [c.to_html(), rough, metal]
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
	_cache[key] = m
	return m


static func metal(c: Color = Color(0.32, 0.33, 0.36)) -> StandardMaterial3D:
	return color_mat(c, 0.35, 0.85)


static func glow(c: Color, energy: float = 3.0) -> StandardMaterial3D:
	var key := "g_%s_%.1f" % [c.to_html(), energy]
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = c.darkened(0.3)
	m.emission_enabled = true
	m.emission = c
	m.emission_energy_multiplier = energy
	m.roughness = 0.3
	_cache[key] = m
	return m


## Cristal mágico: emissivo, com brilho de borda (rim). NÃO usa cache porque cada
## torre anima o próprio brilho (pisca ao atirar).
static func crystal(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.emission_enabled = true
	m.emission = c
	m.emission_energy_multiplier = 3.0
	m.metallic = 0.3
	m.roughness = 0.1
	m.rim_enabled = true
	m.rim = 0.8
	return m


## Ponto de luz suave (textura radial) usado por todas as partículas.
static func soft_dot_mesh() -> QuadMesh:
	if _cache.has("dot"):
		return _cache["dot"]
	var tex := GradientTexture2D.new()
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.gradient = _ramp([[0.0, Color(1, 1, 1, 1)], [0.35, Color(1, 1, 1, 0.55)], [1.0, Color(1, 1, 1, 0)]])
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.vertex_color_use_as_albedo = true
	m.albedo_texture = tex
	m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	var q := QuadMesh.new()
	q.size = Vector2(0.3, 0.3)
	q.material = m
	_cache["dot"] = q
	return q


# --- Partículas -------------------------------------------------------------

## Cria um emissor contínuo de partículas mágicas na cor/estilo da Ordem.
static func order_particles(order, color: Color, radius: float = 0.4) -> GPUParticles3D:
	var fx: Dictionary = ORDER_FX.get("none" if order == null else str(order), ORDER_FX["none"])
	var p := GPUParticles3D.new()
	p.amount = int(fx["amount"])
	p.lifetime = 1.6
	p.local_coords = false
	p.draw_pass_1 = soft_dot_mesh()
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = radius
	pm.gravity = fx["gravity"]
	pm.initial_velocity_min = 0.05
	pm.initial_velocity_max = 0.3
	pm.direction = Vector3.UP
	pm.spread = 180.0
	pm.scale_min = float(fx["size"]) * 0.6
	pm.scale_max = float(fx["size"]) * 1.4
	pm.color = color * 1.6
	pm.color_ramp = _alpha_fade()
	p.process_material = pm
	return p


static func _alpha_fade() -> GradientTexture1D:
	if _cache.has("fade"):
		return _cache["fade"]
	var t := GradientTexture1D.new()
	t.gradient = _ramp([[0.0, Color(1, 1, 1, 0)], [0.15, Color(1, 1, 1, 1)], [1.0, Color(1, 1, 1, 0)]])
	_cache["fade"] = t
	return t


# --- Malhas auxiliares ------------------------------------------------------

## Adiciona uma malha como filha de parent, com material, posição, rotação
## (graus) e escala. Retorna o MeshInstance3D.
static func part(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3,
		rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scl
	parent.add_child(mi)
	return mi


static func box(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b


static func cyl(top: float, bottom: float, height: float, segments: int = 12) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = top
	c.bottom_radius = bottom
	c.height = height
	c.radial_segments = segments
	c.rings = 1
	return c


static func sphere(radius: float, height: float = -1.0, segments: int = 12, rings: int = 6) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = radius
	s.height = radius * 2.0 if height < 0.0 else height
	s.radial_segments = segments
	s.rings = rings
	return s


static func capsule(radius: float, height: float) -> CapsuleMesh:
	var c := CapsuleMesh.new()
	c.radius = radius
	c.height = height
	c.radial_segments = 10
	c.rings = 4
	return c


## Gema facetada (octaedro alongado).
static func gem(radius: float, height: float) -> SphereMesh:
	return sphere(radius, height, 6, 2)


## Ameias (merlões) em volta de um círculo, no topo de torres/muralhas.
static func crenellations(parent: Node3D, radius: float, y: float, count: int,
		merlon: Vector3, mat: Material) -> void:
	var b := box(merlon)
	for i in count:
		var a: float = TAU * i / count
		part(parent, b, mat, Vector3(cos(a) * radius, y, sin(a) * radius), Vector3(0, -rad_to_deg(a), 0))


## Rotação Y (radianos) que alinha o eixo +X local com a direção dir (no plano XZ).
static func yaw_to(dir: Vector3) -> float:
	return atan2(-dir.z, dir.x)
