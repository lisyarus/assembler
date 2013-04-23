raw: task1.asm
	yasm task1.asm -o build/task1.o -f elf32
	gcc build/task1.o -o build/task1 -m32

nodebug: task1-nodebug.asm
	yasm task1-nodebug.asm -o build/task1-nodebug.o -f elf32
	gcc build/task1-nodebug.o -o build/task1-nodebug -m32

win32: task1-win32.asm
	yasm task1-win32.asm -o build/task1-win32.o -f win32
	gcc build/task1-win32.o -o build/task1-win32 -m32
