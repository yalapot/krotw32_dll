#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>
#include <krotnano_v3.h>
#include <tracetool.h>


#define THIS_PROFIL            1
#define PROFIL_MM_SHIFT_UP    80
#define PROFIL_MM_INVERSE      0
#define PROFIL_ROW_INVERSE     1
#define PROFIL_SENS_IS_ENCODER 1

#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

#define _TRACE_STEP_           3

#define MAGN_SENSORS          18
#define FIRST_SENSLINE_SIZE   18
#define THECOND_SENSLINE_SIZE 18 
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    2

#define MAX_DATA_CODE         2000

#define Orient_dAy_value      540.550
#define Orient_KAy_value     -243.548
#define Orient_dAz_value      506.539
#define Orient_KAz_value      241.194


#define Orientation_shift_value    -7
#define Orientation_shift_2_value   0
#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Orientation_shift_direct    1


#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0

#define Invert_sens_string  ""
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 2;
long Odometer_1_sens_value = 15;

void create_sens_sort ( long *sens_sort)
{
     sens_sort[0 ] = 14;
     sens_sort[1 ] = 8 ;
     sens_sort[2 ] = 15;
     sens_sort[3 ] = 0 ;
     sens_sort[4 ] = 16;
     sens_sort[5 ] = 1 ;
     sens_sort[6 ] = 17;
     sens_sort[7 ] = 2 ;
     sens_sort[8 ] = 9 ;
     sens_sort[9 ] = 3 ;
     sens_sort[10] = 10;
     sens_sort[11] = 4 ;
     sens_sort[12] = 11;
     sens_sort[13] = 5 ;
     sens_sort[14] = 12;
     sens_sort[15] = 6 ;
     sens_sort[16] = 13;
     sens_sort[17] = 7 ;
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{

   sens_shift[0]=43;
   sens_shift[2]=43;
   sens_shift[4]=43;
   sens_shift[6]=43;
   sens_shift[8]=43;
   sens_shift[10]=43;
   sens_shift[12]=43;
   sens_shift[14]=43;
   sens_shift[16]=43;

}

#define LENGTH_SENS         (110.0)  // в мм длинна энкодерного датчика (ось энкодера ось полиуританового колеса)
#define ZERO_ANGLE_GRADUS   (47.3) // в градусах угол между осью снаряда и рычагом датчика в крайнем верхнем положении

double Zerro_angle_rad = ((ZERO_ANGLE_GRADUS * 2 * PI) / 360); // угол между осью снаряда и рычагом датчика в крайнем верхнем положении персчитанный в радианы

long Calculate_profil_mm(long src_data, long prof_sens_num, T_OPENED_TRACE *P_trace)
{
    double translate_res;

    translate_res = src_data; 

    translate_res = translate_res
                    - P_trace->profil_calibrate[prof_sens_num][0]
                    + P_trace->profil_calibrate[0][0];


// формула для расчета отклонения энкодерного датчика профиля:
// В формуле Ипользуются две константы (объявлены перед функцией)
// Length_sens межцентровое расстояние в мм (центры:
//                                    ось датчика энкодера;
//                                    ocь полиуретонового колеса датчика)
// Zerro_angle_C (в градусах) угол между осью снаряда
//                            и рычагом датчика в крайнем верхнем положении
//                          (т.е. датчик калибровали в этом положении пультом)
    translate_res = 
       LENGTH_SENS *
       ( sin( Zerro_angle_rad )
         -
         sin( Zerro_angle_rad - (2 * PI) / 4095 * (translate_res - 1000) )
       );



     translate_res += 50;

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
    (void) target_name;

    return KRT_OK;
}

long calc_termo(long adc)
{

   // 325_profil_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}

#include <nano_v1_v3.c>


