#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>
#include <krotnano_v3.h>
#include <tracetool.h>


#define THIS_INTROSCOPE_325_id3201010444 1

#define THIS_STRESS           0
#define THIS_INTROSCOPE       1

#define THIS_PROFIL           0

#define PROFIL_MM_SHIFT_UP    0
#define PROFIL_MM_INVERSE     0
#define PROFIL_SENS_IS_ENCODER 0
#define PROFIL_ROW_INVERSE     0


#define _TRACE_STEP_          4 

#define MAGN_SENSORS          512
#define FIRST_SENSLINE_SIZE   256
#define THECOND_SENSLINE_SIZE 256
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    2

#define MAX_DATA_CODE         3993

// это калибровка для ID 3205010340
double Orient_dAy_value =     510.409;
double Orient_KAy_value =    -240.232;
double Orient_dAz_value =     507.826;
double Orient_KAz_value =     244.713;

int Orientation_shift_direct = 1;

int Orientation_shift_value   = 0;
int Orientation_shift_2_value = 0;

#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Delete_sens_string  "6,7,14,15,22,23,30,31,38,39,46,47,54,55,62,63,70,71,78,79,86,87,94,95,102,103,110,111,118,119,126,127,134,135,142,143,150,151,158,159,166,167,174,175,182,183,190,191,198,199,206,207,214,215,222,223,230,231,238,239,246,247,254,255,262,263,270,271,278,279,286,287,294,295,302,303,310,311,318,319,326,327,334,335,342,343,350,351,358,359,366,367,374,375,382,383,390,391,398,399,406,407,414,415,422,423,430,431,438,439,446,447,454,455,462,463,470,471,478,479,486,487,494,495,502,503,510,511"
#define Num_Sens_Deleted_From_First_Group    64

#define Invert_sens_string  "0-255"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS  1

long num_sens_for_thick = 128;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

void create_sens_sort ( long *sens_sort)
{
   long i;

//  меняем местами сектора                   
   for (i=0; i<MAGN_SENSORS/8; i++) {
//                                куда                        откуда
      sens_sort[ (MAGN_SENSORS/8) * 0 + i ] = (MAGN_SENSORS/8) * 3 + i ;
      sens_sort[ (MAGN_SENSORS/8) * 1 + i ] = (MAGN_SENSORS/8) * 4 + i ;
      sens_sort[ (MAGN_SENSORS/8) * 2 + i ] = (MAGN_SENSORS/8) * 6 + i ;
      sens_sort[ (MAGN_SENSORS/8) * 3 + i ] = (MAGN_SENSORS/8) * 7 + i ;
      sens_sort[ (MAGN_SENSORS/8) * 4 + i ] = (MAGN_SENSORS/8) * 0 + i ;
      sens_sort[ (MAGN_SENSORS/8) * 5 + i ] = (MAGN_SENSORS/8) * 1 + i ;
      sens_sort[ (MAGN_SENSORS/8) * 6 + i ] = (MAGN_SENSORS/8) * 2 + i ;
      sens_sort[ (MAGN_SENSORS/8) * 7 + i ] = (MAGN_SENSORS/8) * 5 + i ;
   };

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   for (i=0; i<MAGN_SENSORS/2; i++)
   {
       sens_shift[i] = 210;
   };
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

      if  ( strncmp(target_name, "32010104", 8)==0 )
      {

         Orient_dAy_value =     522.614;
         Orient_KAy_value =     244.179;
         Orient_dAz_value =     503.013;
         Orient_KAz_value =     244.91 ;

         Orientation_shift_direct = 1; 

         Orientation_shift_value   = 106;
         Orientation_shift_2_value = -14;

         Odometer_0_sens_value = 140;
         Odometer_1_sens_value = 10;

         return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер коррозионник 325 id 32050103 (Nano v3)","Драйвер Стресс-коррозионник 325 (Nano v3)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;
}

long calc_termo(long adc)
{

   // 325_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_v1_v3.c>


