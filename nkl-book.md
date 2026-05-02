# The nkLisp Book

A guide to nkLisp for new users. Covers the essentials of working with the
interpreter, the language's distinguishing features, and the small set of
quirks that surprise people coming from other Lisps.

For exhaustive primitive descriptions, see [nkl-ref.md](nkl-ref.md). For a
one-line-per-primitive cheatsheet, see [nkl-qref.md](nkl-qref.md).

---

## 1. What is nkLisp?

nkLisp is a small, self-contained Lisp interpreter for CP/M, descended from
Alexander Burger's 8kLisp (1986–1987) and a sibling of the early PicoLisp
lineage. The "n" in the name stands for any number of kilobytes — the
original 8kLisp was constrained to fit in 8 KB; nkLisp lifts that ceiling
while keeping everything else compact.

Its character:

  - Single-file Z80 binary, runs on real CP/M or in a CP/M emulator.
  - Bignums up to ~292 decimal digits.
  - No `lambda` keyword, no `prog` keyword, no separate fexpr/expr
    distinction — context-sensitive function bodies do all the work.
  - A reader that understands `[ ... ]` for nestable comments and
    `< ... >` as super-parentheses that close any number of open levels.

If you've used PicoLisp, much of nkLisp will feel familiar but smaller and
older. If you've used Common Lisp or Scheme, almost everything will be
recognisable, but a handful of forms behave subtly differently — see the
**Pitfalls** section below before you write much code.

---

## 2. Getting started

### 2.1. Invoke the interpreter

From CP/M, just type its name:

```
A>nkl
47056 Bytes

:
```

The `47056 Bytes` line reports free heap. The colon `:` is the top-level
prompt. From a host Unix system using the `cpm` emulator:

```
$ cpm nkl
```

### 2.2. Load a file at startup

Pass a filename on the command line and the interpreter will load and
evaluate the file before dropping you at the prompt:

```
A>nkl too.l
```

This is how the bundled tool library (`too.l`) gets brought in.

### 2.3. Exit

Type a single `t` followed by return at the top-level prompt. To exit from
*any* level (e.g. inside a break loop) immediately back to CP/M, evaluate
`(bdos 0)`.

---

## 3. The REPL

The prompt indicates your nesting level. `:` is top level; `1:` means
you're one level deep (typically inside a break loop after an error or
explicit `(stop ...)`); `2:` is two deep, and so on. Returning to a lower
level is done by typing `t`.

Special keys at the prompt (defaults; see the `BSKEY`/`KILLK`/`RTYPK`
constants in `nklisp.def` if you want to remap):

| Key | Effect |
|---|---|
| `^H` | Backspace |
| `^X` | Kill line |
| `^I` | TAB — expands to 4 spaces |
| `^R` | Retype line |
| `^C` | Reset (back to top-level loop) |
| `^M` | Submit line |

Each top-level expression you type is evaluated, and the result is printed
prefixed with `-> `:

```
:(+ 1 2)
-> 3
:(setq x 42)
-> 42
:x
-> 42
```

The variable `@` always holds the result of the previous top-level
evaluation, so `(prin1 @)` will reprint what you just saw.

---

## 4. Three things you need to know about the language

These three features are nkLisp's identity. Skip them and the rest of the
language won't make sense.

### 4.1. Implied lambda — function bodies have no keyword

A function is just a list whose first element is a parameter list (or a
single symbol) and whose remaining elements are the body:

```lisp
(de square (n)
    (* n n) )

(square 5)
-> 25
```

`de` defines `square` as the function `((n) (* n n))`. There is no
`lambda` keyword.

If you want to apply an anonymous function, do it through `apply`:

```lisp
(apply
    '((x y z) (* x (+ y z)))
    '(2 3 4))
-> 14
```

Note: in nkLisp, the params position can also be a *single symbol* rather
than a list, in which case the unevaluated argument list is bound to that
symbol — what other Lisps call a "fexpr". For example
`(de macro-like $args (prin1 $args))` collects every actual argument
unevaluated into `$args`.

