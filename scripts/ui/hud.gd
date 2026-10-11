extends CanvasLayer
class_name HUD
## Interface da partida, montada por código (sem .tscn) para ficar fácil de
## ler e mudar. Só mostra informação e emite sinais; quem decide é o main.gd.
## Ver docs/systems/hud.md.

signal start_wave_pressed
signal build_pressed(tower_id: String)
signal upgrade_pressed(tower_id: String)
signal sell_pressed
signal order_pressed(order: String)
signal restart_pressed

var _top_label: Label
var _wave_button: Button
var _panel: PanelContainer
var _panel_box: VBoxContainer
var _orders_box: HBoxContainer
var _message: Label
var _wave_info: Label
var _current_tower: Tower = null
var _showing_empty_slot: bool = false


func _ready() -> void:
	_build_top_bar()
	_build_side_panel()
	_build_orders_bar()
	_build_message()
	GameState.changed.connect(refresh)
	refresh()


# --- Construção da interface ------------------------------------------------

func _build_top_bar() -> void:
	var bar := PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	bar.add_child(row)
	_top_label = Label.new()
	_top_label.add_theme_font_size_override("font_size", 20)
	_top_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_top_label)
	_wave_info = Label.new()
	_wave_info.add_theme_font_size_override("font_size", 16)
	row.add_child(_wave_info)
	_wave_button = Button.new()
	_wave_button.text = "Iniciar onda (Espaço)"
	_wave_button.pressed.connect(func(): start_wave_pressed.emit())
	row.add_child(_wave_button)


func _build_side_panel() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_panel.offset_left = -300
	_panel.offset_top = 60
	_panel.offset_bottom = -90
	add_child(_panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_panel.add_child(scroll)
	_panel_box = VBoxContainer.new()
	_panel_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel_box.add_theme_constant_override("separation", 6)
	scroll.add_child(_panel_box)
	_panel.visible = false


func _build_orders_bar() -> void:
	var bar := PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -80
	add_child(bar)
	var col := VBoxContainer.new()
	bar.add_child(col)
	var title := Label.new()
	title.text = "Ordens — gaste Favor Real para comprar/subir de nível"
	col.add_child(title)
	_orders_box = HBoxContainer.new()
	_orders_box.add_theme_constant_override("separation", 8)
	col.add_child(_orders_box)


func _build_message() -> void:
	_message = Label.new()
	_message.set_anchors_preset(Control.PRESET_CENTER)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 40)
	_message.add_theme_color_override("font_outline_color", Color.BLACK)
	_message.add_theme_constant_override("outline_size", 8)
	_message.visible = false
	add_child(_message)


# --- Atualização ------------------------------------------------------------

func refresh() -> void:
	_top_label.text = "Ouro: %d    Vidas: %d    Onda: %d    Favor Real: %d" % [
		GameState.gold, GameState.lives, GameState.wave, GameState.favor]
	_refresh_orders()
	if _current_tower != null and is_instance_valid(_current_tower):
		show_tower(_current_tower)
	elif _showing_empty_slot:
		show_empty_slot()


func set_wave_button(enabled: bool, next_info: Dictionary) -> void:
	_wave_button.disabled = not enabled
	if next_info.is_empty():
		_wave_info.text = ""
	else:
		_wave_info.text = "Próxima: %s, %s, %d inimigos" % [
			str(next_info["type"]).capitalize(), GameData.order_display_name(next_info["order"]),
			int(next_info["count"])]


func _refresh_orders() -> void:
	for c in _orders_box.get_children():
		c.queue_free()
	var max_lv: int = int(GameData.economy.get("order_max_level", 3))
	for o in GameData.elements.get("orders", []):
		var b := Button.new()
		var lv: int = GameState.order_level(o)
		b.text = "%s  Nv %d/%d" % [GameData.order_display_name(o), lv, max_lv]
		b.disabled = not GameState.can_upgrade_order(o)
		b.add_theme_color_override("font_color", GameData.order_color(o))
		b.pressed.connect(func(): order_pressed.emit(o))
		_orders_box.add_child(b)


