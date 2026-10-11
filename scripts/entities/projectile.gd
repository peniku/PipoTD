extends Node3D
class_name Projectile
## Projétil disparado por uma torre. Persegue o alvo; se o alvo morrer no
## caminho, segue até a última posição conhecida. Ao chegar aplica o dano
## (e o dano em área, se splash_radius > 0). Ver docs/systems/combat.md.
##
## A lógica usa só a posição no chão (_flat). A altura (arco da pedra da
## catapulta) é puramente visual.
## Estilos: "arrow" (flecha), "boulder" (pedra em arco), "magic" (orbe mágico).

const SPEED := 26.0
const HIT_DISTANCE := 0.4

var target: Enemy
var target_pos: Vector3
var damage: float = 0.0
var attacker_order = null
var ability = null
var splash_radius: float = 0.0
var style: String = "magic"

var _color: Color
var _start_height: float = 2.0
var _start_dist: float = 1.0
var _flat: Vector3              # posição lógica (y = 0)
var _visual: Node3D


func setup(p_target: Enemy, p_damage: float, p_order, p_ability, p_splash: float,
		p_style: String = "magic") -> void:
	target = p_target
	target_pos = _ground(p_target.global_position)
	damage = p_damage
	attacker_order = p_order
	ability = p_ability
	splash_radius = p_splash
	style = p_style
	_color = GameData.order_color(p_order)


func _ready() -> void:
	_flat = _ground(global_position)
	_start_height = global_position.y
	_start_dist = maxf(_flat.distance_to(target_pos), 0.5)
	_visual = Node3D.new()
	add_child(_visual)
	match style:
		"arrow":
			Art.part(_visual, Art.box(Vector3(0.04, 0.04, 0.7)), Art.wood(), Vector3.ZERO)
			Art.part(_visual, Art.cyl(0.0, 0.06, 0.16, 4), Art.metal(), Vector3(0, 0, -0.42), Vector3(-90, 0, 0))
			Art.part(_visual, Art.box(Vector3(0.12, 0.01, 0.14)), Art.color_mat(Color(0.8, 0.78, 0.7)), Vector3(0, 0, 0.3))
		"boulder":
			Art.part(_visual, Art.sphere(0.28, 0.5, 7, 4), Art.stone(), Vector3.ZERO)
		_:
			var core := Art.part(_visual, Art.sphere(0.16), Art.glow(_color, 6.0), Vector3.ZERO)
			core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var l := OmniLight3D.new()
			l.light_color = _color
			l.light_energy = 1.5
			l.omni_range = 3.0
			_visual.add_child(l)
			var trail := Art.order_particles(attacker_order, _color, 0.08)
			trail.amount = 24
			trail.lifetime = 0.45
			var pm := trail.process_material as ParticleProcessMaterial
			pm.gravity = Vector3.ZERO
			pm.scale_min = 0.12
			pm.scale_max = 0.22
			_visual.add_child(trail)


func _process(delta: float) -> void:
	if is_instance_valid(target) and target.is_alive():
		target_pos = _ground(target.global_position)
	var to_target: Vector3 = target_pos - _flat
	var step: float = SPEED * delta
	if to_target.length() <= maxf(step, HIT_DISTANCE):
		_impact()
		return
	_flat += to_target.normalized() * step
	# Altura visual: cai da torre até o alvo; a pedra faz um arco
	var frac: float = clampf(1.0 - _flat.distance_to(target_pos) / _start_dist, 0.0, 1.0)
	var h: float = lerpf(_start_height, 0.8, frac)
	if style == "boulder":
		h += sin(frac * PI) * (2.0 + _start_dist * 0.25)
	var new_pos := _flat + Vector3.UP * h
	if new_pos.distance_squared_to(global_position) > 0.0001:
		look_at(new_pos, Vector3.UP)
	global_position = new_pos
	if style == "boulder":
		_visual.rotation.x += delta * 8.0


func _impact() -> void:
	var hit_pos := target_pos + Vector3.UP * 0.6
	if splash_radius > 0.0:
		for e in get_tree().get_nodes_in_group("enemies"):
			var enemy := e as Enemy
			if enemy and enemy.is_alive() and _flat_dist(enemy.global_position, target_pos) <= splash_radius:
				enemy.take_hit(damage, attacker_order, ability)
	elif is_instance_valid(target) and target.is_alive():
		target.take_hit(damage, attacker_order, ability)
	var fx_color: Color = Color(0.7, 0.6, 0.45) if style != "magic" else _color
	if style != "arrow":
		VFX.impact(get_parent(), hit_pos, fx_color, splash_radius, 18 if splash_radius > 0.0 else 10)
	queue_free()


static func _ground(p: Vector3) -> Vector3:
	return Vector3(p.x, 0.0, p.z)


static func _flat_dist(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
