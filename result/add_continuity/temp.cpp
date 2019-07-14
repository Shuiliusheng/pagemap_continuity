#include<iostream>
#include<string.h>
#include<stdio.h>
using namespace std;

int array[1000];

void process()
{
    FILE *p=fopen("log","r");
    while(!feof(p))
    {
	int t1=0,t2=0;
        fscanf(p,"%d %d",&t1,&t2);
        if(t1>=1000)
        {
	    printf("%d*4KB:%d\n",t1,t2);
            continue;
	}
        array[t1]+=t2;	
    }
    fclose(p);
    
    for(int i=0;i<1000;i++)
    {
	if(array[i]!=0)
	    printf("%d*4KB:%d\n",i,array[i]);
    }
}

int main()
{
   for(int i=0;i<1000;i++)
   {
       array[i]=0;
   }
   process();
   return 0;
}
