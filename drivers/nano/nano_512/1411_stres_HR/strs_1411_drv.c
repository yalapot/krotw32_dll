#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>


#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 3;

#define MAGN_SENSORS          1280
#define FIRST_SENSLINE_SIZE   1280
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-1279"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define THICK_NUM_DATA   (MAGN_SENSORS/8)

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
   long i=0;
   long tmp_sens_sort[MAGN_SENSORS];

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   for(i = 0; i < MAGN_SENSORS/8; i++)
   {
       sens_sort[MAGN_SENSORS/8 * 3 + i] = tmp_sens_sort[MAGN_SENSORS/8 * 0 + i];
       sens_sort[MAGN_SENSORS/8 * 5 + i] = tmp_sens_sort[MAGN_SENSORS/8 * 1 + i];
       sens_sort[MAGN_SENSORS/8 * 7 + i] = tmp_sens_sort[MAGN_SENSORS/8 * 2 + i];
       sens_sort[MAGN_SENSORS/8 * 1 + i] = tmp_sens_sort[MAGN_SENSORS/8 * 3 + i];
       sens_sort[MAGN_SENSORS/8 * 6 + i] = tmp_sens_sort[MAGN_SENSORS/8 * 4 + i];
       sens_sort[MAGN_SENSORS/8 * 0 + i] = tmp_sens_sort[MAGN_SENSORS/8 * 5 + i];
       sens_sort[MAGN_SENSORS/8 * 2 + i] = tmp_sens_sort[MAGN_SENSORS/8 * 6 + i];
       sens_sort[MAGN_SENSORS/8 * 4 + i] = tmp_sens_sort[MAGN_SENSORS/8 * 7 + i];
   }


}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{

    long i;

       for (i=0; i < MAGN_SENSORS/8; i++) {
          sens_shift[i + MAGN_SENSORS/8 * 1 ] = 700; //423;
          sens_shift[i + MAGN_SENSORS/8 * 3 ] = 700; //423;
          sens_shift[i + MAGN_SENSORS/8 * 5 ] = 700; //423;
          sens_shift[i + MAGN_SENSORS/8 * 7 ] = 700; //423;
       };
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // סענוסס 1400 M NANO_512
      if (strncmp(target_name, "14110202", 8)==0)
      {
          ODOMETER_STEP = 3; // 3.012 

          Orientation_dAy_value =  507.769;
          Orientation_KAy_value =  242.007;
          Orientation_dAz_value =  518.216;
          Orientation_KAz_value =  239.409;

          Orientation_shift_group_1 = 400;
          Orientation_shift_group_2 = 0;

//          Odometer_0_sens_value = 929;
//          Odometer_1_sens_value = 423;

          return KRT_OK;

      } 

     MessageBox(NULL, "Âûבונועו הנףדמי הנאיגונ! \nÝעמ הנאיגונ ÑÊ 1400 (Nano512)","הנאיגונ ÑÊ 1400 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
     return KRT_ERR;
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>


