#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 4;

#define MAGN_SENSORS          512
#define FIRST_SENSLINE_SIZE   512
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3993

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

   long sektor_size = MAGN_SENSORS/8;

//  меняем местами сектора                   
   for (i=0; i < sektor_size; i++) {
//                       куда                откуда
      sens_sort[ sektor_size * 0 + i ] = sektor_size * 0 + i ;
      sens_sort[ sektor_size * 1 + i ] = sektor_size * 4 + i ;
      sens_sort[ sektor_size * 2 + i ] = sektor_size * 1 + i ;
      sens_sort[ sektor_size * 3 + i ] = sektor_size * 5 + i ;
      sens_sort[ sektor_size * 4 + i ] = sektor_size * 2 + i ;
      sens_sort[ sektor_size * 5 + i ] = sektor_size * 6 + i ;
      sens_sort[ sektor_size * 6 + i ] = sektor_size * 3 + i ;
      sens_sort[ sektor_size * 7 + i ] = sektor_size * 7 + i ;
   };

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   long sektor_size = MAGN_SENSORS/8;

   for (i=0; i < sektor_size; i++) {
       sens_shift[ sektor_size * 1 + i ] = 316;
       sens_shift[ sektor_size * 3 + i ] = 316;
       sens_shift[ sektor_size * 5 + i ] = 316;
       sens_shift[ sektor_size * 7 + i ] = 316;
   };
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      if  ( strncmp(target_name, "30100101", 8)==0 )
      {
          Orientation_dAy_value =  499.104;
          Orientation_KAy_value =  242.897;
          Orientation_dAz_value =  516.893;
          Orientation_KAz_value =  241.893;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 =  10;
          Orientation_shift_group_2 =  0;

          return KRT_OK;
      }


      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник 500 (Nano512)","Драйвер TFI 30 inch (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

