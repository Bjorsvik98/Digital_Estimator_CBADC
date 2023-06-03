#ifndef STDLIB_H
#define STDLIB_H

#include <stdarg.h>
// #include <stdint.h>


extern long time();
extern long insn();

// #ifdef USE_MYSTDLIB
// extern char *malloc();
// extern int printf(const char *format, ...);
// void printf_c(int c);
// void printf_s(char *p);
// static void printf_c(int c);

extern void *memcpy(void *dest, const void *src, long n);
extern char *strcpy(char *dest, const char *src);
extern int strcmp(const char *s1, const char *s2);
void *memset(void *s, int c, unsigned int count);



#endif