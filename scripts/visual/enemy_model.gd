class_name EnemyModel
extends Node3D
## Modelo 3D procedural de um inimigo, escolhido pela facção da Ordem
## (elements.json → factions.<ordem>.model). A frente do modelo é -Z
## (direção em que o PathFollow3D anda). Anima a caminhada. Só visual.
## Ver docs/art-direction.md.

var height: float = 1.6             # altura aproximada (para a barra de vida)
var _legs: Array = []               # pivôs das pernas (balançam)
var _arms: Array = []
var _body: Node3D                   # balança/sobe e desce
var _t: float = 0.0
var _walk_speed: float = 8.0


func build(model: String, order, is_boss: bool, armored: bool) -> void:
	_t = randf() * 10.0
	_body = Node3D.new()
	add_child(_body)
	var eye: Color = GameData.order_color(order) if order != null else Color(1.0, 0.25, 0.1)
	match model:
		"knight": _knight(eye)
		"skeleton": _skeleton(eye)
		"giant": _giant(eye)
		"demon": _demon(eye)
		"beast": _beast(eye)
		"golem": _golem(eye)
		_: _goblin(eye)
	if armored and model != "knight" and model != "golem":
		_armor()
	if is_boss:
		_boss_extras(eye)


# --- Peças ------------------------------------------------------------------

