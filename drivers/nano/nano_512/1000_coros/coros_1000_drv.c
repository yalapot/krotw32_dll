#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          768
#define FIRST_SENSLINE_SIZE   512
#define THECOND_SENSLINE_SIZE 256
#define GROUP_NUM_IN_DEVICE   2

#define MAX_DATA_CODE         3993

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-511,512-767"
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
   long i;

   long base_sens_count = 0;
   long ext_sens_count = FIRST_SENSLINE_SIZE;
   long internal_cirkle_counter=0;

   long tmp_sens_sort[MAGN_SENSORS];

   // 1000_cor_nano512_tolst_sten
   if  ( strncmp(Target_name_driver, "10060101", 8) == 0)
   {
       i=0;
       while (1)
       {
          internal_cirkle_counter=0;
          for (; internal_cirkle_counter < 8; internal_cirkle_counter++)
          {
             sens_sort[base_sens_count] =  i;
             i++;
             base_sens_count++;
             if (i>=MAGN_SENSORS) break;

          };
          if (i>=MAGN_SENSORS) break;

          for (; internal_cirkle_counter < 12; internal_cirkle_counter++)
          {
             sens_sort[ext_sens_count] =  i;
             i++;
             ext_sens_count++;
             if (i>=MAGN_SENSORS) break;
          };
          if (i>=MAGN_SENSORS) break;
       };


       memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

       for(i = 0; i < 128; i++)
       {
           sens_sort[128 * 1 + i] = tmp_sens_sort[128 * 2 + i];
           sens_sort[128 * 2 + i] = tmp_sens_sort[128 * 3 + i];
           sens_sort[128 * 3 + i] = tmp_sens_sort[128 * 1 + i];
       }

       for(i = 0; i < 64; i++)
       {
           sens_sort[FIRST_SENSLINE_SIZE + 64 * 1 + i] = tmp_sens_sort[FIRST_SENSLINE_SIZE + 64 * 2 + i];
           sens_sort[FIRST_SENSLINE_SIZE + 64 * 2 + i] = tmp_sens_sort[FIRST_SENSLINE_SIZE + 64 * 3 + i];
           sens_sort[FIRST_SENSLINE_SIZE + 64 * 3 + i] = tmp_sens_sort[FIRST_SENSLINE_SIZE + 64 * 1 + i];
       }

       return;
   };

   // 1000_cor_nano512_baypas
   if  ( strncmp(Target_name_driver, "10070101", 8) == 0)
   {
       i=0;
       while (1)
       {
          internal_cirkle_counter=0;
          for (; internal_cirkle_counter < 8; internal_cirkle_counter++)
          {
             sens_sort[base_sens_count] =  i;
             i++;
             base_sens_count++;
             if (i>=MAGN_SENSORS) break;

          };
          if (i>=MAGN_SENSORS) break;

          for (; internal_cirkle_counter < 12; internal_cirkle_counter++)
          {
             sens_sort[ext_sens_count] =  i;
             i++;
             ext_sens_count++;
             if (i>=MAGN_SENSORS) break;
          };
          if (i>=MAGN_SENSORS) break;
       };


       memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

       for(i = 0; i < 128; i++)
       {
           sens_sort[128 * 0 + i] = tmp_sens_sort[128 * 3 + i];
           sens_sort[128 * 1 + i] = tmp_sens_sort[128 * 0 + i];
           sens_sort[128 * 2 + i] = tmp_sens_sort[128 * 1 + i];
           sens_sort[128 * 3 + i] = tmp_sens_sort[128 * 2 + i];
       }

       for(i = 0; i < 64; i++)
       {
           sens_sort[FIRST_SENSLINE_SIZE + 64 * 0 + i] = tmp_sens_sort[FIRST_SENSLINE_SIZE + 64 * 3 + i];
           sens_sort[FIRST_SENSLINE_SIZE + 64 * 1 + i] = tmp_sens_sort[FIRST_SENSLINE_SIZE + 64 * 0 + i];
           sens_sort[FIRST_SENSLINE_SIZE + 64 * 2 + i] = tmp_sens_sort[FIRST_SENSLINE_SIZE + 64 * 1 + i];
           sens_sort[FIRST_SENSLINE_SIZE + 64 * 3 + i] = tmp_sens_sort[FIRST_SENSLINE_SIZE + 64 * 2 + i];
       }

       return;
   };


   base_sens_count = 8;
   ext_sens_count = FIRST_SENSLINE_SIZE;
   internal_cirkle_counter=0;

   i=8;
   while (1)
   {
      for (internal_cirkle_counter=0; internal_cirkle_counter<8; internal_cirkle_counter++)
      {
         sens_sort[ext_sens_count] =  i;
         i++;
         ext_sens_count++;
         if (i>=MAGN_SENSORS) break;

      };
      if (i>=MAGN_SENSORS) break;

      for (internal_cirkle_counter=0; internal_cirkle_counter<16; internal_cirkle_counter++)
      {
         sens_sort[base_sens_count] =  i;
         i++;
         base_sens_count++;
         if (i>=MAGN_SENSORS) break;
      };
      if (i>=MAGN_SENSORS) break;
   };

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
    int i;

    for (i=512; i<768; i++)
    {
       sens_shift[i] = 4;
    }
}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
                                  
       // 1000_cor_nano512_bypas
      if  ( strncmp(target_name, "10070101", 8)==0 )
      {
          Orientation_dAy_value =  468.079;
          Orientation_KAy_value =  241.938;
          Orientation_dAz_value =  504.826;
          Orientation_KAz_value = -242.759;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 =  -309;
          Orientation_shift_group_2 =  -102;

          Odometer_0_sens_value = 47;
          Odometer_1_sens_value = 303;

          return KRT_OK;
      }

      // 1000_cor_nano512_tolst_sten
      if  ( strncmp(target_name, "10060101", 8)==0 )
      {
          Orientation_dAy_value =  477.005;
          Orientation_KAy_value = -242.949;
          Orientation_dAz_value =  510.007;
          Orientation_KAz_value = -238.535;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 =  235;
          Orientation_shift_group_2 =  140;

          return KRT_OK;
      }

      if  ( strncmp(target_name, "10050101", 8)==0  ||
            strcmp(target_name, "Nano512")==0
          )
      {
          Orientation_dAy_value =  661.911;
          Orientation_KAy_value = -238.692;
          Orientation_dAz_value =  379.039;
          Orientation_KAz_value = -245.42 ;

          Orientation_shift_group_1 = 300;
          Orientation_shift_group_2 = 106;

          return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник 1000 (Nano512)","Драйвер Коррозионник 1000 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   // 1000_cor_nano512 first nano 512
   if  ( strncmp(Target_name_driver, "10050101", 8) ==0 )
   {
       return (adc * 3300 / 256 - 250) / 28; // AD22103
   }

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

