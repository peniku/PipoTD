extends Node3D
## Cena principal da partida. Monta o mundo a partir de data/maps/<map>.json
## (chão, rota, grade de construção, câmera, luz), cria o WaveManager e o HUD, e trata a
## entrada do jogador (cliques, teclas, câmera). Ver docs/architecture.md.

@export var map_id: String = "map_01"

const CAM_PAN_SPEED := 18.0
const CAM_ZOOM_STEP := 2.0
const CAM_MIN_HEIGHT := 12.0
const CAM_MAX_HEIGHT := 45.0

var map_data: Dictionary
var path: Path3D
var waves: WaveManager
var hud: HUD
var camera: Camera3D
var _cam_target: Vector3 = Vector3.ZERO
var _cam_height: float = 28.0
var grid: BuildGrid
var _selected_cell: Vector2i = Vector2i(-1, -1)
var _has_selection: bool = false


func _ready() -> void:
	map_data = GameData.load_map(map_id)
	GameState.reset()
	_build_environment()
	_build_ground()
	_build_path()
	_build_grid()
	_build_camera()

	waves = WaveManager.new()
	waves.name = "WaveManager"
	add_child(waves)
	waves.setup(path)
	waves.wave_started.connect(func(_n, _i): _refresh_wave_button())
	waves.wave_cleared.connect(func(_n): _refresh_wave_button())
	waves.all_waves_cleared.connect(func(): hud.show_message("Vitória! Todas as ondas defendidas.", true))

	hud = HUD.new()
	hud.name = "HUD"
	add_child(hud)
	hud.start_wave_pressed.connect(_on_start_wave)
	hud.build_pressed.connect(_on_build)
	hud.upgrade_pressed.connect(_on_upgrade)
	hud.sell_pressed.connect(_on_sell)
	hud.order_pressed.connect(func(o): GameState.upgrade_order(o))
	hud.restart_pressed.connect(func(): get_tree().reload_current_scene())
	GameState.game_over.connect(_on_game_over)
	GameData.data_reloaded.connect(_on_data_reloaded)
	_refresh_wave_button()


# --- Montagem do mundo ------------------------------------------------------

func _build_environment() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.shadow_enabled = true
	add_child(sun)

	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.53, 0.68, 0.82)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.75, 0.75, 0.8)
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)


func _build_ground() -> void:
	var size: Array = map_data.get("ground_size", [44, 32])
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(float(size[0]), float(size[1]))
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.36, 0.55, 0.28)
	ground.material_override = mat
	ground.name = "Ground"
	add_child(ground)


func _build_path() -> void:
	path = Path3D.new()
	path.name = "Route"
	var curve := Curve3D.new()
	var pts: Array = map_data.get("path", [])
	for p in pts:
		curve.add_point(Vector3(float(p[0]), 0.0, float(p[1])))
	path.curve = curve
	add_child(path)

	# Estrada visual: uma caixa achatada por segmento
	var width: float = float(map_data.get("path_width", 2.4))
	var road_mat := StandardMaterial3D.new()
	road_mat.albedo_color = Color(0.62, 0.5, 0.35)
	for i in range(pts.size() - 1):
		var a := Vector3(float(pts[i][0]), 0.02, float(pts[i][1]))
		var b := Vector3(float(pts[i + 1][0]), 0.02, float(pts[i + 1][1]))
		var seg := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(width, 0.04, a.distance_to(b) + width)
		seg.mesh = box
		seg.material_override = road_mat
		add_child(seg)
		seg.position = (a + b) / 2.0
		seg.look_at(b, Vector3.UP)

	# Marcadores de entrada (verde) e saída/castelo (vermelho)
	if pts.size() >= 2:
		_add_marker(Vector3(float(pts[0][0]), 0, float(pts[0][1])), Color(0.2, 0.8, 0.2))
		_add_marker(Vector3(float(pts[-1][0]), 0, float(pts[-1][1])), Color(0.85, 0.2, 0.2))


func _add_marker(pos: Vector3, color: Color) -> void:
	var m := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.0, 2.5, 2.0)
	m.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	m.material_override = mat
	m.position = pos + Vector3.UP * 1.25
	add_child(m)


func _build_grid() -> void:
	grid = BuildGrid.new()
	grid.name = "BuildGrid"
	add_child(grid)
	grid.setup(map_data)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.fov = 50
	add_child(camera)
	_update_camera()


func _update_camera() -> void:
	camera.position = _cam_target + Vector3(0, _cam_height, _cam_height * 0.75)
	camera.look_at(_cam_target, Vector3.UP)


# --- Entrada ----------------------------------------------------------------

