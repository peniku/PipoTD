extends Node
## Tradução do jogo (singleton "Loc"). Todos os textos que o jogador vê vêm
## de data/i18n/<idioma>.json através de Loc.t("chave"). O idioma escolhido
## fica salvo em user://settings.cfg. Ver docs/systems/localization.md.
##
## Adicionar um idioma: criar data/i18n/<código>.json com as mesmas chaves e
## incluir o código em LANGUAGES.

signal language_changed

const LANGUAGES := ["pt", "en"]       # ordem do botão de idioma no menu
const DEFAULT_LANGUAGE := "pt"
const SETTINGS_PATH := "user://settings.cfg"

var language: String = DEFAULT_LANGUAGE
var _strings: Dictionary = {}           # código -> {chave: texto}


func _ready() -> void:
	for code in LANGUAGES:
		_strings[code] = _load("res://data/i18n/%s.json" % code)
	language = _saved_or_system_language()
	TranslationServer.set_locale(language)


## Texto da chave no idioma atual. args = valores para %s/%d/%.1f.
## Se faltar no idioma atual, usa o português; se faltar em tudo, mostra a chave.
func t(key: String, args: Array = []) -> String:
	var s = _strings.get(language, {}).get(key, null)
	if s == null:
		s = _strings.get(DEFAULT_LANGUAGE, {}).get(key, key)
	if args.is_empty():
		return str(s)
	return str(s) % args


func has_key(key: String, code: String = "") -> bool:
	return _strings.get(language if code == "" else code, {}).has(key)


func keys(code: String) -> Array:
	return _strings.get(code, {}).keys()


func set_language(code: String) -> void:
	if not code in LANGUAGES or code == language:
		return
	language = code
	TranslationServer.set_locale(code)
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("game", "language", code)
	cfg.save(SETTINGS_PATH)
	language_changed.emit()


## Próximo idioma da lista (para o botão do menu).
func next_language() -> String:
	return LANGUAGES[(LANGUAGES.find(language) + 1) % LANGUAGES.size()]


## Nome do idioma escrito nele mesmo ("Português", "English").
func language_name(code: String) -> String:
	return str(_strings.get(code, {}).get("lang.name", code))


func _saved_or_system_language() -> String:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		var saved: String = str(cfg.get_value("game", "language", ""))
		if saved in LANGUAGES:
			return saved
	var sys := OS.get_locale_language()
	return sys if sys in LANGUAGES else "en"


func _load(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Loc: não consegui abrir %s" % path)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Dictionary else {}
