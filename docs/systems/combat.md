# Sistema: Combate e dano

**Código:** `Enemy.take_hit` / `_apply_damage` / `_apply_ability` em `scripts/entities/enemy.gd`; `GameData.damage_multiplier`
**Dados:** `data/elements.json`, campo `ability` em `data/towers.json`

## Fórmula do dano de um golpe

```
dano_final = dano_da_torre × multiplicador_de_Ordem × (1 − armadura)
```

- A armadura é ignorada se a Ordem da torre estiver em `armor_piercing_orders` (hoje: Pedra) e também pelo dano de veneno.
- A Ordem de dano de uma Dual é a **primeira** da lista `element` (decisão D-009).

## Multiplicador de Ordem
Roda (`cycle`): cada Ordem é forte contra a seguinte.

```
Sagrado → Necromancia → Gelo → Fogo → Druídico → Pedra → Sagrado
```

| Situação | Multiplicador (`multipliers`) | Valor atual |
|---|---|---|
| Torre sem Ordem (Arqueiros, Catapulta) | — | 1,0 |
| Torre com Ordem × inimigo sem Ordem | `vs_no_order` | 0,8 |
| Torre forte contra o inimigo | `strong` | 2,0 |
| Torre fraca contra o inimigo | `weak` | 0,5 |
| Demais combinações | `neutral` | 1,0 |

Exemplo: Fogo atacando um inimigo Druídico = ×2,0. Fogo atacando um inimigo de Gelo = ×0,5.

## Habilidades (`ability`)
| `type` | Parâmetros | Efeito |
|---|---|---|
| `slow` | `amount`, `duration` | lentidão (ver [enemies.md](enemies.md)) |
| `stun` | `chance`, `duration` | chance de atordoar |
| `poison` | `dps_ratio`, `duration` | veneno com base no dano do golpe |
| `todo` | `note` | placeholder das Duais; ainda sem efeito |

Torres de área aplicam a habilidade em todos os inimigos atingidos.
