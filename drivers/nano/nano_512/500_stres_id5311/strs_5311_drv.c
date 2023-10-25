#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>


#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 4;

#define MAGN_SENSORS          320
#define FIRST_SENSLINE_SIZE   320
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-319"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS  1

#define THICK_NUM_DATA   (MAGN_SENSORS/8)

char Target_name_driver[32];

double Orientation_dAy_value = 0;
double Orientation_KAy_value = 0;
double Orientation_dAz_value = 0;
double Orientation_KAz_value = 0;

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
   long i;
   long tmp_sens_sort[MAGN_SENSORS];

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   for(i = 0; i < 80; i++)
   {
       sens_sort[80 * 1 + i] = tmp_sens_sort[80 * 3 + i];
       sens_sort[80 * 2 + i] = tmp_sens_sort[80 * 1 + i];
       sens_sort[80 * 3 + i] = tmp_sens_sort[80 * 2 + i];
   }
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   // �������� � 3 � 4 ��������
   for (i=0; i<80; i++) {
       sens_shift[i + 80] = 274;
       sens_shift[i + 240] = 274;
   };

   // ������� ����� ��������� ������ �����
   for (i=0; i<MAGN_SENSORS; i+=8) {
         sens_shift[i+0] += 9;
         sens_shift[i+1] += 9;
         sens_shift[i+2] += 9;
         sens_shift[i+3] += 9;
   };


}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // ������ 500 NANO_512
      if (strncmp(target_name, "53100101", 8)==0)
      {
          Orientation_dAy_value =  516.333;
          Orientation_KAy_value =  229.337;
          Orientation_dAz_value =  490.262;
          Orientation_KAz_value =  225.870;

          Orientation_shift_group_1 = 0;
          Orientation_shift_group_2 = 0;

          return KRT_OK;

      } 

      // ������ 500 NANO_512
      if (strncmp(target_name, "53110101", 8)==0)
      {
          Orientation_dAy_value =  516.333;
          Orientation_KAy_value =  229.337;
          Orientation_dAz_value =  490.262;
          Orientation_KAz_value =  225,870;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 = 50;
          Orientation_shift_group_2 = 0;

          Odometer_0_sens_value = 152;
          Odometer_1_sens_value = 312;

          return KRT_OK;

      } 


     MessageBox(NULL, "�������� ������ �������! \n��� ������� �� 500 (Nano512)","������� �� 700 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
     return KRT_ERR;
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>


