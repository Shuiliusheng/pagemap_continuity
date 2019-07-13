#define _POSIX_C_SOURCE 200809L
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#define PAGE_SIZE 0x1000



uint64_t last_paddr=0;
uint64_t continuity=0;
uint64_t record[1024*1024];
uint64_t behavior[4]={0};
#define MAX 1024*1024

static void process(uint64_t address, uint64_t data) 
{
	uint64_t present=(data >> 63) & 1;
	uint64_t paddr=data & 0x7fffffffffffff;
	if(present!=1)
	{
		//printf("-1\r");
		behavior[0]++;
		continuity=0;
		last_paddr=0;
		return;
	}	
	if(paddr==0)
	{
		continuity=0;
		last_paddr=0;
		//printf(" 0\r");
		behavior[1]++;
		return;
	}
	if(paddr==(last_paddr+1))
	{
		continuity++;
		behavior[2]++;
		printf("paddr=(last_paddr+1): %d %d\n", continuity, behavior[2]);
		last_paddr=paddr;
		return ;
	}
	else
	{
		continuity=continuity%(MAX);
		record[continuity]++;
		if(continuity!=0)
		{
			printf("continuity: %d\n", continuity);
		}	
		last_paddr=paddr;
		continuity=0;
		//printf("+1\r");
		behavior[3]++;
	}
}

void save_log(uint64_t last_addr, uint64_t end_addr, char dirname[])
{
	char filename[200];
	sprintf(filename,"%s/pagemap-0x%lx-0x%lx.log",dirname,last_addr,end_addr);
	FILE *p=fopen(filename,"w");
	fprintf(p,"behavior 0 (present=-1):%-10ld\n",behavior[0]);
	fprintf(p,"behavior 1 (    padd=0):%-10ld\n",behavior[1]);
	fprintf(p,"behavior 2 (continue  ):%-10ld\n",behavior[2]);
	fprintf(p,"behavior 3 (not contin):%-10ld\n",behavior[3]);
	for(int i=0;i<MAX;i++)
	{
		if(record[i]!=0)
		{
			fprintf(p,"continuity: %10ld 4KB:%-10ld\n",i+1,record[i]);
		}
	}
	fclose(p);
}

int main(int argc, char *argv[]) 
{
    char filename[BUFSIZ];
    if(argc != 5) {
        printf("Usage: %s pid start_address end_addr dst_dir\n",
            argv[0]);
        return 1;
    }

    errno = 0;
    int pid = (int)strtol(argv[1], NULL, 0);
    if(errno) {
        perror("strtol");
        return 1;
    }
    snprintf(filename, sizeof filename, "/proc/%d/pagemap", pid);

    int fd = open(filename, O_RDONLY);
    if(fd < 0) {
        perror("open");
        return 1;
    }

    uint64_t start_address = strtoul(argv[2], NULL, 0);
    uint64_t end_address = strtoul(argv[3], NULL, 0);

	for(int t=0;t<MAX;t++)
		record[t]=0;
	
	
	uint64_t n=0;
	printf("Start Vaddr:0x%-16lx \n", start_address);
    for(uint64_t i = start_address; i < end_address; i += 0x1000) 
	{
        uint64_t data;
        uint64_t index = (i / PAGE_SIZE) * sizeof(data);
        if(pread(fd, &data, sizeof(data), index) != sizeof(data)) {
            perror("pread");
            break;
        }
        process(i, data);
		
		n++;
		if(n%(1024*1024)==0)
		{
			//save_log(start_address,i, argv[4]);
		}
    }
	printf("End Vaddr:0x%-16lx \n", end_address);
	printf("\n");
	save_log(start_address,end_address, argv[4]);
    close(fd);
    return 0;
}