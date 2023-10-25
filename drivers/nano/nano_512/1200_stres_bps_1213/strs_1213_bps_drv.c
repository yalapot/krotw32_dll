#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>

#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 3;

#define MAGN_SENSORS          1024
#define FIRST_SENSLINE_SIZE   1024
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num       0

#define Invert_sens_string  "0-1023"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define THICK_NUM_DATA   (MAGN_SENSORS/8)

//#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS  1

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

   long i=0;
   long tmp_sens_sort[MAGN_SENSORS];

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   for(i = 0; i < 128; i++)
   {
       sens_sort[128 * 0 + i] = tmp_sens_sort[128 * 0 + i];
       sens_sort[128 * 1 + i] = tmp_sens_sort[128 * 4 + i];
       sens_sort[128 * 2 + i] = tmp_sens_sort[128 * 1 + i];
       sens_sort[128 * 3 + i] = tmp_sens_sort[128 * 5 + i];
       sens_sort[128 * 4 + i] = tmp_sens_sort[128 * 2 + i];
       sens_sort[128 * 5 + i] = tmp_sens_sort[128 * 6 + i];
       sens_sort[128 * 6 + i] = tmp_sens_sort[128 * 3 + i];
       sens_sort[128 * 7 + i] = tmp_sens_sort[128 * 7 + i];
   }                                                

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{

   long i;
   
   for (i=0; i < MAGN_SENSORS/8; i++) {
      sens_shift[i + MAGN_SENSORS/8 * 1 ] = 635;
      sens_shift[i + MAGN_SENSORS/8 * 3 ] = 635;
      sens_shift[i + MAGN_SENSORS/8 * 5 ] = 635;
      sens_shift[i + MAGN_SENSORS/8 * 7 ] = 635;
   };

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      if (strncmp(target_name, "12130101", 8)==0)
      {
          Orientation_dAy_value =  495.317;
          Orientation_KAy_value =  240.003;
          Orientation_dAz_value =  549.445;
          Orientation_KAz_value = -239.908;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 =  0;
          Orientation_shift_group_2 =  0;

//          Odometer_0_sens_value = 187;
//          Odometer_1_sens_value = 705;

          return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер СК 1200 байпас(Nano512)","драйвер СК 1200 байпас(Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>

