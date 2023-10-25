/* ‹ */
#define MALE 0
#define FEMALE 1
#define GERM 2

/* €„…† */
#define IMENIT  0
#define RODIT   1
#define DATELN  2
#define VINIT   3
#define TVORIT  4
#define PREDLOG 5

/* ‘“™-ˆ‹ */
#define SUSCH  0
#define PRIL   1

#ifdef _Windows
#include <windows.h>
#define PUBLIC far pascal _export
#else
#define PUBLIC
#endif

#define NUMBER     double

char * PUBLIC buildnn(int num,char * kor,char * b1,char * b234,char * b5,char * word);
int PUBLIC transns(NUMBER num,char * v,int w,int pad,int pril);