# PipoTd — Evolução das torres

## Árvore

```
Arqueiros / Catapulta  (base, sem Ordem)
        │  evolui para qualquer Ordem que você possua
        ▼
Single nível 1 → nível 2 → nível 3      (exige a Ordem no nível 1/2/3)
        │
        ▼
Dual (2 Ordens)          ← v1
        │
        ▼
Triple (3 Ordens: suporte ou dano)  ← depois da v1
        │
        ▼
Quad / torre das 6 Ordens           ← futuro
```

- Toda torre nasce como **Arqueiros** ou **Catapulta** e é evoluída no lugar.
- Uma Single nível 1 pode virar a Single nível 2 da mesma Ordem **ou** uma Dual que inclua essa Ordem (se o jogador tiver a outra Ordem).
- Requisitos ficam no campo `requires` de cada torre em `data/towers.json` (ex.: `{"fogo": 1, "pedra": 1}`).

## Escopo da v1

2 base + 6 Singles × 3 níveis + 15 Duais = **35 torres**.

## Lista (gerada a partir de `data/towers.json` + `data/i18n/`)

Os ids internos das Ordens continuam `sagrado` e `pedra`; na tela aparecem como **Divino/Divine** e **Terra/Earth**. Nomes e descrições ficam em `data/i18n/` (ver [systems/localization.md](systems/localization.md)). Visual de cada camada: [art-direction.md](art-direction.md#torres). Mira: [systems/towers.md](systems/towers.md#mira-escolhida-pelo-jogador).

| Camada | Torre (PT) | Tower (EN) | Ordem(s) | Papel |
|---|---|---|---|---|
| base | Torre dos Arqueiros (`arqueiros`) | Archer Tower | — | alvo único barato |
| base | Catapulta (`catapulta`) | Catapult | — | dano em área barato |
| single_1 | Capela do Clérigo (`sagrado_1`) | Cleric's Chapel | Divino | dano alto, alvo único |
| single_2 | Templo do Paladino (`sagrado_2`) | Paladin's Temple | Divino | dano alto, alvo único |
| single_3 | Catedral Celestial (`sagrado_3`) | Celestial Cathedral | Divino | dano alto, alvo único |
| single_1 | Altar Sombrio (`necromancia_1`) | Dark Altar | Necromancia | dano enorme, ataque lento |
| single_2 | Cripta do Necromante (`necromancia_2`) | Necromancer's Crypt | Necromancia | dano enorme, ataque lento |
| single_3 | Torre do Lich (`necromancia_3`) | Lich Tower | Necromancia | dano enorme, ataque lento |
| single_1 | Obelisco de Gelo (`gelo_1`) | Frost Obelisk | Gelo | desacelera inimigos |
| single_2 | Torre do Inverno (`gelo_2`) | Winter Tower | Gelo | desacelera inimigos |
| single_3 | Bastião Glacial (`gelo_3`) | Glacial Bastion | Gelo | desacelera inimigos |
| single_1 | Braseiro Arcano (`fogo_1`) | Arcane Brazier | Fogo | dano em área |
| single_2 | Torre do Evocador (`fogo_2`) | Evoker's Tower | Fogo | dano em área |
| single_3 | Pira Infernal (`fogo_3`) | Infernal Pyre | Fogo | dano em área |
| single_1 | Círculo Druídico (`druidico_1`) | Druidic Circle | Druídico | veneno ao longo do tempo |
| single_2 | Bosque Antigo (`druidico_2`) | Ancient Grove | Druídico | veneno ao longo do tempo |
| single_3 | Árvore Ancestral (`druidico_3`) | Ancestral Tree | Druídico | veneno ao longo do tempo |
| single_1 | Bastião Anão (`pedra_1`) | Dwarven Bastion | Terra | atordoa, bom contra armadura |
| single_2 | Fortaleza da Montanha (`pedra_2`) | Mountain Fortress | Terra | atordoa, bom contra armadura |
| single_3 | Cidadela de Pedra Rúnica (`pedra_3`) | Runestone Citadel | Terra | atordoa, bom contra armadura |
| dual | Eclipse (`sagrado_necromancia`) | Eclipse | Divino + Necromancia | alterna dano sagrado/sombrio; cobre a fraqueza dos dois |
| dual | Santuário de Cristal (`sagrado_gelo`) | Crystal Sanctuary | Divino + Gelo | raio que perfura vários inimigos em linha |
| dual | Pira do Inquisidor (`sagrado_fogo`) | Inquisitor's Pyre | Divino + Fogo | dano alto em área pequena |
| dual | Bosque Abençoado (`sagrado_druidico`) | Blessed Grove | Divino + Druídico | aumenta o dano das torres vizinhas (suporte) |
| dual | Bastião dos Paladinos (`sagrado_pedra`) | Paladins' Bastion | Divino + Terra | golpe pesado que atordoa o alvo |
| dual | Cripta Gélida (`necromancia_gelo`) | Frozen Crypt | Necromancia + Gelo | congela e amplifica o dano recebido |
| dual | Fogo Infernal (`necromancia_fogo`) | Hellfire | Necromancia + Fogo | queimadura forte ao longo do tempo |
| dual | Pântano Pestilento (`necromancia_druidico`) | Plague Swamp | Necromancia + Druídico | praga que espalha entre inimigos próximos |
| dual | Mausoléu (`necromancia_pedra`) | Mausoleum | Necromancia + Terra | invoca esqueletos que bloqueiam a rota por instantes |
| dual | Alquimista (`gelo_fogo`) | Alchemist | Gelo + Fogo | nuvem de vapor: área + lentidão |
| dual | Pântano Congelado (`gelo_druidico`) | Frozen Marsh | Gelo + Druídico | lentidão forte em área |
| dual | Geleira (`gelo_pedra`) | Glacier | Gelo + Terra | avalanche periódica em área grande |
| dual | Incêndio Florestal (`fogo_druidico`) | Wildfire | Fogo + Druídico | fogo que se espalha pelo caminho |
| dual | Forja Anã (`fogo_pedra`) | Dwarven Forge | Fogo + Terra | canhão de alto dano em área |
| dual | Treant Ancião (`druidico_pedra`) | Ancient Treant | Druídico + Terra | raízes prendem inimigos (stun em área) |
