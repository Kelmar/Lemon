SRCPATH=./src
BUILDDIR=./build
SRCS=main.s serial.s

OBJS=$(addprefix $(BUILDDIR)/, $(SRCS:s=o))
FULLSRCS=$(addprefix $(SRCPATH)/, $(SRCS))

all: lemon.rom

.PHONY: clean echo

$(BUILDDIR):
	mkdir $(BUILDDIR)

$(BUILDDIR)/%.o: $(SRCPATH)/%.s $(BUILDDIR)
	wla-65c02 -Iinclude -x -w -o $@ $<

lemon.rom lemon.sym: $(OBJS) lemon.link
	wlalink -S lemon.link lemon.rom

clean:
	rm -rf $(BUILDDIR)
	rm -f *.sym *.rom

echo:
	echo "Objects: $(OBJS)"
	echo "Sources: $(FULLSRCS)"
