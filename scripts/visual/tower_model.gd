class_name TowerModel
extends Node3D
## Modelo 3D procedural de uma torre, escolhido pela camada (tier) e pelas
## Ordens. Também anima o cristal (gira, flutua, pisca ao atirar) e o braço
## da catapulta. Só visual. Ver docs/art-direction.md.

var muzzle_height: float = 2.0
var _crystals: Array = []          # Node3D que giram/flutuam
var _crystal_mats: Array = []      # materiais que piscam ao atirar
var _lights: Array = []
var _arm: Node3D                   # braço da catapulta
var _flash: float = 0.0
var _t: float = 0.0
var _orbit: Node3D


func build(t: Dictionary) -> void:
	_t = randf() * 10.0
	var tier: String = str(t.get("tier", "base"))
	var orders: Array = _orders_of(t)
	match tier:
		"base":
			if float(t.get("splash_radius", 0.0)) > 0.0:
				_catapult()
			else:
				_watchtower()
		"dual":
			_stone_tower(orders, 3, true)
		_:
			_stone_tower(orders, int(tier.substr(tier.length() - 1)), false)


static func _orders_of(t: Dictionary) -> Array:
	var el = t.get("element", null)
	if el is Array:
		return el
	return [el]


# --- Torres base ------------------------------------------------------------

func _watchtower() -> void:
	var w := Art.wood()
	Art.part(self, Art.box(Vector3(1.5, 0.45, 1.5)), Art.stone(), Vector3(0, 0.22, 0))
	for x in [-0.55, 0.55]:
		for z in [-0.55, 0.55]:
			Art.part(self, Art.box(Vector3(0.16, 2.2, 0.16)), w, Vector3(x, 1.5, z), Vector3(x * 6, 0, -z * 6))
	# travessas em X
	for s in [-1.0, 1.0]:
		Art.part(self, Art.box(Vector3(0.08, 1.5, 0.08)), w, Vector3(0.56 * s, 1.3, 0), Vector3(40, 0, 0))
		Art.part(self, Art.box(Vector3(0.08, 1.5, 0.08)), w, Vector3(0, 1.3, 0.56 * s), Vector3(0, 0, 40))
	Art.part(self, Art.box(Vector3(1.55, 0.14, 1.55)), w, Vector3(0, 2.55, 0))
	for s in [-1.0, 1.0]:
		Art.part(self, Art.box(Vector3(1.55, 0.4, 0.07)), w, Vector3(0, 2.8, 0.74 * s))
		Art.part(self, Art.box(Vector3(0.07, 0.4, 1.55)), w, Vector3(0.74 * s, 2.8, 0))
	for x in [-0.7, 0.7]:
		for z in [-0.7, 0.7]:
			Art.part(self, Art.box(Vector3(0.1, 0.9, 0.1)), w, Vector3(x, 3.05, z))
	Art.part(self, Art.cyl(0.0, 1.25, 0.9, 4), Art.roof(), Vector3(0, 3.95, 0), Vector3(0, 45, 0))
	# arqueiro: silhueta encapuzada
	Art.part(self, Art.capsule(0.16, 0.6), Art.color_mat(Color(0.18, 0.22, 0.15)), Vector3(0.2, 2.95, 0.1))
	Art.part(self, Art.sphere(0.12), Art.color_mat(Color(0.12, 0.14, 0.1)), Vector3(0.2, 3.32, 0.1))
	_add_light(Color(1.0, 0.62, 0.3), 0.9, 3.5, Vector3(0, 3.0, 0))
	muzzle_height = 3.0


func _catapult() -> void:
	var w := Art.wood()
	Art.part(self, Art.box(Vector3(1.7, 0.3, 1.7)), Art.stone(), Vector3(0, 0.15, 0))
	for s in [-1.0, 1.0]:
		Art.part(self, Art.box(Vector3(1.6, 0.16, 0.16)), w, Vector3(0, 0.4, 0.5 * s))
		Art.part(self, Art.box(Vector3(0.14, 1.2, 0.14)), w, Vector3(-0.15, 0.95, 0.5 * s), Vector3(0, 0, 18))
		Art.part(self, Art.box(Vector3(0.14, 1.2, 0.14)), w, Vector3(0.25, 0.95, 0.5 * s), Vector3(0, 0, -18))
		for x in [-0.6, 0.6]:
			Art.part(self, Art.cyl(0.2, 0.2, 0.08, 10), w, Vector3(x, 0.4, 0.6 * s), Vector3(90, 0, 0))
	Art.part(self, Art.cyl(0.07, 0.07, 1.1, 8), Art.metal(), Vector3(0.05, 1.45, 0), Vector3(90, 0, 0))
	_arm = Node3D.new()
	_arm.position = Vector3(0.05, 1.45, 0)
	add_child(_arm)
	Art.part(_arm, Art.box(Vector3(1.9, 0.12, 0.12)), w, Vector3(-0.45, 0, 0))
	Art.part(_arm, Art.box(Vector3(0.35, 0.12, 0.35)), w, Vector3(-1.35, 0.08, 0))
	Art.part(_arm, Art.sphere(0.17, 0.3, 7, 4), Art.stone(), Vector3(-1.35, 0.25, 0))
	Art.part(_arm, Art.box(Vector3(0.45, 0.4, 0.45)), Art.stone_dark(), Vector3(0.55, -0.15, 0))
	_arm.rotation_degrees.z = 25
	muzzle_height = 1.9


# --- Torres de Ordem --------------------------------------------------------

