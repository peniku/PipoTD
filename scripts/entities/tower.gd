extends Node3D
class_name Tower
## Torre construída numa célula da grade (BuildGrid). Todos os números (dano, velocidade, alcance…)
## são lidos de GameData a cada disparo, então mudar towers.json + recarregar
## altera torres já construídas. Ver docs/systems/towers.md.

signal fired(tower: Tower)

var tower_id: String = ""
var total_spent: int = 0          # soma de tudo que foi gasto (para vender)
var _cooldown: float = 0.0
var _visual: TowerModel
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
			float(t.get("splash_radius", 0.0)), _projectile_style(t))
	get_parent().add_child(proj)
	proj.global_position = global_position + Vector3.UP * _muzzle_height
	if _visual:
		_visual.on_fire()
	fired.emit(self)


## Estilo visual do projétil: flecha (Arqueiros), pedra (Catapulta) ou magia.
func _projectile_style(t: Dictionary) -> String:
	if str(t.get("tier", "")) == "base":
		return "boulder" if float(t.get("splash_radius", 0.0)) > 0.0 else "arrow"
	return "magic"


func dps() -> float:
	return GameData.dps(tower_id)


# --- Visual (modelo em scripts/visual/tower_model.gd) -----------------------

func _rebuild_visual() -> void:
	if _visual:
		_visual.queue_free()
	_visual = TowerModel.new()
	_visual.build(data())
	add_child(_visual)
	_muzzle_height = _visual.muzzle_height
	_build_range_ring(float(data().get("range", 8.0)))


## Anel dourado no chão mostrando o alcance (visível quando selecionada).
func _build_range_ring(range_m: float) -> void:
	var was_visible := _range_ring != null and _range_ring.visible
	if _range_ring:
		_range_ring.queue_free()
	_range_ring = MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = range_m - 0.08
	ring.outer_radius = range_m
	ring.rings = 64
	ring.ring_segments = 4
	_range_ring.mesh = ring
	_range_ring.position.y = 0.08
	_range_ring.material_override = Art.glow(Color(1.0, 0.8, 0.4), 2.0)
	var disc := MeshInstance3D.new()
	disc.mesh = Art.cyl(range_m, range_m, 0.01, 48)
	var dm := StandardMaterial3D.new()
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dm.albedo_color = Color(1.0, 0.85, 0.5, 0.025)
	disc.material_override = dm
	_range_ring.add_child(disc)
	_range_ring.visible = was_visible
	add_child(_range_ring)


func set_selected(selected: bool) -> void:
	if _range_ring:
		_range_ring.visible = selected


## Recalcula visual/alcance (usado quando os dados são recarregados).
func refresh() -> void:
	_rebuild_visual()