func _process(delta: float) -> void:
	var move := Vector3.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): move.z -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): move.z += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): move.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move.x += 1
	if move != Vector3.ZERO:
		_cam_target += move.normalized() * CAM_PAN_SPEED * delta
		_update_camera()
	# Cursor da grade segue o mouse
	var mouse_cell = _pick_cell(get_viewport().get_mouse_position())
	grid.show_hover(mouse_cell if mouse_cell != null else Vector2i(-1, -1), mouse_cell != null)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_select_cell(_pick_cell(event.position))
			MOUSE_BUTTON_RIGHT:
				_select_cell(null)
			MOUSE_BUTTON_WHEEL_UP:
				_cam_height = clampf(_cam_height - CAM_ZOOM_STEP, CAM_MIN_HEIGHT, CAM_MAX_HEIGHT)
				_update_camera()
			MOUSE_BUTTON_WHEEL_DOWN:
				_cam_height = clampf(_cam_height + CAM_ZOOM_STEP, CAM_MIN_HEIGHT, CAM_MAX_HEIGHT)
				_update_camera()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				_on_start_wave()
			KEY_ESCAPE:
				_select_cell(null)
			KEY_F5:
				GameData.reload()  # recarrega data/*.json sem fechar o jogo


## Célula da grade sob a posição de tela (raio da câmera × plano do chão), ou null.
func _pick_cell(screen_pos: Vector2):
	var from: Vector3 = camera.project_ray_origin(screen_pos)
	var dir: Vector3 = camera.project_ray_normal(screen_pos)
	var hit = Plane(Vector3.UP, 0.0).intersects_ray(from, dir)
	if hit == null:
		return null
	var c: Vector2i = grid.world_to_cell(hit)
	if not grid._in_bounds(c):
		return null
	return c


## Seleciona uma célula (null = limpar). Célula com torre → painel da torre;
## célula livre → painel de construção; célula bloqueada → limpa a seleção.
func _select_cell(cell) -> void:
	if _has_selection:
		var old: Tower = grid.tower_at(_selected_cell)
		if old:
			old.set_selected(false)
	_has_selection = false
	grid.show_selected(Vector2i.ZERO, false)
	if cell == null:
		hud.clear_selection()
		return
	var c: Vector2i = cell
	var tower: Tower = grid.tower_at(c)
	if tower == null and not grid.is_free(c):
		hud.clear_selection()
		return
	_selected_cell = c
	_has_selection = true
	grid.show_selected(c, true)
	if tower:
		tower.set_selected(true)
		hud.show_tower(tower)
	else:
		hud.show_empty_cell()


# --- Ações do jogador -------------------------------------------------------

func _on_start_wave() -> void:
	waves.start_next_wave()
	_refresh_wave_button()


func _refresh_wave_button() -> void:
	var can: bool = waves.can_start_next()
	var next_info: Dictionary = {}
	if waves.current_wave < waves.total_waves():
		next_info = WaveManager.describe_wave(waves.current_wave + 1)
	hud.set_wave_button(can, next_info)


func _on_build(tower_id: String) -> void:
	if not _has_selection or not grid.is_free(_selected_cell):
		return
	var cost: int = int(GameData.get_tower(tower_id).get("cost", 0))
	if not GameState.spend(cost):
		return
	var tower := Tower.new()
	tower.setup(tower_id, cost)
	grid.place_tower(_selected_cell, tower)
	_select_cell(_selected_cell)


func _on_upgrade(new_id: String) -> void:
	if not _has_selection:
		return
	var tower: Tower = grid.tower_at(_selected_cell)
	if tower == null:
		return
	var t: Dictionary = GameData.get_tower(new_id)
	if not GameState.meets_requirements(t.get("requires", {})):
		return
	var cost: int = int(t.get("cost", 0))
	if not GameState.spend(cost):
		return
	tower.upgrade_to(new_id, cost)
	_select_cell(_selected_cell)


func _on_sell() -> void:
	if not _has_selection:
		return
	var tower: Tower = grid.remove_tower(_selected_cell)
	if tower == null:
		return
	var refund: int = int(tower.total_spent * float(GameData.economy.get("sell_refund", 0.75)))
	tower.queue_free()
	GameState.earn(refund)
	_select_cell(_selected_cell)


func _on_game_over(wave_reached: int) -> void:
	hud.show_message("O castelo caiu! Você chegou à onda %d." % wave_reached, true)
	_refresh_wave_button()


func _on_data_reloaded() -> void:
	for t in get_tree().get_nodes_in_group("towers"):
		(t as Tower).refresh()
	hud.refresh()
	_refresh_wave_button()
