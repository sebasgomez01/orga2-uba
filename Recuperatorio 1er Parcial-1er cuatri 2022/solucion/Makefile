CC=c99
CFLAGS= -Wall -Wextra -pedantic -O0 -g -lm -Wno-unused-variable -Wno-unused-parameter -no-pie #-DENABLE_C
NASM=nasm
NASMFLAGS=-f elf64 -g -F DWARF

all: main tester

OBJS := ej1_c.o str.o ej1_asm.o 
tester: tester.c $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

main: main.c $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

ej1_c.o: ej1.c ejs.h
	$(CC) $(CFLAGS) -c $< -o $@

ej1_asm.o: ej1.asm ejs.h
	echo "-------- Compiling ASM -------------"
	$(NASM) $(NASMFLAGS) $< -o $@

str.o: str.c str.h
	$(CC) $(CFLAGS) -c $< -o $@


clean:
	rm -f *.o
	rm -f main tester
	rm -f salida.propios.*

