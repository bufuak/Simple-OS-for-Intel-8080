#include <iostream>
#include "8080emuCPP.h"
#include "gtuos.h"
#include "memory.h"
#include <string>
	// This is just a sample main function, you should rewrite this file to handle problems 
	// with new multitasking and virtual memory additions.
int main (int argc, char**argv)
{
	if (argc != 3){
		std::cerr << "Usage: prog exeFile debugOption\n";
		exit(1); 
	}
	int DEBUG = atoi(argv[2]);

	memory mem;
	CPU8080 theCPU(&mem);
	GTUOS	theOS;

	theCPU.ReadFileIntoMemoryAt(argv[1], 0x0000);
 	unsigned cycles = 0;
 	unsigned cpucycle = 0;
 	unsigned oscycle = 0;
 	unsigned workingcycles = 0;
 	std::string key;
	do	
	{
		cpucycle = theCPU.Emulate8080p(DEBUG);
		cycles += cpucycle;
		workingcycles += cpucycle;
		if(theCPU.isSystemCall())
		{
			oscycle = theOS.handleCall(theCPU,cycles);
			cycles += oscycle;
			workingcycles += oscycle;
		}
		
		//printf("11111 %d\n",workingcycles);
		workingcycles = theOS.schedule(theCPU,workingcycles,DEBUG);
		//printf("22222 %d\n",workingcycles);
	}	
	while (!theCPU.isHalted());
	theOS.writeMem(theCPU);
	printf("cycles: %d\n",cycles);
	return 0;
}

