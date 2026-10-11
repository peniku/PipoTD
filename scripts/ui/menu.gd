extends Node3D
## Menu principal (cena inicial do jogo). Fundo: o mapa 1 montado pelo
## WorldBuilder com algumas torres decorativas e câmera girando devagar.
## Botões: Jogar, Idioma (alterna PT/EN e salva) e Sair.
## Ver docs/systems/menu.md.

const GAME_SCENE := "res://scenes/main.tscn"
const MAP_ID := "map_01"
## Torres só de enfeite no fundo: [id, x, z]
const DECOR_TOWERS := [
	["fogo_3", -6.0, -5.0], ["gelo_2", 4.0, -5.0], ["sagrado_necromancia", -2.0, 4.0],
	["druidico_pedra", 6.0, 4.0], ["arqueiros", -14.0, -5.0], ["catapulta", 14.0, 4.0],
]

var _camera: Camera3D
var _yaw: float = 0.0
var _title: Label
var _subtitle: Label
var _play: Button
var _lang: Button
var _quit: Button
var _hint: Label
var _credits: Label


func _ready() -> void:
	WorldBuilder.new().build(self, GameData.load_map(MAP_ID))
	for d in DECOR_TOWERS:
		var m := TowerModel.new()
		m.build(GameData.get_tower(d[0]))
		m.position = Vector3(d[1], 0, d[2])
		add_child(m)
	_camera = Camera3D.new()
	_camera.fov = 45
	_camera.far = 400.0
	add_child(_camera)
	_build_ui()
	Loc.language_changed.connect(_retranslate)
	_retranslate()
	_play.grab_focus()


func _process(delta: float) -> void:
	_yaw += delta * 0.04
	_camera.position = Vector3(sin(_yaw) * 34.0, 17.0, cos(_yaw) * 34.0)
	_camera.look_at(Vector3(0, 1.5, 0), Vector3.UP)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.theme = HUD.make_theme()
	layer.add_child(root)

	# Escurece as bordas para destacar o painel
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.25)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(440, 0)
	var style := HUD.panel_style(0.82)
	style.set_content_margin_all(32)
	panel.add_theme_stylebox_override("panel", style)
	root.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)

	_title = _label(col, 64, HUD.GOLD)
	_subtitle = _label(col, 18, HUD.MUTED)
	col.add_child(HSeparator.new())
	_play = _button(col, func(): get_tree().change_scene_to_file(GAME_SCENE))
	_lang = _button(col, func(): Loc.set_language(Loc.next_language()))
	_quit = _button(col, func(): get_tree().quit())
	_hint = _label(col, 13, HUD.MUTED)

	_credits = Label.new()
	_credits.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_credits.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_credits.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_credits.offset_bottom = -14
	_credits.add_theme_font_size_override("font_size", 12)
	_credits.add_theme_color_override("font_color", HUD.MUTED)
	root.add_child(_credits)


func _label(parent: Control, size: int, color: Color) -> Label:
	var l := Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l


func _button(parent: Control, action: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 52)
	b.add_theme_font_size_override("font_size", 24)
	b.pressed.connect(action)
	parent.add_child(b)
	return b


func _retranslate() -> void:
	_title.text = Loc.t("hud.title")
	_subtitle.text = Loc.t("menu.subtitle")
	_play.text = Loc.t("menu.play")
	_lang.text = Loc.t("menu.language", [Loc.language_name(Loc.language)])
	_quit.text = Loc.t("menu.quit")
	_hint.text = Loc.t("menu.hint")
	_credits.text = Loc.t("menu.credits")
