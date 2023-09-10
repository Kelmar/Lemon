SRCS=main.s
OBJS=main.o

all: lemon.rom

.s.o:
	wla-65c02 -x $<

lemon.rom: $(OBJS) lemon.link
	wlalink -S lemon.link lemon.rom

clean:
	rm -f *.sym *.rom *.o
