all: test task2
	gcc build/task2.o build/test.o -lstdc++ -o build/test -m32

test: test.cpp
	g++ -std=c++11 test.cpp -c -o build/test.o -m32

task2: task2.asm
	yasm task2.asm -o build/task2.o -f elf32
	
clean:
	rm -f build/test.o
	rm -f build/task2.o
	rm -f build/test