### 4.2. Implied prog — extra parameters are local variables

If you list more parameters than the caller will ever supply, the unused
ones are bound to `nil` on entry. That gives you free local variables
without a `prog` or `let`:

```lisp
(de range (n [loc:] i out)
    (setq i 0)
    (setq out nil)
    (while (lessp i n)
        (push i out)
        (inc i))
    (reverse out))

(range 5)
-> (0 1 2 3 4)
```

The `[loc:]` is just a comment marker — purely a convention for "everything
after this is a local". The reader strips comments, so `range`'s real
parameter list is `(n i out)`. Callers pass only `n`; `i` and `out` start
out as nil.

`go`, `return`, and labels (small integers) work anywhere inside a function
body, so structured-jump style is also available without an explicit
`prog`.

### 4.3. Reader oddities — comments and super-parens

Comments are `[` ... `]`, and they nest:

```lisp
[a comment with [nested] brackets]
```

Super-parentheses are `<` and `>`. A `<` opens like `(`; a `>` closes
*every* still-open paren back to the matching `<`. They're used to avoid
running tails of `))))` at the end of a deeply nested form. The two
definitions below are equivalent:

```lisp
(de tree-leftmost (node)
    (if (atom node)
        node
        (tree-leftmost (car node)) ) )

<de tree-leftmost (node)
    (if (atom node)
        node
        (tree-leftmost (car node>
```

The single `>` at the end of the second form closes the inner
`(car node`, the `(tree-leftmost`, the `(if`, and the `<de`-opened
paren — four levels in one stroke. Use super-parens sparingly: they're powerful but make it
harder to spot mismatched parens with an editor that highlights pairs.

---

## 5. Pitfalls — things that bite

These are real, not hypothetical. Each one will cost you an evening if you
trip over it without warning.

### 5.1. `(cond)` is not implicit progn

In most Lisps, `(cond (test e1 e2 e3))` evaluates all of `e1 e2 e3` in
sequence and returns the value of `e3`. **In nkLisp it evaluates only
`e1`** and ignores `e2 e3`. If you want sequencing inside a clause, wrap
it in `progn`:

```lisp
(cond
    ((zerop n) 'done)
    (t (progn (do-thing) (do-other-thing) (recurse))))
```

`if`, `when`, `unless`, `progn`, `catch` all *do* use implicit progn. Only
`cond` is the odd one out.

### 5.2. A list-headed form is an implied IF, not a lambda call

You might be tempted to write:

```lisp
('((x y z) (* x (+ y z))) 2 3 4)
```

…expecting it to apply the lambda to `2 3 4`. **It does not.** A form
whose head (car) is a list is treated as an *implied IF*: the head is the
condition, the first cdr element is the true-branch, and remaining
elements are the false-branch. So the form above evaluates the lambda
expression as a condition (which produces a truthy value), then returns
the first arg, `2`.

To call an anonymous function, route it through `apply`:

```lisp
(apply '((x y z) (* x (+ y z))) '(2 3 4))
-> 14
```

### 5.3. `(alloc N)` does not return

`(alloc N)` reserves `N` file channels (and optionally a peek/poke
buffer), but it does *not* return to its caller — it performs a reset
equivalent to `^C`. Always call `alloc` at the *top level*, never inside a
function body or `progn`. Calling it mid-evaluation will silently abort
whatever you were doing and dump you back at the top-level prompt.

### 5.4. Loaded files should end in `t`

The reader and REPL share a loop (`revalo`). When it reads from a file,
it keeps reading expressions until it sees the literal symbol `t` —
that's its exit signal. A file that ends without a trailing `t` may
either drop you into an unexpected prompt or, in nested loads, read
garbage past the end of the file.

```lisp
[contents.l]
(de answer () 42)
(de question () 'unknown)
t                         [<-- terminator]
```

### 5.5. Numeric tokens read as numbers, not symbols

