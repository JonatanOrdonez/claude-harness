# Claude Code: de un prompt a un harness

Material de clase. El proyecto de práctica es esta misma carpeta: un archivo [src/operations.ts](src/operations.ts) al que, a través de prompts, se le agregan las operaciones **suma, resta, multiplicación y división**.
Cada paso de la clase agrega una pieza del ecosistema hasta tener un harness que hace todo el flujo: implementar → probar → revisar.

---

## 1. Conceptos

### Qué es Claude
Claude es el modelo de lenguaje de Anthropic. Por sí solo recibe texto y devuelve texto. **Claude Code** es la aplicación (CLI, extensión de VS Code, app de escritorio, web) que le da manos: leer archivos, editarlos, ejecutar comandos, buscar en el código.

### Qué es un harness
El **harness** es todo lo que rodea al modelo para que haga trabajo útil y confiable:

```
 ┌──────────────────────── HARNESS ────────────────────────┐
 │  Instrucciones   CLAUDE.md                              │
 │  Herramientas    Read, Edit, Bash, Grep...              │
 │  Permisos        qué puede y qué no puede hacer         │
 │  Skills          procedimientos reutilizables           │
 │  Agentes         ayudantes especializados               │
 │  Hooks           reglas que se ejecutan siempre         │
 │        ┌──────────────┐                                 │
 │        │    Modelo    │  ← el "cerebro"                 │
 │        └──────────────┘                                 │
 └─────────────────────────────────────────────────────────┘
```

Idea clave: **el modelo propone, el harness controla.** Un prompt es una petición; un harness convierte esa petición en un proceso repetible y verificable.

### Las piezas

| Pieza | Archivo | Quién la ejecuta | Para qué sirve |
|---|---|---|---|
| Memoria del proyecto | `CLAUDE.md` | Claude la lee al iniciar | Contexto: comandos, estructura, convenciones |
| Configuración | `.claude/settings.json` | El harness | Permisos y hooks |
| Skills | `.claude/skills/<nombre>/SKILL.md` | Claude decide (o tú con `/nombre`) | Recetas paso a paso reutilizables |
| Agentes | `.claude/agents/<nombre>.md` | Claude los delega | Subagentes con su propio contexto, herramientas y modelo |
| Hooks | `settings.json` → `hooks` | **El harness, siempre** | Automatizar: linters, tests, bloqueos |

**CLAUDE.md vs skill vs hook** (la pregunta más común):
- *CLAUDE.md*: "esto es cierto siempre en este proyecto". Es una **sugerencia** que Claude puede olvidar.
- *Skill*: "así se hace esta tarea concreta". Se carga **solo cuando hace falta**.
- *Hook*: "esto debe pasar sí o sí". Es **código determinista**; no depende de que Claude se acuerde.

> Nota: no existe un `config.md`. La configuración y los hooks viven en `.claude/settings.json`
> (`~/.claude/settings.json` para global, `.claude/settings.local.json` para lo personal sin versionar).

### Dónde viven los archivos

```
claude/
├── CLAUDE.md                      # memoria del proyecto
├── .claude/
│   ├── settings.json              # permisos + hooks
│   ├── skills/
│   │   └── add-operation/SKILL.md
│   └── agents/
│       ├── operation-writer.md
│       ├── operation-tester.md
│       └── code-reviewer.md
├── scripts/harness.sh             # el harness final (headless)
├── src/operations.ts              # lo que se va construyendo
├── test/                          # operations.test.ts lo crea operation-tester
└── package.json  tsconfig.json  eslint.config.mjs
```

---

## 2. Preparación

Requisitos: Node.js 20 o superior (`node -v`) y Claude Code instalado (`claude --version`).

```bash
cd claude
npm install                # TypeScript, tsx y ESLint
npm test                   # sin tests todavía (node:test + tsx)
npm run typecheck          # tsc --noEmit
npm run lint
claude                     # abrir Claude Code en esta carpeta
```

Para la clase, empiecen **sin** `CLAUDE.md` ni `.claude/` (muévanlos temporalmente a otra carpeta, o creen cada archivo en vivo siguiendo los pasos). `src/operations.ts` empieza vacío y `test/` no existe.

---

## 3. Paso a paso

La tarea es siempre la misma: **agregar operaciones a `operations.ts`**. Lo que cambia es **cuánto del trabajo hace el harness por ti**. Se avanza operación por operación, una por paso:

| Paso | Operación (prompt) | Pieza nueva |
|---|---|---|
| 0 | suma | nada |
| 1 | resta | `CLAUDE.md` |
| 2 | (repetir resta) | permisos |
| 3 | multiplicación | agentes |
| 4 | división | skill `/add-operation` |
| 5 | probar el lint | hooks |
| 6 | todo en un comando | `harness.sh` |

