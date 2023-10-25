#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>

#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 3; // 3.012 

#define MAGN_SENSORS          1152
#define FIRST_SENSLINE_SIZE   1152
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3993

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-1151"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define THICK_NUM_DATA   FIRST_SENSLINE_SIZE

char Target_name_driver[32];

double Orientation_dAy_value = 1;
double Orientation_KAy_value = 1;
double Orientation_dAz_value = 1;
double Orientation_KAz_value = 1;

int Orientation_shift_direct = 0;

int Orientation_shift_group_1 = 0;
int Orientation_shift_group_2 = 0;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

long Amplification_Group0 = 10;
long Amplification_Group1 = 10;
long smooth_win_length0 = 6;
long smooth_win_length1 = 6;

void create_sens_sort ( long *sens_sort)
{

    (void) sens_sort;

}; // void create_sens_sort ( long *sens_sort)

void create_sens_shift ( long *sens_shift)
{
    long i;

    for (i = 0; i < MAGN_SENSORS; i += 2)
    {
        sens_shift[i + 1] += 1;

    };
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // Новый 1400 КРОТ М байпас NANO_512
      if (strncmp(target_name, "14060201",8)==0)
      {
          Orientation_dAy_value =  485.851;
          Orientation_KAy_value =  240.036;
          Orientation_dAz_value =  515.089;
          Orientation_KAz_value =  240.889;

          Orientation_shift_direct = 0;

          Orientation_shift_group_1 = -400;

          return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионника 1400 (Nano512)","драйвер Коррозионника 1400 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>


