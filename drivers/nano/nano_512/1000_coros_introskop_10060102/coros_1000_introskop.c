#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       1

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          512
#define FIRST_SENSLINE_SIZE   512
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3993

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
   long tmp_sens_sort[MAGN_SENSORS];

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   for(i = 0; i < MAGN_SENSORS/4; i++)
   {
       sens_sort[MAGN_SENSORS/4 * 2 + i] = tmp_sens_sort[MAGN_SENSORS/4 * 3 + i];
       sens_sort[MAGN_SENSORS/4 * 3 + i] = tmp_sens_sort[MAGN_SENSORS/4 * 2 + i];
   }
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{

   (void) sens_shift;
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
                                  
      // 1000_cor_introskop
      if  ( strncmp(target_name, "10060102", 8)==0 )
      {
          Orientation_dAy_value =  477.005;
          Orientation_KAy_value = -242.949;
          Orientation_dAz_value =  510.007;
          Orientation_KAz_value = -238.535;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 =  142;
          Orientation_shift_group_2 =  0;

          Odometer_0_sens_value = 355;
          Odometer_1_sens_value = 100;

          return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник 1000 интроскоп (Nano512)","Драйвер Коррозионник 1000 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

