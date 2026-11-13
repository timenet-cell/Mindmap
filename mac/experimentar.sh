#!/bin/bash
# Abre a app acabada de compilar e confirma que ela fica aberta e mostra a janela.
# Corre no workflow do GitHub (num Mac Apple Silicon) e também se pode correr à mão: mac/experimentar.sh
set -uo pipefail
cd "$(dirname "$0")/.."

SAIDA=build-teste
rm -rf "$SAIDA"; mkdir -p "$SAIDA"
PAGINA="$HOME/Library/Application Support/Mindmap/index.html"
rm -f "$PAGINA"

# Abre-se o programa directamente, para ficar com o que ele escrever quando falha.
dist/Mindmap.app/Contents/MacOS/Mindmap > "$SAIDA/app.log" 2>&1 &
PID=$!
sleep 12

VIVA=sim; kill -0 "$PID" 2> /dev/null || VIVA=nao

# As janelas que a app tem no ecrã.
cat > "$SAIDA/janelas.swift" <<'SWIFT'
import CoreGraphics
import Foundation
let pid = Int(CommandLine.arguments[1]) ?? 0
let todas = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
let minhas = todas.filter { ($0[kCGWindowOwnerPID as String] as? Int) == pid && ($0[kCGWindowLayer as String] as? Int) == 0 }
for j in minhas { print("janela:", j[kCGWindowBounds as String] ?? "") }
print("janelas: \(minhas.count)")
SWIFT
swift "$SAIDA/janelas.swift" "$PID" > "$SAIDA/janelas.txt" 2>&1
screencapture -x "$SAIDA/ecra.png" 2> /dev/null || true
log show --last 2m --predicate 'process == "Mindmap"' --style compact > "$SAIDA/sistema.log" 2>&1 || true
cp ~/Library/Logs/DiagnosticReports/Mindmap* "$SAIDA/" 2> /dev/null || true
kill "$PID" 2> /dev/null

echo "--- a app ficou aberta? $VIVA"
echo "--- o que a app escreveu:"; cat "$SAIDA/app.log"
echo "--- janelas:"; cat "$SAIDA/janelas.txt"
echo "--- página copiada para fora da app:"; ls -la "$PAGINA" 2>&1
echo "--- registo do sistema (fim):"; tail -n 40 "$SAIDA/sistema.log"
echo "--- relatórios de falha:"; ls "$SAIDA" | grep -i -E "\.(ips|crash)$" || echo "nenhum"
for R in "$SAIDA"/*.ips "$SAIDA"/*.crash; do [ -f "$R" ] && head -n 80 "$R"; done

[ "$VIVA" = sim ] || { echo "ERRO: a app fechou-se sozinha."; exit 1; }
grep -q "janelas: [1-9]" "$SAIDA/janelas.txt" || { echo "ERRO: a app ficou aberta mas não mostrou nenhuma janela."; exit 1; }
[ -f "$PAGINA" ] || { echo "ERRO: a página não foi copiada para fora da app."; exit 1; }
echo "A app abre e mostra a janela."
