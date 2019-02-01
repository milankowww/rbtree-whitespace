CC=gcc
COPTS=-O0 -ggdb -Wall
SATAN=./satan
BLACKTIME=./blacktime

all: rbtree.white
	$(SATAN) rbtree.white

test: rbtree.white
	WHITEDBG=1 $(SATAN) rbtree.white

%.white:	%.asm
	$(BLACKTIME) $< > $@

# prerequisites
blacktime: blacktime.c Makefile
	$(CC) $(COPTS) -o blacktime blacktime.c
satan: satan.c Makefile
	$(CC) $(COPTS) -o satan satan.c
