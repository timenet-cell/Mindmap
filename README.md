# Mindmap

Um mapa de ideias com cara de desenho animado, num único ficheiro HTML. Serve para pôr cá fora o que anda na cabeça, arrumar as ideias e travar os pensamentos que andam às voltas.

- **O Cérebro** fica ao centro. Na primeira vez, a app pergunta que nome lhe queres dar.
- **As ideias** são nuvens animadas à volta dele. Carregar numa faz com que ela deslize até ao centro (inspirado na VNI da Armaro Gatecontrol), e `Esc` volta para trás.
- **Bonecos e emoções:** cada ideia pode ter um boneco com 10 emoções (feliz, calmo, com carinho, triste, zangado, furioso, ansioso, assustado, cansado, confuso).
- **🤜 Bater:** um punho bate no boneco e o ecrã abana. **🤚 Festinhas:** uma mão faz-lhe festas e saem corações. A app conta quantas vezes já libertaste.
- **Os meus bonecos:** podes criar bonecos com as tuas próprias imagens, uma por emoção. As imagens ficam só no teu computador e não vêm para este repositório.

## O que se faz com cada ideia

- **Ao criar uma ideia**, a app pergunta logo **o que é**: 👤 Pessoa, 🐾 Animal, 🔑 Objecto ou 💭 Ideia (escolhe-se com o rato ou com `↑` `↓`, enquanto se escreve o nome).
- **A barra de baixo** tem tudo o que se pode fazer com a ideia escolhida (a que acabaste de criar, ou a das setas) ou, sem escolha, com a ideia aberta. Está sempre no mesmo sítio e com nome:
  - **＋ Nova ideia** (sempre dentro da ideia aberta);
  - **✏️ Escrever**: as notas, as perguntas (gavetas) do que a ideia é, como separadores, e o **📦 Arrumar por hoje**. Clicar no boneco da ideia aberta faz o mesmo;
  - **💗 Sentir**: pôr cá para fora (bater, festinhas, abraçar, agradecer, gritar, chorar), dizer como me sinto com a ideia, e respirar;
  - **⋯ Mais**: o que é, a cor, mudar o boneco, mudar o nome e apagar.
- **Olhar para fora:** em cada pessoa e animal há um botão **💙 Como se sente?** (na barra, no cartão aberto e na janela de Escrever) para dizeres como achas que ele se sente. É isso que muda a cara do boneco. Há também a pergunta escrita «Como se sente».
- **Como me sinto com uma ideia** é outra coisa: o que tu sentes aparece num selo pequeno ao lado do boneco e conta nas estatísticas.
- **Apagar uma ideia** pede sempre confirmação e a password.
- **As gavetas dependem do que a ideia é**: um assunto tem as 13 perguntas; uma pessoa tem 7, todas sobre ela (como esta pessoa se sente, o que gosto e o que não gosto nesta pessoa, o que me custa, o que lhe queria dizer…); um animal tem 5 e um objecto 4.
- **🧠 O meu Cérebro** (na barra de cima) junta Despejar, As minhas entradas, Como tens andado e Assuntos arrumados.
- O botão **?** (em baixo, à direita) mostra como se anda pelo mapa.
- **Nos campos de texto**, o `Enter` muda de linha e o botão **✓ Guardar** (ou `⌘Enter`) confirma. Cada ideia sugere o que escrever conforme o que é.
- **O texto do Cérebro é um diário sobre ti**: escreves, carregas em **✓ Guardar** e fica uma entrada com a data e a hora em **📖 As minhas entradas**; o campo fica livre para a próxima.
- **As pessoas** têm boneco de 👦 rapaz ou 👧 rapariga (escolhe-se logo a seguir a dizer que é uma pessoa).

## Como usar

Faz duplo clique em `index.html`, de preferência no Chrome.

| Rato / tecla | O que faz |
|---|---|
| Clicar numa ideia | Abre-a; a câmara viaja até ela e aproxima-se mais nas ideias mais fundas |
| `←` `↑` `↓` `→` | Escolhe a ideia mais próxima nessa direcção; `Enter` abre-a |
| `⌘[` / `⌘]` (ou `Alt+←` / `Alt+→`) | Voltar / avançar pelas ideias por onde passaste |
| Carregar no fundo e arrastar | Anda pelo mapa |
| Roda do rato (ou beliscar no trackpad) | Zoom no sítio do rato |
| Duplo clique no fundo / `0` | Ver tudo |
| `Tab` | Nova ideia (e `Tab` outra vez para a seguinte) |
| `Esc` | Fecha a janela da ideia aberta (ela fica só escolhida); outra vez, tira a escolha |
| `B` / `F` / `E` | Bater / Festinhas / Mudar emoção |
| `⌘K` | Procurar |
| `⌘Z` | Desfazer |