> Si prefieren, usen la misma operación en todos los pasos (reseteando `operations.ts`) para comparar la calidad del resultado de forma directa.

### Paso 0: Claude sin nada (solo el modelo + herramientas)
Sin `CLAUDE.md` ni `.claude/`. Prompt:

> Agrega una función de suma a src/operations.ts

**Observar:** Claude explora el repo, adivina convenciones (¿`export default`? ¿`function` o flecha? ¿nombre `sum` o `add`? ¿tipos explícitos o `any`?), probablemente no escribe tests ni corre el linter. Funciona, pero depende de la suerte.

### Paso 1: CLAUDE.md (darle contexto)
Agregar [CLAUDE.md](CLAUDE.md). Reiniciar la sesión (se lee al iniciar). Prompt:

> Agrega la resta

**Observar:** ahora usa `subtract`, exporta por nombre, tipa parámetros y retorno, usa comillas simples y punto y coma, escribe en español y corre `npm test`, `npm run typecheck` y `npm run lint` por su cuenta. Pueden generarlo con `/init` y comparar.
**Mensaje:** el contexto es la mejora más barata. Pero sigue siendo una sugerencia.

### Paso 2: Permisos (settings.json, parte 1)
Agregar solo el bloque `permissions` de [.claude/settings.json](.claude/settings.json).

**Observar:** deja de pedir confirmación para `npm test`, `npm run typecheck` y `npm run lint`, y no puede leer ni editar `.env` ni hacer `rm -rf`.
**Mensaje:** el harness define el radio de acción, no el modelo.

### Paso 3: Agentes (delegar con contexto aislado)
Agregar [operation-writer](.claude/agents/operation-writer.md), [operation-tester](.claude/agents/operation-tester.md) y [code-reviewer](.claude/agents/code-reviewer.md). Prompt:

> Agrega la multiplicación. Usa el agente operation-writer para implementarla, después operation-tester para escribir los tests y al final code-reviewer para revisar.

**Observar:**
- Claude lanza **tres agentes, uno tras otro**: cada uno trabaja en su propio contexto y solo devuelve un resumen.
- El writer no puede tocar `test/` y el tester no puede tocar `src/` (lo dicen sus instrucciones). El reviewer solo tiene herramientas de lectura.
- El tester corre con un modelo más barato (`haiku`); el writer y el reviewer con `sonnet`.

**Mensaje:** un agente = rol + herramientas limitadas + contexto propio. El hilo principal no se llena de ruido, y un revisor sin permiso de editar no puede "arreglar a escondidas".

| | Skill | Agente |
|---|---|---|
| Qué es | Instrucciones que Claude sigue | Otro "Claude" al que se delega |
| Contexto | El mismo de la conversación | Aislado; solo devuelve el resultado |
| Herramientas/modelo | Los de la sesión | Configurables por agente |

**Los agentes no se llaman entre sí.** El orquestador es la sesión principal (o el harness). Por eso aquí el prompt tiene que decir el orden; el siguiente paso evita repetirlo cada vez. Los agentes independientes (dos revisores sobre archivos distintos) pueden correr en paralelo; estos tres no, porque cada uno necesita el resultado del anterior.

### Paso 4: Un skill (repetir un procedimiento)
Agregar [add-operation](.claude/skills/add-operation/SKILL.md). Prompt:

> /add-operation división

**Observar:** sin explicar el flujo, lanza writer → tester → reviewer en orden, devuelve los bugs al agente correcto y solo termina con APROBADO. La división es la mejor operación para la demo: el caso `divide(1, 0)` debe lanzar `RangeError` y no devolver `Infinity`. Si el writer lo olvida, el tester o el reviewer lo detectan.
**Mensaje:** el skill codifica *cómo lo hace tu equipo* y le da el rol de orquestador a la sesión principal. Solo carga su contenido completo cuando se usa (la `description` es lo único que está siempre en contexto, por eso debe decir *cuándo* usarlo).

### Paso 5: Hooks (automatización determinista)
Agregar el bloque `hooks` de [settings.json](.claude/settings.json). No hacen falta scripts: el hook es un comando de shell, el mismo que ya usas a mano:

```json
"PostToolUse": [{
  "matcher": "Edit|Write",
  "hooks": [{ "type": "command",
              "command": "cd \"$CLAUDE_PROJECT_DIR\" && npm run typecheck --silent 1>&2 && npm run lint --silent 1>&2 || exit 2" }]
}]
```

Probar dos cosas:

1. Pedir que agregue una función con `any` o con comillas dobles → `tsc` o ESLint fallan → el hook devuelve el error a Claude → **se corrige solo**.
2. Pedir que edite `.env` → **bloqueado** por `permissions.deny` (`Edit(./.env)`), sin necesidad de hook.

