#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>


#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 3;

#define MAGN_SENSORS          960
#define FIRST_SENSLINE_SIZE   960
#define THECOND_SENSLINE_SIZE 0
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-959"
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

   long base_sens_count = 0;
   long internal_cirkle_counter=0;
   long outernal_cirkle_counter=0;
   long sector_counter = 0;

   long tmp_sens_sort[MAGN_SENSORS];

   if (strncmp(Target_name_driver, "14110201", 8)==0)
   {
       memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

       for(i = 0; i < 120; i++)
       {
           sens_sort[120 * 0 + i] = tmp_sens_sort[120 * 0 + i];
           sens_sort[120 * 2 + i] = tmp_sens_sort[120 * 1 + i];
           sens_sort[120 * 4 + i] = tmp_sens_sort[120 * 2 + i];
           sens_sort[120 * 6 + i] = tmp_sens_sort[120 * 3 + i];
           sens_sort[120 * 3 + i] = tmp_sens_sort[120 * 4 + i];
           sens_sort[120 * 5 + i] = tmp_sens_sort[120 * 5 + i];
           sens_sort[120 * 7 + i] = tmp_sens_sort[120 * 6 + i];
           sens_sort[120 * 1 + i] = tmp_sens_sort[120 * 7 + i];
       }

       return;
   }


   while (1)
   {
      base_sens_count = (120 * sector_counter) + 96;
      sector_counter++;

      for (outernal_cirkle_counter=0; outernal_cirkle_counter < 5; outernal_cirkle_counter++)
      {

          for (internal_cirkle_counter=0; internal_cirkle_counter < 24; internal_cirkle_counter++)
          {
             sens_sort[i] =  base_sens_count + internal_cirkle_counter;
             i++;

             if (i>=MAGN_SENSORS) break;
          }
          if (i>=MAGN_SENSORS) break;

          base_sens_count-=24;

      }

      if (i>=MAGN_SENSORS) break;
   }

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   for(i = 0; i < 120; i++)
   {
       sens_sort[120 * 6 + i] = tmp_sens_sort[120 * 0 + i];
       sens_sort[120 * 0 + i] = tmp_sens_sort[120 * 1 + i];
       sens_sort[120 * 2 + i] = tmp_sens_sort[120 * 2 + i];
       sens_sort[120 * 4 + i] = tmp_sens_sort[120 * 3 + i];
       sens_sort[120 * 1 + i] = tmp_sens_sort[120 * 4 + i];
       sens_sort[120 * 3 + i] = tmp_sens_sort[120 * 5 + i];
       sens_sort[120 * 5 + i] = tmp_sens_sort[120 * 6 + i];
       sens_sort[120 * 7 + i] = tmp_sens_sort[120 * 7 + i];
   }

   // Старый 1400 стресс с блоком NANO_512
   if (strncmp(Target_name_driver, "14100102", 8)==0)
   {
/*
       memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

       base_sens_count = 0;
       while (base_sens_count < MAGN_SENSORS)
       {
           for(i = 0; i < 12; i++)
           {
               sens_sort[base_sens_count + i] = tmp_sens_sort[base_sens_count + 11 - i];
           }
           base_sens_count += 12;
       }

       memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

       for(i = 0; i < 120; i++)
       {
           sens_sort[120 * 6 + i] = tmp_sens_sort[120 * 0 + i];
           sens_sort[120 * 1 + i] = tmp_sens_sort[120 * 1 + i];
           sens_sort[120 * 0 + i] = tmp_sens_sort[120 * 2 + i];
           sens_sort[120 * 3 + i] = tmp_sens_sort[120 * 3 + i];
           sens_sort[120 * 2 + i] = tmp_sens_sort[120 * 4 + i];
           sens_sort[120 * 5 + i] = tmp_sens_sort[120 * 5 + i];
           sens_sort[120 * 4 + i] = tmp_sens_sort[120 * 6 + i];
           sens_sort[120 * 7 + i] = tmp_sens_sort[120 * 7 + i];
       }
*/
   }

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{

   long i;
   
   if (strncmp(Target_name_driver, "14110101", 8)==0)
   {

       for (i=0; i < MAGN_SENSORS/8; i++) {
          sens_shift[i + 120 * 0 ] = 423;
          sens_shift[i + 120 * 2 ] = 423;
          sens_shift[i + 120 * 4 ] = 423;
          sens_shift[i + 120 * 6 ] = 423;
       };

       return;
   }

   if (strncmp(Target_name_driver, "14110201", 8)==0)
   {

       for (i=0; i < MAGN_SENSORS/8; i++) {
          sens_shift[i + 120 * 0 ] = 698; //423;
          sens_shift[i + 120 * 2 ] = 698; //423;
          sens_shift[i + 120 * 4 ] = 698; //423;
          sens_shift[i + 120 * 6 ] = 698; //423;
       };

       return;
   }

   if (strncmp(Target_name_driver, "14100102", 8)==0)
   {

       // смещение четных секторов
       for (i=0; i < MAGN_SENSORS/8; i++) {
          sens_shift[i + 120 * 0 ] = 707;
          sens_shift[i + 120 * 2 ] = 707;
          sens_shift[i + 120 * 4 ] = 707;
          sens_shift[i + 120 * 6 ] = 707;
       };

/*
       // смещение нечетных секторов
       for (i=0; i < MAGN_SENSORS/8; i++) {
          sens_shift[i + 120 * 1 ] = 427;
          sens_shift[i + 120 * 3 ] = 427;
          sens_shift[i + 120 * 5 ] = 427;
          sens_shift[i + 120 * 7 ] = 427;
       };
*/
       return;
   }

       for (i=0; i < MAGN_SENSORS/8; i++) {
          sens_shift[i + 120 * 0 ] = 427;
          sens_shift[i + 120 * 2 ] = 427;
          sens_shift[i + 120 * 4 ] = 427;
          sens_shift[i + 120 * 6 ] = 427;
       };
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);

      // стресс 1400 M NANO_512
      if (strncmp(target_name, "14110201", 8)==0)
      {
          ODOMETER_STEP = 3; // 3.012 

          Orientation_dAy_value =  507.769;
          Orientation_KAy_value =  242.007;
          Orientation_dAz_value =  518.216;
          Orientation_KAz_value =  239.409;

          Orientation_shift_group_1 = -300;
          Orientation_shift_group_2 = 0;

          Odometer_0_sens_value = 929;
          Odometer_1_sens_value = 423;

          return KRT_OK;

      } 

      // Новый 1400 стресс NANO_512
      if (strncmp(target_name, "14110101", 8)==0)
      {
          ODOMETER_STEP = 5;

          Orientation_dAy_value =  509.396;
          Orientation_KAy_value =  240.409;
          Orientation_dAz_value =  495.1  ;
          Orientation_KAz_value = -241.099;

          Orientation_shift_group_1 = 425;
          Orientation_shift_group_2 =   0;

          return KRT_OK;

      } 

      // Старый 1400 стресс с блоком NANO_512
      if (strncmp(target_name, "14100102", 8)==0)
      {
          ODOMETER_STEP = 3; // 3.012 

          Orientation_dAy_value =  507.983;
          Orientation_KAy_value = -246.910;
          Orientation_dAz_value =  476.968;
          Orientation_KAz_value = -239.062;

          Orientation_shift_direct = 0;

          Orientation_shift_group_1 = -60;
          Orientation_shift_group_2 = 0;

          Odometer_0_sens_value =  89;
          Odometer_1_sens_value = 569;

          return KRT_OK;

      } 

      // 1400 стресс с блоком NANO_512 (настройки по умолчанию)
      if (strncmp(target_name, "141", 3)==0)
      {
          ODOMETER_STEP = 5;

          Orientation_dAy_value =  488.9796;
          Orientation_KAy_value = -243.363 ;
          Orientation_dAz_value =  524.997 ;
          Orientation_KAz_value = -240.996 ;

          Orientation_shift_group_1 = 0;
          Orientation_shift_group_2 = 0;

          return KRT_OK;

      } 

     MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер СК 1400 (Nano512)","драйвер СК 1400 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
     return KRT_ERR;
}

long calc_termo(long adc)
{
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_512_drv.c>


