# Testes

## Teste automático (smoke test)
**Arquivos:** `tests/smoke_test.tscn` + `tests/smoke_test.gd`

Abre a partida sem tela, com ouro infinito, e confere:
1. a grade tem mais de 100 células construíveis e nenhuma encosta na estrada;
2. constrói 10 torres (Arqueiros e Catapultas) nas células mais perto da estrada;
3. não deixa construir em célula ocupada;
4. compra Fogo e Pedra e evolui uma torre até `fogo_1` e depois até a Dual `fogo_pedra`;
5. vende uma torre e recebe ouro;
6. roda 6 ondas até o fim;
7. o castelo sobrevive.

### Rodar
Na pasta do projeto:

```
godot --headless --fixed-fps 60 res://tests/smoke_test.tscn
```

No Windows, use o caminho do executável, por exemplo:

```
"C:\Godot\Godot_v4.5.1-stable_win64_console.exe" --headless --fixed-fps 60 res://tests/smoke_test.tscn
```

Resultado esperado: linhas `OK` e no fim `RESULTADO: PASSOU` (código de saída 0). Qualquer `FALHA` mostra o que quebrou.

`--fixed-fps 60` faz o tempo do jogo andar o mais rápido possível, então 6 ondas levam poucos segundos.

## Teste manual
Abra no editor e aperte F5 do Godot (rodar). Roteiro rápido no [manual do jogador](manual/jogador.md).

## Capturas de tela
**Arquivos:** `tests/screenshot.tscn` + `tests/screenshot.gd`

Abre o jogo **com janela** (não funciona com `--headless`), monta uma defesa com vários tipos de torre, pula para uma onda e salva 4 imagens: `overview`, `closeup`, `castle`, `portal`.

```
"E:\Projetos\Godot\Godot_v4.5.1-stable_win64_console.exe" --path . res://tests/screenshot.tscn -- --out=E:/Projetos/PipoTD/docs/images --wave=8
```

- `--out=` pasta de saída (padrão: `user://screenshots`).
- `--wave=` qual onda (facção) mostrar.
- `--gallery` em vez da defesa: uma criatura de cada facção parada na estrada, mais um chefe e um blindado → `gallery.png`.

As imagens em `docs/images/` são usadas em [art-direction.md](art-direction.md).
