#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       1

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          1024
#define FIRST_SENSLINE_SIZE   512
#define THECOND_SENSLINE_SIZE 512
#define GROUP_NUM_IN_DEVICE   2

#define MAX_DATA_CODE         3943

#define Delete_sens_string    "96-127,224-255,352-383,464-511,736-767,992-1023"

// Это сколько датчиков удалено из ПЕРВОГО! пояса
#define Deleted_sens_num      144

#define Invert_sens_string  "0-511"
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
  (void) sens_sort;
/*
   long i;
   long tmp_sens_sort[MAGN_SENSORS];

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   // сортируем сектора 1 пояса
   for (i = 0; i < 128; i++)
   {
       sens_sort[128 * 0 + i] = tmp_sens_sort[128 * 1 + i];
       sens_sort[128 * 1 + i] = tmp_sens_sort[128 * 0 + i];
       sens_sort[128 * 2 + i] = tmp_sens_sort[128 * 3 + i];
       sens_sort[128 * 3 + i] = tmp_sens_sort[128 * 2 + i];
   }
*/

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{


   long i;

   for(i = FIRST_SENSLINE_SIZE; i < MAGN_SENSORS; i++)
   {
      sens_shift[i] = 200;// 368; //294;
   }

   for (i=FIRST_SENSLINE_SIZE; i<MAGN_SENSORS; i+=8)
   {
       sens_shift[i+ 0] += 7; //8;
       sens_shift[i+ 1] += 7; //8;
       sens_shift[i+ 2] += 7; //8;
       sens_shift[i+ 3] += 7; //8;
   }

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      if  ( strncmp(target_name, "82010101", 8)==0 )
      {
          Orientation_dAy_value =  527.244;
          Orientation_KAy_value = -240.344;
          Orientation_dAz_value =  509.793;
          Orientation_KAz_value =  240.825;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 =  -14;
          Orientation_shift_group_2 =   75;

          Odometer_0_sens_value =  40;
          Odometer_1_sens_value = 233;

          return KRT_OK;
      }


      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник 700 (Nano512)","Драйвер Коррозионник 700 (1024 датчика)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

