#include <stdint.h>
#include "include/coefficients.h"
// #include <stdio.h>

#if IBEX_STATE == 1 
   #include "simple_system_common.h"
#else
   #ifdef USE_MYSTDLIB
      // #include "include/stdlib.h"
   #else
      #include <stdio.h>
      #include <stdlib.h>
      #include <string.h>
   #endif
#endif


int main() {

   // Init fir filter variables
   #if IBEX_STATE == 1 
      int32_t outArray[S_HEIGHT*LUT_SIZE/N] = {0};          // Output array
   #else
      #ifdef USE_MYSTDLIB
         int32_t* outArray = (int32_t*)0x190;
         memset(outArray, 0, S_HEIGHT * sizeof(int32_t));
      #else
         int32_t outArray[S_HEIGHT] = {0};          // Output array
         printf("\nInfo: Starting FIR filter with no LUT used, as in the specialisation project \n");
      #endif
   #endif

   int32_t* addr;                                        // Base address pointer to H matrix row
   int32_t* LUT_addr;                                    // Pointer for speciific column LUT entry                  

   // Fir filter algorithm

   // #if N < LUT_SIZE 
   //    for (int k = 0; k < (S_HEIGHT-(K*N)/LUT_SIZE); k++) {
   //    addr = &H[0][0];                                   // Set base address to row in H matrix
   //    int32_t tempOutput = 0;
   //    for (int i = 0; i < (K*N)/LUT_SIZE; i++) {         // Loop over all LUT entries in row
   //       LUT_addr = addr + S[i+k];                       // Set pointer specific entry in LUT
   //       tempOutput += *LUT_addr;
   //       addr += ADDR_SHIFT;                             // Increment base address to next row in H matrix                
   //       // printf("*LUT_addr: %d \n", *LUT_addr);
   //       // printf("outArray[%d] = %d, i = %d, k = %d\n", (k*LUT_SIZE)/N, outArray[(k*LUT_SIZE)/N], i, k);
   //    }
   //    outArray[k] += tempOutput;
   // }
   
   
   
   // // #elif LUT_SIZE == N
   // #elif LUT_SIZE == N
   //    for (int k = 0; k < (S_HEIGHT-(K*N)/LUT_SIZE); k+=((N-1)/LUT_SIZE) +1) {
   //       addr = &H[0][0];                                   // Set base address to row in H matrix
   //       int32_t tempOutput = 0;
   //       for (int i = 0; i < (K*N)/LUT_SIZE; i++) {         // Loop over all LUT entries in row
   //          LUT_addr = addr + S[i+k];                       // Set pointer specific entry in LUT
   //          tempOutput += *LUT_addr;
   //          addr += ADDR_SHIFT;                             // Increment base address to next row in H matrix                
   //          // printf("*LUT_addr: %d \n", *LUT_addr);
   //          // printf("outArray[%d] = %d, i = %d, k = %d\n", (k*LUT_SIZE)/N, outArray[(k*LUT_SIZE)/N], i, k);
   //          // uint32_t num1 = 2321, num2 = 1771731, test1 = 0;
   //          // asm volatile("test %0, %1,%2\n":"=r"(test1):"r"(num1),"r"(num2):);

   //       }
   //       if (LUT_SIZE == 1) { 
   //          outArray[k/N] += tempOutput; 
   //       }
   //       else { 
   //          outArray[k] += tempOutput; 
   //       }
   //    }
   // #elif LUT_SIZE == 1
   for (int k = K1; k < (((S_HEIGHT-K)/DSR)+K1); k=k+1 ) {
      for (int i = 0; i < K; i++) { 
         // printf("checking S[%d] = %d \n", ((k-K1))+i, S[((k-K1))+i][0]);
         for (int j = 0; j < (H_WIDTH); j++) {
            if (S[((k-K1)*DSR)+i][j] == 1) {
               outArray[k] += H[i][j];
            } else {
               outArray[k] -= H[i][j];
            }
            // if (outArray[k] > 16384) {
            //    printf("warining! outArray[%d] = %d \n", k, outArray[k]);
            // }
            // printf("outArray[%d] = %d, i = %d, k = %d, j = %d, S[%d][%d] = %d, H[%d][%d] = %d\n", k, outArray[k], i, k, j, ((k-K1)*DSR)+i, j, S[((k-K1)*DSR)+i][j], i, j, H[i][j]);
         }
      }
   }
   // #endif


   #if IBEX_STATE == 1 
      for(int i=0;i<(S_HEIGHT*LUT_SIZE)/N;i++) {       // Loop over all output values
         puthex(outArray[i]);
         putchar('\n');
      }
      return 0;
   #else
      #ifdef USE_MYSTDLIB
         return outArray[0];
      #else
         printf("Info: Finished FIR filter \n");
         FILE *fp;                                       // File pointer   
         fp=fopen("result.txt","w+");                    // Open file for writing
         for(int i=0;i<S_HEIGHT;i++) {
            // printf("out[%d] = %d \n", i, outArray[i]);
            fprintf(fp,"%d\n", outArray[i]);
         }
         fclose(fp); 
         printf("Info: u_hat written to c_files/result.txt\n");
         printf("Info: The result from the simulation can be found in decimal format in result.txt \n\n");
         return 0;
      #endif
   #endif
}



