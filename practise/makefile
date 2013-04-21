test: test.cpp arctg
	g++ -std=c++11 -I/home/lisyarus/projects/cpp-lib/ test.cpp -c -o test.o -m32
	gcc test.o arctg.o -lstdc++ -o test -m32

arctg: arctg.asm
	yasm arctg.asm -o arctg.o -f elf32
