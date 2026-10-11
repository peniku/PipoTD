extends CanvasLayer
class_name HUD
## Interface da partida, montada por código (sem .tscn) para ficar fácil de
## ler e mudar. Só mostra informação e emite sinais; quem decide é o main.gd.
## Visual: painéis escuros com borda dourada e fonte serifada (tema medieval).
## Todo texto vem de Loc.t() (data/i18n). Ver docs/systems/hud.md.

signal start_wave_pressed
signal build_pressed(tower_id: String)
signal upgrade_pressed(tower_id: String)
signal sell_pressed
signal targeting_pressed(mode: String)
signal order_pressed(order: String)
signal restart_pressed
signal menu_pressed

const GOLD := Color(0.86, 0.68, 0.32)
const PARCHMENT := Color(0.93, 0.87, 0.74)
const MUTED := Color(0.66, 0.6, 0.5)

static var _font: Font

var _root: Control
var _title_label: Label
var _gold_label: Label
var _lives_label: Label
var _wave_label: Label
var _favor_label: Label
var _wave_button: Button
var _menu_button: Button
var _wave_info: Label
var _panel: PanelContainer
var _panel_box: VBoxContainer
var _orders_title: Label
var _orders_box: HBoxContainer
var _message: Label
var _announce: Label
var _end_buttons: VBoxContainer
var _current_tower: Tower = null
var _showing_empty_cell: bool = false
var _last_wave_enabled: bool = true
var _last_next_info: Dictionary = {}


## Fonte serifada do sistema (Cinzel/Georgia/…); usada também no texto 3D.
static func serif_font() -> Font:
	if _font == null:
		var f := SystemFont.new()
		f.font_names = PackedStringArray(["Cinzel", "Trajan Pro", "Georgia", "Palatino Linotype",
				"Book Antiqua", "Times New Roman", "serif"])
		f.font_weight = 600
		_font = f
	return _font


## Tema medieval (painéis escuros, borda dourada). Público para o menu usar.
static func make_theme() -> Theme:
	var th := Theme.new()
	th.default_font = serif_font()
	th.default_font_size = 16
	th.set_color("font_color", "Label", PARCHMENT)
	th.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.7))
	th.set_constant("shadow_offset_x", "Label", 1)
	th.set_constant("shadow_offset_y", "Label", 1)
	th.set_stylebox("panel", "PanelContainer", panel_style())

	var normal := panel_style(0.95, GOLD.darkened(0.35), 1)
	normal.bg_color = Color(0.16, 0.11, 0.08)
	normal.set_content_margin_all(8)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.27, 0.18, 0.11)
	hover.border_color = GOLD
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.36, 0.24, 0.12)
	pressed.border_color = GOLD.lightened(0.3)
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.1, 0.09, 0.08)
	disabled.border_color = Color(0.3, 0.27, 0.22)
	th.set_stylebox("normal", "Button", normal)
	th.set_stylebox("hover", "Button", hover)
	th.set_stylebox("pressed", "Button", pressed)
	th.set_stylebox("hover_pressed", "Button", pressed)
	th.set_stylebox("disabled", "Button", disabled)
	th.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	th.set_color("font_color", "Button", PARCHMENT)
	th.set_color("font_hover_color", "Button", Color(1.0, 0.92, 0.7))
	th.set_color("font_pressed_color", "Button", Color(1.0, 0.85, 0.45))
	th.set_color("font_hover_pressed_color", "Button", Color(1.0, 0.85, 0.45))
	th.set_color("font_disabled_color", "Button", Color(0.45, 0.42, 0.38))
	var line := StyleBoxLine.new()
	line.color = GOLD.darkened(0.3)
	line.thickness = 1
	th.set_stylebox("separator", "HSeparator", line)
	return th


static func panel_style(alpha: float = 0.9, border: Color = GOLD, width: int = 2) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.07, 0.055, 0.045, alpha)
	s.border_color = border
	s.set_border_width_all(width)
	s.set_corner_radius_all(3)
	s.shadow_color = Color(0, 0, 0, 0.5)
	s.shadow_size = 6
	s.set_content_margin_all(10)
	return s


