# Testes

## Teste automático (smoke test)
**Arquivos:** `tests/smoke_test.tscn` + `tests/smoke_test.gd`

Abre a partida sem tela, com ouro infinito, e confere:
1. o mapa tem slots;
2. constrói 10 torres (Arqueiros e Catapultas);
3. compra Fogo e Pedra e evolui uma torre até `fogo_1` e depois até a Dual `fogo_pedra`;
4. vende uma torre e recebe ouro;
5. roda 6 ondas até o fim;
6. o castelo sobrevive.

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
