#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>
#include <krotnano_v1.h>
#include <tracetool.h>


#define THIS_PROFIL            0
#define PROFIL_MM_SHIFT_UP     0
#define PROFIL_MM_INVERSE      0
#define PROFIL_ROW_INVERSE     0
#define PROFIL_SENS_IS_ENCODER 0

#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

#define _TRACE_STEP_           2

#define MAGN_SENSORS          96
#define FIRST_SENSLINE_SIZE   96
#define THECOND_SENSLINE_SIZE  0 
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         4095

#define Orient_dAy_value      587.723
#define Orient_KAy_value     -245.848
#define Orient_dAz_value      566.899
#define Orient_KAz_value     -239.532


#define Orientation_shift_value     0
#define Orientation_shift_2_value   0
#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Orientation_shift_direct    1


#define Delete_sens_string ""

#define Num_Sens_Deleted_From_First_Group   0

#define Invert_sens_string  ""
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

void create_sens_sort ( long *sens_sort)
{

/*
   long lasti_count;
   long i;
   long tmp_val;


   // развернем опрос датчиков в блоке
   for (lasti_count = 0; lasti_count < FIRST_SENSLINE_SIZE; lasti_count += 8) {
       for (i=0; i<8/2; i++) {
           tmp_val = sens_sort[ lasti_count + i];
           sens_sort[ lasti_count + i] = sens_sort[ lasti_count + 7-i];
           sens_sort[ lasti_count + 7-i] = tmp_val;
       }
   };
*/
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   (void*) sens_shift;
}

long Calculate_profil_mm(long src_data, long prof_sens_num, T_OPENED_TRACE *P_trace)
{
    double translate_res;

    (void) prof_sens_num;
    (void) P_trace;

    translate_res = src_data; 

    translate_res = translate_res * 80 / 240 - 330;
//    if (translate_res < 30) translate_res += 5;
//    if (translate_res < 20) translate_res += 5;


    if ( translate_res > 199 ) translate_res = 199;
    if ( translate_res <   0 ) translate_res =   0;

   if (PROFIL_MM_INVERSE > 0)
   {
        translate_res = PROFIL_MM_INVERSE - translate_res;
   }

   return (long) translate_res;
};

long check_file_ID(char* target_name)
{

      if  ( strncmp(target_name, "SP000102", 8)==0 )
      {
         return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер самописца (Nano v1)","Драйвер самописца (Nano v1)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

}

long calc_termo(long adc)
{

   // 1000_profil_nanoV1 с энкодерами
   return (adc * 3300 / 256 - 250) / 28; // AD22103
//   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_v1_v3.c>


