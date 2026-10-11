extends Node
## Carrega os números do jogo de data/*.json.
## Todo o código de jogo deve ler daqui, nunca usar números fixos.

const TOWERS_PATH := "res://data/towers.json"
const ELEMENTS_PATH := "res://data/elements.json"
const ECONOMY_PATH := "res://data/economy.json"

var towers: Dictionary = {}   # id -> dados da torre
var elements: Dictionary = {}
var economy: Dictionary = {}

signal data_reloaded


func _ready() -> void:
	reload()


func reload() -> void:
	towers.clear()
	for t in _load_json(TOWERS_PATH).get("towers", []):
		towers[t["id"]] = t
	elements = _load_json(ELEMENTS_PATH)
	economy = _load_json(ECONOMY_PATH)
	data_reloaded.emit()


func get_tower(id: String) -> Dictionary:
	return towers.get(id, {})


func dps(id: String) -> float:
	var t := get_tower(id)
	return float(t.get("damage", 0)) * float(t.get("attack_speed", 0))


## Multiplicador de dano de uma Ordem atacando outra (null = sem Ordem).
func damage_multiplier(attacker, defender) -> float:
	var m: Dictionary = elements.get("multipliers", {})
	if attacker == null:
		return 1.0
	if defender == null:
		return float(m.get("vs_no_order", 1.0))
	var cycle: Array = elements.get("cycle", [])
	var i := cycle.find(attacker)
	var j := cycle.find(defender)
	if i == -1 or j == -1:
		return 1.0
	var n := cycle.size()
	if (i + 1) % n == j:
		return float(m.get("strong", 1.0))
	if (j + 1) % n == i:
		return float(m.get("weak", 1.0))
	return float(m.get("neutral", 1.0))


## Ordem que define o tipo de dano da torre. Duais usam a PRIMEIRA Ordem da lista.
func tower_damage_order(t: Dictionary):
	var e = t.get("element", null)
	if e is Array:
		return e[0] if e.size() > 0 else null
	return e


## Cor de uma Ordem (null = sem Ordem), lida de elements.json.
func order_color(order) -> Color:
	var colors: Dictionary = elements.get("colors", {})
	var key: String = "none" if order == null else str(order)
	return Color.html(str(colors.get(key, "#ffffff")))


func order_display_name(order) -> String:
	if order == null:
		return "Sem Ordem"
	var names: Dictionary = elements.get("display_names", {})
	return str(names.get(order, order))


func ignores_armor(order) -> bool:
	return order != null and order in elements.get("armor_piercing_orders", [])


func load_map(map_id: String) -> Dictionary:
	return _load_json("res://data/maps/%s.json" % map_id)


func _load_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("GameData: não consegui abrir %s" % path)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Dictionary else {}
