PROG_NAME=nkl
PROG_ORIG=100
# DATA_ORIG is derived from HIHEAP in nklisp.def to keep them in sync.
# HIHEAP is the high byte (e.g. 19H) of the heap-start address.
DATA_ORIG := $(shell awk '/^HIHEAP[[:space:]]+EQU/ {gsub("H","",$$3); print $$3 "00"}' nklisp.def)

LDFLAGS=/N/Y/E

CPM = @[ -x ./bin/cpm ] && ./bin/cpm || cpm

FILES = README.md LICENSE.md Makefile mk.bat \
	nkl-book.md nkl-ref.md nkl-qref.md structures \
	nklisp.mac nklisp.def \
	inout.mac subr.mac garbage.mac prim.mac fsubr.mac systab.mac \
	tests.mac \
	factor.l nqueen.l snapshot.l too.l

OBJS =	nklisp.rel \
	inout.rel \
	subr.rel \
	garbage.rel \
	prim.rel \
	fsubr.rel \
	systab.rel

COMMA := ,
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

NAMES = $(subst $(SPACE),$(COMMA),$(OBJS:.rel=))

all: $(PROG_NAME).com

$(PROG_NAME).com: $(OBJS)
	$(CPM) bin/l80 /P:$(PROG_ORIG),/D:$(DATA_ORIG),$(NAMES),$(PROG_NAME)$(LDFLAGS)

$(OBJS): %.rel : %.mac
	$(CPM) bin/m80 =$<

nklisp.rel:		nklisp.mac nklisp.def
inout.rel:		inout.mac nklisp.def
subr.rel:		subr.mac nklisp.def
garbage.rel:	garbage.mac nklisp.def
prim.rel:		prim.mac nklisp.def
fsubr.rel:		fsubr.mac nklisp.def
systab.rel:		systab.mac nklisp.def

# tests.com - assembly-level unit tests.  tests.rel is linked FIRST so its
# START sits at PROG_ORIG; nklisp.rel is still linked but its COLD never
# runs (we do our own minimal init in tests.mac and exit via BDOS).
tests.rel: tests.mac nklisp.def
	$(CPM) bin/m80 =tests

# tests.com gets a higher /D origin so the extra test code can fit in
# the program area without overlapping the data segment.  Standalone
# binary, not subject to nkl.com's layout constraints.
TEST_DATA_ORIG = 2000

tests.com: tests.rel $(OBJS)
	@printf "/P:$(PROG_ORIG),/D:$(TEST_DATA_ORIG)\ntests\n$(NAMES)\ntests/N/E\n" | tr ',' '\n' > .l80in
	$(CPM) bin/l80 < .l80in
	@rm -f .l80in

clean:
	rm -f $(PROG_NAME).com tests.com *.rel *.prn *.sym *~ r-*.l .test-output

tar:
	tar -zcf $(PROG_NAME).tgz $(FILES)

files:
	@echo $(FILES)

difflist:
	@for f in $(FILES); do git diff --quiet $$f >/dev/null || echo $$f; done

run: $(PROG_NAME).com
	$(CPM) $(PROG_NAME)

# ----- Tests -----

# Full suite. test-lisp greps stdout for "FAIL " (any spec failed) or
# absence of OK/FAIL (interpreter crashed before harness ran).
test: test-lisp test-asm

test-lisp: $(PROG_NAME).com
	@$(CPM) --exec $(PROG_NAME) runtests.l 2>&1 | tee .test-output
	@if grep -q '^FAIL ' .test-output; then exit 1; fi
	@grep -qE '^(OK|FAIL) ' .test-output || { echo "TESTS CRASHED"; exit 2; }

# Assembly-level tests (Layer A).
test-asm: tests.com
	@$(CPM) --exec tests 2>&1 | tee .test-output
	@grep -q '^asm:.*OK' .test-output

# Single-spec shortcut: `make test-ctrl`, `make test-eval`, etc.
test-%: $(PROG_NAME).com
	@printf "(alloc 2)\n(open '(harness l) 1) (revalo 1) (close 1)\n(loadSpec '(t-$* l))\n(bdos 0)\nt\n" > r-$*.l
	@$(CPM) --exec $(PROG_NAME) r-$*.l; rm -f r-$*.l

.PHONY: test test-lisp test-asm run files difflist clean tar all
