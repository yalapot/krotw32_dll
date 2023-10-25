#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>

#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          768
#define FIRST_SENSLINE_SIZE   768
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3993

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-767"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM  0

#define THICK_NUM_DATA   (MAGN_SENSORS/8)

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
   long i;
   long sector_size = 96;

   long tmp_sens_sort[MAGN_SENSORS];

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   // 1000 стресс утолщенка
   if (strncmp(Target_name_driver, "10110101", 8)==0)
   {
       for(i = 0; i < sector_size; i++)
       {
           sens_sort[sector_size * 1 + i] = tmp_sens_sort[sector_size * 7 + i];
           sens_sort[sector_size * 2 + i] = tmp_sens_sort[sector_size * 1 + i];
           sens_sort[sector_size * 3 + i] = tmp_sens_sort[sector_size * 4 + i];
           sens_sort[sector_size * 4 + i] = tmp_sens_sort[sector_size * 2 + i];
           sens_sort[sector_size * 5 + i] = tmp_sens_sort[sector_size * 5 + i];
           sens_sort[sector_size * 6 + i] = tmp_sens_sort[sector_size * 3 + i];
           sens_sort[sector_size * 7 + i] = tmp_sens_sort[sector_size * 6 + i];
       }
   }

   // 1000 стресс байпас
   if (strncmp(Target_name_driver, "10120101", 8)==0)
   {
       for(i = 0; i < sector_size; i++)
       {
           sens_sort[sector_size * 0 + i] = tmp_sens_sort[sector_size * 4 + i];
           sens_sort[sector_size * 1 + i] = tmp_sens_sort[sector_size * 1 + i];
           sens_sort[sector_size * 2 + i] = tmp_sens_sort[sector_size * 5 + i];
           sens_sort[sector_size * 3 + i] = tmp_sens_sort[sector_size * 2 + i];
           sens_sort[sector_size * 4 + i] = tmp_sens_sort[sector_size * 6 + i];
           sens_sort[sector_size * 5 + i] = tmp_sens_sort[sector_size * 3 + i];
           sens_sort[sector_size * 6 + i] = tmp_sens_sort[sector_size * 7 + i];
           sens_sort[sector_size * 7 + i] = tmp_sens_sort[sector_size * 0 + i];
       }
   }

} // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   // 1000 стресс утолщенка
   if (strncmp(Target_name_driver, "10110101", 8)==0)
   {

       for (i=0; i < MAGN_SENSORS/8; i++) {
          sens_shift[i + MAGN_SENSORS/8 * 0 ] = 348;
          sens_shift[i + MAGN_SENSORS/8 * 2 ] = 348;
          sens_shift[i + MAGN_SENSORS/8 * 4 ] = 348;
          sens_shift[i + MAGN_SENSORS/8 * 6 ] = 348;
       };
   }

   // 1000 стресс байпас
   if (strncmp(Target_name_driver, "10120101", 8)==0)
   {
       for(i = 0; i < MAGN_SENSORS/8; i++)
       {
          sens_shift[i + MAGN_SENSORS/8 * 0 ] = 360;
          sens_shift[i + MAGN_SENSORS/8 * 2 ] = 360;
          sens_shift[i + MAGN_SENSORS/8 * 4 ] = 360;
          sens_shift[i + MAGN_SENSORS/8 * 6 ] = 360;
       };
   }

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
	  
	  // 1000 strs utolshenca
      if  ( strncmp(target_name, "10110101", 8)==0 )
      {
          Orientation_dAy_value =  511.725;
          Orientation_KAy_value =  241.772;
          Orientation_dAz_value =  516.488;
          Orientation_KAz_value = -241.488;

          Orientation_shift_group_1 = -260;
          Orientation_shift_group_2 = 0;

          Odometer_0_sens_value =  16;
          Odometer_1_sens_value = 400;

          return KRT_OK;
      }

      // 1000 strs bypas
      if  ( strncmp(target_name, "10120101", 8)==0 )
      {
          Orientation_dAy_value =  490.065;
          Orientation_KAy_value =  242.066;
          Orientation_dAz_value =  529.209;
          Orientation_KAz_value = -239.923;

          Orientation_shift_group_1 = 140;
          Orientation_shift_group_2 = 0;

          Orientation_shift_direct = 1;

          Odometer_0_sens_value = 239;
          Odometer_1_sens_value = 625;

          return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Стресс-Коррозионник 1000 (Nano512)","Драйвер Коррозионник 1000 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>

