#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>


#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 3; // 3.012 

#define MAGN_SENSORS          896
#define FIRST_SENSLINE_SIZE   896
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  ""
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define THICK_NUM_DATA   FIRST_SENSLINE_SIZE

char Target_name_driver[32];

double Orientation_dAy_value = 0;
double Orientation_KAy_value = 0;
double Orientation_dAz_value = 0;
double Orientation_KAz_value = 0;

int Orientation_shift_direct = 0;

int Orientation_shift_group_1 = 0;
int Orientation_shift_group_2 = 0;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

long Amplification_Group0 = 10;
long Amplification_Group1 = 10;
long smooth_win_length0 = 4;
long smooth_win_length1 = 4;

void create_sens_sort ( long *sens_sort)
{
    long i;

    (void) sens_sort;

    for (i=0; i <  32; i++) sens_sort[  0 + i] = 448 + i;
    for (i=0; i <  96; i++) sens_sort[ 32 + i] = 800 + i;
    for (i=0; i <  32; i++) sens_sort[128 + i] = 768 + i;
    for (i=0; i < 160; i++) sens_sort[160 + i] = 608 + i;
    for (i=0; i < 128; i++) sens_sort[320 + i] =  32 + i;
    for (i=0; i <  32; i++) sens_sort[448 + i] =   0 + i;
    for (i=0; i < 128; i++) sens_sort[480 + i] = 192 + i;
    for (i=0; i <  32; i++) sens_sort[608 + i] = 160 + i;
    for (i=0; i < 128; i++) sens_sort[640 + i] = 480 + i;
    for (i=0; i < 128; i++) sens_sort[768 + i] = 320 + i;
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i, j;


   // сдвижка между парами ласт
   for (i=0; i<MAGN_SENSORS; i+=16) {
      for (j=0; j<8; j++) {
         sens_shift[i+j+8] += 13;
      };
   };
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // стресс 1416 M NANO_512
      if (strncmp(target_name, "14160101", 8)==0)
      {
          Orientation_dAy_value =  469.370;
          Orientation_KAy_value =  244.051;
          Orientation_dAz_value =  495.797;
          Orientation_KAz_value = -244.150;

          Orientation_shift_group_1 = 234;
          Orientation_shift_group_2 = 0;

          Odometer_0_sens_value = 0;
          Odometer_1_sens_value = 448;

          return KRT_OK;

      } 

     MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер СК 1416 (Nano512)","драйвер СК 1416 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
     return KRT_ERR;
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>


