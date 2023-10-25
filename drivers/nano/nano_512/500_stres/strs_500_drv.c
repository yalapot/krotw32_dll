#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>


#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 4;

#define MAGN_SENSORS          576
#define FIRST_SENSLINE_SIZE   576
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-576"
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
   long i, j;
   long tmp;

   // меняем местами первый и последний сектора
   for (i=0; i<144; i++) {
      sens_sort[i    ] = 432 + i;
      sens_sort[i+432] = i;
   };

   // меняем местами пары ласт между собой
   for (i=0; i<MAGN_SENSORS; i+=16) {
      for (j=0; j<8; j++) {
         tmp = sens_sort[i+j];
         sens_sort[i+j] = sens_sort[i+j + 8];
         sens_sort[i+j + 8] = tmp;
      };
   };
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i, j;

   // смещение вo 1 и 3 секторах
   for (i=0; i<144; i++) {
      sens_shift[i+ 144 * 0 ] = 200;
      sens_shift[i+ 144 * 2 ] = 200;
   };


   // сдвижка между парами ласт
   for (i=0; i<MAGN_SENSORS; i+=16) {
      for (j=0; j<8; j++) {
         sens_shift[i+j] += 8;
      };
   };

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // стресс 500 NANO_512
      if (strncmp(target_name, "53100101", 8)==0)
      {
          Orientation_dAy_value =  491.784;
          Orientation_KAy_value =  241.974;
          Orientation_dAz_value =  514.021;
          Orientation_KAz_value =  237.887;

          Orientation_shift_group_1 = 38;
          Orientation_shift_group_2 = 0;

          Odometer_0_sens_value = 212;
          Odometer_1_sens_value = 451;

          return KRT_OK;

      } 


     MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер СК 500 (Nano512)","драйвер СК 700 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
     return KRT_ERR;
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>


