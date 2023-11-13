CC=c99
CFLAGS= -Wall -Wextra -pedantic -O0 -g -lm -Wno-unused-variable -Wno-unused-parameter -no-pie
NASM=nasm
NASMFLAGS=-f elf64 -g -F DWARF

all: main tester

OBJS := ejercicios_c.o ejercicios_asm.o

tester: tester.c $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

main: main.c $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

ejercicios_c.o: ejercicios.c ejercicios.h
	$(CC) $(CFLAGS) -c $< -o $@

ejercicios_asm.o: ejercicios.asm ejercicios.h
	$(NASM) $(NASMFLAGS) $< -o $@


# ej2_c.o: ej2.c ejs.h
# 	$(CC) $(CFLAGS) -c $< -o $@

# ej2_asm.o: ej2.asm ejs.h
# 	$(NASM) $(NASMFLAGS) $< -o $@
clean:
	rm -f *.o
	rm -f main tester


