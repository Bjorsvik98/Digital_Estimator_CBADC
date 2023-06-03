#include <stdint.h>
#include "include/coefficients.h"
// #include <stdio.h>

#ifdef IBEX_OFF
   #ifdef USE_MYSTDLIB
      // #include "include/stdlib.h"
   #else
      #include <stdio.h>
      #include <stdlib.h>
      #include <string.h>
   #endif
#else
   #include "simple_system_common.h"
#endif


int main() {

   // Init fir filter variables
   #ifdef IBEX_OFF
      #ifdef USE_MYSTDLIB
         int32_t* outArray = (int32_t*)0x190;
         memset(outArray, 0, S_HEIGHT * sizeof(int32_t));
      #else
         int32_t outArray[S_HEIGHT*LUT_SIZE/N] = {0};          // Output array
         printf("Info: Starting FIR filter \n");
      #endif
   #else
     int32_t outArray[S_HEIGHT*LUT_SIZE/N] = {0};          // Output array
   #endif

   // Fir filter algorithm
   // for (int k = 0; k < (samples/DSR - K1); k++ ) {
   int32_t* addr;                                        // Base address pointer to H matrix row
   int32_t* LUT_addr;                                    // Pointer for speciific column LUT entry                  
   // printf("addr = %p\n", addr);


   if (N < LUT_SIZE) {
      for (int k = 0; k < (S_HEIGHT-(K*N)/LUT_SIZE); k++) {
      addr = &H[0][0];                                   // Set base address to row in H matrix
      int32_t tempOutput = 0;
      for (int i = 0; i < (K*N)/LUT_SIZE; i++) {         // Loop over all LUT entries in row
         LUT_addr = addr + S[i+k];                       // Set pointer specific entry in LUT
         tempOutput += *LUT_addr;
         addr += ADDR_SHIFT;                             // Increment base address to next row in H matrix                
         // printf("*LUT_addr: %d \n", *LUT_addr);
         // printf("outArray[%d] = %d, i = %d, k = %d\n", (k*LUT_SIZE)/N, outArray[(k*LUT_SIZE)/N], i, k);
      }
      outArray[k] += tempOutput;
   }
   }
   
   
   else{
      for (int k = 0; k < (S_HEIGHT-(K*N)/LUT_SIZE); k+=((N-1)/LUT_SIZE) +1) {
         addr = &H[0][0];                                   // Set base address to row in H matrix
         int32_t tempOutput = 0;
         for (int i = 0; i < (K*N)/LUT_SIZE; i++) {         // Loop over all LUT entries in row
            LUT_addr = addr + S[i+k];                       // Set pointer specific entry in LUT
            tempOutput += *LUT_addr;
            addr += ADDR_SHIFT;                             // Increment base address to next row in H matrix                
            // printf("*LUT_addr: %d \n", *LUT_addr);
            // printf("outArray[%d] = %d, i = %d, k = %d\n", (k*LUT_SIZE)/N, outArray[(k*LUT_SIZE)/N], i, k);
            // uint32_t num1 = 2321, num2 = 1771731, test1 = 0;
            // asm volatile("test %0, %1,%2\n":"=r"(test1):"r"(num1),"r"(num2):);

         }
         if (LUT_SIZE == 1) { 
            outArray[k/N] += tempOutput; 
         }
         else { 
            outArray[k] += tempOutput; 
         }
      }
   }






   #ifdef IBEX_OFF
      #ifdef USE_MYSTDLIB
         return outArray[0];
      #else
         printf("Info: Finished FIR filter \n");
         FILE *fp;                                       // File pointer   
         fp=fopen("result.txt","w+");                    // Open file for writing
         for(int i=0;i<(S_HEIGHT*LUT_SIZE)/N;i++)        // Loop over all output values
         {
            // printf("out[%d] = %d \n", i, outArray[i]);
            fprintf(fp,"%d\n", outArray[i]);             // Write to file
         }
         printf("Info: u_hat written to file \n");
         fclose(fp); 
         return 0;
      #endif
   #else
      for(int i=0;i<(S_HEIGHT*LUT_SIZE)/N;i++) {       // Loop over all output values
         puthex(outArray[i]);
         putchar('\n');
      }
      return 0;
   #endif
     
}



