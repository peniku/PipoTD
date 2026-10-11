extends Node
class_name WaveManager
## Gera e solta as ondas de inimigos na rota, a partir de economy.json.
## Ver docs/systems/waves.md para a fórmula completa.

signal wave_started(n: int, info: Dictionary)
signal wave_cleared(n: int)
signal all_waves_cleared

var path: Path3D
var current_wave: int = 0
var active: bool = false

var _to_spawn: int = 0
var _spawn_timer: float = 0.0
var _alive: int = 0
var _info: Dictionary = {}


func setup(p_path: Path3D) -> void:
	path = p_path


func total_waves() -> int:
	return int(GameData.economy.get("waves", {}).get("count", 55))


func can_start_next() -> bool:
	return not active and current_wave < total_waves() and not GameState.is_over


## Calcula a configuração da onda n (1-based). Função pura: útil para o
## painel de balanceamento mostrar a curva de vida das ondas.
static func describe_wave(n: int) -> Dictionary:
	var w: Dictionary = GameData.economy.get("waves", {})
	var pattern: Array = w.get("pattern", ["normal"])
	var wave_type: String = str(pattern[(n - 1) % pattern.size()])
	var types: Dictionary = w.get("types", {})
	var tp: Dictionary = types.get(wave_type, {})

	var order = null
	var first_el: int = int(w.get("first_elemental_wave", 5))
	if n >= first_el:
		var cycle: Array = GameData.elements.get("cycle", [])
		if cycle.size() > 0:
			order = cycle[(n - first_el) % cycle.size()]

	var hp: float = float(w.get("base_hp", 60)) * pow(float(w.get("hp_growth_per_wave", 1.12)), n - 1)
	hp *= float(tp.get("hp_mult", 1.0))
	if order != null:
		hp *= float(w.get("elemental_hp_multiplier", 1.0))

	var kg: Dictionary = GameData.economy.get("kill_gold", {})
	var gold: float = (float(kg.get("base", 3)) + float(kg.get("growth_per_wave", 0.5)) * (n - 1))
	gold *= float(tp.get("gold_mult", 1.0))

	return {
		"wave": n,
		"type": wave_type,
		"order": order,
		"count": int(tp.get("count", 10)),
		"hp": hp,
		"speed": float(w.get("base_speed", 3.0)) * float(tp.get("speed_mult", 1.0)),
		"armor": float(tp.get("armor", 0.0)),
		"regen": float(tp.get("regen", 0.0)),
		"gold": maxi(1, int(round(gold))),
		"scale": float(tp.get("scale", 1.0)),
	}


func start_next_wave() -> bool:
	if not can_start_next():
		return false
	current_wave += 1
	_info = describe_wave(current_wave)
	_to_spawn = int(_info["count"])
	_spawn_timer = 0.0
	active = true
	GameState.on_wave_started(current_wave)
	wave_started.emit(current_wave, _info)
	return true


func _process(delta: float) -> void:
	if not active or _to_spawn <= 0:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_one()
		var interval: float = float(GameData.economy.get("waves", {}).get("spawn_interval", 0.8))
		_spawn_timer = interval


func _spawn_one() -> void:
	var e := Enemy.new()
	e.setup(_info["hp"], _info["speed"], _info["order"], _info["armor"], _info["regen"],
			_info["gold"], _info["type"], _info["scale"])
	e.died.connect(_on_enemy_died)
	e.reached_end.connect(_on_enemy_reached_end)
	path.add_child(e)
	_to_spawn -= 1
	_alive += 1


func _on_enemy_died(_e: Enemy, gold: int) -> void:
	GameState.earn(gold)
	_enemy_gone()


func _on_enemy_reached_end(e: Enemy) -> void:
	var lives_cost: Dictionary = GameData.economy.get("lives_lost", {})
	GameState.lose_life(int(lives_cost.get(e.wave_type, lives_cost.get("default", 1))))
	_enemy_gone()


func _enemy_gone() -> void:
	_alive -= 1
	if active and _to_spawn <= 0 and _alive <= 0:
		active = false
		GameState.on_wave_cleared(current_wave)
		wave_cleared.emit(current_wave)
		if current_wave >= total_waves():
			all_waves_cleared.emit()