The reader tries to parse each token as a number first; only if that
fails does it become a symbol. So `'0`, `'1`, `'-3`, `'1+` and any
other numeric-looking token are *numbers*, not single-character or
short symbols of the same name. Primitives that strictly require a
symbol — `ascii`, `unpack`, `intern` — will refuse them:

```lisp
(ascii 'A)
-> 65

(ascii '0)
0: symbol error               [drops into a break loop]
```

If you genuinely need a symbol whose print-name happens to look
numeric, build it via `char` (a symbol from a single byte) or `pack`
(a symbol from a list of single-character symbols):

```lisp
(char 48)
-> 0                          [the symbol "0", not the number]
(ascii (char 48))
-> 48

(pack (list (char 49) (char 50)))
-> 12                         [the symbol "12"]
```

---

## 6. Defining functions

`de` is the canonical way to define a function:

```lisp
(de double (n)
    (* n 2))

(double 21)
-> 42
```

Recursion works as you'd expect:

```lisp
(de fact (n)
    (if (zerop n)
        1
        (* n (fact (1- n)))))

(fact 6)
-> 720
```

Mutual recursion also works because function definitions live in the
symbol's function cell (separate from its value cell — nkLisp is a Lisp-2).

For a one-shot anonymous function, build the list literally and hand it
to `apply` (see Pitfall 5.2 for why direct call doesn't work):

```lisp
(apply '((a b) (- a b)) '(10 7))
-> 3
```

To inspect a function's body, use `getd`:

```lisp
(getd 'fact)
-> ((n) (if (zerop n) 1 (* n (fact (1- n)))))
```

---

## 7. Working with files

Two patterns:

**Loading a Lisp source file.** From the command line, `nkl source.l`. From
within the REPL, redirect console input with `in`:

```lisp
(in source l)
```

Note that `in` is a fexpr — its arguments are filename / type / drive,
*unquoted*.

**Reading and writing files programmatically.** Allocate channels with
`alloc` at startup, then use the channel-based primitives:

```lisp
(alloc 2)                          [reserve 2 file channels]

(create '(out txt) 0)              [open channel 0 for write]
(prin1 'hello 0)
(prin1 'world 0)
(close 0)

(open '(out txt) 0)                [reopen for read]
(read 0)                           [-> hello]
(read 0)                           [-> world]
(close 0)
```

The full set is `open`, `create`, `close`, `read`, `prin1`, `print`,
`getc`, `putc`, `cr`, `sp`, `seek`, `where`, `eofp` — see the reference
manual for details.

---

## 8. Calling out to the system

nkLisp exposes the underlying Z80 / CP/M machine through four primitives:

  - `(bdos c [de])` — call CP/M BDOS with C set to the function number.
    `(bdos 0)` exits to CP/M.
  - `(bios n bc de)` — call BIOS function `n` with BC and DE set.
  - `(call addr [de])` — jump to a machine-language routine at `addr`,
    optionally with `de` set. The routine returns its result in the A
    register, which nkLisp boxes back into a Lisp byte.
  - `(port addr [byte])` — Z80 `IN`/`OUT`. With one arg, reads the port
    and returns the byte. With two, writes `byte` and returns it.

These are the escape hatches when the standard primitives don't reach
something you need.

---

## 9. Debugging

nkLisp ships with a small debugging toolkit. Some primitives are built
into the binary; others (marked `(*)` in the reference) live in `too.l`
and need to be loaded with `nkl too.l` or `(in too l)`.

  - `(stop cond)` — drop into a break loop if `cond` is non-nil. The
    prompt shows your nesting level (`1:`, `2:`, ...). Type `t` to
    return one level.
  - `(step)` / `(run)` — enter / leave single-step mode.
  - `(ss)` — show stack. Shows what's currently on the evaluator stack;
    useful inside a break loop to see how you got there.
  - `(*) (trace foo)` / `(untrace foo)` — wrap `foo` so it prints its
    arguments and return value on every call.
  - `(*) (break foo [cond])` / `(unbreak foo)` — set a breakpoint on
    entry to `foo`, optionally guarded by `cond`.
  - `(*) (pp foo)` — pretty-print a function's definition.
  - `(*) (ed foo)` — single-character structure editor for `foo`'s body
    (RETURN/SPACE/BACKSPACE to navigate, `i`/`d`/`r` to edit, `e` to
    save, `q` to quit).
  - `(*) (who atom)` — list every function that mentions `atom`. Useful
    to find callers.

The variable `@` always holds the last top-level result, and `ss` holds
the stack-top during single-step execution.

---

## 10. Bignum arithmetic

Numbers in nkLisp are **arbitrary-precision integers** by default. There
is no separate "small int" / "big int" type, no overflow at 2^16 or
2^24, no fixnum tag — every number is a length-prefixed sequence of
digit-bytes on the heap. The arithmetic primitives (`+`, `-`, `*`, `/`,
`%`, `1+`, `1-`, `2*`, `2/`, `sqrt`, `abs`, `min`, `max`) all operate
transparently on whatever size their arguments happen to be.

```lisp
(* 12345 12345)
-> 152399025

(* 99999 99999 99999 99999)
-> 99996000059999600001

(* 1000000 1000000 1000000)
-> 1000000000000000000
```

The hard limits:

  - A single number occupies at most **121 bytes** on the heap, which is
    enough for about **292 decimal digits**. Going past that triggers an
    `Ovrfl error`.
  - The reader and printer use the **current radix** (set with
    `(radix N)`; calling `(radix 0)` returns the current value without
    changing it). Common useful radixes are 2, 8, 10, 16. Beyond 36 you
    run out of digit characters.
  - There are **no fractions and no floating point**. `(/ 5 2)` gives 2,
    and `(/ 5 2 t)` gives the same result — but only for some inputs;
    the round flag's exact direction is implementation-defined (see the
    reference manual). For exact division, check the remainder with `%`.

