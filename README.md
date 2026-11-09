# Mindmap

Um mapa de ideias simples, num único ficheiro HTML. Inspirado na VNI da Armaro Gatecontrol: a ideia em que estás fica num bloco ao centro e os ramos ficam à volta. Carregar num ramo faz com que ele deslize até ao centro.

## Como usar

Faz duplo clique em `index.html`. Abre no browser e não precisa de instalação nem de internet.

| Tecla | O que faz |
|---|---|
| `Tab` | Novo ramo (e `Tab` outra vez para o seguinte) |
| `← →` | Escolher um ramo |
| `Enter` | Entrar no ramo escolhido |
| `Espaço` | Abrir o ramo numa caixa grande, para escrever notas |
| `Esc` | Voltar ao nível de cima |
| `F2` | Renomear |
| `⌫` | Apagar (há sempre *Desfazer*) |
| `⌘K` | Procurar |
| `⌘Z` | Desfazer |

Para mudar uma ideia de sítio, arrasta o bloco para cima de outro bloco ou para o caminho (rasto) que aparece no centro.

## Onde ficam os dados

- **Sempre no browser** do próprio computador (`localStorage`).
- **No Chrome ou no Edge**: em *Ficheiro → Gravar automaticamente num ficheiro…* escolhes um `ideias.json`, por exemplo no iCloud Drive. Daí em diante cada alteração grava lá sozinha.
- **No Safari**: usa *Ficheiro → Exportar cópia* de vez em quando. A app avisa quando a última cópia tiver mais de 7 dias.
