#include <iostream>
#include "8080emuCPP.h"
#include "gtuos.h"
#include <sys/types.h>
#include <unistd.h>
#include <string>

unsigned char cyclesGTUOS[] = {
	10,10,10,10,100,100,5,50,40,40,80
};

int GTUOS::randomN = 1;

GTUOS::GTUOS()
{
	currentThread=0;
	Threads[currentThread].threadid=0;
	Threads[currentThread].borntime=0;
	Threads[currentThread].status=2; // 0 for blocked , 2 for running , 1 for ready
	Threads[currentThread].isAlive=1;
	Threads[currentThread].yield=0;
	Threads[currentThread].usedcycles=0;
	Threads[currentThread].startingadress = 0;
	activeThreadNumber=1;
	lastCreated=0;
}


unsigned GTUOS::handleCall(const CPU8080 & cpu, unsigned cycles){
	int index;
	uint8_t uint8_integer;
	int integer;
	char chr;
	std::string str;
	index = cpu.state->b << 8 | cpu.state->c;
	switch (cpu.state->a)
	{
		case 0x01:
		 	printf("%d\n",cpu.state->b); 
		 	break;
		case 0x02:
			uint8_integer = cpu.memory->at(index++);
			while(uint8_integer!= 0x00)
			{
				printf("%d",uint8_integer);
				uint8_integer = cpu.memory->at(index++);
			}
			
			printf("\n");
			break;
		case 0x03:
			std::cin >> integer;
			cpu.state->b = (uint8_t)integer;
			break;
		case 0x04:
			std::cin >> integer;
			cpu.memory->at(index) = (uint8_t)integer;
			break;
		case 0x05:
			chr = cpu.memory->at(index++);
			while(chr!= 0x00)
			{
				printf("%c",chr);
				chr = cpu.memory->at(index++);
			}
			break;
		case 0x06:
			int i;
			std::getline(std::cin,str);
			for(i=0;i<str.size();i++)
			{
				cpu.memory->at(index++)=(uint8_t)str[i];
			}
			cpu.memory->at(index++) = (uint8_t)'\n';
			cpu.memory->at(index) = 0x00;
			break;
		case 0x07:
			srand(time(NULL));
			randomN += 1;
			integer = ((std::rand()*getpid()*randomN)%255)+1; // Get more randomness
			// printf("Random number: %d\n",(uint8_t)integer);
			cpu.state->b = (uint8_t) integer;
			break;
		case 0x08:	// TExit
			//printf("Çıkıyorum %d\n",currentThread);
			Threads[currentThread].status -= 2;
			Threads[currentThread].isAlive = 0;
			Threads[currentThread].state = *(cpu.state);
			activeThreadNumber--;
			break;
		case 0x09: // TJoin
			//printf("Uyuyom knk şunu beklerken %d\n",cpu.state->b);
			Threads[currentThread].status -=2; // Make it blocked
			Threads[currentThread].state = *(cpu.state);
 			break;
 		case 0x0a: // TYield
 			Threads[currentThread].yield =1;
 			break;
 		case 0x0b: // TCreate
 			if(currentThread!=0)
 			{
 				std::cerr<<"Only proccesses can create threads!\n";
 				return 0;
 				break;
 			}
 			else
 			{
 				if(lastCreated==MAX_THREADS)
 				{
 					//printf("Malloc maybe\n");
 					return 0;
 					break;
 					// malloc maybe?
 				}
 				else
 				{
 					lastCreated++;
 					activeThreadNumber++;
 					//printf("Oluşturma emri geldi! Currentthread:%d,oluşturulan %d,total %d\n",currentThread,lastCreated,activeThreadNumber);
 					cpu.state->b = lastCreated;
					Threads[lastCreated].threadid=lastCreated;
					Threads[lastCreated].borntime=cycles;
					Threads[lastCreated].status=1; // 0 for blocked , 2 for running , 1 for ready
					Threads[lastCreated].isAlive=1;
					Threads[lastCreated].yield=0;
					Threads[lastCreated].state=*(cpu.state);
					Threads[lastCreated].state.pc=index;
					Threads[lastCreated].startingadress=index;
					Threads[lastCreated].usedcycles = 0;
					Threads[lastCreated].state.sp= 0xF000 - (0xFF * lastCreated);
		 			break;
 				}
 			}
		default:
			std::cout << "NO!"<< std::endl;
			throw -1;
			break;
		
					   
	}
	return (cyclesGTUOS[cpu.state->a-1]);
}

