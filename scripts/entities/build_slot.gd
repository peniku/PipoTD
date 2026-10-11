extends StaticBody3D
class_name BuildSlot
## Lugar onde o jogador pode construir uma torre. Clicável (colisão na
## camada 2). Guarda referência à torre construída. Ver docs/systems/map.md.

const PICK_LAYER := 2
const SIZE := 1.8

var tower: Tower = null
var _plate: MeshInstance3D
var _mat: StandardMaterial3D


func _ready() -> void:
	collision_layer = 0
	set_collision_layer_value(PICK_LAYER, true)
	collision_mask = 0

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SIZE, 0.6, SIZE)
	shape.shape = box
	shape.position.y = 0.3
	add_child(shape)

	_plate = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(SIZE, 0.15, SIZE)
	_plate.mesh = mesh
	_plate.position.y = 0.075
	_mat = StandardMaterial3D.new()
	_plate.material_override = _mat
	add_child(_plate)
	set_selected(false)


func is_empty() -> bool:
	return tower == null


func set_selected(selected: bool) -> void:
	_mat.albedo_color = Color(0.95, 0.8, 0.3) if selected else Color(0.42, 0.40, 0.36)
	if tower:
		tower.set_selected(selected)
