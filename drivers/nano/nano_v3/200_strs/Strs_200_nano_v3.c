#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>
#include <krotnano_v3.h>
#include <tracetool.h>


#define THIS_PROFIL           0
#define PROFIL_MM_SHIFT_UP    0
#define PROFIL_MM_INVERSE     0
#define PROFIL_SENS_IS_ENCODER 0
#define PROFIL_ROW_INVERSE     0

#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

#define _TRACE_STEP_           3

#define MAGN_SENSORS          192
#define FIRST_SENSLINE_SIZE   192
#define THECOND_SENSLINE_SIZE  0 
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         3943

#define Orient_dAy_value      498.844
#define Orient_KAy_value      230.088
#define Orient_dAz_value      486.602
#define Orient_KAz_value      231.023


#define Orientation_shift_value     -36
#define Orientation_shift_2_value    0
#define Orientation_shift_3_value    0
#define Orientation_shift_4_value    0

#define Orientation_shift_direct    0


#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0

#define Invert_sens_string  "0-191"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS 1

long num_sens_for_thick = 12; //FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

char Target_name_driver[32];

void create_sens_sort ( long *sens_sort)
{

   long i;

   // перетусуем блоки ласт
   for (i=0; i<16; i++) {

      sens_sort[ i + 16 *  0] = i + 16 * 11;
      sens_sort[ i + 16 *  1] = i + 16 *  7;
      sens_sort[ i + 16 *  2] = i + 16 *  3;
                                           
      sens_sort[ i + 16 *  3] = i + 16 *  9;
      sens_sort[ i + 16 *  4] = i + 16 *  5;
      sens_sort[ i + 16 *  5] = i + 16 *  1;
                                           
      sens_sort[ i + 16 *  6] = i + 16 * 10;
      sens_sort[ i + 16 *  7] = i + 16 *  6;
      sens_sort[ i + 16 *  8] = i + 16 *  2;
                                           
      sens_sort[ i + 16 *  9] = i + 16 *  8;
      sens_sort[ i + 16 * 10] = i + 16 *  4;
      sens_sort[ i + 16 * 11] = i + 16 *  0;
   };

   // развернем опрос датчиков в блоке
//   {
//       long lasti_count;
//       long tmp_val;
//
//       for (lasti_count = 0; lasti_count < FIRST_SENSLINE_SIZE; lasti_count += 16) {
//           for (i=0; i<16/2; i++) {
//               tmp_val = sens_sort[ lasti_count + i];
//               sens_sort[ lasti_count + i] = sens_sort[ lasti_count + 15-i];
//               sens_sort[ lasti_count + 15-i] = tmp_val;
//           }
//       };
//   }
   
                                           
}; // void create_sens_sort ( long *sens_sort)

                                           
void create_sens_shift ( long *sens_shift)
{

   long i;
   
   // смещение между ластами
   for (i=0; i<8; i++) {
   
      sens_shift[ i + 8 *  0] = 287;
      sens_shift[ i + 8 *  1] = 282;
      sens_shift[ i + 8 *  2] = 214;
      sens_shift[ i + 8 *  3] = 209;
      sens_shift[ i + 8 *  4] = 182;
      sens_shift[ i + 8 *  5] = 177;

      sens_shift[ i + 8 *  6] = 110;
      sens_shift[ i + 8 *  7] = 105;
      sens_shift[ i + 8 *  8] =  75;
      sens_shift[ i + 8 *  9] =  73;
      sens_shift[ i + 8 * 10] =   5;
      sens_shift[ i + 8 * 11] =   0;

      sens_shift[ i + 8 * 12] = 287;
      sens_shift[ i + 8 * 13] = 282;
      sens_shift[ i + 8 * 14] = 214;
      sens_shift[ i + 8 * 15] = 209;
      sens_shift[ i + 8 * 16] = 182;
      sens_shift[ i + 8 * 17] = 177;

      sens_shift[ i + 8 * 18] = 110;
      sens_shift[ i + 8 * 19] = 105;
      sens_shift[ i + 8 * 20] =  75;
      sens_shift[ i + 8 * 21] =  73;
      sens_shift[ i + 8 * 22] =   5;
      sens_shift[ i + 8 * 23] =   0;
   };

};                 
                  
long Calculate_profil_mm(long src_data, long prof_sens_num, T_OPENED_TRACE *P_trace)
{
   (void) src_data;
   (void) prof_sens_num;
   (void) P_trace;

   return 0;
};

long check_file_ID(char* target_name)
{
    strncpy(Target_name_driver, target_name, 31);

    return KRT_OK;
}

long calc_termo(long adc)
{

   // 200_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}

#include <nano_v1_v3.c>


