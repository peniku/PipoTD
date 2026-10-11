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

## Lista (gerada a partir de `data/towers.json`)

| Camada | Torre | Ordem(s) | Papel |
|---|---|---|---|
| base | Torre de Arqueiros (`arqueiros`) | — | alvo único barato |
| base | Catapulta (`catapulta`) | — | dano em área barato |
| single_1 | Capela (`sagrado_1`) | sagrado | dano alto, alvo único |
| single_2 | Igreja (`sagrado_2`) | sagrado | dano alto, alvo único |
| single_3 | Catedral Radiante (`sagrado_3`) | sagrado | dano alto, alvo único |
| single_1 | Altar Sombrio (`necromancia_1`) | necromancia | dano enorme, ataque lento |
| single_2 | Cripta (`necromancia_2`) | necromancia | dano enorme, ataque lento |
| single_3 | Torre do Lich (`necromancia_3`) | necromancia | dano enorme, ataque lento |
| single_1 | Poço Gelado (`gelo_1`) | gelo | desacelera inimigos |
| single_2 | Torre de Gelo (`gelo_2`) | gelo | desacelera inimigos |
| single_3 | Bastião Glacial (`gelo_3`) | gelo | desacelera inimigos |
| single_1 | Braseiro (`fogo_1`) | fogo | dano em área |
| single_2 | Torre de Chamas (`fogo_2`) | fogo | dano em área |
| single_3 | Fornalha Infernal (`fogo_3`) | fogo | dano em área |
| single_1 | Círculo de Pedras (`druidico_1`) | druidico | veneno ao longo do tempo |
| single_2 | Bosque Druídico (`druidico_2`) | druidico | veneno ao longo do tempo |
| single_3 | Árvore Sagrada (`druidico_3`) | druidico | veneno ao longo do tempo |
| single_1 | Trabuco (`pedra_1`) | pedra | atordoa, bom contra armadura |
| single_2 | Baluarte (`pedra_2`) | pedra | atordoa, bom contra armadura |
| single_3 | Fortaleza de Pedra (`pedra_3`) | pedra | atordoa, bom contra armadura |
| dual | Eclipse (`sagrado_necromancia`) | sagrado + necromancia | alterna dano sagrado/sombrio; cobre a fraqueza dos dois |
| dual | Santuário de Cristal (`sagrado_gelo`) | sagrado + gelo | raio que perfura vários inimigos em linha |
| dual | Pira do Inquisidor (`sagrado_fogo`) | sagrado + fogo | dano alto em área pequena |
| dual | Bosque Abençoado (`sagrado_druidico`) | sagrado + druidico | aumenta o dano das torres vizinhas (suporte) |
| dual | Bastião dos Paladinos (`sagrado_pedra`) | sagrado + pedra | golpe pesado que atordoa o alvo |
| dual | Cripta Gélida (`necromancia_gelo`) | necromancia + gelo | congela e amplifica o dano recebido |
| dual | Fogo Infernal (`necromancia_fogo`) | necromancia + fogo | queimadura forte ao longo do tempo |
| dual | Pântano Pestilento (`necromancia_druidico`) | necromancia + druidico | praga que espalha entre inimigos próximos |
| dual | Mausoléu (`necromancia_pedra`) | necromancia + pedra | invoca esqueletos que bloqueiam a rota por instantes |
| dual | Alquimista (`gelo_fogo`) | gelo + fogo | nuvem de vapor: área + lentidão |
| dual | Pântano Congelado (`gelo_druidico`) | gelo + druidico | lentidão forte em área |
| dual | Geleira (`gelo_pedra`) | gelo + pedra | avalanche periódica em área grande |
| dual | Incêndio Florestal (`fogo_druidico`) | fogo + druidico | fogo que se espalha pelo caminho |
| dual | Forja Anã (`fogo_pedra`) | fogo + pedra | canhão de alto dano em área |
| dual | Ent Ancião (`druidico_pedra`) | druidico + pedra | raízes prendem inimigos (stun em área) |