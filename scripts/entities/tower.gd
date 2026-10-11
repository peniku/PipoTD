extends Node3D
class_name Tower
## Torre construída num slot. Todos os números (dano, velocidade, alcance…)
## são lidos de GameData a cada disparo, então mudar towers.json + recarregar
## altera torres já construídas. Ver docs/systems/towers.md.

signal fired(tower: Tower)

var tower_id: String = ""
var total_spent: int = 0          # soma de tudo que foi gasto (para vender)
var _cooldown: float = 0.0
var _visual: Node3D
var _range_ring: MeshInstance3D
var _muzzle_height: float = 2.0


func setup(id: String, cost_paid: int) -> void:
	tower_id = id
	total_spent = cost_paid


func _ready() -> void:
	add_to_group("towers")
	_rebuild_visual()


func data() -> Dictionary:
	return GameData.get_tower(tower_id)


func damage_order():
	return GameData.tower_damage_order(data())


## Troca esta torre pela evolução new_id (o custo já foi cobrado por quem chama).
func upgrade_to(new_id: String, cost_paid: int) -> void:
	tower_id = new_id
	total_spent += cost_paid
	_rebuild_visual()


func _process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var t: Dictionary = data()
	var aps: float = float(t.get("attack_speed", 1.0))
	if aps <= 0.0:
		return
	var target: Enemy = _find_target(float(t.get("range", 8.0)))
	if target == null:
		return
	_shoot(target, t)
	_cooldown = 1.0 / aps


## Alvo = inimigo vivo dentro do alcance que está mais adiantado na rota.
func _find_target(range_m: float) -> Enemy:
	var best: Enemy = null
	var best_progress: float = -1.0
	var my_pos := Vector2(global_position.x, global_position.z)
	for e in get_tree().get_nodes_in_group("enemies"):
		var enemy := e as Enemy
		if enemy == null or not enemy.is_alive():
			continue
		var p := Vector2(enemy.global_position.x, enemy.global_position.z)
		if my_pos.distance_to(p) <= range_m and enemy.progress > best_progress:
			best = enemy
			best_progress = enemy.progress
	return best


func _shoot(target: Enemy, t: Dictionary) -> void:
	var proj := Projectile.new()
	proj.setup(target, float(t.get("damage", 0)), damage_order(), t.get("ability", null),
			float(t.get("splash_radius", 0.0)))
	get_parent().add_child(proj)
	proj.global_position = global_position + Vector3.UP * _muzzle_height
	fired.emit(self)


func dps() -> float:
	return GameData.dps(tower_id)


# --- Visual provisório (formas simples até termos modelos 3D) ---------------

func _rebuild_visual() -> void:
	if _visual:
		_visual.queue_free()
	_visual = Node3D.new()
	add_child(_visual)
	var t: Dictionary = data()
	var tier: String = str(t.get("tier", "base"))
	var height: float = 1.6
	match tier:
		"single_1": height = 2.0
		"single_2": height = 2.5
		"single_3": height = 3.0
		"dual": height = 3.4
	_muzzle_height = height + 0.3

	var base := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.6
	cyl.bottom_radius = 0.8
	cyl.height = height
	base.mesh = cyl
	base.position.y = height / 2.0
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.55, 0.52, 0.48)
	base.material_override = stone
	_visual.add_child(base)

	# "Telhado" colorido pela Ordem; Duais ganham duas cores
	var orders: Array = []
	var el = t.get("element", null)
	if el is Array:
		orders = el
	else:
		orders = [el]
	for i in orders.size():
		var roof := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = 0.75 - 0.2 * i
		cone.height = 0.9
		roof.mesh = cone
		roof.position.y = height + 0.45 + 0.5 * i
		var mat := StandardMaterial3D.new()
		mat.albedo_color = GameData.order_color(orders[i])
		roof.material_override = mat
		_visual.add_child(roof)

	if float(t.get("splash_radius", 0.0)) > 0.0 and tier == "base":
		# Catapulta: um "braço" para diferenciar dos Arqueiros
		var arm := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.2, 0.2, 1.6)
		arm.mesh = box
		arm.position = Vector3(0, height + 0.2, 0)
		arm.rotation_degrees.x = -30
		arm.material_override = stone
		_visual.add_child(arm)

	_build_range_ring(float(t.get("range", 8.0)))


func _build_range_ring(range_m: float) -> void:
	var was_visible := _range_ring != null and _range_ring.visible
	if _range_ring:
		_range_ring.queue_free()
	_range_ring = MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = range_m
	disc.bottom_radius = range_m
	disc.height = 0.02
	_range_ring.mesh = disc
	_range_ring.position.y = 0.05
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1, 1, 1, 0.12)
	_range_ring.material_override = mat
	_range_ring.visible = was_visible
	add_child(_range_ring)


func set_selected(selected: bool) -> void:
	if _range_ring:
		_range_ring.visible = selected


## Recalcula visual/alcance (usado quando os dados são recarregados).
func refresh() -> void:
	_rebuild_visual()
