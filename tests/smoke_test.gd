extends Node
## Teste automático "fumaça": abre a partida, constrói e evolui torres,
## roda algumas ondas e confere se nada quebra. Não precisa de tela.
##
## Rodar (na pasta do projeto):
##   godot --headless --fixed-fps 60 res://tests/smoke_test.tscn
## Ver docs/testing.md.

const WAVES_TO_RUN := 6
const MAX_FRAMES := 60 * 60 * 6   # 6 minutos de jogo simulado

var main: Node
var frame := 0
var failures: Array = []


func _ready() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	add_child(main)


func _process(_delta: float) -> void:
	frame += 1
	if frame == 2:
		_setup_defense()
	if frame > 2 and main.waves.can_start_next() and main.waves.current_wave < WAVES_TO_RUN:
		main.waves.start_next_wave()
	var done: bool = main.waves.current_wave >= WAVES_TO_RUN and not main.waves.active
	if done or frame >= MAX_FRAMES or GameState.is_over:
		set_process(false)
		_finish(done)


func _setup_defense() -> void:
	var gs = GameState
	gs.gold = 100000  # dinheiro infinito para o teste
	var grid: BuildGrid = main.grid
	var cells: Array = grid.buildable_cells()
	_check(cells.size() > 100, "grade tem muitas células construíveis (%d)" % cells.size())
	# Nenhuma célula construível pode encostar na estrada
	var pts: Array = []
	for p in main.map_data["path"]:
		pts.append(Vector2(p[0], p[1]))
	var min_d: float = INF
	for c in cells:
		min_d = minf(min_d, BuildGrid._dist_to_polyline(grid.cell_center_2d(c), pts))
	_check(min_d >= 2.0, "células longe da estrada (mín %.1f m)" % min_d)
	# Escolhe as 10 células mais próximas da estrada (onde as torres alcançam)
	cells.sort_custom(func(a, b): return BuildGrid._dist_to_polyline(grid.cell_center_2d(a), pts) \
			< BuildGrid._dist_to_polyline(grid.cell_center_2d(b), pts))
	var chosen: Array = cells.slice(0, 10)
	for i in chosen.size():
		main._select_cell(chosen[i])
		main._on_build("arqueiros" if i % 2 == 0 else "catapulta")
		_check(grid.tower_at(chosen[i]) != null, "torre construída na célula %s" % str(chosen[i]))
	# Célula ocupada não aceita outra torre
	main._select_cell(chosen[0])
	var gold_before_dup: int = gs.gold
	main._on_build("arqueiros")
	_check(gs.gold == gold_before_dup, "não constrói em célula ocupada")
	# Compra Ordens e evolui
	gs.favor = 3
	_check(gs.upgrade_order("fogo"), "comprou Fogo")
	_check(gs.upgrade_order("pedra"), "comprou Pedra")
	main._select_cell(chosen[0])
	main._on_upgrade("fogo_1")
	_check(grid.tower_at(chosen[0]).tower_id == "fogo_1", "evoluiu para fogo_1")
	main._on_upgrade("fogo_pedra")
	_check(grid.tower_at(chosen[0]).tower_id == "fogo_pedra", "evoluiu para a Dual fogo_pedra")
	# Vende uma torre
	var gold_before: int = gs.gold
	main._select_cell(chosen[9])
	main._on_sell()
	_check(grid.tower_at(chosen[9]) == null and gs.gold > gold_before, "vendeu torre e recebeu ouro")
	main._select_cell(null)


func _check(cond: bool, label: String) -> void:
	print(("  OK   " if cond else "  FALHA ") + label)
	if not cond:
		failures.append(label)


func _finish(done: bool) -> void:
	var gs = GameState
	_check(done, "rodou %d ondas (parou na %d)" % [WAVES_TO_RUN, main.waves.current_wave])
	_check(gs.lives > 0, "castelo sobreviveu (vidas: %d)" % gs.lives)
	print("Frames simulados: %d | Ouro: %d | Vidas: %d" % [frame, gs.gold, gs.lives])
	print("RESULTADO: " + ("PASSOU" if failures.is_empty() else "FALHOU (%d)" % failures.size()))
	get_tree().quit(0 if failures.is_empty() else 1)
