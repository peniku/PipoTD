extends Node3D
class_name Projectile
## Projétil disparado por uma torre. Persegue o alvo; se o alvo morrer no
## caminho, segue até a última posição conhecida. Ao chegar aplica o dano
## (e o dano em área, se splash_radius > 0). Ver docs/systems/combat.md.

const SPEED := 28.0
const HIT_DISTANCE := 0.4

var target: Enemy
var target_pos: Vector3
var damage: float = 0.0
var attacker_order = null
var ability = null
var splash_radius: float = 0.0


func setup(p_target: Enemy, p_damage: float, p_order, p_ability, p_splash: float) -> void:
	target = p_target
	target_pos = p_target.global_position + Vector3.UP * 0.6
	damage = p_damage
	attacker_order = p_order
	ability = p_ability
	splash_radius = p_splash


func _ready() -> void:
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.15 if splash_radius <= 0.0 else 0.3
	sphere.height = sphere.radius * 2.0
	mesh.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = GameData.order_color(attacker_order)
	mesh.material_override = mat
	add_child(mesh)


func _process(delta: float) -> void:
	if is_instance_valid(target) and target.is_alive():
		target_pos = target.global_position + Vector3.UP * 0.6
	var to_target: Vector3 = target_pos - global_position
	var step: float = SPEED * delta
	if to_target.length() <= maxf(step, HIT_DISTANCE):
		_impact()
		return
	global_position += to_target.normalized() * step


func _impact() -> void:
	if splash_radius > 0.0:
		for e in get_tree().get_nodes_in_group("enemies"):
			var enemy := e as Enemy
			if enemy and enemy.is_alive() and _flat_dist(enemy.global_position, target_pos) <= splash_radius:
				enemy.take_hit(damage, attacker_order, ability)
	elif is_instance_valid(target) and target.is_alive():
		target.take_hit(damage, attacker_order, ability)
	queue_free()


static func _flat_dist(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
