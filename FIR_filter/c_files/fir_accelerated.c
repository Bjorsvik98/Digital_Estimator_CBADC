#include <stdint.h>
#include "include/coefficients.h"
// #include <stdio.h>

#ifdef USE_MYSTDLIB
   // #include "include/stdlib.h"
#else
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>
#endif

// #if LUT_SIZE != 1
//    #error "LUT_SIZE not equal N"
// #endif

int main() {
   int zero = 0;
      // Init fir filter variables
      // #ifdef USE_MYSTDLIB
   int32_t* outArray = (int32_t*)0x190;
   // memset(outArray, 0, (S_HEIGHT+PIPELINE_DELAY) * sizeof(int32_t));
      // #else
      //    int32_t outArray[S_HEIGHT] = {0};          // Output array
      //    printf("Info: Starting FIR filter with LUT SIZE 1 \n");
      // #endif

   int input_state = 1;
   int N_input = N_BIN;
   asm volatile("changevar %0, %1, %2\n":"=r"(N_input):"r"(N_input),"r"(input_state):);
   input_state = 2;
   int K_input = K_BIN;
   asm volatile("changevar %0, %1, %2\n":"=r"(K_input):"r"(K_input),"r"(input_state):);




   //////////////////// Write element for element of H matrix to accelerator ///////////////
   // for (int j = H_HEIGHT-1; j >= 0; j--) {
   for (int j = 0; j < H_HEIGHT; j++) {
      for (int i = 0; i < H_WIDTH; i++) {
         int temp; // make a temporary variable to force the compiler to use the register
         asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H[j][i]), "r"(i):);
      } 
   }

   #if DOUBLEH == 1
      // for (int j = H_HEIGHT-1; j >= 0; j--) {
      for (int j = 0; j < H_HEIGHT; j++) {
         for (int i = 0; i < H_WIDTH; i++) {
            int temp; // make a temporary variable to force the compiler to use the register
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(-H[j][i]), "r"(i+8):);
         } 
      }
   #endif
   #if LUT_SIZE == 2
      // for (int j = H_HEIGHT-1; j >= 0; j--) {
      for (int j = 0; j < H_HEIGHT/2; j++) {
         for (int i = 0; i < H_WIDTH; i++) {
            int temp; // make a temporary variable to force the compiler to use the register
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT_00[j][i]), "r"(i):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT_01[j][i]), "r"(i+8):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT_10[j][i]), "r"(i+16):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT_11[j][i]), "r"(i+24):);
         }
      }
   #endif
   #if LUT_SIZE == 3
      // for (int j = H_HEIGHT-1; j >= 0; j--) {
      for (int j = 0; j < H_HEIGHT/3; j++) {
         for (int i = 0; i < H_WIDTH; i++) {
            int temp; // make a temporary variable to force the compiler to use the register
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT3_000[j][i]), "r"(i):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT3_001[j][i]), "r"(i+8):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT3_010[j][i]), "r"(i+16):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT3_011[j][i]), "r"(i+24):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT3_100[j][i]), "r"(i+32):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT3_101[j][i]), "r"(i+40):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT3_110[j][i]), "r"(i+48):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT3_111[j][i]), "r"(i+56):);
         }
      }
   #endif
   #if LUT_SIZE == 4
      // for (int j = H_HEIGHT-1; j >= 0; j--) {
      for (int j = 0; j < H_HEIGHT/4; j++) {
         for (int i = 0; i < H_WIDTH; i++) {
            int temp; // make a temporary variable to force the compiler to use the register
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_0000[j][i]), "r"(i):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_0001[j][i]), "r"(i+8):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_0010[j][i]), "r"(i+16):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_0011[j][i]), "r"(i+24):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_0100[j][i]), "r"(i+32):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_0101[j][i]), "r"(i+40):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_0110[j][i]), "r"(i+48):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_0111[j][i]), "r"(i+56):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_1000[j][i]), "r"(i+64):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_1001[j][i]), "r"(i+72):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_1010[j][i]), "r"(i+80):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_1011[j][i]), "r"(i+88):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_1100[j][i]), "r"(i+96):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_1101[j][i]), "r"(i+104):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_1110[j][i]), "r"(i+112):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT4_1111[j][i]), "r"(i+120):);
         }
      }
   #endif
      #if LUT_SIZE == 5
      // for (int j = H_HEIGHT-1; j >= 0; j--) {
      for (int j = 0; j < H_HEIGHT/5; j++) {
         for (int i = 0; i < H_WIDTH; i++) {
            int temp; // make a temporary variable to force the compiler to use the register
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_00000[j][i]), "r"(i):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_00001[j][i]), "r"(i+8):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_00010[j][i]), "r"(i+16):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_00011[j][i]), "r"(i+24):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_00100[j][i]), "r"(i+32):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_00101[j][i]), "r"(i+40):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_00110[j][i]), "r"(i+48):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_00111[j][i]), "r"(i+56):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_01000[j][i]), "r"(i+64):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_01001[j][i]), "r"(i+72):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_01010[j][i]), "r"(i+80):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_01011[j][i]), "r"(i+88):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_01100[j][i]), "r"(i+96):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_01101[j][i]), "r"(i+104):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_01110[j][i]), "r"(i+112):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_01111[j][i]), "r"(i+120):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_10000[j][i]), "r"(i+128):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_10001[j][i]), "r"(i+136):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_10010[j][i]), "r"(i+144):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_10011[j][i]), "r"(i+152):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_10100[j][i]), "r"(i+160):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_10101[j][i]), "r"(i+168):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_10110[j][i]), "r"(i+176):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_10111[j][i]), "r"(i+184):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_11000[j][i]), "r"(i+192):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_11001[j][i]), "r"(i+200):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_11010[j][i]), "r"(i+208):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_11011[j][i]), "r"(i+216):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_11100[j][i]), "r"(i+224):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_11101[j][i]), "r"(i+232):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_11110[j][i]), "r"(i+240):);
            asm volatile("loadh %0, %1, %2\n":"=r"(temp):"r"(H_ACC_LUT5_11111[j][i]), "r"(i+248):);
            
         }
      }
   #endif

   #if DSR == 1 
      int inputNr = 0;
      input_state = 0;

      asm volatile("changevar %0, %1, %2\n":"=r"(inputNr):"r"(inputNr),"r"(input_state):);
      //// load the first values
      ///////////////// Needed to use dowmpling /////////////////////
      for (int j = 0; j < (H_HEIGHT)-1; j=j+1) {
         int temp; // make a temporary variable to force the compiler to use the register
         asm volatile("loads %0, %1, %2\n":"=r"(temp):"r"(S_ACC_DOWN[j]),"r"(zero):);
      } 
      //////////////////////// FIR filter ///////////////////////////
      for (int k = H_HEIGHT-1; k < ((S_HEIGHT)); k=k+1 ) {
         int temp; // make a temporary variable to force the compiler to use the register
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[k-H_HEIGHT]):"r"(S_ACC_DOWN[k]),"r"(zero):);
      }
      for (int k = S_HEIGHT; k < ((S_HEIGHT)+PIPELINE_DELAY); k++ ) {
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[k-H_HEIGHT]):"r"(zero),"r"(zero):);
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
      }
      
   #elif DSR == OSR
      int inputNr = 3;
      input_state = 0;
      asm volatile("changevar %0, %1, %2\n":"=r"(inputNr):"r"(inputNr),"r"(input_state):);

      //// load the first values
      ///////////////// Needed to use dowmpling /////////////////////
      for (int j = 0; j < ((H_HEIGHT/((DSR)))); j=j+1) {
         int temp; // make a temporary variable to force the compiler to use the register
         asm volatile("loads %0, %1, %2\n":"=r"(temp):"r"(S_ACC_DOWN_EQUAL_OSR[j]),"r"(S_ACC_DOWN_EQUAL_OSR[j+(S_ACC_DOWN_EQUAL_OSR_HEIGHT/2)]):);
         // asm volatile("loads %0, %1, %2\n":"=r"(temp):"r"(S_ACC_DOWN[j]),"r"(S_ACC_DOWN[j+1]):); // made for stable DSR 8

      } 
      //////////////////////// FIR filter ///////////////////////////
      for (int k = (((H_HEIGHT/((DSR))))); k < ((S_HEIGHT/((DSR+1)/2))/2); k=k+1 ) {
         int temp; // make a temporary variable to force the compiler to use the register
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k)-((H_HEIGHT/(DSR)))]):"r"(S_ACC_DOWN_EQUAL_OSR[k]),"r"(S_ACC_DOWN_EQUAL_OSR[k+(S_ACC_DOWN_EQUAL_OSR_HEIGHT/2)]):);
         // asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k)-((H_HEIGHT/(DSR)))]):"r"(S_ACC_DSR_8[k]),"r"(S_ACC_DSR_8[k+(S_ACC_DSR_8_HEIGHT/2)]):); // made for stable DSR 8

      }


      // for (int k = ((H_HEIGHT/((DSR)/2)) - 2); k < ((S_HEIGHT/((DSR)/2))); k=k+2 ) {
      //    int temp; // make a temporary variable to force the compiler to use the register
      //    asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k/2 + k%2)-H_HEIGHT/(DSR)]):"r"(S_ACC_DOWN[k]),"r"(S_ACC_DOWN[k+1]):);
      // }
      for (int k = ((S_HEIGHT/((DSR+1)/2))/2); k < (((S_HEIGHT/((DSR+1)/2))/2)+(PIPELINE_DELAY)); k=k+1 ) {
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k)-((H_HEIGHT/(DSR)))]):"r"(zero),"r"(zero):);
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");

      }

   #elif DSR == 2 
      int inputNr = 1;
      input_state = 0;

      asm volatile("changevar %0, %1, %2\n":"=r"(inputNr):"r"(inputNr),"r"(input_state):);

      //// load the first values
      ///////////////// Needed to use dowmpling /////////////////////
      for (int j = 0; j < (H_HEIGHT/(DSR))-1; j=j+1) {
         int temp; // make a temporary variable to force the compiler to use the register
         asm volatile("loads %0, %1, %2\n":"=r"(temp):"r"(S_ACC_DOWN[j]),"r"(zero):);
      } 
      //////////////////////// FIR filter ///////////////////////////
      for (int k = (H_HEIGHT/(DSR))-1; k < ((S_HEIGHT/(DSR))); k=k+1 ) {
         int temp; // make a temporary variable to force the compiler to use the register
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k)-(H_HEIGHT/DSR)]):"r"(S_ACC_DOWN[k]),"r"(zero):);
      }
      for (int k = (S_HEIGHT/(DSR)); k < ((S_HEIGHT/(DSR))+PIPELINE_DELAY); k++ ) {
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[k-(H_HEIGHT/DSR)]):"r"(zero),"r"(zero):);
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
      }
   #elif DSR == 4  
      int inputNr = 2;
      input_state = 0;
      asm volatile("changevar %0, %1, %2\n":"=r"(inputNr):"r"(inputNr),"r"(input_state):);

      //// load the first values
      ///////////////// Needed to use dowmpling /////////////////////
      for (int j = 0; j < (H_HEIGHT/(DSR))-1; j=j+1) {
         int temp; // make a temporary variable to force the compiler to use the register
         asm volatile("loads %0, %1, %2\n":"=r"(temp):"r"(S_ACC_DOWN[j]),"r"(zero):);
      } 
      //////////////////////// FIR filter ///////////////////////////
      for (int k = (H_HEIGHT/(DSR))-1; k < ((S_HEIGHT/(DSR))); k=k+1 ) {
         int temp; // make a temporary variable to force the compiler to use the register
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k)-(H_HEIGHT/DSR)]):"r"(S_ACC_DOWN[k]),"r"(zero):);
      }
      for (int k = S_HEIGHT/DSR; k < ((S_HEIGHT/(DSR))+PIPELINE_DELAY); k++ ) {
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[k-(H_HEIGHT/DSR)]):"r"(zero),"r"(zero):);
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");

      }
   #elif DSR == 8 
      int inputNr = 3;
      input_state = 0;
      asm volatile("changevar %0, %1, %2\n":"=r"(inputNr):"r"(inputNr),"r"(input_state):);

      //// load the first values
      ///////////////// Needed to use dowmpling /////////////////////
      for (int j = 0; j < ((H_HEIGHT/((DSR))) - 1); j=j+1) {
         int temp; // make a temporary variable to force the compiler to use the register
         // asm volatile("loads %0, %1, %2\n":"=r"(temp):"r"(S_ACC_DOWN_EQUAL_OSR[j]),"r"(S_ACC_DOWN_EQUAL_OSR[j+(S_ACC_DOWN_EQUAL_OSR_HEIGHT/2)]):);
         asm volatile("loads %0, %1, %2\n":"=r"(temp):"r"(S_ACC_DOWN[j]),"r"(S_ACC_DOWN[j+1]):); // made for stable DSR 8

      } 
      //////////////////////// FIR filter ///////////////////////////
      for (int k = (((H_HEIGHT/((DSR)/2)) - 2)/2); k < ((S_HEIGHT/((DSR)/2))/2); k=k+1 ) {
         int temp; // make a temporary variable to force the compiler to use the register
         // asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k)-((H_HEIGHT/(DSR)))]):"r"(S_ACC_DOWN_EQUAL_OSR[k]),"r"(S_ACC_DOWN_EQUAL_OSR[k+(S_ACC_DOWN_EQUAL_OSR_HEIGHT/2)]):);
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k)-((H_HEIGHT/(DSR)))]):"r"(S_ACC_DSR_8[k]),"r"(S_ACC_DSR_8[k+(S_ACC_DSR_8_HEIGHT/2)]):); // made for stable DSR 8

      }


      // for (int k = ((H_HEIGHT/((DSR)/2)) - 2); k < ((S_HEIGHT/((DSR)/2))); k=k+2 ) {
      //    int temp; // make a temporary variable to force the compiler to use the register
      //    asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k/2 + k%2)-H_HEIGHT/(DSR)]):"r"(S_ACC_DOWN[k]),"r"(S_ACC_DOWN[k+1]):);
      // }
      for (int k = ((S_HEIGHT/((DSR)/2))); k < (((S_HEIGHT/((DSR)/2)))+(PIPELINE_DELAY+2)); k=k+2 ) {
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("calculate %0, %1,%2\n":"=r"(outArray[(k/2 + k%2)-H_HEIGHT/(DSR)]):"r"(zero),"r"(zero):);
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");
         asm volatile("nop\n");

      }
   #endif



   #ifdef USE_MYSTDLIB
      return outArray[0];
   #else
      printf("Info: Finished FIR filter \n");
      FILE *fp;                                       // File pointer   
      fp=fopen("result.txt","w+");                    // Open file for writing
      #if LUT_SIZE == 1
         for(int i=0;i<S_HEIGHT;i++) {
            // printf("out[%d] = %d \n", i, outArray[i]);
            fprintf(fp,"%d\n", outArray[i]);
         }
      #endif
         fclose(fp); 
         printf("Info: u_hat written to file \n");
      return 0;
   #endif
}