Negative numbers work the same as positive ones at the language level —
`-` for unary or binary subtraction, `(minusp n)` to test, `(abs n)` to
strip the sign. The internal representation uses a sign bit on the
length byte; you generally don't need to know that.

```lisp
(setq big (* 999999 999999 999999))
-> 999997000002999999

(- 0 big)
-> -999997000002999999

(minusp (- 0 big))
-> t

(abs (- 0 big))
-> 999997000002999999
```

For large repeated multiplications, the heap fills up faster than you
might expect — each intermediate result is a fresh allocation. If you
hit `Mem error`, force a `(gc)` or restructure to reduce allocation
pressure.

---

## 11. Error handling: catch and throw

nkLisp has no exception system in the modern sense, but it ships with a
classic `(catch tag body)` / `(throw tag value)` pair that's enough to
escape from deep recursion or signal an unusual return.

### How they work

  - `(catch 'tag body...)` evaluates the elements of `body` in order
    (implicit progn). If the body completes normally, the value of the
    last expression is returned.
  - `(throw 'tag value)` unwinds the stack to the most recent
    *outstanding* catch whose tag is `eq` (identity-equal) to the
    thrown tag, and the catch returns `value`.
  - If no matching catch is in scope, throw raises a `Throw error`.

Tags are matched by `eq`, so use symbols (or `t`) — never numbers
or freshly-consed lists.

### Simple example

```lisp
(de find-odd (lst)
    (catch 'found
        (mapc lst
            '((x) (if (oddp x) (throw 'found x))))
        nil))

(find-odd '(2 4 6 7 8))
-> 7

(find-odd '(2 4 6 8))
-> nil
```

`find-odd` walks the list with `mapc`, throwing the first odd element
to the catch. If nothing matches, the body completes normally and the
final `nil` is returned. Without `catch`/`throw` you'd have to
short-circuit the walk yourself — much more code.

### A sentinel for "any error"

Using `t` as the tag is the convention for "catch everything I throw":

