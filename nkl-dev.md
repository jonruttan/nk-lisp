# nkLisp Development

Notes for working on the interpreter itself: build pipeline, repo
layout, conventions, and the bits of the assembly that bite.

## Build pipeline

The interpreter is M80/L80 Z80 assembly, run inside a CP/M emulator
([bin/cpm](bin/cpm) or `cpm` on PATH).

| Command           | Effect                                       |
| ----------------- | -------------------------------------------- |
| `make`            | Builds `nkl.com`. Default target.            |
| `make test`       | Runs the full Lisp-level test suite.         |
| `make test-NAME`  | Runs a single spec (`t-NAME.l`).             |
| `make clean`      | Removes `nkl.com`, `*.rel`, generated files. |
| `make tar`        | Builds a tarball of source files.            |
| `make run`        | Builds and starts an interactive session.    |

### Source line endings

`*.mac` files are committed with **CRLF line endings** — M80
silently emits zero code from LF-only files (no error, just an
empty `.rel`). `.gitattributes` enforces CRLF on commit, but local
edits via tools that default to LF will break the build until the
file is converted (`unix2dos foo.mac`).

`*.l` files are LF.

## Repo layout

```
nklisp.mac      COLD, WARM, REVALO, ERR, EVAL, READ entry
inout.mac       file I/O, READ implementation, console
subr.mac        list and arithmetic primitives, THROW
fsubr.mac       fexprs and special forms (CATCH, IF, etc.)
prim.mac        type checks and tag manipulation
garbage.mac     mark-and-compact GC
systab.mac      static data: oblist, system variables, RST tools

harness.l       test framework
runtests.l      test runner (loads harness, then each spec)
tharness.l      meta-tests for the harness
t-*.l           per-area test specs
too.l           Lisp-level developer tools (pp, sort, trace, who)
factor.l        Lisp-level factorisation example
nqueen.l        Lisp-level N-queens example

nkl-book.md     user guide
nkl-ref.md      language reference
nkl-qref.md     quick reference
nkl-test.md     test framework reference (this and more)
nkl-dev.md      this file
```

## The SYMB macro

System symbols (those built into the interpreter at link time) are
declared via the `SYMB` macro in [systab.mac](systab.mac):

```asm
SYMB MACRO VALUE,CODE,PNAME
LOCAL END
$LEN DEFL END-$
    DB $LEN
    DW VALUE,CODE##,NIL
    DW END
    DC PNAME
    DS (3 - (($-HEAP) AND 3) AND 3)
    DB $LEN
END:
    ENDM
```

- `VALUE` — the symbol's value cell (often the symbol itself for
  constants like `t`, or `NIL`/`0` for fresh symbols).
- `CODE` — entry point if the symbol is called as a function.
  Multiple symbols can share the same `CODE` (e.g., `err` and `t`
  both use `TRET`). The macro uses `LOCAL END` so each invocation
  generates its own end-label and there's no name collision.
- `PNAME` — the print name (the Lisp identifier).

## REVALO

`REVALO` ([nklisp.mac:48](nklisp.mac:48)) is the read-eval loop.
It reads expressions from a channel, evaluates each one, and prints
the result with a `-> ` prefix. It terminates on either:

- **EOF.** When `READ` reaches end-of-file, `READ0` returns `TSYM`
  via the `RD_EOF` path, and REVALO's existing CPDE check fires.
- **An explicit literal `t`.** Same termination as EOF; REVALO
  doesn't know the difference. Some older files end with `t` for
  this reason; new files don't need it.

Mid-form EOF (unbalanced parens, unterminated comment) is still a
syntax error via `READERR`.

## Catchable errors

The `ERR` routine ([nklisp.mac:78](nklisp.mac:78)) walks the
`CBASE` chain via `ECHECK`. If a `(catch 'err …)` frame is in scope,
ERR throws `'err` to it; otherwise it falls through to its original
behavior (print the message, re-enter the REPL).

This is the foundation for `assert-err` in the test harness — see
[nkl-test.md](nkl-test.md) for the full contract.

## Memory layout

After `(alloc N)`:

```
+----------------+ MEMTOP (top of memory)
| file slots     | N slots × FILSIZ each
+----------------+ SINIT (stack base, top of working area)
| stack          | grows down
| ...            |
| heap           | grows up from FREEMEM
+----------------+ HEAPTR
| static data    | constants, oblist, RST tool table source
+----------------+ HEAP / FREEMEM
| program        | code from PROG_ORIG (0x100)
+----------------+ 0x100 (CP/M user start)
| RST vectors    | LDIR'd from TOOLS at startup
+----------------+ 0x0
```

Note: `FREEMEM` and `TOOLS` share an address — the static `TOOLS`
data doubles as the start of the heap once `LDIR` has copied it to
the RST vectors at startup.

## Common gotchas

- **CRLF in `.mac` files:** `unix2dos foo.mac` after any local edit.
- **`<…>` super-paren close:** `>` closes back to the most recent
  `<`. Inside a `<deftest …>`, prefer plain `)` for inner forms.
- **Symbol shadowing:** `(setq car ...)` will redefine the global
  `car`. The harness has no namespace; tests share the oblist with
  user code.

## Adding a primitive

1. Define the function in the appropriate `.mac` file. Most go in
   `subr.mac`; fexprs and special forms in `fsubr.mac`. Use `::` to
   make the entry point public.
2. Register it in [systab.mac](systab.mac)'s symbol chain via
   `SYMB`. Place it in the `PROTECT` block (most primitives) unless
   it needs to be referenced by a fixed label from another module.
3. Add `EXTRN` declarations in any module that calls it.
4. Document it in [nkl-ref.md](nkl-ref.md) and add tests in the
   appropriate `t-*.l` spec.
