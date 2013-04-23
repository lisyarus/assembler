arctg-test: arctg-test.cpp arctg
	g++ -std=c++11 arctg-test.cpp -c -o build/arctg-test.o -m32
	gcc build/arctg-test.o build/arctg.o -lstdc++ -o build/arctg-test -m32

arctg: arctg.asm
	yasm arctg.asm -o build/arctg.o -f elf32
