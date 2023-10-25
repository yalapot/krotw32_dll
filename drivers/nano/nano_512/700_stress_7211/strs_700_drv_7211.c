#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>


#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          448
#define FIRST_SENSLINE_SIZE   448
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-447"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define THICK_NUM_DATA   (MAGN_SENSORS/8)

char Target_name_driver[32];

double Orientation_dAy_value = 0;
double Orientation_KAy_value = 0;
double Orientation_dAz_value = 0;
double Orientation_KAz_value = 0;

int Orientation_shift_direct = 0;

int Orientation_shift_group_1 = 70;
int Orientation_shift_group_2 =  0;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

long Amplification_Group0 = 10;
long Amplification_Group1 = 10;
long smooth_win_length0 = 4;
long smooth_win_length1 = 4;

void create_sens_sort ( long *sens_sort)
{

   long i;
   long tmp_sens_sort[MAGN_SENSORS];

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   for(i = 0; i < 112; i++)
   {
       sens_sort[112 + i] = tmp_sens_sort[336 + i];
       sens_sort[224 + i] = tmp_sens_sort[112 + i];
       sens_sort[336 + i] = tmp_sens_sort[224 + i];
   }

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   // �������� �o 1 � 3 ��������
   for (i=0; i < MAGN_SENSORS/4; i++) {
      sens_shift[i + MAGN_SENSORS/4 * 1] = 260; //326;
      sens_shift[i + MAGN_SENSORS/4 * 3] = 260; //326;
   };

   // �������� ������ �����
   for (i=0; i < MAGN_SENSORS; i+=8) {
      sens_shift[i + 0] += 9;
      sens_shift[i + 1] += 9;
      sens_shift[i + 2] += 9;
      sens_shift[i + 3] += 9;
   };

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // ������ 700 NANO_512
      if (strncmp(target_name, "72110101", 8)==0)
      {
          Orientation_dAy_value =  538.874;
          Orientation_KAy_value =  241.877;
          Orientation_dAz_value =  511.791;
          Orientation_KAz_value =  240.775;

          Orientation_shift_group_1 = 120;
          Orientation_shift_group_2 = 0;

          Odometer_0_sens_value = 280;
          Odometer_1_sens_value = 50;

          return KRT_OK;

      } 


     MessageBox(NULL, "�������� ������ �������! \n��� ������� �� 7211 (Nano512)","������� �� 700 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
     return KRT_ERR;
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>


