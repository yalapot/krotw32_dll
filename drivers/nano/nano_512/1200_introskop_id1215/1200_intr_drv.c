#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>


#define THIS_STRESS               0
#define THIS_INTROSCOPE           1

long ODOMETER_STEP = 3;

#define MAGN_SENSORS          768
#define FIRST_SENSLINE_SIZE   768
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

long Amplification_Group0 = 16;
long Amplification_Group1 = 16;
long smooth_win_length0 = 4;
long smooth_win_length1 = 4;

void create_sens_sort ( long *sens_sort)
{
   long i;

   // меняем местами 2 и 3 сектора
   for (i=0; i<192; i++) {
      sens_sort[ 384 + i ] = 576 + i;
      sens_sort[ 576 + i ] = 384 + i;
   };

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   for (i=0; i<MAGN_SENSORS; i+=16)
   {
       sens_shift[i+  8] += 14; //8;
       sens_shift[i+  9] += 14; //8;
       sens_shift[i+ 10] += 14; //8;
       sens_shift[i+ 11] += 14; //8;
       sens_shift[i+ 12] += 14; //8;
       sens_shift[i+ 13] += 14; //8;
       sens_shift[i+ 14] += 14; //8;
       sens_shift[i+ 15] += 14; //8;
   }

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // интроскоп 1200
      if (strncmp(target_name, "12150101", 8)==0)
      {

          Orientation_dAy_value =  502,335;
          Orientation_KAy_value = -243,417;
          Orientation_dAz_value =  555,758;
          Orientation_KAz_value =  242,950;

          Orientation_shift_group_1 = -238;
          Orientation_shift_group_2 = 0;

          Odometer_0_sens_value = 180;
          Odometer_1_sens_value = 576;

          return KRT_OK;

      } 

     MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер интроскоп 1200 (Nano512)","драйвер СК 1200 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
     return KRT_ERR;
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>


