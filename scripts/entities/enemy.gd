extends PathFollow3D
class_name Enemy
## Inimigo que anda pela rota fixa (filho de um Path3D).
## Ver docs/systems/enemies.md e docs/systems/combat.md.

signal died(enemy: Enemy, gold_reward: int)
signal reached_end(enemy: Enemy)

var max_hp: float = 100.0
var hp: float = 100.0
var speed: float = 3.0          # metros por segundo
var order = null                # Ordem do inimigo (String) ou null
var armor: float = 0.0          # 0..1, fração do dano bloqueada
var regen: float = 0.0          # fração da vida máxima regenerada por segundo
var gold_reward: int = 1
var wave_type: String = "normal"

# Efeitos de status ativos
var _slow_amount: float = 0.0
var _slow_time: float = 0.0
var _stun_time: float = 0.0
var _poison_dps: float = 0.0
var _poison_time: float = 0.0
var _poison_order = null

var _alive: bool = true
var _model: EnemyModel
var _hp_root: Node3D
var _hp_bar: MeshInstance3D
var _bar_width: float = 1.2


## Configura o inimigo. Chamar antes de adicionar à árvore.
func setup(p_hp: float, p_speed: float, p_order, p_armor: float, p_regen: float,
		p_gold: int, p_type: String, p_scale: float) -> void:
	max_hp = p_hp
	hp = p_hp
	speed = p_speed
	order = p_order
	armor = p_armor
	regen = p_regen
	gold_reward = p_gold
	wave_type = p_type
	scale = Vector3.ONE * p_scale


func _ready() -> void:
	loop = false
	rotation_mode = PathFollow3D.ROTATION_Y
	add_to_group("enemies")
	_build_visual()


func _build_visual() -> void:
	var faction: Dictionary = GameData.faction(order)
	var model := EnemyModel.new()
	model.build(str(faction.get("model", "goblin")), order, wave_type == "chefe", armor > 0.0)
	add_child(model)
	_model = model

	# Barra de vida: fundo escuro + preenchimento, sempre virada para a câmera.
	# Só aparece depois do primeiro dano.
	_hp_root = Node3D.new()
	_hp_root.position.y = model.height + 0.35
	_hp_root.visible = false
	add_child(_hp_root)
	var back := MeshInstance3D.new()
	var bq := QuadMesh.new()
	bq.size = Vector2(_bar_width + 0.08, 0.17)
	back.mesh = bq
	back.material_override = _bar_mat(Color(0.05, 0.03, 0.02, 0.85), 0)
	_hp_root.add_child(back)
	_hp_bar = MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(_bar_width, 0.1)
	_hp_bar.mesh = quad
	_hp_bar.material_override = _bar_mat(Color(0.2, 0.9, 0.2), 1)
	_hp_root.add_child(_hp_bar)


func _bar_mat(c: Color, priority: int) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.no_depth_test = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.render_priority = priority
	m.albedo_color = c
	return m


func _process(delta: float) -> void:
	if not _alive:
		return
	_tick_status(delta)
	var moving: bool = _stun_time <= 0.0
	if moving:
		progress += speed * (1.0 - _slow_amount) * delta
	if _model:
		_model.animate(delta, 1.0 - _slow_amount, moving)
	if progress_ratio >= 0.999:
		_alive = false
		reached_end.emit(self)
		queue_free()


func _tick_status(delta: float) -> void:
	if regen > 0.0 and hp < max_hp:
		hp = minf(max_hp, hp + max_hp * regen * delta)
		_update_bar()
	if _slow_time > 0.0:
		_slow_time -= delta
		if _slow_time <= 0.0:
			_slow_amount = 0.0
	if _stun_time > 0.0:
		_stun_time -= delta
	if _poison_time > 0.0:
		_poison_time -= delta
		_apply_damage(_poison_dps * delta, _poison_order, true)


## Recebe um golpe de torre. attacker_order = Ordem da torre (ou null).
func take_hit(damage: float, attacker_order, ability) -> void:
	if not _alive:
		return
	_apply_damage(damage, attacker_order, false)
	if _alive and ability is Dictionary:
		_apply_ability(ability, damage, attacker_order)


func _apply_damage(amount: float, attacker_order, ignore_armor: bool) -> void:
	if not _alive:
		return
	var mult: float = GameData.damage_multiplier(attacker_order, order)
	var final_dmg: float = amount * mult
	if not ignore_armor and not GameData.ignores_armor(attacker_order):
		final_dmg *= (1.0 - armor)
	hp -= final_dmg
	_update_bar()
	if hp <= 0.0:
		_alive = false
		_death_fx()
		died.emit(self, gold_reward)
		queue_free()


## Explosão na cor da facção + "+ouro" flutuando (só visual).
func _death_fx() -> void:
	var parent := get_parent()
	var pos := global_position + Vector3.UP * (_model.height * 0.5 if _model else 0.8)
	VFX.impact(parent, pos, GameData.order_color(order), 0.0, 22 if wave_type == "chefe" else 12)
	VFX.float_text(parent, pos + Vector3.UP * 0.6, "+%d" % gold_reward, Color(1.0, 0.82, 0.3))


func _apply_ability(ability: Dictionary, damage: float, attacker_order) -> void:
	match str(ability.get("type", "")):
		"slow":
			_slow_amount = maxf(_slow_amount, float(ability.get("amount", 0.3)))
			_slow_time = maxf(_slow_time, float(ability.get("duration", 2.0)))
		"stun":
			if randf() < float(ability.get("chance", 0.0)):
				_stun_time = maxf(_stun_time, float(ability.get("duration", 0.5)))
		"poison":
			_poison_dps = damage * float(ability.get("dps_ratio", 0.5))
			_poison_time = float(ability.get("duration", 4.0))
			_poison_order = attacker_order
		_:
			pass  # habilidades ainda não implementadas (ex.: "todo" das Duais)


func _update_bar() -> void:
	if _hp_bar == null:
		return
	var ratio: float = clampf(hp / max_hp, 0.0, 1.0)
	_hp_root.visible = ratio < 0.999
	_hp_bar.scale.x = maxf(ratio, 0.01)
	var mat := _hp_bar.material_override as StandardMaterial3D
	mat.albedo_color = Color(0.85, 0.15, 0.1).lerp(Color(0.35, 0.85, 0.25), ratio)


func is_alive() -> bool:
	return _alive