func _stone_tower(orders: Array, level: int, dual: bool) -> void:
	var col: Color = GameData.order_color(orders[0])
	var r := 0.72
	var h := 2.0 + 0.7 * (level - 1) + (0.6 if dual else 0.0)
	var st := Art.stone()
	# Base, corpo e anéis
	Art.part(self, Art.cyl(r * 1.25, r * 1.4, 0.45, 8), Art.stone_dark(), Vector3(0, 0.22, 0))
	Art.part(self, Art.cyl(r * 0.85, r, h, 12), st, Vector3(0, h / 2 + 0.4, 0))
	var trim := Art.metal(Color(0.55, 0.45, 0.25)) if orders[0] in ["sagrado", "fogo", "pedra"] \
			else Art.metal(Color(0.25, 0.27, 0.32))
	Art.part(self, Art.cyl(r * 0.98, r * 1.02, 0.1, 12), trim, Vector3(0, 0.4 + h * 0.45, 0))
	var top := h + 0.4
	Art.part(self, Art.cyl(r * 1.15, r * 0.95, 0.35, 12), Art.stone_dark(), Vector3(0, top + 0.1, 0))
	Art.crenellations(self, r * 1.05, top + 0.45, 8, Vector3(0.24, 0.35, 0.22), st)
	# Janelas com brilho mágico
	var win := Art.glow(col, 2.2)
	for k in level:
		var a := k * 2.1
		var y := 0.9 + k * 0.75
		Art.part(self, Art.box(Vector3(0.1, 0.38, 0.16)), win,
				Vector3(cos(a) * r * 0.93, y, sin(a) * r * 0.93), Vector3(0, -rad_to_deg(a), 0))
	# Contrafortes no nível 3
	if level >= 3:
		for k in 4:
			var a := TAU * k / 4.0 + PI / 4
			Art.part(self, Art.box(Vector3(0.35, 1.6, 0.3)), st,
					Vector3(cos(a) * r * 1.05, 0.95, sin(a) * r * 1.05), Vector3(0, -rad_to_deg(a), -14))
	# Estandarte nos níveis 2+
	if level >= 2:
		Art.part(self, Art.box(Vector3(0.04, 1.0, 0.45)), Art.color_mat(col.darkened(0.55), 0.9),
				Vector3(r * 0.9, top - 0.7, 0))
	# Cristal(is)
	var gem_r := 0.2 + 0.07 * level
	var cy := top + 1.0 + 0.15 * level
	if dual:
		_orbit = Node3D.new()
		_orbit.position = Vector3(0, cy, 0)
		add_child(_orbit)
		for i in 2:
			var c2: Color = GameData.order_color(orders[i])
			_add_crystal(_orbit, c2, gem_r * 0.9, Vector3(cos(PI * i) * 0.45, 0, sin(PI * i) * 0.45), orders[i])
		_add_light(col.lerp(GameData.order_color(orders[1]), 0.5), 1.6, 5.5, Vector3(0, cy, 0))
		# Pináculo central
		Art.part(self, Art.cyl(0.0, 0.18, 1.0, 6), trim, Vector3(0, top + 0.75, 0))
	else:
		_add_crystal(self, col, gem_r, Vector3(0, cy, 0), orders[0])
		_add_light(col, 1.0 + 0.3 * level, 4.0 + level, Vector3(0, cy, 0))
		if level >= 2:
			_orbit = Node3D.new()
			_orbit.position = Vector3(0, cy, 0)
			add_child(_orbit)
			var shard_mat := Art.glow(col, 3.0)
			for i in level:
				var a := TAU * i / level
				Art.part(_orbit, Art.gem(0.07, 0.22), shard_mat, Vector3(cos(a) * 0.6, 0, sin(a) * 0.6))
	muzzle_height = cy


func _add_crystal(parent: Node3D, col: Color, radius: float, pos: Vector3, order) -> void:
	var holder := Node3D.new()
	holder.position = pos
	parent.add_child(holder)
	var mat := Art.crystal(col)
	Art.part(holder, Art.gem(radius, radius * 3.0), mat, Vector3.ZERO)
	_crystals.append(holder)
	_crystal_mats.append(mat)
	var fx := Art.order_particles(order, col, radius * 1.6)
	holder.add_child(fx)


func _add_light(col: Color, energy: float, range_m: float, pos: Vector3) -> void:
	var l := OmniLight3D.new()
	l.light_color = col
	l.light_energy = energy
	l.omni_range = range_m
	l.position = pos
	l.set_meta("base_energy", energy)
	add_child(l)
	_lights.append(l)


# --- Animação ---------------------------------------------------------------

## Chamado pela torre quando dispara.
func on_fire() -> void:
	_flash = 1.0
	if _arm:
		var tw := create_tween()
		tw.tween_property(_arm, "rotation_degrees:z", -55.0, 0.12)
		tw.tween_property(_arm, "rotation_degrees:z", 25.0, 0.6)


func _process(delta: float) -> void:
	_t += delta
	_flash = maxf(0.0, _flash - delta * 4.0)
	for i in _crystals.size():
		var c: Node3D = _crystals[i]
		c.rotation.y += delta * 0.9
		c.position.y = sin(_t * 1.6 + i) * 0.12
	if _orbit:
		_orbit.rotation.y -= delta * 1.2
	for m in _crystal_mats:
		(m as StandardMaterial3D).emission_energy_multiplier = 3.0 + _flash * 5.0
	for l in _lights:
		var base: float = l.get_meta("base_energy")
		(l as OmniLight3D).light_energy = base * (1.0 + _flash * 1.5 + sin(_t * 3.0) * 0.06)
