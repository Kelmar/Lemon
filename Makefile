SRCPATH=./src
BUILDDIR=./build
SRCS=main.s serial.s

AS=ca65
CC=cc65
LD=ld65

OBJS=$(addprefix $(BUILDDIR)/, $(SRCS:s=o))
FULLSRCS=$(addprefix $(SRCPATH)/, $(SRCS))

ASFLAGS=--cpu 65c02 -I include
LDFLAGS=

all: lemon.rom

.PHONY: clean echo

$(BUILDDIR):
	mkdir $(BUILDDIR)

$(BUILDDIR)/%.o: $(SRCPATH)/%.s $(BUILDDIR)
	${AS} ${ASFLAGS} --debug-info -o $@ $<

lemon.rom lemon.sym: $(OBJS) src/lemon.cfg
	${LD} ${LDFLAGS} $(OBJS) -C src/lemon.cfg -o lemon.rom

clean:
	rm -rf $(BUILDDIR)
	rm -f *.sym *.rom

echo:
	echo "Objects: $(OBJS)"
	echo "Sources: $(FULLSRCS)"
