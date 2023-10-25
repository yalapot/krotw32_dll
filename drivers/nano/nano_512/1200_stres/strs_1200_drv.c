#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>

#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          864
#define FIRST_SENSLINE_SIZE   864
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3943

#define Delete_sens_string  "0,1,106-109,214-217,322-325,430-433,538-541,646-649,754-757,862,863"
#define Deleted_sens_num    32

#define Invert_sens_string  "0-863"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 4

#define THICK_NUM_DATA   (MAGN_SENSORS/8)

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
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;
   
   for (i=0; i < MAGN_SENSORS/8; i++) {
      sens_shift[i                   ] = 141;
      sens_shift[i + MAGN_SENSORS  /4] = 141;
      sens_shift[i + MAGN_SENSORS*2/4] = 141;
      sens_shift[i + MAGN_SENSORS*3/4] = 141;
   };
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      if (strncmp(target_name, "12100101", 8)==0)
      {
          Orientation_dAy_value =  635.157;
          Orientation_KAy_value = -247.587;
          Orientation_dAz_value =  499.917;
          Orientation_KAz_value = -247.112;

          Orientation_shift_group_1 = 250;
          Orientation_shift_group_2 =   0;

          return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер СК 1200 (Nano512)","драйвер СК 1200 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>

