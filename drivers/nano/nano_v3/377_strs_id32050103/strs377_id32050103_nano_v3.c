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

#define _TRACE_STEP_           5

#define MAGN_SENSORS          224
#define FIRST_SENSLINE_SIZE   224
#define THECOND_SENSLINE_SIZE  0
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         4095

// это калибровка для ID 3205010340
double Orient_dAy_value =     510.409;
double Orient_KAy_value =    -240.232;
double Orient_dAz_value =     507.826;
double Orient_KAz_value =     244.713;

int Orientation_shift_direct = 1;

int Orientation_shift_value   = -67;
int Orientation_shift_2_value = 0;

#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Delete_sens_string "96-111,208-223"

#define Num_Sens_Deleted_From_First_Group    32
#define Invert_sens_string  "0-243"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = 244;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

void create_sens_sort ( long *sens_sort)
{
   long i;

   long tmp_sens_sort[MAGN_SENSORS];


   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   for(i = 0; i < 48; i++)
   {
       sens_sort[ i +   0 +  0 ] = tmp_sens_sort[ i + 112 +  0 ];
       sens_sort[ i +   0 + 48 ] = tmp_sens_sort[ i +   0 + 48 ];
       sens_sort[ i + 112 +  0 ] = tmp_sens_sort[ i + 112 + 48 ];
       sens_sort[ i + 112 + 48 ] = tmp_sens_sort[ i +   0 +  0 ];
   }

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   for (i=0; i < 48; i++) {

       // первые сектора при опросе 2 потоками
//       sens_shift[ i +  0 ] = 180; // смещение назад в измерениях
//       sens_shift[ i + 112 + 0 ] = 180; // смещение назад в измерениях


       // вторые сектора при опросе 2 потоками
       sens_shift[ i +  48 ] = 180; // смещение назад в измерениях
       sens_shift[ i + 112 + 48 ] = 180; // смещение назад в измерениях
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

      if  ( strncmp(target_name, "32050103", 8)==0 )
      {

         Orient_dAy_value =     510.409;
         Orient_KAy_value =    -240.232;
         Orient_dAz_value =     507.826;
         Orient_KAz_value =     244.713;

         Orientation_shift_direct = 1; 
                                       
         Orientation_shift_value   = -74;
         Orientation_shift_2_value = 0;

         Odometer_0_sens_value = 152;
         Odometer_1_sens_value =  56;

         return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер стресс 325 id 32050103 (Nano v3)","Драйвер Стресс-коррозионник 325 (Nano v3)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;
}

long calc_termo(long adc)
{

   // 325_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_v1_v3.c>