func _ready() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = make_theme()
	add_child(_root)
	_build_top_bar()
	_build_side_panel()
	_build_orders_bar()
	_build_message()
	GameState.changed.connect(refresh)
	Loc.language_changed.connect(_retranslate)
	_retranslate()


# --- Construção da interface ------------------------------------------------

func _build_top_bar() -> void:
	var bar := PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.offset_left = 12
	bar.offset_right = -12
	bar.offset_top = 10
	_root.add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 26)
	bar.add_child(row)
	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 22)
	_title_label.add_theme_color_override("font_color", GOLD)
	row.add_child(_title_label)
	_gold_label = _stat(row, Color(1.0, 0.82, 0.35))
	_lives_label = _stat(row, Color(0.95, 0.45, 0.4))
	_wave_label = _stat(row, PARCHMENT)
	_favor_label = _stat(row, Color(0.75, 0.65, 1.0))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_wave_info = Label.new()
	_wave_info.add_theme_color_override("font_color", MUTED)
	_wave_info.add_theme_font_size_override("font_size", 15)
	row.add_child(_wave_info)
	_wave_button = Button.new()
	_wave_button.pressed.connect(func(): start_wave_pressed.emit())
	row.add_child(_wave_button)
	_menu_button = Button.new()
	_menu_button.pressed.connect(func(): menu_pressed.emit())
	row.add_child(_menu_button)


func _stat(row: HBoxContainer, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 19)
	l.add_theme_color_override("font_color", color)
	row.add_child(l)
	return l


func _build_side_panel() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_panel.offset_left = -340
	_panel.offset_right = -12
	_panel.offset_top = 74
	_panel.offset_bottom = -112
	_root.add_child(_panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_panel.add_child(scroll)
	_panel_box = VBoxContainer.new()
	_panel_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel_box.add_theme_constant_override("separation", 7)
	scroll.add_child(_panel_box)
	_panel.visible = false


func _build_orders_bar() -> void:
	var bar := PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bar.offset_bottom = -12
	_root.add_child(bar)
	var col := VBoxContainer.new()
	bar.add_child(col)
	_orders_title = Label.new()
	_orders_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_orders_title.add_theme_font_size_override("font_size", 13)
	_orders_title.add_theme_color_override("font_color", GOLD)
	col.add_child(_orders_title)
	_orders_box = HBoxContainer.new()
	_orders_box.add_theme_constant_override("separation", 8)
	col.add_child(_orders_box)


func _build_message() -> void:
	_message = Label.new()
	_message.set_anchors_preset(Control.PRESET_CENTER)
	_message.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 46)
	_message.add_theme_color_override("font_color", GOLD)
	_message.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.0))
	_message.add_theme_constant_override("outline_size", 10)
	_message.visible = false
	_root.add_child(_message)

	_announce = Label.new()
	_announce.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_announce.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_announce.offset_top = 110
	_announce.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_announce.add_theme_font_size_override("font_size", 34)
	_announce.add_theme_color_override("font_color", PARCHMENT)
	_announce.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.0))
	_announce.add_theme_constant_override("outline_size", 8)
	_announce.modulate.a = 0.0
	_root.add_child(_announce)


# --- Atualização ------------------------------------------------------------

## Reaplica todos os textos fixos no idioma atual.
func _retranslate() -> void:
	_title_label.text = Loc.t("hud.title")
	_wave_button.text = Loc.t("hud.call_wave")
	_menu_button.text = Loc.t("hud.menu")
	_orders_title.text = Loc.t("hud.orders_title")
	set_wave_button(_last_wave_enabled, _last_next_info)
	refresh()


