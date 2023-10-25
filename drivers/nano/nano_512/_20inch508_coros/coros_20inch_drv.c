#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

#define ODOMETER_STEP         5

#define MAGN_SENSORS          384
#define FIRST_SENSLINE_SIZE   256
#define THECOND_SENSLINE_SIZE 128
#define GROUP_NUM_IN_DEVICE   2

#define MAX_DATA_CODE         3993

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-255, 256-383"
#define Zerro_sens_string   ""


#define ADD_THEN_CAHANGE_ODOM 0

#define THICK_NUM_DATA   FIRST_SENSLINE_SIZE

#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS  1

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

   (void) sens_sort;

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
    long i;

    for (i=0; i < FIRST_SENSLINE_SIZE; i++)
    {
        sens_shift[i] = 230;
    }
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
                                  
      if  ( strncmp(target_name, "20000101", 8)==0 )
      {
          Orientation_dAy_value =   486.018;
          Orientation_KAy_value =  -241.018;
          Orientation_dAz_value =   489.01;
          Orientation_KAz_value =  -242.01;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 = 67;
          Orientation_shift_group_2 = 39;

          return KRT_OK;
      }


      MessageBox(NULL, "�������� ������ �������! \n��� ������� ������������ 508 c ����� ������� (Nano512)","������� ������������ 1000 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // �������� MAGN_SENSORS � file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

