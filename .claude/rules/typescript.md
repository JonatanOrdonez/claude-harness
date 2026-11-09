---
paths:
  - "src/**/*.ts"
---

# Reglas de TypeScript

- Modo `strict`. CommonJS (sin `"type": "module"`): los imports van **sin extensión**: `import { add } from './operations';`.
- Sin `any` ni `@ts-ignore`. Tipar siempre parámetros y retorno: `export function add(a: number, b: number): number`.
- Una función pura por operación, exportada por nombre (nada de `export default`). Sin dependencias de runtime.
- Los tipos reemplazan la validación de argumentos: no se valida `typeof` en runtime.
- Casos inválidos de dominio (por ejemplo dividir entre cero) lanzan `RangeError` con mensaje en español; nunca devuelven `Infinity` ni `NaN`.
- Nombres en inglés; comentarios en español, una línea sobre cada función exportada.
- Estilo (lo exige ESLint): comillas simples, punto y coma, indentación de 2 espacios, coma final en listas multilínea.
- Al terminar: `npm run typecheck` y `npm run lint` sin errores.
