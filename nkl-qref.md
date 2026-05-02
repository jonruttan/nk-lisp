# nkLisp Quick Reference

## Invocation and Exit

- **Invoke:** `nkl <cr>` or `nkl too.l<cr>`
- **Exit:** Type a single `t` or execute `(bdos 0)`.

## Special Characters

 - `^M` Terminate input
 - `^H` Backspace, erase last character
 - `^X` Kill line
 - `^R` Retype line
 - `^I` TAB, expands to 4 spaces
 - `^C` Reset nkLisp

## Global Variables

- **`t`:** "true" flag, returned by the predicate functions. 
- **`gc`:** When non-nil print garbage collector messages (Default nil).
- **`intern`:** When non-nil new symbols will be interned. Use caution! (Default `t`).
- **`alloc`:** The start address of `alloc`ed memory.
- **`ss`:** Top of the stack during single-step execution.
- **`@`:** The last result printed in the top-level revalo loop.
- **`key`:** When non-nil enable console breaks (ESC).

## Non-Standard Features

- **Implied Lambda:** Functional bodies without `lambda`.
- **Implied Prog:** Local variables created by excessive symbols in parameter lists.

## nkLisp Objects

- **Symbols:** Strings not identical to an interned symbol.
- **Numbers:** Represented as bignums with max size of 121 bytes.
- **Cons Pair:** 4-byte objects consisting of a `car` and a `cdr`.
- **nil:** Special object viewed as both an empty list and an atom.

## Evaluation and Assignment