unsigned GTUOS::schedule(CPU8080 & cpu,unsigned cycles,uint8_t DEBUG)
{
	//printf("pc %d, currentThread %d , cycles %d, total threads %d\n",cpu.state->pc,currentThread,cycles,activeThreadNumber);

	uint16_t index;
	index = cpu.state->b << 8 | cpu.state->c;
	uint8_t changeThread;
	changeThread = currentThread;
	while(1)
	{
		//printf("changeThread : %d, lastCreated: %d\n",changeThread,lastCreated);
		//printf("Alive %d, status %d \n",Threads[changeThread].isAlive,Threads[changeThread].status);

		if(changeThread>lastCreated)
		{
			changeThread=0;
			continue;
		}
		if(Threads[changeThread].isAlive == 1) // If thread is alive
		{
			if(Threads[changeThread].status == 2) // If thread is running
			{
				if(cycles >= QUANTUM)
				{
					//printf("%d 'nın süresi doldu, saveliyoruz\n",changeThread);
					if(activeThreadNumber == 1)
					{
						currentThread=changeThread;
						return 0; // We dont have to change thread, there is only one thread
					}
					// Store cpu's values to thread table
					Threads[changeThread].state=*(cpu.state);
					//printf("cycles %d\n",cycles);
					//Threads[changeThread].usedcycles += cycles;				
					Threads[changeThread].status -= 1; // Make it ready.
					// change thread
					changeThread++;
				}
				else if(Threads[changeThread].yield==1)
				{
					if (DEBUG == 3)
							printThreads();
					//printf("Burda mıyız lan?\n");	
					Threads[changeThread].yield=0;
					// Store cpu's values to thread table
					Threads[changeThread].state = *(cpu.state);
					//Threads[changeThread].usedcycles += cycles;
					Threads[changeThread].status -=1; // Make it ready.
					// changeThread
					changeThread++; 
				}
				else
				{
					currentThread = changeThread;
					//printf("Çalıştık şimdi kaç?%d\n",currentThread);
					// keep running
					return cycles;
				}
			}
			else if(Threads[changeThread].status == 1) // If thread is ready
			{
				if(changeThread==currentThread) // If we dont change our thread
				{
					Threads[changeThread].status += 1; // Make it running
					Threads[changeThread].usedcycles += cycles;
					return 0;	
				}
				if (DEBUG == 2 || DEBUG == 3)
				{
					printf("***Switching %d to %d. %d worked total %d cycles.\n",currentThread,changeThread,currentThread,Threads[currentThread].usedcycles);
					if (DEBUG ==3)
						printThreads();
				}
				
				// Load thread values to CPU
				cpu.state[0] = Threads[changeThread].state;
				Threads[currentThread].usedcycles += cycles;
				Threads[changeThread].status += 1; // Make it running
				// Make it currentThread
				currentThread = changeThread;
				return 0; // New threads working time is 0
			}
			else // If thread is blocked
			{
				if(Threads[Threads[changeThread].state.b].isAlive == 0) // The waited thread is exited
				{
					if((DEBUG == 2 || DEBUG ==3) && (currentThread != changeThread))
					{
						printf("***Switching %d to %d. %d worked total %d cycles.\n",currentThread,changeThread,currentThread,Threads[currentThread].usedcycles);
						if (DEBUG ==3)
							printThreads();
					}
					//printf("Uyanıyom çünkü %d bitmiş \n",Threads[changeThread].state.b);
					// we can release block
					Threads[changeThread].status += 2; // Make it running
					//printf("Status is now: %d\n",Threads[changeThread].status);
					Threads[currentThread].usedcycles += cycles;
					cpu.state[0] = Threads[changeThread].state;
					cpu.state->b = Threads[cpu.state->b].state.b;
					currentThread = changeThread;
					return 0; // This thread's worktime is 0
				}
				else
				{
					//std::cout<<"Threadi bekliyorum" <<std::endl;
					// Wait condition is not made.
					changeThread++;
				}
			}
		}
		else // This thread is dead.
		{
			//printf("Dönüyoruz\n");
			changeThread++;
		}
	}

}

void GTUOS::printThreads()
{
	int i=0;
	printf("TID   Status 	BornTime   WorkTime   SA     Registers\n");
	printf("------------------------------------------------------\n");
	for(i=0;i<=lastCreated;i++)
	{
		if(Threads[i].isAlive!=0)
		{
			std::	string status;
			if (Threads[i].status==0)
			{
				status = "Blocked";
			}
			else if (Threads[i].status==1)
			{
				status = "Ready";
			}
			else
			{
				status = "Running";
			}
			printf("%3ld%9s%12d%11d%5ld     A:%02x B:%02x C:%02x D:%02x E:%02x H:%02x L:%02x\n",Threads[i].threadid,status.c_str(),
					Threads[i].borntime,Threads[i].usedcycles,Threads[i].startingadress,
					Threads[i].state.a,Threads[i].state.b,Threads[i].state.c,
					Threads[i].state.d,Threads[i].state.e,Threads[i].state.h,
					Threads[i].state.l);
		}
	}
	printf("-----------------------------------------------------\n");
}

void GTUOS::writeMem(const CPU8080 & cpu)
{
	FILE *f = fopen("exe.mem","w");
	if (f == NULL)
	{	
		printf("Error opening file!\n");
		exit(1);
	}
	int i;
	int j;
	int memorySize = 0x10000; // Size of memory look memory.h
	int memoryContent;
	char str[4];
	for(i=0;i<memorySize;i += 16)
	{
		fprintf(f,"%04x: ",i);
		for(j=i;j<i+16;j++)
		{
			memoryContent = cpu.memory->at(j);
			fprintf(f,"%02x ",memoryContent);
		}
		fprintf(f,"\n");
	}
	fclose(f);
	return;
}
