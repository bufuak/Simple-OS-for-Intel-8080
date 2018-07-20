#ifndef H_GTUOS
#define H_GTUOS

#include "8080emuCPP.h"
#define QUANTUM 100
#define MAX_THREADS 255

typedef struct {
	uint64_t threadid;
	State8080 state;
	unsigned borntime;
	unsigned usedcycles;
	unsigned deathtime;
	uint8_t status; // 0 for blocked , 2 for running , 1 for ready
	uint8_t isAlive; // If 0 we don't schedule it.
	uint64_t startingadress;
	uint64_t stackspace;
	uint8_t yield;
} ThreadTable;

class GTUOS{
	public:
		GTUOS();
		unsigned handleCall(const CPU8080 & cpu,unsigned cycles);
		unsigned schedule(CPU8080 & cpu,unsigned cycles, uint8_t DEBUG);
		void printThreads();
		void writeMem(const CPU8080 & cpu);
	private:
		static int randomN;
		uint8_t currentThread;
		uint32_t createdPc;
		uint32_t letThread;
		uint8_t lastCreated;
		uint8_t activeThreadNumber;
		ThreadTable Threads [MAX_THREADS];
};

#endif
