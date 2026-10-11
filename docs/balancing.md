# PipoTd — Balanceamento

## Onde ficam os números

| Arquivo | Conteúdo |
|---|---|
| `data/towers.json` | cada torre: `cost`, `damage`, `attack_speed` (ataques/s), `range` (metros), `splash_radius`, `ability`, `requires`, `upgrades_to` |
| `data/elements.json` | ciclo das Ordens e multiplicadores forte/fraco |
| `data/economy.json` | ouro inicial, juros, Favor Real, curva de vida das ondas |

Todos os valores atuais são **provisórios**. Explicação de cada campo: [data-reference.md](data-reference.md).

## Como balancear hoje
1. Rode o jogo.
2. Edite o JSON em `data/` e salve.
3. Aperte **F5** na janela do jogo: torres já construídas, preços e ondas futuras passam a usar os valores novos.

## Painel de balanceamento (planejado — Fase 2 do [todo.md](todo.md))

Duas camadas:

1. **Painel no editor Godot** (plugin em `addons/`): tabela com todas as torres, edição de dano / velocidade / range / custo, colunas calculadas de **DPS** (`damage × attack_speed`) e **DPS por ouro**, salvando direto no `towers.json`.
2. **Painel de debug dentro do jogo** (tecla F1): sliders para ajustar uma torre em tempo real durante a partida, com botão "salvar no JSON".

Assim dá para testar uma onda, mexer no slider e ver o efeito na hora.
