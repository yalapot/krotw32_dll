#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 1;

#define MAGN_SENSORS          224
#define FIRST_SENSLINE_SIZE   224
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         4095

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  ""
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define THICK_NUM_DATA   FIRST_SENSLINE_SIZE

//#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS  1

char Target_name_driver[32];

double Orientation_dAy_value =  540.073;
double Orientation_KAy_value = -244.353;
double Orientation_dAz_value =  547.670;
double Orientation_KAz_value =  243.310;

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
   long last_count;

   // md22
   // смещение вo 2 и 4 секторах
   for (i=0; i< 224 / 4; i++) {
      sens_shift[i + 224 / 4] = 1118;
      sens_shift[i + 672 / 4] = 1118;
   };

   // смещение ласт по 2 датчиков
   for (last_count = 0; last_count < MAGN_SENSORS; last_count += 4) {
        for (i=0; i<2; i++) {
            sens_shift[last_count + 2 + i] += 60;
        };
   };

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
                                  
      return KRT_OK;
//      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник 508 c двумя поясами (Nano512)","Драйвер Коррозионник 1000 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
//      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