| Evento | Cuándo corre | Uso típico |
|---|---|---|
| `PreToolUse` | Antes de usar una herramienta | Bloquear, validar |
| `PostToolUse` | Después de usarla | Linter, formatter |
| `Stop` | Cuando Claude cree que terminó | Tests: si fallan, **no puede terminar** |
| `UserPromptSubmit` | Al enviar un prompt | Inyectar contexto |

Contrato de un hook: **exit 0** = ok; **exit 2** = bloquea y lo que escribas en stderr vuelve a Claude (por eso `1>&2 || exit 2`; `tsc`, ESLint y npm salen con 1, que Claude no ve). El `matcher` filtra por herramienta (`Edit|Write`).

Cuando la lógica necesita decidir según el archivo o los parámetros (el hook recibe un JSON por stdin con `tool_input.file_path`), ahí sí conviene un script. Para correr un comando fijo, basta una línea.

**Mensaje:** esto es lo que convierte "por favor corre el linter" (CLAUDE.md) en "el linter siempre corre" (hook).

Comando útil: `/hooks` muestra los hooks activos.

### Paso 6: El harness completo
Con todo lo anterior, el flujo ya es un sistema. El último paso lo saca del chat: [scripts/harness.sh](scripts/harness.sh) usa `claude -p` (modo headless) para encadenar **implementar y probar → revisar → verificar** y devolver un código de salida.

```bash
./scripts/harness.sh "potencia"       # una operación que no se vio en clase
```

```
 operación ──► Claude + CLAUDE.md ──► operation-writer ──► operation-tester
                                         │ hooks: tipos + lint en cada edición
                                         ▼
                       code-reviewer (APROBADO / CAMBIOS REQUERIDOS)
                                         │
                          tsc + eslint + npm test (verificación objetiva)
                                         │
                                 exit 0 / exit 1
```

**Mensaje final:** en el paso 0 la calidad dependía del prompt. En el paso 6 depende del sistema: contexto, roles, procedimientos, reglas automáticas y una verificación objetiva. Eso es un harness. Se puede correr en CI, en lote sobre muchas operaciones o programado.

---

## 4. Resumen de una diapositiva

| Paso | Se agrega | Aporta | Garantía |
|---|---|---|---|
| 0 | Nada | Modelo + herramientas | Ninguna |
| 1 | `CLAUDE.md` | Contexto y convenciones | Sugerencia |
| 2 | `permissions` | Límites | Del harness |
| 3 | Agentes | Roles, herramientas limitadas, contexto aislado | Separación |
| 4 | Skill | Orquestación repetible | Consistencia |
| 5 | Hooks | Lint/tests/bloqueos | **Determinista** |
| 6 | `harness.sh` | Automatización de punta a punta | Verificable (exit code) |

## 5. Referencia: cómo debería quedar `operations.ts`

Para que el profesor compare (el resultado de Claude no tiene que ser idéntico, pero sí cumplir las convenciones):

```ts
// Suma dos números.
export function add(a: number, b: number): number {
  return a + b;
}

// Divide a entre b. Lanza RangeError si b es cero.
export function divide(a: number, b: number): number {
  if (b === 0) {
    throw new RangeError('No se puede dividir entre cero');
  }
  return a / b;
}
```

Señales de que el harness está funcionando: tipos explícitos sin `any`, nombres `add`/`subtract`/`multiply`/`divide`, `RangeError` en división entre cero, un `test/operations.test.ts` con casos felices, negativos, decimales y errores.

## 6. Ejercicios para estudiantes

1. Agregar `power` y `modulo` con `/add-operation` y comparar con hacerlo "a mano" (paso 0).
2. Escribir un agente `docs-writer` que agregue JSDoc a cada función, y encadenarlo al flujo.
3. Agregar un hook `Stop` propio (por ejemplo, correr `npx prettier --check .`).
4. Quitar a propósito una línea de `CLAUDE.md` (por ejemplo, la de `RangeError`) y ver qué capa detecta el problema: el reviewer, los tests o nadie.

## 7. Limitaciones a mencionar

- Los hooks ejecutan comandos con **tus permisos**: revisar siempre los de un repo ajeno.
- `CLAUDE.md` largo = más tokens y menos atención; mantenerlo corto y concreto.
- Un skill o agente con mala `description` nunca se activa o se activa mal.
- Los subagentes no lanzan otros subagentes: la orquestación está en la sesión principal, el skill o el script.
- El revisor y el generador son el mismo modelo: la verificación objetiva (tests, linter) pesa más que su opinión.
- Los nombres de eventos y campos de configuración evolucionan; confirmar con la documentación oficial (`/help`, `/hooks`, docs.claude.com) antes de la clase.
