extends Node
## Gera capturas de tela do jogo (para revisar o visual sem jogar).
## Monta uma defesa variada, chama uma onda e salva PNGs.
##
## Rodar (precisa de janela, NÃO usar --headless):
##   godot res://tests/screenshot.tscn -- --out=C:/caminho/pasta --wave=8 [--lang=en] [--menu] [--gallery]
## Ver docs/testing.md.

var main: Node
var out_dir := "user://screenshots"
var wave_to_show := 8
var frame := 0
var gallery := false
var menu_mode := false
var _original_lang := ""
var _suffix := ""
var shots := [
	{"frame": 150, "name": "overview", "yaw": 0.0, "height": 30.0, "target": Vector3(0, 0, 0)},
	{"frame": 260, "name": "closeup", "yaw": 0.5, "height": 13.0, "target": Vector3(-4, 0, -4)},
	{"frame": 330, "name": "castle", "yaw": -0.6, "height": 15.0, "target": Vector3(19, 0, 9)},
	{"frame": 400, "name": "portal", "yaw": 0.9, "height": 12.0, "target": Vector3(-18, 0, -9)},
]


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg == "--gallery":
			gallery = true
			shots = [{"frame": 90, "name": "gallery", "yaw": -0.35, "height": 7.0, "target": Vector3(-10, 0, -10)}]
		elif arg == "--menu":
			menu_mode = true
			shots = [{"frame": 90, "name": "menu"}]
		elif arg.begins_with("--lang="):
			_original_lang = Loc.language
			Loc.set_language(arg.substr(7))
			_suffix = "_" + arg.substr(7)
		elif arg.begins_with("--wave="):
			wave_to_show = int(arg.substr(7))
	DirAccess.make_dir_recursive_absolute(out_dir)
	main = load("res://scenes/menu.tscn" if menu_mode else "res://scenes/main.tscn").instantiate()
	add_child(main)


func _process(_delta: float) -> void:
	frame += 1
	if frame == 3 and not menu_mode:
		if gallery:
			_gallery()
		else:
			_setup()
	for s in shots:
		if frame == int(s["frame"]) - 25 and not menu_mode:
			main._cam_yaw = s["yaw"]
			main._cam_height = s["height"]
			main._cam_target = s["target"]
			main._update_camera()
		if frame == int(s["frame"]):
			var img := get_viewport().get_texture().get_image()
			var path: String = out_dir.path_join("%s%s.png" % [s["name"], _suffix])
			img.save_png(path)
			print("salvo: ", path)
	if frame > int(shots[-1]["frame"]) + 2:
		if _original_lang != "":
			Loc.set_language(_original_lang)   # não muda a preferência do jogador
		get_tree().quit()


func _setup() -> void:
	GameState.gold = 1000000
	GameState.favor = 12
	for o in ["fogo", "gelo", "sagrado", "necromancia", "druidico", "pedra"]:
		GameState.upgrade_order(o)
		GameState.upgrade_order(o)
	var grid: BuildGrid = main.grid
	var pts: Array = []
	for p in main.map_data["path"]:
		pts.append(Vector2(p[0], p[1]))
	var cells: Array = grid.buildable_cells()
	cells.sort_custom(func(a, b): return BuildGrid._dist_to_polyline(grid.cell_center_2d(a), pts) \
			< BuildGrid._dist_to_polyline(grid.cell_center_2d(b), pts))
	var plan := ["arqueiros", "catapulta", "fogo_1", "gelo_2", "sagrado_2", "necromancia_2",
			"druidico_1", "pedra_2", "fogo_pedra", "gelo_druidico", "sagrado_necromancia", "fogo_2",
			"arqueiros", "catapulta", "gelo_1", "necromancia_fogo"]
	for i in plan.size():
		var c: Vector2i = cells[i * 3]
		main._select_cell(c)
		var target: String = plan[i]
		var base := "catapulta" if target == "catapulta" else "arqueiros"
		main._on_build(base)
		if target != base:
			var t: Tower = grid.tower_at(c)
			var tier: String = str(GameData.get_tower(target).get("tier", ""))
			if tier == "dual":
				var first: String = str(GameData.get_tower(target)["element"][0])
				t.upgrade_to(first + "_1", 0)
			elif tier == "single_2":
				t.upgrade_to(target.replace("_2", "_1"), 0)
			t.upgrade_to(target, 0)
	main._select_cell(cells[9])
	# pula direto para a onda desejada
	main.waves.current_wave = wave_to_show - 1
	main.waves.start_next_wave()


## Uma criatura de cada facção, paradas lado a lado na estrada (+ um chefe).
func _gallery() -> void:
	var orders: Array = [null, "sagrado", "necromancia", "gelo", "fogo", "druidico", "pedra"]
	for i in orders.size():
		var e := Enemy.new()
		e.setup(100, 0.0, orders[i], 0.0, 0.0, 1, "normal", 1.0)
		main.path.add_child(e)
		e.progress = 4.0 + i * 2.0
	var boss := Enemy.new()
	boss.setup(100, 0.0, "fogo", 0.15, 0.0, 1, "chefe", 1.8)
	main.path.add_child(boss)
	boss.progress = 20.0
	var armored := Enemy.new()
	armored.setup(100, 0.0, "gelo", 0.35, 0.0, 1, "blindada", 1.15)
	main.path.add_child(armored)
	armored.progress = 2.0