func refresh() -> void:
	_gold_label.text = Loc.t("hud.gold", [GameState.gold])
	_lives_label.text = Loc.t("hud.lives", [GameState.lives])
	_wave_label.text = Loc.t("hud.wave", [GameState.wave])
	_favor_label.text = Loc.t("hud.favor", [GameState.favor])
	_refresh_orders()
	if _current_tower != null and is_instance_valid(_current_tower):
		show_tower(_current_tower)
	elif _showing_empty_cell:
		show_empty_cell()


func set_wave_button(enabled: bool, next_info: Dictionary) -> void:
	_last_wave_enabled = enabled
	_last_next_info = next_info
	_wave_button.disabled = not enabled
	if next_info.is_empty():
		_wave_info.text = ""
	else:
		_wave_info.text = Loc.t("hud.next", [wave_title(next_info),
				Loc.t("wavetype." + str(next_info["type"])), int(next_info["count"])])


## Anúncio grande no topo quando a onda começa (some sozinho).
func announce_wave(info: Dictionary) -> void:
	_announce.text = Loc.t("hud.announce", [int(info["wave"]), wave_title(info)])
	var tw := create_tween()
	tw.tween_property(_announce, "modulate:a", 1.0, 0.4)
	tw.tween_interval(1.8)
	tw.tween_property(_announce, "modulate:a", 0.0, 0.8)


## Nome da facção da onda, ou do chefe se for onda de chefe.
static func wave_title(info: Dictionary) -> String:
	if str(info.get("type", "")) == "chefe":
		return GameData.boss_name(info.get("order"))
	return GameData.faction_name(info.get("order"))


func _refresh_orders() -> void:
	for c in _orders_box.get_children():
		c.queue_free()
	var max_lv: int = int(GameData.economy.get("order_max_level", 3))
	for o in GameData.elements.get("orders", []):
		var b := Button.new()
		var lv: int = GameState.order_level(o)
		b.text = "%s  %s" % [GameData.order_display_name(o), "◆".repeat(lv) + "◇".repeat(max_lv - lv)]
		b.disabled = not GameState.can_upgrade_order(o)
		var oc: Color = GameData.order_color(o)
		b.add_theme_color_override("font_color", oc)
		b.add_theme_color_override("font_hover_color", oc.lightened(0.3))
		b.add_theme_color_override("font_disabled_color", oc.darkened(0.35) if lv > 0 else Color(0.4, 0.37, 0.33))
		b.pressed.connect(func(): order_pressed.emit(o))
		_orders_box.add_child(b)


func clear_selection() -> void:
	_current_tower = null
	_showing_empty_cell = false
	_panel.visible = false


func show_empty_cell() -> void:
	_current_tower = null
	_showing_empty_cell = true
	_clear_panel()
	_add_title(Loc.t("hud.build_title"))
	for id in GameData.towers:
		var t: Dictionary = GameData.towers[id]
		if str(t.get("tier", "")) != "base":
			continue
		var cost: int = int(t.get("cost", 0))
		var b := Button.new()
		b.text = Loc.t("hud.cost", [GameData.tower_name(id), cost]) + "\n" + _stats_line(t)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.disabled = not GameState.can_afford(cost)
		b.pressed.connect(func(): build_pressed.emit(id))
		_panel_box.add_child(b)
	_panel.visible = true


