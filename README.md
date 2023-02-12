# nkLisp

nkLisp, a fork of 8kLisp, is a very compact Lisp implementation for CP/M, whose
object code size is - as the name says - exactly n kBytes.

The original 8kLisp restricted its size to 8 kBytes. nkLisp lifts this hard
limit.


## Description

nklisp has some non-standard features, which make programs a bit faster and more compact:
  
  - **Implied lambda**
    - A list representing a functional body, like user-defined functions or the second argument to 'apply', does not use the special atom 'lambda' found in other Lisps, but is recognized by context.

  - **Implied prog**
    - The fact that excessive symbols in the parameter list of a functional body are bound to nil, can be used to create local variables (Other Lisps use the function "prog" for that purpose). Besides this, "go" or "return" can be used anywhere inside a nkLisp function.

  - **Case Sensitive**
    - The nkLisp reader always distinguishes between uppercase and lowercase letters.

  - **Comments**
    - The comment characters are '[' and ']'. Anything between will be ignored by nkLisp (comments may be nested).

  - **Super-Parenthesis**
    - The super-parenthesis characters are '<' and '>'.


## Getting Started

### Dependencies

- Microsoft M80 Assembler
- Microsoft L80 Linker
- **Optional:** [ANSI CP/M Emulator and disk image tool](https://github.com/jhallen/cpm)


### Building

#### On CP/M

To build on CP/M transfer the project files and *M80.COM* and *L80.COM* to the CP/M system and issue the following commands:

```sh
M80 =NKLISP
M80 =INOUT
M80 =SUBR
M80 =GARBAGE
M80 =PRIM
M80 =FSUBR
M80 =SYSTAB
L80 /P:100,/D:1900,NKLISP,INOUT,SUBR,GARBAGE,PRIM,FSUBR,SYSTAB,NKL/N/Y/E
```

#### On Another OS

To build on systems supported by the https://github.com/jhallen/cpm emulator:

1. Build the emulator and install the resulting *cpm* executable to the project's *bin/* directory or somewhere within the PATH.

2. Copy M80.COM and L80.COM to the project's *bin/* directory:

```sh
mkdir bin
cd bin
wget http://www.retroarchive.org/cpm/lang/m80.com
wget http://www.retroarchive.org/cpm/lang/l80.com
cd ..
```

3. Build nkLisp:

```sh
make
```


### Running

#### On CP/M

```sh
nkl
```

#### On Another OS

```sh
cpm nkl
```

-or-

```sh
make run
```


## Authors

- [Jon Ruttan](jonruttan@gmail.com)
- Alexander Burger


## License

This project is licensed under the [MIT] License - see the LICENSE.md file for details.


## References

Alexander Burger. 8kLisp. CP/M program, circa 1986-1987.

From the [Computer History Museum][]'s [Software Preservation Group][] archive, [8kLisp][8kLisp. CP/M program, circa 1986-1987].

> The last version of the immediate predecessor of PicoLisp, an 8bit version for Z80 called 8kLisp. The filestamps are preserved from when the files where copied from CP/M (1986 and 1987, CP/M didn't have such meta data), and the explicit dates in the sources are from March 1986 through June 1987.[^1]

The version from the archive is missing the *if, when,* and *unless* functions, and has an undocumented *do* function.

[Computer History Museum]: http://www.computerhistory.org/
[Software Preservation Group]: http://www.softwarepreservation.org/
[8kLisp]: http://www.softwarepreservation.org/projects/LISP/picolisp/8kLisp.tgz/view


[^1]: From: <http://www.softwarepreservation.org/projects/LISP/picolisp/8kLisp.tgz/view>
