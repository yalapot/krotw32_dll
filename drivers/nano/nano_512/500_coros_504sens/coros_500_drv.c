#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

long ODOMETER_STEP = 4;

#define MAGN_SENSORS          504
#define FIRST_SENSLINE_SIZE   360
#define THECOND_SENSLINE_SIZE 144
#define GROUP_NUM_IN_DEVICE   2

#define MAX_DATA_CODE         3943

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-503"
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


   i=0;
   while (1)
   {
      for (internal_cirkle_counter=0; internal_cirkle_counter<10; internal_cirkle_counter++)
      {
         sens_sort[base_sens_count] =  i;
         i++;
         base_sens_count++;
         if (i>=MAGN_SENSORS) break;
      };
      if (i>=MAGN_SENSORS) break;

      for (internal_cirkle_counter=0; internal_cirkle_counter<4; internal_cirkle_counter++)
      {
         sens_sort[ext_sens_count] =  i;
         i++;
         ext_sens_count++;
         if (i>=MAGN_SENSORS) break;

      };
      if (i>=MAGN_SENSORS) break;

   };


}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
 long i;

 long curent_shift = 5;

  for (i=0; i<FIRST_SENSLINE_SIZE; i+=2) {
     curent_shift --;
     sens_shift[i  ] = curent_shift + 5; // +5 это смещение ко второму поясу
     sens_shift[i+1] = curent_shift + 5; 
     if ( curent_shift == 0) curent_shift =5;
  };

  for (i=FIRST_SENSLINE_SIZE; i<MAGN_SENSORS; i+=4) {

     sens_shift[i  ]=13;
     sens_shift[i+1]=13;
     sens_shift[i+2]=0;
     sens_shift[i+3]=0;

  }

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
                                  
      if  ( strncmp(target_name, "53000102", 8)==0 )
      {
          Orientation_dAy_value =  499.104;
          Orientation_KAy_value =  242.897;
          Orientation_dAz_value =  516.893;
          Orientation_KAz_value =  241.893;

          Orientation_shift_direct = 0;

          Orientation_shift_group_1 =  -70;
          Orientation_shift_group_2 =  -31;

          return KRT_OK;
      }


      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник 500 (Nano512)","Драйвер Коррозионник 1000 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

