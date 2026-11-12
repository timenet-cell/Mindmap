// Mindmap para o Mac: uma janela com o index.html num WKWebView.
// A página não muda; este programa só lhe dá o window.MindmapNativo (ver o README),
// que lê e grava o mindmap.json no iCloud Drive ou nos Documentos, fora da app.
import Cocoa
import WebKit

enum Sitio: String { case icloud, documentos }

// Onde ficam as ideias: ler, gravar e mudar de sítio.
final class Guarda {
    private let fm = FileManager.default
    private var casa: URL { fm.homeDirectoryForCurrentUser }
    private var raizICloud: URL { casa.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs") }

    var icloudDisponivel: Bool {
        var pasta: ObjCBool = false
        return fm.fileExists(atPath: raizICloud.path, isDirectory: &pasta) && pasta.boolValue
    }
    func pasta(_ s: Sitio) -> URL {
        s == .icloud ? raizICloud.appendingPathComponent("Mindmap") : casa.appendingPathComponent("Documents/Mindmap")
    }
    func caminho(_ s: Sitio) -> URL { pasta(s).appendingPathComponent("mindmap.json") }

    // A escolha fica nas preferências da app, não no mindmap.json.
    var atual: Sitio {
        get {
            if let v = UserDefaults.standard.string(forKey: "sitio"), let s = Sitio(rawValue: v) {
                if s == .documentos || icloudDisponivel { return s }
            }
            return icloudDisponivel ? .icloud : .documentos
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "sitio") }
    }

    func ler() -> String? { try? String(contentsOf: caminho(atual), encoding: .utf8) }

    // Escrita atómica: ficheiro temporário e depois muda-se o nome.
    func gravar(_ texto: String) throws {
        try fm.createDirectory(at: pasta(atual), withIntermediateDirectories: true)
        try Data(texto.utf8).write(to: caminho(atual), options: .atomic)
    }

    // Leva o ficheiro para o sítio novo. Se lá já houver um, fica guardado com outro nome.
    func mudarPara(_ s: Sitio) throws {
        let de = caminho(atual), para = caminho(s)
        if de.path != para.path && fm.fileExists(atPath: de.path) {
            try fm.createDirectory(at: pasta(s), withIntermediateDirectories: true)
            if fm.fileExists(atPath: para.path) {
                let antigo = pasta(s).appendingPathComponent("mindmap-antes-\(Int(Date().timeIntervalSince1970)).json")
                try fm.moveItem(at: para, to: antigo)
            }
            try fm.moveItem(at: de, to: para)
        }
        atual = s
    }

    func estado() -> [String: Any] {
        let sitios: [[String: Any]] = [
            ["k": "icloud", "nome": "iCloud Drive", "caminho": caminho(.icloud).path, "disponivel": icloudDisponivel],
            ["k": "documentos", "nome": "Documentos", "caminho": caminho(.documentos).path, "disponivel": true],
        ]
        return ["onde": caminho(atual).path, "sitios": sitios]
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandlerWithReply, WKUIDelegate, WKNavigationDelegate, WKDownloadDelegate {
    private let guarda = Guarda()
    private var janela: NSWindow!
    private var web: WKWebView!
    private var aSair = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        fazerMenus()

        let cfg = WKWebViewConfiguration()   // o WKWebsiteDataStore normal (persistente): a reserva no localStorage não se perde
        cfg.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: "mindmap")
        let dados = (try? JSONSerialization.data(withJSONObject: guarda.estado())) ?? Data("{}".utf8)
        let estado = String(data: dados, encoding: .utf8) ?? "{}"
        let ponte = """
        (function () {
          let e = \(estado);
          const h = window.webkit.messageHandlers.mindmap;
          window.MindmapNativo = {
            ler: () => h.postMessage({ op: 'ler' }),
            gravar: texto => h.postMessage({ op: 'gravar', texto }).then(() => {}),
            onde: () => e.onde,
            sitios: () => e.sitios,
            mudarPara: k => h.postMessage({ op: 'mudarPara', k }).then(novo => { e = novo; }),
          };
        })();
        """
        cfg.userContentController.addUserScript(WKUserScript(source: ponte, injectionTime: .atDocumentStart, forMainFrameOnly: true))

        web = WKWebView(frame: .zero, configuration: cfg)
        web.uiDelegate = self
        web.navigationDelegate = self

        janela = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 820),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        janela.title = "Mindmap"
        janela.minSize = NSSize(width: 720, height: 520)
        janela.center()
        janela.setFrameAutosaveName("MindmapJanela")
        janela.contentView = web
        janela.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        guard let pagina = Bundle.main.url(forResource: "index", withExtension: "html") else {
            let a = NSAlert(); a.messageText = "Falta o index.html dentro da app."; a.runModal(); NSApp.terminate(nil); return
        }
        web.loadFileURL(pagina, allowingReadAccessTo: pagina.deletingLastPathComponent())
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    // Antes de sair, a página grava o que ainda falta (ela espera um quarto de segundo depois de cada tecla).
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if aSair || web == nil { return .terminateNow }
        aSair = true
        var respondido = false
        let responder = { if !respondido { respondido = true; NSApp.reply(toApplicationShouldTerminate: true) } }
        web.callAsyncJavaScript("if (typeof gravarTudo === 'function') await gravarTudo();", arguments: [:], in: nil, in: .page) { _ in responder() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { responder() }
        return .terminateLater
    }

