#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          256
#define FIRST_SENSLINE_SIZE   256
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3993

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-256"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define THICK_NUM_DATA   FIRST_SENSLINE_SIZE

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
   long tmp_val;
   long lasta_count;
   long sens_count;

   // меняем порядок датчиков в ласте
   for (lasta_count = 0; lasta_count < MAGN_SENSORS; lasta_count += 8)
   {
       for (sens_count = 0; sens_count < 8 / 2; sens_count ++)
       {
          tmp_val = sens_sort[lasta_count + sens_count];
          sens_sort[lasta_count + sens_count] = sens_sort[lasta_count + 7 - sens_count];
          sens_sort[lasta_count + 7 - sens_count] = tmp_val;
       }
   }
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   (void) sens_shift;
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
                                  
      if  ( strncmp(target_name, "72000101", 8)==0 )
      {
          Orientation_dAy_value =  509.802;
          Orientation_KAy_value = -242.900;
          Orientation_dAz_value =  531.039;
          Orientation_KAz_value = -239.801;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 =  72;
          Orientation_shift_group_2 =  0;

          return KRT_OK;
      }


      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник 700 (Nano512)","Драйвер Коррозионник 700 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

