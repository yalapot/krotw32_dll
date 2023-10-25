#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>
#include <krotnano_v1.h>
#include <tracetool.h>

#define NANO_VERSION_1

#define THIS_PROFIL            1
#define PROFIL_MM_SHIFT_UP     0
#define PROFIL_MM_INVERSE      0
#define PROFIL_ROW_INVERSE     0
#define PROFIL_SENS_IS_ENCODER 1

#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

#define _TRACE_STEP_           5

#define MAGN_SENSORS          32
#define FIRST_SENSLINE_SIZE   32
#define THECOND_SENSLINE_SIZE 32 
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    2

#define MAX_DATA_CODE         2000

// это для 12200102
double Orient_dAy_value =  448.842;
double Orient_KAy_value = -212.701;
double Orient_dAz_value =  556.701;
double Orient_KAz_value = -277.129;

long Orientation_shift_value   =  4;
long Orientation_shift_2_value =  0;
long Orientation_shift_3_value =  0;
long Orientation_shift_4_value =  0;

long Orientation_shift_direct  =  1;


#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0

#define Invert_sens_string  "8-9,14-15,22-25"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 4

long num_sens_for_thick = FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

void create_sens_sort ( long *sens_sort)
{
    (void) sens_sort;

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   (void) sens_shift;
}

#define LENGTH_SENS         (283.5)  // в мм длинна энкодерного датчика (ось энкодера ось полиуританового колеса)
#define ZERO_ANGLE_GRADUS   (63.5)   // в градусах угол между осью снаряда и рычагом датчика в крайнем верхнем положении

double Zerro_angle_rad = ((ZERO_ANGLE_GRADUS * 2 * PI) / 360); // угол между осью снаряда и рычагом датчика в крайнем верхнем положении персчитанный в радианы

long Calculate_profil_mm(long src_data, long prof_sens_num, T_OPENED_TRACE *P_trace)
{
    double translate_res;

    translate_res = src_data; 

// формула для расчета отклонения энкодерного датчика профиля:
// В формуле Ипользуются две константы (объявлены перед функцией)
// Length_sens межцентровое расстояние в мм (центры:
//                                    ось датчика энкодера;
//                                    ocь полиуретонового колеса датчика)
// Zerro_angle_C (в градусах) угол между осью снаряда
//                            и рычагом датчика в крайнем верхнем положении
//                          (т.е. датчик калибровали в этом положении пультом)

    translate_res = translate_res
                    - P_trace->profil_calibrate[prof_sens_num][0]
                    + P_trace->profil_calibrate[0][0];

    translate_res = 
       LENGTH_SENS *
       ( sin(Zerro_angle_rad)
         -
         sin(Zerro_angle_rad - (2 * PI) / 4095 * (translate_res-1000))
       );

     translate_res += PROFIL_MM_SHIFT_UP;

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
      if  ( strncmp(target_name, "12200102", 8)==0 )
      {
         return KRT_OK;
      }

      if  ( strncmp(target_name, "12200103", 8)==0 )
      {
         Orient_dAy_value =  495.088;
         Orient_KAy_value = -175.021;
         Orient_dAz_value =  476.094;
         Orient_KAz_value =  172.373;

         Orientation_shift_value   =  -4;
         Orientation_shift_2_value =   0;

         Orientation_shift_direct  =  0;

         Odometer_0_sens_value = 24;
         Odometer_1_sens_value = 8;

         return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Профиль 1200 (Nano v1)","Драйвер Профиль 1200 (Nano v1)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;
}

long calc_termo(long adc)
{

   // 1200_profil_nanoV1
   return (adc * 3300 / 256 - 250) / 28; // AD22103
//   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_v1_v3.c>