    // Os pedidos da página: ler, gravar e mudar de sítio.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage,
                               replyHandler: @escaping (Any?, String?) -> Void) {
        guard let m = message.body as? [String: Any], let op = m["op"] as? String else { replyHandler(nil, "Pedido inválido"); return }
        do {
            switch op {
            case "ler":
                if let texto = guarda.ler() { replyHandler(texto, nil) } else { replyHandler(NSNull(), nil) }
            case "gravar":
                guard let texto = m["texto"] as? String, !texto.isEmpty else { replyHandler(nil, "Nada para gravar"); return }
                try guarda.gravar(texto)
                replyHandler(true, nil)
            case "mudarPara":
                guard let k = m["k"] as? String, let s = Sitio(rawValue: k) else { replyHandler(nil, "Sítio desconhecido"); return }
                try guarda.mudarPara(s)
                replyHandler(guarda.estado(), nil)
            default:
                replyHandler(nil, "Pedido desconhecido")
            }
        } catch {
            replyHandler(nil, error.localizedDescription)
        }
    }

    // Escolher ficheiros (importar uma cópia, imagens dos bonecos).
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        let painel = NSOpenPanel()
        painel.allowsMultipleSelection = parameters.allowsMultipleSelection
        painel.canChooseDirectories = false
        painel.begin { r in completionHandler(r == .OK ? painel.urls : nil) }
    }

    // alert() e confirm() da página.
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let a = NSAlert(); a.messageText = message; a.addButton(withTitle: "OK"); a.runModal(); completionHandler()
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let a = NSAlert(); a.messageText = message; a.addButton(withTitle: "OK"); a.addButton(withTitle: "Cancelar")
        completionHandler(a.runModal() == .alertFirstButtonReturn)
    }

    // Descargas (Exportar cópia) vão para as Transferências; os links para fora abrem no browser.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences,
                 decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if navigationAction.shouldPerformDownload { decisionHandler(.download, preferences); return }
        if navigationAction.navigationType == .linkActivated, let u = navigationAction.request.url, u.scheme == "https" || u.scheme == "http" {
            NSWorkspace.shared.open(u); decisionHandler(.cancel, preferences); return
        }
        decisionHandler(.allow, preferences)
    }
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) { download.delegate = self }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(navigationResponse.canShowMIMEType ? .allow : .download)
    }
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) { download.delegate = self }
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String,
                  completionHandler: @escaping (URL?) -> Void) {
        let fm = FileManager.default
        let pasta = fm.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        let nome = suggestedFilename.isEmpty ? "mindmap.json" : suggestedFilename
        let base = (nome as NSString).deletingPathExtension, ext = (nome as NSString).pathExtension
        var destino = pasta.appendingPathComponent(nome)
        var i = 2
        while fm.fileExists(atPath: destino.path) {
            destino = pasta.appendingPathComponent(ext.isEmpty ? "\(base) \(i)" : "\(base) \(i).\(ext)")
            i += 1
        }
        completionHandler(destino)
    }

    // Os menus mínimos: sem o menu Editar, copiar e colar não funcionam nos campos de texto.
    // O ⌘Z não está no menu de propósito: a página usa-o para desfazer no mapa.
    private func fazerMenus() {
        let barra = NSMenu()

        let itemApp = NSMenuItem(); barra.addItem(itemApp)
        let menuApp = NSMenu(); itemApp.submenu = menuApp
        menuApp.addItem(withTitle: "Esconder o Mindmap", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        menuApp.addItem(NSMenuItem.separator())
        menuApp.addItem(withTitle: "Sair do Mindmap", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        let itemEditar = NSMenuItem(); barra.addItem(itemEditar)
        let editar = NSMenu(title: "Editar"); itemEditar.submenu = editar
        editar.addItem(withTitle: "Cortar", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editar.addItem(withTitle: "Copiar", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editar.addItem(withTitle: "Colar", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editar.addItem(withTitle: "Selecionar tudo", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        let itemJanela = NSMenuItem(); barra.addItem(itemJanela)
        let menuJanela = NSMenu(title: "Janela"); itemJanela.submenu = menuJanela
        menuJanela.addItem(withTitle: "Minimizar", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        let ecra = NSMenuItem(title: "Ecrã inteiro", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        ecra.keyEquivalentModifierMask = [.command, .control]
        menuJanela.addItem(ecra)

        NSApp.mainMenu = barra
        NSApp.windowsMenu = menuJanela
    }
}

let app = NSApplication.shared
let delegado = AppDelegate()
app.delegate = delegado
app.setActivationPolicy(.regular)
app.run()
