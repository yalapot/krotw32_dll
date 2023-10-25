#include <stdio.h>
#include <math.h>

#define REC_SIZE 262
#define KROT_BLACK_BOX_ALL_SENS 128

//#pragma pack (1)

typedef struct {
  unsigned char Signature   ;
  unsigned char Orientation ;
  unsigned long Abs_time    ;
  unsigned long Abs_track   ;
  unsigned char Real_Dimens ;
  unsigned long Reserved    ;
  unsigned char Termo       ;
} TBlock_Head;

//#pragma pack ()

char *Src_file_name="tm00000.da";
FILE *Src_file;

char *Dist_file_name="tm00000.txt";
FILE *Dist_file;


TBlock_Head Block_Head;

int  Max_Dimension = 0; /* количество реальных циклов измерений в 2-м блоке */

unsigned int data_buf[55000];

int  real_dat_size=0;

int SensRoute[KROT_BLACK_BOX_ALL_SENS] = {
  0,  3,  6,  9, 12, 16, 19, 22, 25, 28, 32, 35, 38, 41, 44, 48, 51, 54, 57, 60,
 64, 67, 70, 73, 76, 80, 83, 86, 89, 92, 96, 99,102,105,108,112,115,118,121,124,

  1,  4,  7, 10, 13, 17, 20, 23, 26, 29, 33, 36, 39, 42, 45, 49, 52, 55, 58, 61,
 65, 68, 71, 74, 77, 81, 84, 87, 90, 93, 97,100,103,106,109,113,116,119,122,125,

  2,  5,  8, 11, 14, 18, 21, 24, 27, 30, 34, 37, 40, 43, 46, 50, 53, 56, 59, 62,
 66, 69, 72, 75, 78, 82, 85, 88, 91, 94, 98,101,104,107,110,114,117,120,123,126,

 15, 31, 47, 63, 79, 95, 111,127
};


void main () {
  int  i, j;

FILE *Src_file;
  if (Src_file=fopen(Src_file_name, "rb")) {

     Dist_file=fopen(Dist_file_name, "wt");

     while (fread(&(Block_Head.Signature), 1, sizeof(TBlock_Head), Src_file)>0) {
        Max_Dimension = Block_Head.Real_Dimens;
        real_dat_size=fread (&(data_buf[0]), Max_Dimension, REC_SIZE, Src_file);

        /* печатаем текстовые данные */
        for (i=0; i<Max_Dimension; i++) {

           for (j=0; j<KROT_BLACK_BOX_ALL_SENS; j++) {
              if (data_buf[i*(REC_SIZE/2)+3+SensRoute[j]]>32000) data_buf[i*(REC_SIZE/2)+3+SensRoute[j]]=32000;
              fprintf(Dist_file, "%d,", data_buf[i*(REC_SIZE/2)+3+SensRoute[j]]);
            }; /* for (int j=0; j<SENSOR_NUM; j++) */
           fprintf(Dist_file, "\n");
        }; /* for (int i=0; Max_Dimension-1; i++) */
      }; 
  }; /* if (Src_file=fopen(Src_file_name, "r")) */

    /* файл закончился */
  fclose(Src_file);
  fclose(Dist_file);
};