- **(eval 'any) -> any:** Evaluate the argument.
- **(quote any) -> any:** Return the argument unevaluated.
- **(apply 'foo 'list) -> any:** Apply the function to the argument list.
- **(setq symbol 'any) -> any:** Set the value cell of `symbol`.
- **(set 'symbol 'any) -> any:** Set the value cell of the symbol.

## Symbol Functions

- **(gensym) -> symbol:** Generate a unique uninterned symbol in the form `Gxxxxx`.
- **(unpack 'symbol) -> list:** Return characters of the symbol as a list.
- **(pack 'list) -> symbol:** Concatenate symbols in the list into a new uninterned symbol.
- **(ascii 'symbol) -> byte:** Return the ASCII value of the first character.
- **(char 'byte) -> symbol:** Return a single-character symbol from ASCII value.
- **(remob 'symbol) -> symbol:** Remove the symbol from the oblist.
- **(intern 'symbol) -> symbol:** Intern the symbol.
- **(oblist) -> list:** Return a list of all currently interned symbols.

## Input and Output

Legal filenames are lists of the form: `(filename type drive)`.

- **(in file) -> file:** Open file and redirect console input.
- **(open 'file 'channel) -> channel:** Open file on channel.
- **(create 'file 'channel) -> channel:** Create file on channel.
- **(close ['channel]) -> channel:** Close the channel.
- **(getc ['channel]) -> byte:** Read a byte from channel.
- **(putc 'byte ['channel]) -> byte:** Write a byte to channel.
- **(read ['channel]) -> any:** Read an expression from channel.
- **(prin1 'any ['channel]):** Write an expression to channel.
- **(print 'any ['channel]):** Write an expression followed by a newline.
- **(cr ['channel]):** Write a newline to channel.
- **(sp ['channel]):** Write a space to channel.
- **(key) -> byte or nil:** Return the next byte of keyboard input or nil.
- **(seek 'num24 'channel) -> num24:** Move the file pointer to num24 in channel.
- **(where 'channel) -> num24:** Return the current file pointer position.
- **(eofp ['channel]) -> bool:** Return `t` if the end of file is reached.

## System Access and Control

- **(revalo ['channel]) -> t:** Re-evaluate the entire oblist from the specified input channel.
- **(radix 'byte) -> byte:** Set the number radix and return the previous value. Pass `0` to read the current value without changing it.
- **(mfree) -> number:** Return the amount of free memory available.
- **(alloc 'number1 ['number2]):** Allocate `number1` file channels, optionally plus `number2` bytes. Does not return to caller (resets like ^C); call only at top level.
- **(@ 'address ['value]) -> Contents of address:** Access or set memory address.
- **(dir [file [ext [drive]]]) -> List of files:** List files in the specified directory. `*` and `?` may be used.
- **(era 'file) -> file:** Erase the specified file.
- **(ren 'oldname 'newname) -> newname:** Rename the specified file.
- **(save filename) -> filename:** Save the current environment to file.
- **(load filename) -> filename:** Load an environment from file.
- **(bios 'no 'bc 'de) -> Areg:** Call the BIOS function.
- **(bdos 'c ['de]) -> HL:** Call location 5 (BDOS call).
- **(call 'address ['de]) -> Areg:** Call a machine language subroutine.
- **(port 'address ['byte]) -> byte:** Z80 port I/O - read with one arg, write with two; returns the byte involved.
- **(gc) -> t:** Force a garbage collection.

## List Manipulation

- **(assoc 'any 'list) -> pair:** Return the dotted pair whose car is equal to the first argument.
- **(member 'any 'list) -> restlist:** Return the restlist starting with the matched element.
- **(memq 'any 'list) -> restlist:** Return the restlist using eq for comparison.
- **(car 'pair) -> 'any:** Return the car part of the argument.
- **(cdr 'pair) -> 'any:** Return the cdr part of the argument.
- **(c[ad]+r 'pair) -> 'any:** Compound car/cdr - `caar`/`cadr`/`cdar`/`cddr` and the eight three-letter forms (`caaar` through `cdddr`). E.g. `(cadr x)` = `(car (cdr x))`.
- **(reverse 'list) -> list:** Return a list with elements in reverse order.
- **(delete 'any 'list) -> list:** Return a list with the first occurrence of the first argument deleted.
- **(length 'list) -> number:** Return the number of elements in the argument.
- **(nth 'num24 'list) -> any:** Return the nth element of the list.
- **(nthcdr 'num24 'list) -> list:** Perform the cdr operation num24 times.
- **(list 'any) -> list:** Return a list of the argument(s).
- **(cons 'any 'any) -> pair:** Return a pair constructed from the arguments.
- **(append 'list 'any) -> list:** Return a concatenated list.
- **(nconc 'list 'any) -> list:** Destructive version of append.
- **(rplaca 'pair 'any) -> pair:** Replace the car of the pair.
- **(rplacd 'pair 'any) -> pair:** Replace the cdr of the pair.
- **(push 'any symbol) -> list:** Push an element onto a list.
- **(pop symbol) -> any:** Pop an element from a list.

## Mapping

- **(mapc 'list 'foo) -> nil:** Apply foo to each element of list.
- **(mapcar 'list 'foo) -> list:** Return a list of foo applied to each element.
- **(mapcan 'list 'foo) -> list:** Return a concatenated list of foo applied to each element.

## Function Definition Access

- **(putd 'symbol 'body) -> symbol:** Set the function cell of symbol to body.
- **(getd 'symbol) -> function definition:** Return the function definition.
- **(de symbol body) -> symbol:** Define a function.

## Property List Access

- **(put 'symbol 'property 'value):** Set the property of symbol.
- **(get 'symbol 'property):** Return the specified property.
- **(putpl 'symbol 'list):** Set the property list of symbol.
- **(getpl 'symbol):** Return the property list of symbol.

## Arithmetic Functions

- **(+ 'number 'number) -> number:** Addition.
- **(- 'number) -> number:** Unary minus.
- **(- 'number 'number) -> number:** Subtraction.
- **(* 'number 'number) -> number:** Multiplication.
- **(/ 'number 'number ['round]) -> number:** Division.
- **(% 'number 'number) -> number:** Modulus.
- **(1+ 'number) -> number:** Add one.
- **(1- 'number) -> number:** Subtract one.
- **(2* 'number) -> number:** Multiply by two.
- **(2/ 'number ['round]) -> number:** Divide by two.
- **(sqrt 'number ['round]) -> number:** Square root.
- **(inc symbol) -> Symbol's new value:** Increment.
- **(dec symbol) -> Symbol's new value:** Decrement.
- **(max 'any 'any) -> any:** Return the greater value.
- **(min 'any 'any) -> any:** Return the smaller value.
- **(abs 'number) -> number:** Absolute value.

## Predicate Functions

- **(not 'any) -> bool:** Return `t` if the argument is nil.
- **(eq 'any 'any) -> bool:** Return `t` if the arguments are identical.
- **(equal 'any 'any) -> bool:** Return `t` if the arguments are structurally equal.
- **(pairp 'any) -> bool:** Return `t` if the argument is a pair.
- **(atom 'any) -> bool:** Return `t` if the argument is atomic.
- **(numberp 'any) -> bool:** Return `t` if the argument is a number.
- **(symbolp 'any) -> bool:** Return `t` if the argument is a symbol.
- **(boundp 'symbol) -> bool:** Return `t` if the symbol is bound to a value.
- **(lessp 'any 'any) -> bool:** Compare numbers, symbols, or lists.
- **(minusp 'number) -> bool:** Return `t` if the argument is less than zero.
- **(zerop 'number) -> bool:** Return `t` if the argument is zero.
- **(oddp 'number) -> bool:** Return `t` if the argument is odd.

## Program Flow

- **(progn body) -> last value:** Evaluate expressions and return the last value.
- **(prog1 body) -> first value:** Evaluate expressions and return the first value.

- **(prog2 body) -> second value:** Evaluate expressions and return the second value.
- **(eprogn body) -> last value:** `eval` expressions and return the last value.
- **(reptn 'num24 body) -> any:** Repeat body num24 times.
- **(do symbol 'num24 'condition 'step 'body) -> any:** Loop with initialization, condition, step, and body.
- **(if 'condition trueExpression falseBody) -> any:** Conditional evaluation.
- **(when 'condition body) -> any:** Evaluate body if condition is non-nil.
- **(unless 'condition body) -> any:** Evaluate body if condition is nil.
- **(cond ('cond1 'expr1) ('cond2 'expr2) ...) -> any:** Multi-way conditional. Only the *first* expression in a clause's body is evaluated (no implicit progn); wrap multiple exprs in `progn`.
- **(while 'condition body) -> any:** Loop while condition is true.
- **(until 'condition body) -> any:** Loop until condition is true.
- **(go 'label) [No return to caller]:** Transfer control to label.
- **(return 'value) [No return to caller]:** Exit function with value.
- **(catch 'tag 'body) -> body's return value:** Set up a catch frame.
- **(throw 'tag 'value) [No return to caller]:** Transfer control to a catch frame.
- **(and (expr1) (expr2) ... ):** Evaluate expressions and return the last non-nil value.
- **(or (expr1) (expr2) ... ):** Evaluate expressions and return the first non-nil value.

## Debugging

- **(ss) -> t:** Show stack.
- **(stop 'condition):** Enter break loop if condition is non-nil.
- **(step) -> nil:** Enter single-step execution.
- **(run) -> nil:** Terminate single-step execution.
- **(*) (pp foo):** Pretty-print a function.
- **(*) (trace foo1 foo2 ...):** Trace functions.
- **(*) (untrace foo1 foo2 ...):** Untrace functions.
- **(*) (break foo [condition]) -> foo:** Stop execution when entering function foo.
- **(*) (unbreak foo1 foo2 ...):** Unbreak functions.
- **(*) (ed foo) -> foo:** Edit function definition.
- **(*) (who atom):** List functions referring to the atom.
- **(*) (sort list):** Quick-sort list with lessp.

## Error Messages

- **XXXX unbound error:** XXXX is an unbound symbol.
- **XXXX undef error:** XXXX is an undefined function.
- **XXXX: list error:** Detected XXXX where argument must be a list.
- **XXXX: symbol error:** Detected XXXX where argument must be a symbol.
- **XXXX: number error:** Detected XXXX where argument must be a number.
- **XXXX: byte error:** Detected XXXX where argument must be a single-byte number (0 .. 255).
- **Circ error:** Function cannot be applied to circular list structure.
- **Create error:** File cannot be created.
- **Disk error:** Unsuccessful write operation due to a full disk.
- **File error:** Illegal channel or file access.
- **Go error:** Matching label not found in function body.
- **Load error:** Incorrect environment dump file.
- **Mem error:** Out of memory.
- **Ovrfl error:** Arithmetic overflow.
- **Open error:** File cannot be opened.
- **Read error:** Illegal s-expression or end-of-file inside a comment.
- **Range error:** Expected a number in the range 0 .. 16777215.
- **Size error:** Symbol name is too long.
- **Throw error:** Executed a throw without a matching catch.
