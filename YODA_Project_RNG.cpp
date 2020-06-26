/****************************************************/
/* A C++ program that performs a Galois LFSR        */
/* operation on an input seed. To be uses as the    */
/* golden standard.                                 */
/*                                                  */
/* Project: YODA Project, ID: P04                   */
/* Group members:                                   */
/*  Keenan Robinson (RBNKEE001), Noel Loxton        */
/*  Noel Loxton (LXTNOE001)                         */
/*  Mauro Borrageio (BRRMAU002)                     */
/*                                                  */
/* Date Modified: 21/06/2020                        */
/****************************************************/
#include <stdio.h>
#include <stdint.h>
#include <sys/time.h>
//Use the following URL to understand how this code works:
//https://en.wikipedia.org/wiki/Linear-feedback_shift_register
//NOTE: the design is based off of the Galois LFSR.
uint32_t runtime = 0;
clock_t execTime;
char s[32+1];
unsigned lfsr_galois(void);
const int numbers = 4;
uint32_t memory[numbers] = {0};
double timeTaken = 0;

unsigned lfsr_galois(void)
{
    struct timeval begin, end;  //variables to store the start and end times
    gettimeofday(&begin, 0);    // start timing

    uint32_t start_seed = 0b11001100011010001110011010011110;  /* Any nonzero start state will work. */
                                                                /* This is the seed value*/
    uint32_t separate_seed; //seed for each LFSR iteration
    uint32_t lfsr;
    unsigned period = 0;    //acts as count

    do
    {
        //Output current seed based on period
        separate_seed = start_seed + 314159265*period;

        //printf("Current seed: %u\n", separate_seed);
        lfsr = separate_seed;
        unsigned lsb = lfsr & 1;    /* Get LSB (i.e., the output bit). */
        /*To view the current seed*/
        /*printf("Current Seed");
        for (int i = 0; i < 32; i++)    //for displaying the number as a string
          {
             s[31 - i] = (lfsr & (1 << i)) ? '1' : '0';
          }
        printf("\n%10d: %s", period, s);
        printf("\t");
        printf("Decimal: %u\n", lfsr);     //make sure it is interpreted as an unsigned number!
        /*End viewing the seed*/

        //Randomising
        /*printf("LFSR Output");*/
        lfsr >>= 1;                 /* Shift register */
        if (lsb)                    /* If the output bit is 1, */
            lfsr ^= 0x80200003;     /* apply toggle mask: 0b10000000001000000000000000000011 */
                                    /* this relates the 32-bit Maximum Feedback polynomial.*/
                                    /* ^ is an XOR operation. */

        /*for (int i = 0; i < 32; i++)    //for displaying the number as a string
          {
             s[31 - i] = (lfsr & (1 << i)) ? '1' : '0';
          }
        printf("\n%10d: %s", period, s);
        printf("\t");
        printf("Decimal: %u\n\n", lfsr);     //make sure it is interpreted as an unsigned number!
        */
        for (int i = 0; i < 32; i++)    //for displaying the number as a string
          {
             s[31 - i] = (lfsr & (1 << i)) ? '1' : '0';
          }
        //printf("%s\n", s);
        printf("%u\n", lfsr);

        //Writing to memory
        memory[period] = lfsr;

        period++;
    }
    /*while (lfsr != start_seed);
    {
      return period;
    }*/
    while (period != numbers);
    {
        //To get the time taken to execute the code
        gettimeofday(&end, 0);
        long seconds = end.tv_sec - begin.tv_sec;
        long microseconds = end.tv_usec - begin.tv_usec;
        printf("Time measured: %.3f microseconds.\n", seconds*1e6 + microseconds);
        return period;
    }
}

int main() {
    execTime = clock();
    lfsr_galois();
    execTime = clock()-execTime; //total program runtime
    printf("Execution time [ms]: %fms\n",timeTaken);
    return 0;
}