func clear_selection() -> void:
	_current_tower = null
	_showing_empty_slot = false
	_panel.visible = false


func show_empty_slot() -> void:
	_current_tower = null
	_showing_empty_slot = true
	_clear_panel()
	_add_title("Construir torre")
	for id in GameData.towers:
		var t: Dictionary = GameData.towers[id]
		if str(t.get("tier", "")) != "base":
			continue
		var cost: int = int(t.get("cost", 0))
		var b := Button.new()
		b.text = "%s — %d ouro\n%s" % [t.get("name", id), cost, _stats_line(t)]
		b.disabled = not GameState.can_afford(cost)
		b.pressed.connect(func(): build_pressed.emit(id))
		_panel_box.add_child(b)
	_panel.visible = true


func show_tower(tower: Tower) -> void:
	_current_tower = tower
	_showing_empty_slot = false
	_clear_panel()
	var t: Dictionary = tower.data()
	_add_title(str(t.get("name", tower.tower_id)))
	_add_text("Ordem: %s" % _orders_text(t))
	_add_text(str(t.get("role", "")))
	_add_text(_stats_line(t))
	_add_text("DPS: %.1f" % tower.dps())

	var ups: Array = t.get("upgrades_to", [])
	if ups.size() > 0:
		_add_title("Evoluir para")
	for up_id in ups:
		var u: Dictionary = GameData.get_tower(up_id)
		if u.is_empty():
			continue
		var cost: int = int(u.get("cost", 0))
		var req: Dictionary = u.get("requires", {})
		var ok_req: bool = GameState.meets_requirements(req)
		var b := Button.new()
		b.text = "%s — %d ouro" % [u.get("name", up_id), cost]
		if not ok_req:
			b.text += "\nPrecisa: %s" % _requires_text(req)
		b.disabled = not ok_req or not GameState.can_afford(cost)
		b.pressed.connect(func(): upgrade_pressed.emit(up_id))
		_panel_box.add_child(b)

	var refund: int = int(tower.total_spent * float(GameData.economy.get("sell_refund", 0.75)))
	var sell := Button.new()
	sell.text = "Vender (+%d ouro)" % refund
	sell.pressed.connect(func(): sell_pressed.emit())
	_panel_box.add_child(sell)
	_panel.visible = true


func show_message(text: String, with_restart: bool = false) -> void:
	_message.text = text
	_message.visible = true
	if with_restart:
		var b := Button.new()
		b.text = "Jogar de novo"
		b.set_anchors_preset(Control.PRESET_CENTER)
		b.position.y += 60
		b.pressed.connect(func(): restart_pressed.emit())
		add_child(b)


# --- Auxiliares -------------------------------------------------------------

func _clear_panel() -> void:
	for c in _panel_box.get_children():
		c.queue_free()


func _add_title(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 18)
	_panel_box.add_child(l)


func _add_text(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 260
	_panel_box.add_child(l)


func _stats_line(t: Dictionary) -> String:
	var s := "Dano %d · Vel %.2f/s · Alcance %.1f" % [
		int(t.get("damage", 0)), float(t.get("attack_speed", 0)), float(t.get("range", 0))]
	if float(t.get("splash_radius", 0.0)) > 0.0:
		s += " · Área %.1f" % float(t.get("splash_radius", 0))
	return s


func _orders_text(t: Dictionary) -> String:
	var el = t.get("element", null)
	if el is Array:
		var names: Array = []
		for o in el:
			names.append(GameData.order_display_name(o))
		return " + ".join(names)
	return GameData.order_display_name(el)


func _requires_text(req: Dictionary) -> String:
	var parts: Array = []
	for o in req:
		parts.append("%s Nv %d" % [GameData.order_display_name(o), int(req[o])])
	return ", ".join(parts)
