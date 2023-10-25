#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>

#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          960
#define FIRST_SENSLINE_SIZE   640
#define THECOND_SENSLINE_SIZE 320
#define GROUP_NUM_IN_DEVICE   2

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-959"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 4

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

   long base_sens_count = 0;
   long ext_sens_count = FIRST_SENSLINE_SIZE;
   long internal_cirkle_counter=0;


   i=0;
   while (1)
   {
      for (internal_cirkle_counter=0; internal_cirkle_counter<8; internal_cirkle_counter++)
      {
         sens_sort[base_sens_count] =  i;
         i++;
         base_sens_count++;
         if (i>=MAGN_SENSORS) break;
      };
      if (i>=MAGN_SENSORS) break;

      for (internal_cirkle_counter=0; internal_cirkle_counter<4; internal_cirkle_counter++)
      {
         sens_sort[ext_sens_count] =  i;
         i++;
         ext_sens_count++;
         if (i>=MAGN_SENSORS) break;

      };
      if (i>=MAGN_SENSORS) break;

   };

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
     (void) sens_shift;
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      if (strncmp(target_name, "12050101", 8)==0)
      {
         Orientation_dAy_value =  350.057;
         Orientation_KAy_value = -240.984;
         Orientation_dAz_value =  468.981;
         Orientation_KAz_value = -241.982;

         Orientation_shift_group_1 = 153;
         Orientation_shift_group_2 = -80;

         Odometer_0_sens_value = 253;
         Odometer_1_sens_value = 573;

         return KRT_OK;
      } 

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник 1200 (Nano512)","Драйвер Коррозионник 1200 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

