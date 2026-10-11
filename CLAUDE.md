# Instruções para sessões de IA neste projeto

Projeto **PipoTd**: tower defense 3D medieval em Godot 4.5, inspirado no Element TD 2. Idioma do projeto e da documentação: **português**.

## Antes de começar
1. Leia [docs/README.md](docs/README.md) (mapa da documentação).
2. Leia [docs/todo.md](docs/todo.md) para saber o que está feito e o que vem a seguir.
3. Leia [docs/architecture.md](docs/architecture.md) antes de mexer em código.

## Regra principal: TUDO documentado em .md
O dono do projeto quer o projeto **perfeitamente documentado em Markdown**, para entender o sistema e, no futuro, ter um manual. Em toda alteração:

- **docs/todo.md** — marque `[x]` o que foi feito; adicione novos itens que surgirem. Todo passo planejado precisa estar lá.
- **docs/changelog.md** — adicione uma entrada datada descrevendo o que mudou e por quê.
- **docs/systems/*.md** — atualize o doc do sistema que você alterou (combate, ondas, economia, torres, mapa, HUD…). Sistema novo = doc novo + link em docs/README.md.
- **docs/data-reference.md** — qualquer campo novo/alterado em `data/*.json` é explicado aqui.
- **docs/decisions.md** — decisões de design ou técnicas com o motivo.
- **docs/manual/** — se mudar algo que o jogador vê (controles, regras), atualize o manual.
- Pode criar quantos .md forem necessários; mantenha o índice em docs/README.md.

## Regras de código
- **Nenhum número de balanceamento fixo no código.** Dano, velocidade, alcance, custos, vidas, ondas: sempre em `data/*.json`, lidos via `GameData`.
- Lógica do jogo separada do visual (facilita multiplayer no futuro).
- GDScript tipado; comentários em português.

## Testar
Rode o teste automático antes de commitar (ver [docs/testing.md](docs/testing.md)):

```
godot --headless --fixed-fps 60 res://tests/smoke_test.tscn
```

Tem que terminar com `RESULTADO: PASSOU`.
