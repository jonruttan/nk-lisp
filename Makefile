PROG_NAME=nkl
PROG_ORIG=100
DATA_ORIG=1900

LDFLAGS=/N/Y/E

CPM = @[ -x ./bin/cpm ] && ./bin/cpm || cpm

FILES = README.md COPYING Makefile mk.bat \
	nkl.doc structures\
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
	rm -f $(PROG_NAME).com *.rel *.prn *.sym *~

tar:
	tar -zcf $(PROG_NAME).tgz $(FILES)

files:
	@echo $(FILES)

difflist:
	@for f in $(FILES); do git diff --quiet $$f >/dev/null || echo $$f; done

run: $(PROG_NAME).com
	$(CPM) $(PROG_NAME)
