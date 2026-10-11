# Referência dos arquivos de dados

Todos os números do jogo ficam em `data/`. Depois de editar, aperte **F5** com o jogo aberto para recarregar (o mapa só muda reiniciando a partida). Campos começando com `_doc` são só comentários.

---

## `data/towers.json`
`{ "version": 1, "towers": [ ... ] }` — cada item é uma torre:

| Campo | Tipo | Significado |
|---|---|---|
| `id` | texto | identificador único (`fogo_1`, `fogo_pedra`). Usado em `upgrades_to` |
| `name` | texto | nome mostrado ao jogador |
| `tier` | texto | `base`, `single_1`, `single_2`, `single_3`, `dual` |
| `element` | `null`, texto ou lista | Ordem(ns). Dual = lista de 2; a primeira define o dano |
| `cost` | inteiro | ouro para construir/evoluir para ela |
| `damage` | número | dano por golpe |
| `attack_speed` | número | golpes por segundo (0,5 = um a cada 2 s) |
| `range` | número | alcance em metros |
| `splash_radius` | número | raio de dano em área; 0 = alvo único |
| `ability` | `null` ou objeto | habilidade (tipos em [systems/combat.md](systems/combat.md)) |
| `requires` | objeto | níveis de Ordem exigidos, ex. `{"fogo": 1, "pedra": 1}` |
| `upgrades_to` | lista de ids | evoluções possíveis a partir desta torre |
| `targeting` | texto | prioridade de mira (hoje sempre `first`; uso futuro) |
| `role` | texto | descrição curta do papel |

**DPS** = `damage × attack_speed` (sem contar área nem multiplicadores).

---

## `data/elements.json`
| Campo | Significado |
|---|---|
| `orders` | lista das 6 Ordens (ids) |
| `cycle` | ordem da roda de fraquezas: cada uma é forte contra a seguinte |
| `multipliers.strong` | dano contra a Ordem que você vence |
| `multipliers.weak` | dano contra a Ordem que vence você |
| `multipliers.neutral` | demais combinações |
| `multipliers.vs_no_order` | dano de torre com Ordem em inimigo sem Ordem |
| `display_names` | nomes de tela (`sagrado` → "Divino", `pedra` → "Terra") |
| `colors` | cor de cada Ordem (`none` = sem Ordem), em hexadecimal |
| `armor_piercing_orders` | Ordens que ignoram armadura |
| `factions.<ordem>` | facção inimiga de cada Ordem (`none` = sem Ordem): `name` (nome da facção), `boss` (nome do chefe), `model` (modelo 3D: `goblin`, `knight`, `skeleton`, `giant`, `demon`, `beast`, `golem`) |

---

## `data/economy.json`
| Campo | Significado |
|---|---|
| `start_gold` | ouro inicial |
| `start_lives` | vidas iniciais |
| `start_favor` | Favor Real inicial |
| `interest_per_wave` | taxa de juros por onda (0,05 = 5%) |
| `interest_cap` | juros máximos por onda (`null` = sem teto) |
| `favor_every_n_waves` | ganha 1 Favor Real a cada N ondas |
| `order_max_level` | nível máximo de cada Ordem |
| `order_level_cost_favor` | Favor Real por nível de Ordem |
| `sell_refund` | fração devolvida ao vender (0,75 = 75%) |
| `kill_gold.base` | ouro por abate na onda 1 |
| `kill_gold.growth_per_wave` | ouro extra por abate a cada onda |
| `lives_lost` | vidas perdidas por inimigo que passa, por tipo (`default` para o resto) |
| `waves.count` | total de ondas |
| `waves.base_hp` | vida de um inimigo normal na onda 1 |
| `waves.hp_growth_per_wave` | multiplicador de vida por onda (1,12 = +12% por onda) |
| `waves.elemental_hp_multiplier` | vida extra de ondas com Ordem |
| `waves.first_elemental_wave` | primeira onda com Ordem |
| `waves.spawn_interval` | segundos entre inimigos |
| `waves.base_speed` | velocidade base (m/s) |
| `waves.pattern` | sequência de tipos que se repete |
| `waves.types.<tipo>` | `count`, `hp_mult`, `speed_mult`, `armor`, `regen`, `gold_mult`, `scale` |

---

## `data/maps/<id>.json`
Ver [systems/map.md](systems/map.md): `id`, `name`, `ground_size`, `path`, `path_width`, `build_grid` (`cell_size`, `road_clearance`, `end_clearance`, `blocked_cells`).

Bloco `scenery` (só visual, ver [art-direction.md](art-direction.md#cenário)):

| Campo | Significado |
|---|---|
| `seed` | semente aleatória (mesma semente = mesmo cenário) |
| `terrain_size` | tamanho do terreno visível em metros (maior que a área jogável) |
| `forest_depth` | até quantos metros além da área jogável vai a floresta |
| `trees` | quantidade de pinheiros |
| `rocks` | quantidade de rochas |
| `grass_tufts` | tufos de grama |
| `mountains` | montanhas ao fundo |
