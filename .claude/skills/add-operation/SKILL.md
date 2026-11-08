---
name: add-operation
description: Agrega una operación aritmética nueva (suma, resta, multiplicación, división...) a operations.ts orquestando los agentes operation-writer, operation-tester y code-reviewer. Úsalo cuando el usuario pida agregar una operación.
---

# Agregar una operación

Argumento: la operación a agregar (ej. `division`).

Los agentes no se llaman entre sí: tú eres el orquestador. Lanza los agentes **uno a la vez y en este orden**, porque cada uno depende del resultado del anterior:

1. **`operation-writer`**: pásale la operación pedida. Guarda su respuesta (firma y casos de error).
2. **`operation-tester`**: pásale esa respuesta para que sepa qué probar.
3. **`code-reviewer`**: pídele revisar la operación y sus tests.

Después:

- Si el tester reporta un bug en la función, vuelve al paso 1 con ese reporte (máximo 2 vueltas).
- Si el revisor responde CAMBIOS REQUERIDOS, pasa los bloqueantes al agente que corresponda (código → writer, tests → tester) y repite el paso 3.
- Termina solo cuando el revisor diga APROBADO y `npm run typecheck`, `npm run lint` y `npm test` pasen.

Al final resume al usuario: qué se agregó, cuántos tests y el veredicto del revisor.
