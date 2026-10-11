# Setup: instalar e rodar

## 1. Godot
Baixe o **Godot 4.5.x (versão padrão, não a .NET)** em https://godotengine.org/download e descompacte numa pasta. Não precisa instalar.

No PC do dono já está em **`E:\Projetos\Godot\`** (4.5.1): `Godot_v4.5.1-stable_win64.exe` (editor) e `..._console.exe` (mesmo programa, mostrando mensagens no terminal).

## 2. Baixar o projeto
Com o Git instalado, no terminal:

```
cd E:\projetos
git clone https://github.com/peniku/PipoTD.git PipoTd
```

## 3. Abrir
1. Abra o Godot → **Importar** → selecione `E:\projetos\PipoTd\project.godot`.
2. Na primeira vez ele importa os arquivos (alguns segundos).
3. Aperte **F5** (ou o botão ▶) para jogar.

## 4. Editar números
Abra os arquivos em `data/` em qualquer editor (VS Code, Notepad++). Com o jogo rodando, aperte **F5 dentro da janela do jogo** para recarregar. Campos explicados em [data-reference.md](data-reference.md).

## 5. Trabalhar com a IA no PC
- Opção A: abrir esta conversa no app desktop do Claude no PC (liga a conversa ao computador).
- Opção B: usar o Claude Code (CLI) dentro de `E:\projetos\PipoTd`. Ele lê o `CLAUDE.md` e segue as regras de documentação.
