#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 4;

#define MAGN_SENSORS          384
#define FIRST_SENSLINE_SIZE   256
#define THECOND_SENSLINE_SIZE 128
#define GROUP_NUM_IN_DEVICE   2

#define MAX_DATA_CODE         3993

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-383"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define THICK_NUM_DATA   FIRST_SENSLINE_SIZE

#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS  1

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
   (void) sens_sort;

/*
   long i;

   long base_sens_count = 8;
   long ext_sens_count = FIRST_SENSLINE_SIZE;
   long internal_cirkle_counter=0;

   i=8;
   while (1)
   {

      for (internal_cirkle_counter=0; internal_cirkle_counter<8; internal_cirkle_counter++)
      {
         sens_sort[ext_sens_count] =  i;
         i++;
         ext_sens_count++;
         if (i>=MAGN_SENSORS) break;

      };
      if (i>=MAGN_SENSORS) break;

      for (internal_cirkle_counter=0; internal_cirkle_counter<16; internal_cirkle_counter++)
      {
         sens_sort[base_sens_count] =  i;
         i++;
         base_sens_count++;
         if (i>=MAGN_SENSORS) break;
      };
      if (i>=MAGN_SENSORS) break;
   };
*/
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;
   
   for (i=0; i <  FIRST_SENSLINE_SIZE ; i++)
   {
      sens_shift[i] = 504;
   }
}

long check_file_ID(char* target_name)
{
     strncpy(Target_name_driver, target_name, 31);

     Orientation_dAy_value =  532.9  ;
     Orientation_KAy_value = -253.352;
     Orientation_dAz_value =  587.42 ;
     Orientation_KAz_value = -247.69 ;

     Orientation_shift_group_1 =  -33;
     Orientation_shift_group_2 =  5;

     return KRT_OK;
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