No topo do mapa está sempre o caminho até à ideia aberta (Cérebro › … › ideia); cada nome é um botão.

Para mudar uma ideia de sítio, arrasta-a para cima de outra.

## Onde ficam os dados

Os dados ficam sempre **fora da pasta da app** e nunca vêm para este repositório.

- **App compilada para o Mac (o caminho principal):** num `mindmap.json` no **iCloud Drive** (`iCloud Drive/Mindmap/`) ou nos **Documentos** (`Documentos/Mindmap/`). Na primeira vez a app pergunta qual dos dois prefere, e dá para mudar depois em *Ficheiro → Onde guardar as ideias…*. O WebView guarda também uma cópia de reserva.
- **No Chrome ou no Edge, sem compilar:** em *Ficheiro → Gravar automaticamente num ficheiro…* escolhe-se onde fica o `mindmap.json`.
- **No Safari, sem compilar:** o Safari não deixa uma página gravar em ficheiros. Os dados ficam só no Safari, por isso é preciso usar *Ficheiro → Exportar cópia*. A app compilada resolve isto.

## Compilar para o Mac

A app de Mac está em `mac/main.swift` (Swift + WKWebView, sem projecto do Xcode). Para a compilar como **Universal** (Intel + Apple Silicon), num Mac com as ferramentas de linha de comandos do Xcode:

```bash
mac/compilar.sh
```

Fica em `dist/Mindmap.app` (e `dist/Mindmap-Mac-Universal.zip`). Precisa do macOS 11.3 ou mais recente.

O GitHub também a compila sozinho em cada pull request e em cada alteração ao `main` (workflow *App para o Mac*): o zip fica nos *Artifacts* dessa execução, com o nome `Mindmap-Mac-Universal`. Como a app tem só assinatura ad-hoc, na primeira vez abre-se com o botão direito › *Abrir* (ou, no Terminal, `xattr -dr com.apple.quarantine Mindmap.app`).

### Como a app fala com a página

Faz-se uma app de Mac que mostra o `index.html` num **WKWebView** (Swift, ou Tauri 2, que no Mac também usa o WKWebView). A página não muda; o programa à volta dela só tem de lhe dar o objecto abaixo, **antes** de os scripts da página correrem (por exemplo com um `WKUserScript` em `atDocumentStart`, ou o `initialization_script` do Tauri):

```js
window.MindmapNativo = {
  ler(): Promise<string | null>,      // o texto do mindmap.json, ou null se ainda não existir
  gravar(texto: string): Promise<void>, // escrever de forma atómica (ficheiro temporário + mudar o nome)
  onde(): string,                     // o caminho, para mostrar à pessoa
  sitios(): Array<{ k: 'icloud' | 'documentos', nome: string, caminho: string, disponivel: boolean }>,
  mudarPara(k: 'icloud' | 'documentos'): Promise<void> // mover o ficheiro para lá e usar esse sítio daí em diante
};
```

- **Caminhos:**
  - iCloud Drive: `~/Library/Mobile Documents/com~apple~CloudDocs/Mindmap/mindmap.json` (está disponível se a pasta `com~apple~CloudDocs` existir).
  - Documentos: `~/Documents/Mindmap/mindmap.json`.
  - Nunca dentro do `.app`.
- **Sítio por omissão:** o iCloud Drive se estiver disponível; se não, os Documentos. A escolha guarda-se nas preferências da app (`UserDefaults`), não no `mindmap.json`.
- **App sem sandbox**, assinada ad-hoc para uso pessoal: assim lê e escreve nesses caminhos sem pedir mais permissões.
- **Rede:** a página vai buscar `versao.json` e `index.html` a `raw.githubusercontent.com` para avisar de versões novas. O WebView tem de poder fazer esses pedidos.
- **WebView:** usar um `WKWebsiteDataStore` persistente (o normal), para a cópia de reserva no `localStorage` não se perder.
- **Para testar sem compilar:** no Chrome, define-se um `window.MindmapNativo` falso antes de carregar a página. A app passa a usá-lo em vez do browser.
