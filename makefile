CC=g++
CFLAGS=-I.
DEPS = gtuos.h memory.h 8080emuCPP.h memoryBase.h gtuos.cpp 8080emu.cpp
OBJ = emulator.o


buildemulator:
	$(CC)  main.cpp $(DEPS) -o emulator.out $(CFLAGS) 

clean:
	rm *.o DEPS