func show_tower(tower: Tower) -> void:
	_current_tower = tower
	_showing_empty_cell = false
	_clear_panel()
	var t: Dictionary = tower.data()
	_add_title(GameData.tower_name(tower.tower_id))
	var orders := Label.new()
	orders.text = _orders_text(t)
	orders.add_theme_color_override("font_color", GameData.order_color(GameData.tower_damage_order(t)))
	_panel_box.add_child(orders)
	_add_text(GameData.tower_role(tower.tower_id), MUTED)
	_add_text(_stats_line(t))
	_add_text(Loc.t("hud.dps", [tower.dps()]), GOLD)
	_panel_box.add_child(HSeparator.new())
	_add_targeting(tower)
	_panel_box.add_child(HSeparator.new())

	var ups: Array = t.get("upgrades_to", [])
	if ups.size() > 0:
		_add_title(Loc.t("hud.upgrade_title"))
	for up_id in ups:
		var u: Dictionary = GameData.get_tower(up_id)
		if u.is_empty():
			continue
		var cost: int = int(u.get("cost", 0))
		var req: Dictionary = u.get("requires", {})
		var ok_req: bool = GameState.meets_requirements(req)
		var b := Button.new()
		b.text = Loc.t("hud.cost", [GameData.tower_name(up_id), cost])
		if not ok_req:
			b.text += "\n" + Loc.t("hud.requires", [_requires_text(req)])
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.disabled = not ok_req or not GameState.can_afford(cost)
		b.add_theme_color_override("font_color", GameData.order_color(GameData.tower_damage_order(u)).lerp(PARCHMENT, 0.4))
		b.pressed.connect(func(): upgrade_pressed.emit(up_id))
		_panel_box.add_child(b)

	_panel_box.add_child(HSeparator.new())
	var refund: int = int(tower.total_spent * float(GameData.economy.get("sell_refund", 0.75)))
	var sell := Button.new()
	sell.text = Loc.t("hud.sell", [refund])
	sell.pressed.connect(func(): sell_pressed.emit())
	_panel_box.add_child(sell)
	_panel.visible = true


## Botões de modo de mira (o modo atual fica "apertado").
func _add_targeting(tower: Tower) -> void:
	var title := Label.new()
	title.text = Loc.t("hud.target_title")
	title.add_theme_color_override("font_color", GOLD)
	_panel_box.add_child(title)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	_panel_box.add_child(grid)
	for mode in Tower.TARGET_MODES:
		var b := Button.new()
		b.text = Loc.t("target." + mode)
		b.toggle_mode = true
		b.button_pressed = tower.targeting == mode
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 13)
		b.pressed.connect(func(): targeting_pressed.emit(mode))
		grid.add_child(b)


func show_message(text: String, with_buttons: bool = false) -> void:
	_message.text = text
	_message.visible = true
	if with_buttons and _end_buttons == null:
		_end_buttons = VBoxContainer.new()
		_end_buttons.set_anchors_preset(Control.PRESET_CENTER)
		_end_buttons.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_end_buttons.position.y += 70
		_end_buttons.add_theme_constant_override("separation", 10)
		_root.add_child(_end_buttons)
		for pair in [["hud.play_again", restart_pressed], ["hud.back_menu", menu_pressed]]:
			var b := Button.new()
			b.text = Loc.t(pair[0])
			b.add_theme_font_size_override("font_size", 22)
			var sig: Signal = pair[1]
			b.pressed.connect(func(): sig.emit())
			_end_buttons.add_child(b)


# --- Auxiliares -------------------------------------------------------------

func _clear_panel() -> void:
	for c in _panel_box.get_children():
		c.queue_free()


func _add_title(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", GOLD)
	_panel_box.add_child(l)


func _add_text(text: String, color: Color = PARCHMENT) -> void:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 290
	l.add_theme_color_override("font_color", color)
	_panel_box.add_child(l)


func _stats_line(t: Dictionary) -> String:
	var s := Loc.t("hud.stats", [int(t.get("damage", 0)), float(t.get("attack_speed", 0)), float(t.get("range", 0))])
	if float(t.get("splash_radius", 0.0)) > 0.0:
		s += Loc.t("hud.stats_area", [float(t.get("splash_radius", 0))])
	return s


func _orders_text(t: Dictionary) -> String:
	var el = t.get("element", null)
	if el is Array:
		var names: Array = []
		for o in el:
			names.append(GameData.order_display_name(o))
		return Loc.t("hud.orders", [" + ".join(names)])
	return Loc.t("hud.order", [GameData.order_display_name(el)])


func _requires_text(req: Dictionary) -> String:
	var parts: Array = []
	for o in req:
		parts.append(Loc.t("hud.order_level", [GameData.order_display_name(o), int(req[o])]))
	return ", ".join(parts)
