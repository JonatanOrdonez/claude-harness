# operations – operaciones aritméticas

Librería mínima en TypeScript (Node 20+) con funciones aritméticas en `src/operations.ts`. Proyecto de práctica para la clase de Claude Code.

## Comandos

- Instalar: `npm install`
- Tests: `npm test` (`node:test` ejecutado con `tsx`)
- Tipos: `npm run typecheck` (`tsc`, no genera archivos)
- Lint: `npm run lint` (autofix: `npm run lint:fix`)

## Estructura

- `src/operations.ts`: una función exportada por operación (`add`, `subtract`, `multiply`, `divide`).
- `test/operations.test.ts`: tests de esas funciones.

## Convenciones generales

- Comentarios, mensajes de error y nombres de test en español; identificadores en inglés.
- Todo cambio de comportamiento lleva sus tests.
- Las reglas específicas están en `.claude/rules/` y se cargan según el archivo que se edite:
  - `typescript.md` para `src/**/*.ts`
  - `tests.md` para `test/**/*.ts`

## Antes de dar una tarea por terminada

1. `npm run typecheck` sin errores.
2. `npm run lint` sin errores.
3. `npm test` en verde.

## Flujo para agregar una operación

Cada operación nueva pasa por cuatro agentes, en orden y uno a la vez:

1. `operation-planner`: planifica (firma, casos de error, casos de prueba); no escribe código.
2. `operation-writer`: implementa la función en `src/operations.ts`.
3. `operation-tester`: escribe los tests en `test/operations.test.ts`.
4. `code-reviewer`: revisa y da el veredicto.

El skill `/add-operation` describe este flujo.
