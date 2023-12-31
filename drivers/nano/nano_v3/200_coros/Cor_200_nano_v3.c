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

#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

#define _TRACE_STEP_           3

#define MAGN_SENSORS          128
#define FIRST_SENSLINE_SIZE   128
#define THECOND_SENSLINE_SIZE  0 
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         3943

#define Orient_dAy_value      508.445
#define Orient_KAy_value      188.007
#define Orient_dAz_value      511.383
#define Orient_KAz_value     -183.467

#define Orientation_shift_value      -4
#define Orientation_shift_2_value    0
#define Orientation_shift_3_value    0
#define Orientation_shift_4_value    0

#define Orientation_shift_direct    1


#define Delete_sens_string  "12-15,28-31,44-47,60-63,76-79,92-95,108-111,124-127"

#define Num_Sens_Deleted_From_First_Group    32

#define Invert_sens_string  "0-127"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

//#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS 1

long num_sens_for_thick = 12; //FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 26;
long Odometer_1_sens_value = 95;

char Target_name_driver[32];

void create_sens_sort ( long *sens_sort)
{

/*
   long sector_count;
   long lasti_count;
   long i;
   long tmp_val;

   // ��������� ����� �������� � ������

       sector_count = 6 * 16;

       for (i=0; i<4/2; i++) {
           // 0 ����� � �������
           lasti_count = sector_count + 0;
           tmp_val = sens_sort[ lasti_count + i];
           sens_sort[ lasti_count + i] = sens_sort[ lasti_count + 3-i];
           sens_sort[ lasti_count + 3-i] = tmp_val;

           // 1 ����� � �������
           lasti_count = sector_count + 4;
           tmp_val = sens_sort[ lasti_count + i];
           sens_sort[ lasti_count + i] = sens_sort[ lasti_count + 3-i];
           sens_sort[ lasti_count + 3-i] = tmp_val;

           // 2 ����� � �������
           lasti_count = sector_count + 8;
           tmp_val = sens_sort[ lasti_count + i];
           sens_sort[ lasti_count + i] = sens_sort[ lasti_count + 3-i];
           sens_sort[ lasti_count + 3-i] = tmp_val;
       }
*/

    (void )sens_sort;

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i, j;

   for (j=1; j<8; j+=2)
   {
       for (i=0; i<16; i++)
       {
          sens_shift[j*16 + i] = 178;
       }
   }
}

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


