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

clean:
	rm -f $(PROG_NAME).com *.rel *.prn *.sym *~ r-*.l .test-output

tar:
	tar -zcf $(PROG_NAME).tgz $(FILES)

files:
	@echo $(FILES)

difflist:
	@for f in $(FILES); do git diff --quiet $$f >/dev/null || echo $$f; done

run: $(PROG_NAME).com
	$(CPM) $(PROG_NAME)

# ----- Tests -----

# test greps stdout for "FAIL " (any spec failed) or absence of the
# DONE sentinel (interpreter crashed mid-run).
test: $(PROG_NAME).com
	@$(CPM) --exec $(PROG_NAME) runtests.l 2>&1 | tee .test-output
	@if grep -q '^FAIL ' .test-output; then exit 1; fi
	@grep -q '^DONE' .test-output || { echo "TESTS CRASHED"; exit 2; }

# Single-spec shortcut: `make test-ctrl`, `make test-eval`, etc.
# alloc 3 so a spec that loads its own dependencies (e.g., t-too
# loads too.l on channel 2) has slots available.
test-%: $(PROG_NAME).com
	@printf "(alloc 3)\n(open '(harness l) 1) (revalo 1) (close 1)\n(load-spec '(t-$* l))\n(bdos 0)\n" > r-$*.l
	@$(CPM) --exec $(PROG_NAME) r-$*.l; rm -f r-$*.l

.PHONY: test run files difflist clean tar all
