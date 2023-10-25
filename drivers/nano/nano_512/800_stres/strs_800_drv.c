#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>


#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          512
#define FIRST_SENSLINE_SIZE   512
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-511"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

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

   long i;
   long tmp_sens_sort[MAGN_SENSORS];

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   // сортируем сектора 1 пояса
   for (i = 0; i < 128; i++)
   {
       sens_sort[128 * 0 + i] = tmp_sens_sort[128 * 3 + i];
       sens_sort[128 * 1 + i] = tmp_sens_sort[128 * 1 + i];
       sens_sort[128 * 2 + i] = tmp_sens_sort[128 * 2 + i];
       sens_sort[128 * 3 + i] = tmp_sens_sort[128 * 0 + i];
   }

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   // смещение вo 2 и 4 секторах
   for (i=0; i<128; i++) {
      sens_shift[i+128] = 256;
      sens_shift[384+i] = 256;
   };

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // стресс 700 NANO_512
      if (strncmp(target_name, "72100101", 8)==0)
      {
          Orientation_dAy_value =  540.073;
          Orientation_KAy_value = -244.353;
          Orientation_dAz_value =  547.670;
          Orientation_KAz_value =  243.310;

          Orientation_shift_group_1 = 80;
          Orientation_shift_group_2 = 0;

          Odometer_0_sens_value = 14;
          Odometer_1_sens_value = 270;

          return KRT_OK;

      } 


     MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер СК 700 (Nano512)","драйвер СК 700 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
     return KRT_ERR;
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>


