all: app

app: main.o
	ld -m elf_i386 -o app main.o -lc -I /lib/ld-linux.so.2
	touch entrada.txt
	touch chave.txt
	
main.o: main.asm
	nasm -f elf32 main.asm

clean:
	rm *.o app
	rm saidaCrip.txt
	rm saidaDescrip.txt