func _leg(pos: Vector3, length: float, radius: float, mat: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pos
	_body.add_child(pivot)
	Art.part(pivot, Art.capsule(radius, length), mat, Vector3(0, -length / 2, 0))
	_legs.append(pivot)
	return pivot


func _arm(pos: Vector3, length: float, radius: float, mat: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pos
	_body.add_child(pivot)
	Art.part(pivot, Art.capsule(radius, length), mat, Vector3(0, -length / 2, 0))
	_arms.append(pivot)
	return pivot


func _eyes(y: float, z: float, spread: float, size: float, col: Color) -> void:
	var m := Art.glow(col, 6.0)
	for s in [-1.0, 1.0]:
		Art.part(_body, Art.sphere(size, -1, 6, 3), m, Vector3(s * spread, y, z))


# --- Facções ----------------------------------------------------------------

func _goblin(eye: Color) -> void:
	var skin := Art.color_mat(Color(0.20, 0.25, 0.12), 0.8)
	var leather := Art.color_mat(Color(0.22, 0.15, 0.09), 0.9)
	Art.part(_body, Art.capsule(0.26, 0.75), leather, Vector3(0, 0.75, 0), Vector3(-15, 0, 0))
	Art.part(_body, Art.sphere(0.22), skin, Vector3(0, 1.18, -0.12))
	for s in [-1.0, 1.0]:
		Art.part(_body, Art.cyl(0.0, 0.07, 0.3, 5), skin, Vector3(s * 0.24, 1.25, -0.1), Vector3(0, 0, s * 70))
	_eyes(1.2, -0.31, 0.08, 0.035, eye)
	_leg(Vector3(-0.12, 0.45, 0), 0.45, 0.08, skin)
	_leg(Vector3(0.12, 0.45, 0), 0.45, 0.08, skin)
	_arm(Vector3(-0.3, 0.95, 0), 0.5, 0.07, skin)
	var a := _arm(Vector3(0.3, 0.95, 0), 0.5, 0.07, skin)
	Art.part(a, Art.box(Vector3(0.06, 0.06, 0.55)), Art.metal(), Vector3(0, -0.5, -0.2))
	height = 1.45


func _knight(eye: Color) -> void:
	var steel := Art.metal(Color(0.22, 0.22, 0.25))
	var gold := Art.metal(Color(0.6, 0.47, 0.2))
	Art.part(_body, Art.capsule(0.3, 0.95), steel, Vector3(0, 0.95, 0))
	Art.part(_body, Art.box(Vector3(0.72, 0.18, 0.4)), gold, Vector3(0, 1.32, 0))
	Art.part(_body, Art.cyl(0.18, 0.2, 0.36, 10), steel, Vector3(0, 1.62, 0))
	Art.part(_body, Art.box(Vector3(0.26, 0.05, 0.05)), Art.glow(eye, 5.0), Vector3(0, 1.64, -0.19))
	Art.part(_body, Art.box(Vector3(0.6, 1.1, 0.05)), Art.color_mat(Color(0.25, 0.04, 0.05)), Vector3(0, 1.0, 0.28), Vector3(8, 0, 0))
	_leg(Vector3(-0.14, 0.55, 0), 0.55, 0.1, steel)
	_leg(Vector3(0.14, 0.55, 0), 0.55, 0.1, steel)
	var a := _arm(Vector3(0.38, 1.25, 0), 0.6, 0.09, steel)
	Art.part(a, Art.box(Vector3(0.05, 0.9, 0.1)), Art.metal(Color(0.7, 0.7, 0.75)), Vector3(0, -0.95, -0.15), Vector3(-30, 0, 0))
	var b := _arm(Vector3(-0.38, 1.25, 0), 0.6, 0.09, steel)
	Art.part(b, Art.box(Vector3(0.08, 0.6, 0.45)), gold, Vector3(-0.08, -0.5, -0.05))
	height = 1.95


func _skeleton(eye: Color) -> void:
	var bone := Art.color_mat(Color(0.78, 0.75, 0.66), 0.7)
	Art.part(_body, Art.cyl(0.05, 0.05, 0.7, 6), bone, Vector3(0, 0.95, 0))
	for k in 4:
		Art.part(_body, Art.cyl(0.2 - k * 0.02, 0.2 - k * 0.02, 0.04, 10), bone, Vector3(0, 1.05 + k * 0.1, 0))
	Art.part(_body, Art.box(Vector3(0.36, 0.1, 0.18)), bone, Vector3(0, 0.62, 0))
	Art.part(_body, Art.sphere(0.17, 0.32), bone, Vector3(0, 1.58, -0.02))
	Art.part(_body, Art.box(Vector3(0.18, 0.08, 0.14)), bone, Vector3(0, 1.45, -0.06))
	_eyes(1.6, -0.15, 0.06, 0.04, eye)
	_leg(Vector3(-0.1, 0.6, 0), 0.6, 0.04, bone)
	_leg(Vector3(0.1, 0.6, 0), 0.6, 0.04, bone)
	_arm(Vector3(-0.25, 1.35, 0), 0.6, 0.035, bone)
	var a := _arm(Vector3(0.25, 1.35, 0), 0.6, 0.035, bone)
	Art.part(a, Art.box(Vector3(0.04, 0.04, 0.7)), Art.metal(Color(0.3, 0.27, 0.2)), Vector3(0, -0.6, -0.25))
	height = 1.85


func _giant(eye: Color) -> void:
	var skin := Art.color_mat(Color(0.30, 0.38, 0.46), 0.75)
	var fur := Art.color_mat(Color(0.26, 0.24, 0.21), 1.0)
	var leather := Art.color_mat(Color(0.15, 0.10, 0.07), 0.9)
	Art.part(_body, Art.capsule(0.48, 1.3), fur, Vector3(0, 1.15, 0))
	Art.part(_body, Art.cyl(0.5, 0.5, 0.14, 12), leather, Vector3(0, 0.95, 0))
	Art.part(_body, Art.box(Vector3(0.2, 0.18, 0.06)), Art.metal(Color(0.5, 0.5, 0.55)), Vector3(0, 0.95, -0.5))
	for s in [-1.0, 1.0]:
		Art.part(_body, Art.sphere(0.24, 0.3, 8, 4), fur, Vector3(s * 0.45, 1.6, 0))
	Art.part(_body, Art.sphere(0.28), skin, Vector3(0, 1.98, -0.08))
	Art.part(_body, Art.cyl(0.0, 0.2, 0.45, 6), Art.color_mat(Color(0.88, 0.9, 0.95), 0.9), Vector3(0, 1.72, -0.25), Vector3(-160, 0, 0))
	_eyes(2.02, -0.33, 0.1, 0.045, eye)
	var ice := Art.crystal(Color(0.55, 0.85, 1.0))
	for s in [-1.0, 1.0]:
		for k in 3:
			Art.part(_body, Art.gem(0.08, 0.4), ice, Vector3(s * (0.4 + k * 0.08), 1.65 + k * 0.08, k * 0.08 - 0.08), Vector3(0, 0, -s * (20 + k * 15)))
	_leg(Vector3(-0.22, 0.65, 0), 0.65, 0.16, skin)
	_leg(Vector3(0.22, 0.65, 0), 0.65, 0.16, skin)
	_arm(Vector3(-0.58, 1.6, 0), 0.95, 0.14, skin)
	var a := _arm(Vector3(0.58, 1.6, 0), 0.95, 0.14, skin)
	Art.part(a, Art.cyl(0.14, 0.08, 1.0, 7), Art.wood(), Vector3(0, -1.2, -0.2), Vector3(-40, 0, 0))
	height = 2.4


func _demon(eye: Color) -> void:
	var skin := Art.color_mat(Color(0.28, 0.05, 0.04), 0.6)
	var dark := Art.color_mat(Color(0.08, 0.04, 0.04), 0.5)
	var veins := Art.glow(Color(1.0, 0.35, 0.05), 3.0)
	Art.part(_body, Art.capsule(0.32, 1.0), skin, Vector3(0, 1.0, 0), Vector3(-10, 0, 0))
	Art.part(_body, Art.box(Vector3(0.05, 0.6, 0.04)), veins, Vector3(0, 1.05, -0.3), Vector3(-10, 0, 0))
	Art.part(_body, Art.sphere(0.21), skin, Vector3(0, 1.62, -0.1))
	for s in [-1.0, 1.0]:
		Art.part(_body, Art.cyl(0.0, 0.07, 0.42, 6), dark, Vector3(s * 0.17, 1.86, -0.05), Vector3(-25, 0, -s * 35))
		# asas
		Art.part(_body, Art.box(Vector3(0.9, 0.6, 0.03)), dark, Vector3(s * 0.55, 1.35, 0.3), Vector3(0, s * 25, s * 20))
	_eyes(1.66, -0.28, 0.08, 0.045, eye)
	_leg(Vector3(-0.15, 0.55, 0), 0.55, 0.1, skin)
	_leg(Vector3(0.15, 0.55, 0), 0.55, 0.1, skin)
	_arm(Vector3(-0.4, 1.3, 0), 0.65, 0.08, skin)
	_arm(Vector3(0.4, 1.3, 0), 0.65, 0.08, skin)
	var l := OmniLight3D.new()
	l.light_color = Color(1.0, 0.4, 0.1)
	l.light_energy = 0.8
	l.omni_range = 2.5
	l.position = Vector3(0, 1.1, -0.5)
	_body.add_child(l)
	height = 2.0


func _beast(eye: Color) -> void:
	var fur := Art.color_mat(Color(0.10, 0.09, 0.09), 1.0)
	var fur2 := Art.color_mat(Color(0.17, 0.15, 0.14), 1.0)
	var spike := Art.color_mat(Color(0.05, 0.05, 0.05), 0.6)
	for k in 6:
		Art.part(_body, Art.cyl(0.0, 0.07, 0.3, 4), spike, Vector3(0, 1.05 + sin(k * 0.6) * 0.05, -0.45 + k * 0.17), Vector3(25, 0, 0))
	Art.part(_body, Art.box(Vector3(0.16, 0.06, 0.26)), fur, Vector3(0, 0.78, -0.95))
	for s in [-1.0, 1.0]:
		Art.part(_body, Art.cyl(0.0, 0.02, 0.08, 4), Art.color_mat(Color(0.85, 0.82, 0.7)), Vector3(s * 0.06, 0.8, -1.08), Vector3(180, 0, 0))
	Art.part(_body, Art.capsule(0.3, 1.3), fur, Vector3(0, 0.75, 0), Vector3(90, 0, 0))
	Art.part(_body, Art.sphere(0.26), fur2, Vector3(0, 0.95, -0.72))
	Art.part(_body, Art.box(Vector3(0.18, 0.16, 0.3)), fur2, Vector3(0, 0.88, -0.98))
	for s in [-1.0, 1.0]:
		Art.part(_body, Art.cyl(0.0, 0.07, 0.2, 4), fur, Vector3(s * 0.14, 1.2, -0.68))
	Art.part(_body, Art.capsule(0.07, 0.6), fur, Vector3(0, 0.85, 0.75), Vector3(-60, 0, 0))
	_eyes(1.02, -0.93, 0.1, 0.035, eye)
	for z in [-0.4, 0.4]:
		_leg(Vector3(-0.18, 0.6, z), 0.55, 0.07, fur)
		_leg(Vector3(0.18, 0.6, z), 0.55, 0.07, fur)
	_walk_speed = 11.0
	height = 1.35


func _golem(eye: Color) -> void:
	var st := Art.stone()
	var crack := Art.glow(eye, 3.5)
	Art.part(_body, Art.box(Vector3(0.85, 0.85, 0.55)), st, Vector3(0, 1.15, 0), Vector3(0, 0, 3))
	Art.part(_body, Art.box(Vector3(0.6, 0.35, 0.45)), st, Vector3(0, 0.62, 0))
	Art.part(_body, Art.box(Vector3(0.34, 0.3, 0.32)), st, Vector3(0, 1.75, -0.08))
	Art.part(_body, Art.box(Vector3(0.06, 0.5, 0.02)), crack, Vector3(0.12, 1.15, -0.28), Vector3(0, 0, 20))
	Art.part(_body, Art.box(Vector3(0.22, 0.04, 0.02)), crack, Vector3(-0.15, 1.3, -0.28))
	_eyes(1.78, -0.25, 0.08, 0.04, eye)
	_leg(Vector3(-0.2, 0.5, 0), 0.4, 0.15, st)
	_leg(Vector3(0.2, 0.5, 0), 0.4, 0.15, st)
	for s in [-1.0, 1.0]:
		var a := _arm(Vector3(s * 0.55, 1.45, 0), 0.8, 0.16, st)
		Art.part(a, Art.box(Vector3(0.32, 0.3, 0.32)), st, Vector3(0, -0.95, 0))
	_walk_speed = 5.0
	height = 2.1


# --- Extras -----------------------------------------------------------------

func _armor() -> void:
	var plate := Art.metal(Color(0.35, 0.36, 0.4))
	for s in [-1.0, 1.0]:
		Art.part(_body, Art.sphere(0.16, 0.18, 8, 3), plate, Vector3(s * 0.32, height * 0.72, 0))
	Art.part(_body, Art.box(Vector3(0.42, 0.4, 0.06)), plate, Vector3(0, height * 0.55, -0.3))


func _boss_extras(col: Color) -> void:
	var gold := Art.metal(Color(0.75, 0.58, 0.2))
	Art.part(_body, Art.cyl(0.2, 0.22, 0.1, 8), gold, Vector3(0, height + 0.05, -0.05))
	for k in 5:
		var a := TAU * k / 5.0
		Art.part(_body, Art.cyl(0.0, 0.04, 0.18, 4), gold, Vector3(cos(a) * 0.19, height + 0.18, sin(a) * 0.19 - 0.05))
	var aura := Art.order_particles(null, col, 0.7)
	aura.amount = 30
	(aura.process_material as ParticleProcessMaterial).gravity = Vector3(0, 0.8, 0)
	aura.position = Vector3(0, height * 0.5, 0)
	_body.add_child(aura)
	var l := OmniLight3D.new()
	l.light_color = col
	l.light_energy = 1.5
	l.omni_range = 4.0
	l.position = Vector3(0, height * 0.6, 0)
	_body.add_child(l)


# --- Animação ---------------------------------------------------------------

## moving = false quando atordoado (fica parado).
func animate(delta: float, speed_factor: float, moving: bool) -> void:
	if not moving:
		return
	_t += delta * _walk_speed * clampf(speed_factor, 0.3, 2.0)
	var swing := sin(_t) * 0.6
	for i in _legs.size():
		(_legs[i] as Node3D).rotation.x = swing * (1.0 if i % 2 == 0 else -1.0) * (1.0 if i < 2 else -1.0)
	for i in _arms.size():
		(_arms[i] as Node3D).rotation.x = -swing * 0.6 * (1.0 if i % 2 == 0 else -1.0)
	_body.position.y = absf(sin(_t)) * 0.06
	_body.rotation.z = sin(_t) * 0.04
