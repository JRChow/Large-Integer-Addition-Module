#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char* argv[])
{
   int i;
   int itr;
   int MAX_CHAR;
   
   if (argc != 2)
   {
      fprintf(stderr, "%s\n", "Usage: ./randCharGen charNumber");
      exit(EXIT_FAILURE);
   }
   
   MAX_CHAR = atoi(argv[1]);
   srand(time(NULL));
   
   for (itr = 0; itr < MAX_CHAR; itr++)
   {
      i = rand() % 0x7F;
      if (i == 0x09 || i == 0x0A || (i >= 0x20 && i <= 0x7E))
         printf("%c", i);
   }
   return 0;
}
