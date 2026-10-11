extends Node
## Estado da partida do jogador local: ouro, vidas, onda, Favor Real e Ordens.
## Singleton (autoload) "GameState". Ver docs/systems/economy.md.

signal changed                      # qualquer valor mudou (HUD escuta)
signal game_over(wave_reached: int)

var gold: int = 0
var lives: int = 0
var wave: int = 0                   # última onda iniciada (0 = nenhuma)
var favor: int = 0                  # Favor Real disponível
var orders: Dictionary = {}         # "fogo" -> nível (0..order_max_level)
var is_over: bool = false


func _ready() -> void:
	reset()


func reset() -> void:
	var eco: Dictionary = GameData.economy
	gold = int(eco.get("start_gold", 150))
	lives = int(eco.get("start_lives", 50))
	favor = int(eco.get("start_favor", 0))
	wave = 0
	is_over = false
	orders.clear()
	for o in GameData.elements.get("orders", []):
		orders[o] = 0
	changed.emit()


# --- Ouro -------------------------------------------------------------------

func can_afford(amount: int) -> bool:
	return gold >= amount


func spend(amount: int) -> bool:
	if not can_afford(amount):
		return false
	gold -= amount
	changed.emit()
	return true


func earn(amount: int) -> void:
	gold += amount
	changed.emit()


## Juros aplicados ao fim de cada onda: ouro × taxa, limitado por interest_cap.
func apply_interest() -> int:
	var eco: Dictionary = GameData.economy
	var rate: float = float(eco.get("interest_per_wave", 0.0))
	var bonus: int = int(floor(gold * rate))
	var cap = eco.get("interest_cap", null)
	if cap != null:
		bonus = mini(bonus, int(cap))
	if bonus > 0:
		earn(bonus)
	return bonus


# --- Vidas ------------------------------------------------------------------

func lose_life(amount: int = 1) -> void:
	if is_over:
		return
	lives = maxi(lives - amount, 0)
	changed.emit()
	if lives == 0:
		is_over = true
		game_over.emit(wave)


# --- Ondas e Favor Real -----------------------------------------------------

func on_wave_started(n: int) -> void:
	wave = n
	changed.emit()


## Chamado quando uma onda termina (todos os inimigos mortos ou passaram).
func on_wave_cleared(n: int) -> void:
	apply_interest()
	var every: int = int(GameData.economy.get("favor_every_n_waves", 5))
	if every > 0 and n % every == 0:
		favor += 1
	changed.emit()


# --- Ordens -----------------------------------------------------------------

func order_level(order: String) -> int:
	return int(orders.get(order, 0))


func can_upgrade_order(order: String) -> bool:
	var max_lv: int = int(GameData.economy.get("order_max_level", 3))
	var cost: int = int(GameData.economy.get("order_level_cost_favor", 1))
	return order_level(order) < max_lv and favor >= cost


func upgrade_order(order: String) -> bool:
	if not can_upgrade_order(order):
		return false
	favor -= int(GameData.economy.get("order_level_cost_favor", 1))
	orders[order] = order_level(order) + 1
	changed.emit()
	return true


## true se o jogador tem todas as Ordens nos níveis exigidos (campo "requires").
func meets_requirements(requires: Dictionary) -> bool:
	for o in requires:
		if order_level(o) < int(requires[o]):
			return false
	return true
