extends Node3D
class_name BuildGrid
## Grade de construção estilo Element TD: o chão é dividido em células e o
## jogador pode construir em qualquer célula livre que não esteja na estrada
## (nem colada na entrada/castelo). Cada torre ocupa uma célula.
## Ver docs/systems/map.md.

var cell_size: float = 2.0
var origin: Vector2 = Vector2.ZERO     # canto (x, z) mínimo da grade
var cols: int = 0
var rows: int = 0

var _buildable: Dictionary = {}        # Vector2i -> true
var _towers: Dictionary = {}           # Vector2i -> Tower
var _cursor: MeshInstance3D
var _cursor_mat: StandardMaterial3D
var _selected_marker: MeshInstance3D


## Calcula quais células podem receber torres a partir do mapa.
func setup(map_data: Dictionary) -> void:
	var g: Dictionary = map_data.get("build_grid", {})
	cell_size = float(g.get("cell_size", 2.0))
	var clearance: float = float(g.get("road_clearance", 0.0))
	var end_clearance: float = float(g.get("end_clearance", 3.0))
	var size: Array = map_data.get("ground_size", [44, 32])
	var w: float = float(size[0])
	var d: float = float(size[1])
	cols = int(floor(w / cell_size))
	rows = int(floor(d / cell_size))
	origin = Vector2(-cols * cell_size / 2.0, -rows * cell_size / 2.0)

	var pts: Array = []
	for p in map_data.get("path", []):
		pts.append(Vector2(float(p[0]), float(p[1])))
	var half_road: float = float(map_data.get("path_width", 2.4)) / 2.0
	# Uma célula fica bloqueada se seu quadrado encostar na estrada
	var block_dist: float = half_road + cell_size / 2.0 + clearance - 0.01

	for cx in cols:
		for cz in rows:
			var c := Vector2i(cx, cz)
			var center: Vector2 = cell_center_2d(c)
			if _dist_to_polyline(center, pts) < block_dist:
				continue
			if pts.size() > 0 and (center.distance_to(pts[0]) < end_clearance \
					or center.distance_to(pts[-1]) < end_clearance):
				continue
			_buildable[c] = true

	for b in g.get("blocked_cells", []):
		_buildable.erase(Vector2i(int(b[0]), int(b[1])))

	_build_overlay()
	_build_cursor()


# --- Consultas --------------------------------------------------------------

func cell_center_2d(c: Vector2i) -> Vector2:
	return origin + Vector2((c.x + 0.5) * cell_size, (c.y + 0.5) * cell_size)


func cell_to_world(c: Vector2i) -> Vector3:
	var p: Vector2 = cell_center_2d(c)
	return Vector3(p.x, 0.0, p.y)


func world_to_cell(pos: Vector3) -> Vector2i:
	return Vector2i(int(floor((pos.x - origin.x) / cell_size)), int(floor((pos.z - origin.y) / cell_size)))


func is_buildable(c: Vector2i) -> bool:
	return _buildable.has(c)


func is_free(c: Vector2i) -> bool:
	return is_buildable(c) and not _towers.has(c)


func tower_at(c: Vector2i) -> Tower:
	return _towers.get(c, null)


func buildable_cells() -> Array:
	return _buildable.keys()


# --- Alterações -------------------------------------------------------------

func place_tower(c: Vector2i, tower: Tower) -> bool:
	if not is_free(c):
		return false
	add_child(tower)
	tower.position = cell_to_world(c)
	_towers[c] = tower
	return true


func remove_tower(c: Vector2i) -> Tower:
	var t: Tower = _towers.get(c, null)
	_towers.erase(c)
	return t


# --- Visual -----------------------------------------------------------------

## Desenha um quadrado claro em cada célula construível (MultiMesh = 1 draw call).
func _build_overlay() -> void:
	var quad := PlaneMesh.new()
	quad.size = Vector2(cell_size * 0.92, cell_size * 0.92)
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1, 1, 1, 0.07)
	quad.material = mat

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = quad
	mm.instance_count = _buildable.size()
	var i := 0
	for c in _buildable:
		mm.set_instance_transform(i, Transform3D(Basis(), cell_to_world(c) + Vector3.UP * 0.02))
		i += 1
	var mmi := MultiMeshInstance3D.new()
	mmi.name = "GridOverlay"
	mmi.multimesh = mm
	add_child(mmi)


func _build_cursor() -> void:
	_cursor = _make_square(Color(0.3, 1.0, 0.3, 0.35))
	_cursor_mat = _cursor.material_override
	_cursor.visible = false
	add_child(_cursor)
	_selected_marker = _make_square(Color(1.0, 0.85, 0.3, 0.5))
	_selected_marker.visible = false
	add_child(_selected_marker)


func _make_square(color: Color) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(cell_size, cell_size)
	m.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	m.material_override = mat
	return m


## Mostra o cursor sobre a célula: verde = livre, vermelho = não dá para construir.
func show_hover(c: Vector2i, visible_flag: bool) -> void:
	if not visible_flag or not _in_bounds(c):
		_cursor.visible = false
		return
	_cursor.visible = true
	_cursor.position = cell_to_world(c) + Vector3.UP * 0.04
	if is_free(c) or tower_at(c) != null:
		_cursor_mat.albedo_color = Color(0.3, 1.0, 0.3, 0.35)
	else:
		_cursor_mat.albedo_color = Color(1.0, 0.3, 0.3, 0.35)


func show_selected(c: Vector2i, visible_flag: bool) -> void:
	_selected_marker.visible = visible_flag
	if visible_flag:
		_selected_marker.position = cell_to_world(c) + Vector3.UP * 0.05


func _in_bounds(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < cols and c.y < rows


static func _dist_to_polyline(p: Vector2, pts: Array) -> float:
	var best: float = INF
	for i in range(pts.size() - 1):
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		var ab: Vector2 = b - a
		var t: float = 0.0
		if ab.length_squared() > 0.0:
			t = clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
		best = minf(best, p.distance_to(a + ab * t))
	return best
