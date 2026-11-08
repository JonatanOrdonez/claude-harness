# operations – operaciones aritméticas

Librería mínima en TypeScript (Node 20+) con funciones aritméticas en `src/operations.ts`. Proyecto de práctica para la clase de Claude Code.

## Comandos

- Instalar: `npm install`
- Tests: `npm test` (usa `node:test` ejecutado con `tsx`, sin librerías de testing)
- Tipos: `npm run typecheck` (`tsc`, no genera archivos)
- Lint: `npm run lint` (autofix: `npm run lint:fix`)

## Estructura

- `src/operations.ts`: una función exportada por operación (`add`, `subtract`, `multiply`, `divide`).
- `test/operations.test.ts`: tests de esas funciones.

## Convenciones

- TypeScript en modo `strict`. CommonJS (sin `"type": "module"`); los imports van **sin extensión**: `import { add } from '../src/operations';`.
- Sin `any` ni `@ts-ignore`. Tipar parámetros y retorno: `export function add(a: number, b: number): number`.
- Una función pura por operación, exportada por nombre. Sin dependencias de runtime.
- Estilo (lo exige ESLint): comillas simples, punto y coma, indentación de 2 espacios, coma final en listas multilínea.
- Nombres en inglés, comentarios y mensajes de error en español.
- Los tipos reemplazan la validación de argumentos: no se valida `typeof` en runtime.
- Casos inválidos de dominio (por ejemplo dividir entre cero) lanzan `RangeError`; nunca devuelven `Infinity` ni `NaN`.
- Cada operación nueva lleva sus tests: caso feliz, negativos/decimales y casos de error.

## Antes de dar una tarea por terminada

1. `npm run typecheck` sin errores.
2. `npm run lint` sin errores.
3. `npm test` en verde.

## Flujo para agregar una operación

Cada operación nueva pasa por tres agentes, en orden y uno a la vez:

1. `operation-writer`: implementa la función en `src/operations.ts`.
2. `operation-tester`: escribe los tests en `test/operations.test.ts`.
3. `code-reviewer`: revisa y da el veredicto.

El skill `/add-operation` describe este flujo.
