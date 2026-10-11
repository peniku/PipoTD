# Sistema: Idiomas (localização)

**Código:** `scripts/autoload/loc.gd` (singleton `Loc`)
**Dados:** `data/i18n/pt.json`, `data/i18n/en.json`
**Idiomas:** Português (`pt`) e Inglês (`en`). Escolha no menu principal ([menu.md](menu.md)).

## Regra
**Nenhum texto que o jogador vê fica escrito no código nem nos dados de jogo.** Todo texto é uma *chave* traduzida por `Loc.t("chave")`. Os arquivos de dados (`towers.json`, `elements.json`) só têm números e ids.

## Como funciona
- Ao abrir o jogo, `Loc` carrega todos os arquivos de `data/i18n/`.
- Idioma inicial: o salvo em `user://settings.cfg` (`[game] language=`); se não houver, o idioma do sistema operacional se for `pt`/`en`; senão inglês.
- `Loc.t("hud.gold", [150])` → `"Ouro  150"` / `"Gold  150"`. Os valores entram nos `%d`, `%s`, `%.1f` do texto.
- Se uma chave faltar no idioma atual, usa o português; se faltar em todos, mostra a própria chave (fica fácil de achar o erro).
- `Loc.set_language("en")` troca o idioma, salva a escolha e emite `language_changed`; HUD e menu se re-traduzem na hora.
- `user://` no Windows fica em `%APPDATA%\Godot\app_userdata\PipoTd\`.

## Famílias de chaves
| Prefixo | Exemplo | Usado por |
|---|---|---|
| `lang.name` | "English" | botão de idioma |
| `tower.<id>.name` / `.role` | `tower.fogo_1.name` | nome e descrição da torre (`GameData.tower_name/role`) |
| `order.<id>` | `order.sagrado` = "Divino"/"Divine" | nome da Ordem (`GameData.order_display_name`) |
| `faction.<ordem>.name` / `.boss` | `faction.fogo.boss` = "Senhor Demônio"/"Demon Lord" | facção e chefe (`GameData.faction_name/boss_name`) |
| `wavetype.<tipo>` | `wavetype.massa` = "Horda"/"Horde" | tipo de onda |
| `target.<modo>` | `target.weakest` = "Menos HP"/"Least HP" | modos de mira |
| `hud.*` | `hud.sell` | interface da partida |
| `msg.*` | `msg.victory` | vitória / derrota |
| `menu.*` | `menu.play` | menu principal |

## Adicionar um texto novo
1. Crie a chave em **`pt.json` e `en.json`** (o teste automático falha se um idioma tiver chave que o outro não tem).
2. Use `Loc.t("minha.chave")` no código.
3. Se o texto aparece numa tela que já está aberta, re-aplique em `_retranslate()`.

## Adicionar uma torre/facção nova
Além dos dados, crie `tower.<id>.name` e `tower.<id>.role` (ou `faction.<ordem>.name/.boss`) nos dois idiomas — o teste confere.

## Adicionar um idioma (ex.: espanhol)
1. Copie `data/i18n/en.json` para `es.json` e traduza os valores (não as chaves).
2. Acrescente `"es"` em `LANGUAGES` em `loc.gd`.
3. O botão do menu passa a alternar entre os três.

## Por que não o sistema de CSV do Godot?
Ver decisão D-014 em [../decisions.md](../decisions.md).
