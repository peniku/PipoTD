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
	_test_localization()
	_test_menu()
	main = load("res://scenes/main.tscn").instantiate()
	add_child(main)


func _process(_delta: float) -> void:
	frame += 1
	if frame == 2:
		_test_targeting()
		_test_hud_language()
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


## Os dois idiomas têm as mesmas chaves e todo nome de torre/Ordem/facção existe.
func _test_localization() -> void:
	var pt: Array = Loc.keys("pt")
	var en: Array = Loc.keys("en")
	var missing_en: Array = pt.filter(func(k): return not k in en)
	var missing_pt: Array = en.filter(func(k): return not k in pt)
	_check(missing_en.is_empty() and missing_pt.is_empty(),
			"pt e en têm as mesmas chaves (faltando en: %s, pt: %s)" % [missing_en, missing_pt])
	var ok := true
	for id in GameData.towers:
		for code in Loc.LANGUAGES:
			ok = ok and Loc.has_key("tower.%s.name" % id, code) and Loc.has_key("tower.%s.role" % id, code)
	for o in GameData.elements.get("orders", []) + ["none"]:
		for code in Loc.LANGUAGES:
			ok = ok and Loc.has_key("order.%s" % o, code) and Loc.has_key("faction.%s.name" % o, code) \
					and Loc.has_key("faction.%s.boss" % o, code)
	_check(ok, "todas as torres, Ordens e facções têm nome em todos os idiomas")


## O menu principal abre sem erro.
func _test_menu() -> void:
	var menu: Node = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	_check(menu.get("_play") != null and menu._play.text != "", "menu principal abre e tem botão Jogar")
	menu.queue_free()


## Trocar o idioma muda os textos da interface e os nomes vindos dos dados.
func _test_hud_language() -> void:
	var original: String = Loc.language
	Loc.set_language("en")
	_check(GameData.tower_name("arqueiros") == "Archer Tower" and main.hud._wave_button.text.contains("Call wave"),
			"inglês: nomes e HUD traduzidos")
	Loc.set_language("pt")
	_check(GameData.tower_name("arqueiros") == "Torre dos Arqueiros" and main.hud._wave_button.text.contains("Chamar"),
			"português: nomes e HUD traduzidos")
	Loc.set_language(original)


## Cada modo de mira escolhe o inimigo certo entre 5 parados na estrada.
func _test_targeting() -> void:
	var grid: BuildGrid = main.grid
	var cell: Vector2i = grid.world_to_cell(Vector3(-17, 0, -7))
	_check(grid.is_free(cell), "célula de teste da mira está livre")
	var tower := Tower.new()
	tower.setup("arqueiros", 0)
	grid.place_tower(cell, tower)
	# [progresso na rota, vida]
	var specs := {"A": [1.0, 200.0], "B": [3.5, 150.0], "C": [5.0, 50.0], "D": [6.5, 600.0], "E": [8.0, 300.0]}
	var enemies := {}
	for k in specs:
		var e := Enemy.new()
		e.setup(specs[k][1], 0.0, null, 0.0, 0.0, 0, "normal", 1.0)
		main.path.add_child(e)
		e.progress = specs[k][0]
		enemies[k] = e
	var expected := {"first": "E", "last": "A", "strongest": "D", "weakest": "C", "closest": "B"}
	_check(tower.targeting == "first", "mira padrão vem do towers.json (first)")
	for mode in expected:
		tower.set_targeting(mode)
		var got: Enemy = tower.find_target(30.0)
		_check(got == enemies[expected[mode]], "mira '%s' escolhe o inimigo %s" % [mode, expected[mode]])
	tower.set_targeting("weakest")
	tower.upgrade_to("fogo_1", 0)
	_check(tower.targeting == "weakest", "mira continua igual depois de evoluir a torre")
	tower.cycle_targeting()
	_check(tower.targeting == "closest", "tecla T passa para o próximo modo")
	for k in enemies:
		enemies[k].queue_free()
	grid.remove_tower(cell)
	tower.queue_free()
