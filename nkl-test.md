# nkLisp Test Framework

A Lisp-level test harness that runs entirely inside the CP/M
emulator. Specs are loaded one at a time, each runs its tests
independently, and the runner prints a per-spec summary line that's
easy to grep from CI.

## Files

- `harness.l` — defines `deftest`, `assert`, `assert-err`, `pending`,
  `deftest!`, `before-each`, `after-each`, `run-tests`, `load-spec`.
- `tharness.l` — meta-tests for the harness itself.
- `t-*.l` — spec files, one per area (e.g., `t-arith.l`, `t-list.l`).
- `runtests.l` — top-level runner; loads `harness.l`, then each spec.

## Running

| Command            | Effect                                     |
| ------------------ | ------------------------------------------ |
| `make test`        | Full suite. Exits non-zero on any failure. |
| `make test-arith`  | Single spec. Spec name = file `t-NAME.l`.  |

The single-spec runner allocates 3 file slots so a spec that loads
its own dependencies (e.g., `t-too.l` opens `too.l` on channel 2)
works standalone.

## Spec file shape

```lisp
[T-FOO.L - one-line description]

<deftest test-something
    (assert 42 (foo 6 7))
    (assert 'a (car '(a b)))>

<deftest test-other-thing
    (assert nil (foo nil))>
```

Conventions:

- **CP/M 8.3 names:** `t-foo.l`, not `t-foo-bar.l`.
- **Super-paren `<…>`:** the `>` closes back to the most recent `<`,
  so use `>` only at the very end of a `deftest`. Use plain `)` for
  inner expressions, or `>` will close too far back.
- **No trailing terminator needed** — `revalo` exits cleanly when
  it reaches EOF.  An explicit trailing `t` still works (legacy
  behavior, used in some older files) but isn't required.

## Assertions

### `(assert expected actual)`

Compares with `equal`. Prints `.` on pass, `F` on fail. Records the
failure with the test name, both values, and the unevaluated `actual`
form for the failure report.

```lisp
(assert 3 (+ 1 2))
(assert '(1 2 3) (list 1 2 3))
```

### `(asserteq expected actual)`

Same shape, but compares with `eq` (pointer identity). Use for
symbols and explicit identity tests.

```lisp
(asserteq 'foo 'foo)
```

### `(assert-err form)`

Passes if `form` raises an interpreter error. Wraps `form` in
`(catch 'err …)` and checks if the catch fired. See **Catchable
errors** below for how the mechanism works.

```lisp
(assert-err (car 'not-a-list))
(assert-err (/ 1 0))
```

**Known limitation:** if `form` itself does `(throw 'err X)`,
`assert-err`'s catch returns `X`, not the symbol `'err`, and the
test reports as no-error. Tests shouldn't intentionally throw `'err`
from inside `assert-err`.

## Test variants

### `(pending name)`

Registers a test by name only; the body is dropped. Prints `_` per
pending in the assertion output and `N pending` in the summary line.
Useful for tracking known-broken or deferred work without removing
context.

```lisp
<pending test-implied-lambda-direct-call>
```

### `(deftest! name body…)`

Expected-fail. The body is run with output suppressed; the test
passes iff the body records at least one assertion failure. If the
body passes everything, records a meta-failure
`expected-fail / passed-instead`.

Used for the harness's own self-check (a deliberate-fail test that
verifies the failure path itself).

```lisp
<deftest! tharness-expected-fail
    (assert 1 2)>
```

## Setup and teardown

### `(before-each form…)` and `(after-each form…)`

Register thunks that run around each test in the current spec. Reset
to no-ops at the start of each `load-spec`.

```lisp
<after-each (era '(tio dat))>

<deftest test-create-write-read-bytes
    (create '(tio dat) 1)
    (putc 65 1)
    (close 1)
    ...>
```

Both forms run for regular tests *and* for `deftest!` xfail-tests.

## Output format

Per spec, the harness prints one line of dots/Fs/underscores
followed by a summary:

```
.....F.._...
FAIL test-foo expected 42 got 43 in (foo 6 7)
FAIL t-bar 12 tests 1 failures
```

A test that crashes (uncaught error) records as one failure per
crashed stage:

```
FAIL test-foo expected no-error got body-crashed in nil
FAIL test-bar expected no-error got after-each-crashed in nil
```

On success:

```
............
OK t-bar 12 tests 1 pending 32 assertions
```

Summary lines are space-separated tokens — easy to grep:

- `^OK <spec> <ntests> tests [<npending> pending] <nasserts> assertions`
- `^FAIL <spec> <ntests> tests [<npending> pending] <nfails> failures`

The runner ([runtests.l](runtests.l)) prints `DONE` after the last
spec. The Makefile checks for `DONE` to detect mid-run interpreter
crashes.

## Catchable interpreter errors

The harness's `assert-err` relies on a small interpreter change:
errors thrown by `ERR` can be caught from Lisp with `(catch 'err …)`.

### How it works

A new well-known symbol `err` lives in the system oblist (see
[systab.mac](systab.mac)). The `ERR` routine in
[nklisp.mac](nklisp.mac) walks the `CBASE` chain looking for an
`'err` catch frame. If one is in scope, ERR throws `'err` to it
instead of printing the error and dropping into the REPL.

```lisp
(catch 'err (car 'x))    ; returns 'err
(catch 'err 42)          ; returns 42 (no error)
```

### Edge cases

- **No catch in scope:** `ERR` falls back to the original behavior —
  prints the error message and re-enters the REPL.
- **Nested catches:** the innermost matching `'err` catch wins, like
  any other tag.
- **Other catch tags don't intercept:** `(catch 'other (car 'x))`
  doesn't catch the type error; the throw propagates past it to the
  next outer `'err` catch (or to the REPL).
- **User-throws of `'err`:** `(throw 'err V)` from user code is
  caught by `'err` and returns `V` — indistinguishable from a
  normal `(catch tag)` interaction. `assert-err` inherits this:
  see the limitation note above.

### Test isolation

Every stage of every test (setup, body, teardown) runs through
`run-stage`, which wraps the eval in `(catch 'err …)`. A crash in
any stage records a failure tagged with the stage name, prints `F`
(suppressed inside an xfail body), and the spec continues to the
next test.

## Adding a new spec

1. Create `t-NAME.l` in the repo root (CP/M 8.3 — keep `NAME` short).
2. Write `<deftest …>` blocks.
3. Add `(load-spec '(t-NAME l))` to [runtests.l](runtests.l).
4. Run `make test-NAME` to iterate, or `make test` for the full
   suite.

If the spec depends on a library construct (like `too.l`), load it
on channel 2 from inside the spec file:

```lisp
(open '(too l) 2) (revalo 2) (close 2)
```

The runner allocates 3 file slots (channel 1 for `load-spec`,
channel 2 for spec-internal loads).
