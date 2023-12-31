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

#define _TRACE_STEP_           4

#define MAGN_SENSORS          480
#define FIRST_SENSLINE_SIZE   480
#define THECOND_SENSLINE_SIZE  0
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         4095

// ��� ���������� ��� ID 3205010340
double Orient_dAy_value =     510.409;
double Orient_KAy_value =    -240.232;
double Orient_dAz_value =     507.826;
double Orient_KAz_value =     244.713;

int Orientation_shift_direct = 1;

int Orientation_shift_value   = 0;
int Orientation_shift_2_value = 0;

#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0
#define Invert_sens_string  "0-575"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS 1

long num_sens_for_thick = 480;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 547;
long Odometer_1_sens_value = 252;

void create_sens_sort ( long *sens_sort)
{

   long i;
   long tmp;

   // ������ ������� ������ � ��������� �������
   for (i=0; i<120; i++) {
      sens_sort[i + 120] = 360 + i;
      sens_sort[i + 360] = i + 120;
   };

   for (i=0; i<120; i++) {
      tmp = sens_sort[i + 240];
      sens_sort[i + 240] = sens_sort[i + 360];
      sens_sort[i + 360] = tmp;
   };
/*
   // ������ ������� ���� ���� ����� �����
   for (i=0; i<MAGN_SENSORS; i+=16) {
      for (j=0; j<8; j++) {
         tmp = sens_sort[i+j];
         sens_sort[i+j] = sens_sort[i+j + 8];
         sens_sort[i+j + 8] = tmp;
      };
   };
*/
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{

   long i;

   // �������� �o 1 � 3 ��������
   for (i=0; i<120; i++) {
      sens_shift[i + 120 * 0] = 250;
      sens_shift[i + 120 * 2] = 250;
   };


   // ������� ����� ������ ����
//   for (i=0; i<MAGN_SENSORS; i+=16) {
//      for (j=0; j<8; j++) {
//         sens_shift[i+j + 8] += 10;
//      };
//   };

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
      if  ( strncmp(target_name, "5310010445", 10)==0 )
      {

         Orient_dAy_value =     507.607;
         Orient_KAy_value =    -240.918;
         Orient_dAz_value =     505.244;
         Orient_KAz_value =     246.164;

         Orientation_shift_direct = 0;
                                       
         Orientation_shift_value   = 280;
         Orientation_shift_2_value = 0;

         Odometer_0_sens_value = 212;
         Odometer_1_sens_value = 451;

         return KRT_OK;
      }

      MessageBox(NULL, "�������� ������ �������! \n��� ������� ������ 500 id 53100104 (Nano v3)","������� ������-������������ 500 (Nano v3)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;
}

long calc_termo(long adc)
{

   // 325_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_v1_v3.c>


