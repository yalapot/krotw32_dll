#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>

#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          1152
#define FIRST_SENSLINE_SIZE   864
#define THECOND_SENSLINE_SIZE 288
#define GROUP_NUM_IN_DEVICE   2

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
long smooth_win_length0 = 4;
long smooth_win_length1 = 4;

void create_sens_sort ( long *sens_sort)
{
   long i, j;

   long base_sens_count;
   long ext_sens_count;
   long internal_cirkle_counter;

   long tmp_sens_sort[MAGN_SENSORS];


   // Новый 1400 M bayapas NANO_512
   if (strncmp(Target_name_driver, "14060201", 8)==0)
   {

      memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

      for(i = 0; i < 384; i++)
      {
          sens_sort[384 * 0 + i] = tmp_sens_sort[384 * 1 + i];
          sens_sort[384 * 1 + i] = tmp_sens_sort[384 * 2 + i];
          sens_sort[384 * 2 + i] = tmp_sens_sort[384 * 0 + i];
      }

      memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

      base_sens_count = 0;
      while (base_sens_count < MAGN_SENSORS)
      {
         for (internal_cirkle_counter=0; internal_cirkle_counter < 6; internal_cirkle_counter++)
         {
            for (i=0; i<32; i++)
            {
                sens_sort[ base_sens_count + internal_cirkle_counter * 32 + i ] = 
                          tmp_sens_sort[ base_sens_count + (5-internal_cirkle_counter)*32 + i]; 
            }
         }
         base_sens_count += 192;
      }

      // растащим датчики на пояса
      memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

      i=0;
      base_sens_count = 0;
      ext_sens_count = FIRST_SENSLINE_SIZE;
      while (1)
      {
         for (internal_cirkle_counter=0; internal_cirkle_counter<12; internal_cirkle_counter++)
         {
            sens_sort[base_sens_count] =  tmp_sens_sort[i];
            base_sens_count++;
            if (base_sens_count >= FIRST_SENSLINE_SIZE) base_sens_count = 0;
            i++;
            if (i>=MAGN_SENSORS) break;
         };
         if (i>=MAGN_SENSORS) break;

         for (internal_cirkle_counter=0; internal_cirkle_counter<4; internal_cirkle_counter++)
         {
            sens_sort[ext_sens_count] = tmp_sens_sort[i];
            ext_sens_count++;
            if (ext_sens_count >= MAGN_SENSORS) ext_sens_count = FIRST_SENSLINE_SIZE;
            i++;
            if (i>=MAGN_SENSORS) break;

         };
         if (i>=MAGN_SENSORS) break;
      };

      return;

   } // if (strncmp(Target_name_driver, "14060201", 8)==0)

   // Новый 1400 корозионник NANO_512 для старой бочки
   if (strncmp(Target_name_driver, "14050101", 8)==0)
   {
       j = 0;
       for (i=0; i<864; i++) {
          sens_sort[ i ] = j;
          i++; j++;
          sens_sort[ i ] = j;
          i++; j++;
          sens_sort[ i ] = j;
          i++; j++;
          sens_sort[ i ] = j;
          i++; j++;
          sens_sort[ i ] = j;
          i++; j++;
          sens_sort[ i ] = j;
          j+=3;
       };

       j = 6;
       for (i=864; i<1152; i++) {
          sens_sort[ i ] = j;
          i++; j++;
          sens_sort[ i ] = j;
          j+=7;
       };

       return;
   }

   // Иранский 1400 байпас коррозионник
   base_sens_count = FIRST_SENSLINE_SIZE - 288;
   ext_sens_count = MAGN_SENSORS - 96;
   internal_cirkle_counter=0;

   i=0;
   while (1)
   {
      for (internal_cirkle_counter=0; internal_cirkle_counter<12; internal_cirkle_counter++)
      {
         sens_sort[base_sens_count] =  i;
         base_sens_count++;
         if (base_sens_count >= FIRST_SENSLINE_SIZE) base_sens_count = 0;
         i++;
         if (i>=MAGN_SENSORS) break;
      };
      if (i>=MAGN_SENSORS) break;

      for (internal_cirkle_counter=0; internal_cirkle_counter<4; internal_cirkle_counter++)
      {
         sens_sort[ext_sens_count] =  i;
         ext_sens_count++;
         if (ext_sens_count >= MAGN_SENSORS) ext_sens_count = FIRST_SENSLINE_SIZE;
         i++;
         if (i>=MAGN_SENSORS) break;

      };
      if (i>=MAGN_SENSORS) break;

   };

}; // void create_sens_sort ( long *sens_sort)

void create_sens_shift ( long *sens_shift)
{

      (void) sens_shift;

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // Новый 1400 КРОТ М байпас NANO_512
      if (strncmp(target_name, "14060201",8)==0)
      {
          ODOMETER_STEP = 3; // 3.012 

          Orientation_dAy_value =  485.851;
          Orientation_KAy_value =  240.036;
          Orientation_dAz_value =  515.089;
          Orientation_KAz_value =  240.889;

          Orientation_shift_direct = 0;

          Orientation_shift_group_1 = 21;
          Orientation_shift_group_2 = -10;

          return KRT_OK;
      }

      // Иран 1400 корозионник NANO_512
      if (strncmp(target_name, "14060101",8)==0)
      {
          Orientation_dAy_value =  498.735;
          Orientation_KAy_value = -242.739;
          Orientation_dAz_value =  517.002;
          Orientation_KAz_value = -241.523;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 = -204;
          Orientation_shift_group_2 = -152;

          ODOMETER_STEP = 5;

          return KRT_OK;
      }

      // Старый 1400 корозионник с блоком NANO_512
      if (strncmp(target_name, "14050102", 8)==0)
      {
          ODOMETER_STEP = 3; // 3.012 

          Orientation_dAy_value =  501.378;
          Orientation_KAy_value = -242.622;
          Orientation_dAz_value =  504.002;
          Orientation_KAz_value = -241.001;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 = 621;
          Orientation_shift_group_2 = 162;

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


