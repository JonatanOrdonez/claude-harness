---
paths:
  - "test/**/*.ts"
---

# Reglas de tests

- Se usa `node:test` y `node:assert/strict`; no agregar librerías de testing. Se ejecutan con `npm test` (vía `tsx`).
- Un archivo por módulo: `test/<modulo>.test.ts`. Importar el código sin extensión: `import { divide } from '../src/operations';`.
- Nombres en español descriptivo: `test('divide lanza RangeError al dividir entre cero', ...)`.
- Cada operación cubre como mínimo: caso feliz, negativos, decimales y casos de error.
- Decimales: comparar con tolerancia, `assert.ok(Math.abs(actual - esperado) < 1e-9)`; nunca `equal` con flotantes.
- Errores: `assert.throws(() => divide(1, 0), RangeError)`, indicando siempre el tipo.
- Probar el contrato, no la implementación: los valores esperados se escriben a mano, no se calculan con la misma fórmula.
- Una aserción principal por test. Sin mocks: son funciones puras.
- Sin `any` ni `@ts-ignore`; el archivo debe pasar el estilo de ESLint.
- Si un test falla por un bug real, no se ajusta el test para que pase: se reporta el bug.
