#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       1

long ODOMETER_STEP = 4;

#define MAGN_SENSORS          256
#define FIRST_SENSLINE_SIZE   256
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

   for (i=0; i<32; i++)
   {
       sens_sort[ 0 + i ] = 128 + i;
   }

   for (i=0; i<128; i++)
   {
       sens_sort[ 32 + i ] = 0 + i;
   }
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i, j;


   // сдвижка между парами ласт
   for (i=0; i<MAGN_SENSORS; i+=16) {
      for (j=0; j<8; j++) {
         sens_shift[i+j] += 12;
      };
   };
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
                                  
      if  ( strncmp(target_name, "42150101", 8)==0 )
      {
          Orientation_dAy_value =  496.974;
          Orientation_KAy_value =  238.974;
          Orientation_dAz_value =  524.897;
          Orientation_KAz_value = -240.017;

          Orientation_shift_direct = 0;

          Orientation_shift_group_1 =  137;
          Orientation_shift_group_2 =  0;

          return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Интроскоп 426 (Nano512)","Интроскоп 426 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