```lisp
(de safe-divide (a b)
    (catch t
        (if (zerop b)
            (throw t 'divide-by-zero)
            (/ a b))))

(safe-divide 10 2)
-> 5

(safe-divide 10 0)
-> divide-by-zero
```

This is exactly the pattern `ed` in `too.l` uses to bail out of the
structure editor when the user types `q`.

### What catch does *not* do

  - It does not catch language-level errors (`unbound`, `undef`, `byte`,
    etc.) — those drop you into a break loop, not into the catch.
  - It is not a `try`/`finally` — there's no clean-up form. Whatever
    state you mutated before the throw stays mutated.
  - Tags must match by `eq`, not `equal` — use symbols.

---

## 12. A worked example: factorials too big for a 32-bit integer

This pulls the previous sections together: function definition, implied
prog locals, recursion, bignum arithmetic, and a small touch of
debugging.

### First version: naive recursive

```lisp
(de fact (n)
    (if (zerop n)
        1
        (* n (fact (1- n)))))
```

`if` returns 1 in the base case; otherwise multiplies `n` by the
factorial of `n - 1`. Standard textbook Lisp. Try it:

```lisp
(fact 0)
-> 1
(fact 5)
-> 120
(fact 10)
-> 3628800
```

So far nothing surprising — these all fit in a normal integer. Now
push past 32 bits:

```lisp
(fact 13)
-> 6227020800

(fact 20)
-> 2432902008176640000

(fact 25)
-> 15511210043330985984000000
```

No overflow, no special syntax, no hint that anything unusual is
happening — the bignum machinery just works. `(fact 100)` will give you
all 158 digits of 100! and `(fact 170)` is around the practical limit
(170! has 308 digits, which exceeds the 292-digit ceiling). Past that,
nkLisp raises `Ovrfl error`.

### Second version: iterative with implied prog

The recursive version uses stack space proportional to `n`, which can
be a problem on tiny machines. An iterative version uses implied prog
locals and a `while` loop:

```lisp
(de fact-iter (n [loc:] acc)
    (setq acc 1)
    (while (not (zerop n))
        (setq acc (* acc n))
        (dec n))
    acc)

(fact-iter 20)
-> 2432902008176640000
```

The `[loc:]` comment and the extra `acc` parameter is the implied-prog
idiom from §4.2 — `acc` starts as `nil` (because the caller never
supplies a second argument) and is then `setq`'d to 1. `dec` decrements
`n` in place; `while` keeps looping until `n` hits zero.

### Inspecting it

If the iterative version misbehaves, you can step through it. Trace
prints arguments and return values on each call:

```lisp
(in too l)                    [load too.l for trace, etc.]
(trace fact-iter)
(fact-iter 4)
fact-iter (4)
 fact-iter = 24
-> 24
(untrace fact-iter)
```

Or set a breakpoint that fires when a particular condition holds at
function entry. This works best on the *recursive* version, since each
recursive call is a fresh entry:

```lisp
(break fact (equal n 2))
(fact 5)
[Break]
1:n
-> 2
1:t                            [resume]
-> 120
```

For the iterative `fact-iter` a single break at entry won't help much
(the condition is only checked once); use `(stop ...)` inside the loop
body instead, or trace through with `(step)`.

That's the core debugging loop: trace for "what's it doing", break for
"what's the state when it gets here".

---

## 13. Where to go next

  - **[nkl-ref.md](nkl-ref.md)** — the reference manual: every primitive,
    every signature, with examples and the small print.
  - **[nkl-qref.md](nkl-qref.md)** — the quick reference: one entry per
    primitive, just enough to remind you of the signature.
  - **`too.l`** — the bundled debugger / pretty-printer / sort utility,
    written in nkLisp itself; a good source of idiomatic examples.
  - **`factor.l`, `nqueen.l`** — small example programs.

Build from source with `make` (see the project README); the result is
`nkl.com`, ready to run on CP/M or under a CP/M emulator.
