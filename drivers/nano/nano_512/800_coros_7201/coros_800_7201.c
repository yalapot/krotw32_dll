#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       1

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          1024
#define FIRST_SENSLINE_SIZE   512
#define THECOND_SENSLINE_SIZE 512
#define GROUP_NUM_IN_DEVICE   2

#define MAX_DATA_CODE         3943

#define Delete_sens_string   "96-127,208-223,352-383,464-479"

// Это сколько датчиков удалено из ПЕРВОГО! пояса
#define Deleted_sens_num      96

#define Invert_sens_string  "0-511"
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

    sens_sort[992 ] = 960;
    sens_sort[993 ] = 961;
    sens_sort[994 ] = 962;
    sens_sort[995 ] = 963;
    sens_sort[996 ] = 964;
    sens_sort[997 ] = 965;
    sens_sort[998 ] = 966;
    sens_sort[999 ] = 967;
    sens_sort[1000] = 968;
    sens_sort[1001] = 969;
    sens_sort[1002] = 970;
    sens_sort[1003] = 971;
    sens_sort[1004] = 972;
    sens_sort[1005] = 973;
    sens_sort[1006] = 974;
    sens_sort[1007] = 975;
    sens_sort[1008] = 976;
    sens_sort[1009] = 977;
    sens_sort[1010] = 978;
    sens_sort[1011] = 979;
    sens_sort[1012] = 980;
    sens_sort[1013] = 981;
    sens_sort[1014] = 982;
    sens_sort[1015] = 983;
    sens_sort[1016] = 984;
    sens_sort[1017] = 985;
    sens_sort[1018] = 986;
    sens_sort[1019] = 987;
    sens_sort[1020] = 988;
    sens_sort[1021] = 989;
    sens_sort[1022] = 990;
    sens_sort[1023] = 991;
                    
    sens_sort[960] =  992;
    sens_sort[961] =  993;
    sens_sort[962] =  994;
    sens_sort[963] =  995;
    sens_sort[964] =  996;
    sens_sort[965] =  997;
    sens_sort[966] =  998;
    sens_sort[967] =  999;
    sens_sort[968] = 1000;
    sens_sort[969] = 1001;
    sens_sort[970] = 1002;
    sens_sort[971] = 1003;
    sens_sort[972] = 1004;
    sens_sort[973] = 1005;
    sens_sort[974] = 1006;
    sens_sort[975] = 1007;
    sens_sort[976] = 1008;
    sens_sort[977] = 1009;
    sens_sort[978] = 1010;
    sens_sort[979] = 1011;
    sens_sort[980] = 1012;
    sens_sort[981] = 1013;
    sens_sort[982] = 1014;
    sens_sort[983] = 1015;
    sens_sort[984] = 1016;
    sens_sort[985] = 1017;
    sens_sort[986] = 1018;
    sens_sort[987] = 1019;
    sens_sort[988] = 1020;
    sens_sort[989] = 1021;
    sens_sort[990] = 1022;
    sens_sort[991] = 1023;

}; // void create_sens_sort[ ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{


   long i;

   for(i = FIRST_SENSLINE_SIZE; i < MAGN_SENSORS; i++)
   {
      sens_shift[i] = 206; // 368; //294;
   }

   for (i=FIRST_SENSLINE_SIZE; i<MAGN_SENSORS; i+=8)
   {
       sens_shift[i+ 0] += 7; //8;
       sens_shift[i+ 1] += 7; //8;
       sens_shift[i+ 2] += 7; //8;
       sens_shift[i+ 3] += 7; //8;
   }

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
                                  
      if  ( strncmp(target_name, "82010101", 8)==0 )
      {
          Orientation_dAy_value =  527.244;
          Orientation_KAy_value = -240.344;
          Orientation_dAz_value =  509.793;
          Orientation_KAz_value =  240.825;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 = -9;
          Orientation_shift_group_2 = 145;

          Odometer_0_sens_value = 412;
          Odometer_1_sens_value = 204;

          return KRT_OK;
      }


      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник 700 (Nano512)","Драйвер Коррозионник 700 (832 датчика)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

