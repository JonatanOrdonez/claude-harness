#!/usr/bin/env bash
# Harness mínimo: Claude en modo headless agrega una operación usando los agentes del proyecto
# y el código de salida depende de que lint, tests y revisión pasen. Sirve para CI o para lotes.
#
# Uso: ./scripts/harness.sh "division"
set -euo pipefail
cd "$(dirname "$0")/.."

OPERATION="${1:?Uso: harness.sh \"operacion\" (ej. division)}"
REVIEW="$(mktemp)"

echo "==> 1/3 Implementar y probar"
claude -p "Agrega la operación '$OPERATION' a src/operations.ts. Primero lanza el agente operation-writer y, cuando termine, el agente operation-tester." \
  --permission-mode acceptEdits \
  --max-turns 20

echo "==> 2/3 Revisar"
claude -p "Usa el agente code-reviewer para revisar los cambios. Termina con APROBADO o CAMBIOS REQUERIDOS." \
  --permission-mode plan | tee "$REVIEW"

echo "==> 3/3 Verificar (tipos + lint + tests)"
npm run typecheck
npm run lint
npm test

grep -q "APROBADO" "$REVIEW" && echo "OK: operación agregada" || { echo "FALLO: revisión no aprobada"; exit 1; }
