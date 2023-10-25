#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <krtapi.h>


#define THIS_STRESS           0
#define THIS_INTROSCOPE       1

long ODOMETER_STEP = 5;

#define MAGN_SENSORS          704
#define FIRST_SENSLINE_SIZE   256
#define THECOND_SENSLINE_SIZE 448
#define GROUP_NUM_IN_DEVICE   2

#define MAX_DATA_CODE         3993

#define Delete_sens_string  ""
#define Deleted_sens_num    0

#define Invert_sens_string  "0-255"
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

   long tmp_sort[1024];

   // меняем порядок датчиков в ласте
   for (lasta_count = 0; lasta_count < FIRST_SENSLINE_SIZE; lasta_count += 8)
   {
       for (sens_count = 0; sens_count < 8 / 2; sens_count ++)
       {
          tmp_val = sens_sort[lasta_count + sens_count];
          sens_sort[lasta_count + sens_count] = sens_sort[lasta_count + 7 - sens_count];
          sens_sort[lasta_count + 7 - sens_count] = tmp_val;
       }
   }

   sens_sort[32]=71;
   sens_sort[33]=70;
   sens_sort[34]=69;
   sens_sort[35]=68;
   sens_sort[36]=67;
   sens_sort[37]=66;
   sens_sort[38]=65;
   sens_sort[39]=64;
   sens_sort[40]=79;
   sens_sort[41]=78;
   sens_sort[42]=77;
   sens_sort[43]=76;
   sens_sort[44]=75;
   sens_sort[45]=74;
   sens_sort[46]=73;
   sens_sort[47]=72;
   sens_sort[48]=87;
   sens_sort[49]=86;
   sens_sort[50]=85;
   sens_sort[51]=84;
   sens_sort[52]=83;
   sens_sort[53]=82;
   sens_sort[54]=81;
   sens_sort[55]=80;
   sens_sort[56]=95;
   sens_sort[57]=94;
   sens_sort[58]=93;
   sens_sort[59]=92;
   sens_sort[60]=91;
   sens_sort[61]=90;
   sens_sort[62]=89;
   sens_sort[63]=88;

   sens_sort[64]=39;
   sens_sort[65]=38;
   sens_sort[66]=37;
   sens_sort[67]=36;
   sens_sort[68]=35;
   sens_sort[69]=34;
   sens_sort[70]=33;
   sens_sort[71]=32;
   sens_sort[72]=47;
   sens_sort[73]=46;
   sens_sort[74]=45;
   sens_sort[75]=44;
   sens_sort[76]=43;
   sens_sort[77]=42;
   sens_sort[78]=41;
   sens_sort[79]=40;
   sens_sort[80]=55;
   sens_sort[81]=54;
   sens_sort[82]=53;
   sens_sort[83]=52;
   sens_sort[84]=51;
   sens_sort[85]=50;
   sens_sort[86]=49;
   sens_sort[87]=48;
   sens_sort[88]=63;
   sens_sort[89]=62;
   sens_sort[90]=61;
   sens_sort[91]=60;
   sens_sort[92]=59;
   sens_sort[93]=58;
   sens_sort[94]=57;
   sens_sort[95]=56;


   // второй пояс двинем на 256 датчиков покругу чтоб ласта отмаркированная первой стала первой на развертке
   for ( sens_count = 0; sens_count < THECOND_SENSLINE_SIZE; sens_count++)
   {
       tmp_val = sens_count - 256;
       if ( tmp_val < 0) tmp_val += THECOND_SENSLINE_SIZE;

       tmp_val += FIRST_SENSLINE_SIZE;

       sens_sort[tmp_val] = sens_count + FIRST_SENSLINE_SIZE;
   }

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   for(i = FIRST_SENSLINE_SIZE; i < MAGN_SENSORS; i++)
   {
      sens_shift[i] = 336;
   }


   for (i=FIRST_SENSLINE_SIZE; i<MAGN_SENSORS; i+=16)
   {
       sens_shift[i+ 8] += 8;
       sens_shift[i+ 9] += 8;
       sens_shift[i+10] += 8;
       sens_shift[i+11] += 8;
       sens_shift[i+12] += 8;
       sens_shift[i+13] += 8;
       sens_shift[i+14] += 8;
       sens_shift[i+15] += 8;
   }

}

long check_file_ID(char* target_name)
{
      strncpy(Target_name_driver, target_name, 31);
                                  
      if  ( strncmp(target_name, "72000102", 8)==0 )
      {
          Orientation_dAy_value =  509.802;
          Orientation_KAy_value = -242.900;
          Orientation_dAz_value =  531.039;
          Orientation_KAz_value = -239.801;

          Orientation_shift_direct = 1;

          Orientation_shift_group_1 =   72;
          Orientation_shift_group_2 =  -40;

          Odometer_0_sens_value = 107;
          Odometer_1_sens_value = 235;

          return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Коррозионник id 72000102 (Nano512)","Драйвер Коррозионник 700 (Nano512)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;

     // сравнить MAGN_SENSORS и file_head.magn_sensors_num !!!!!!!!!!!!!
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}



#include <nano_512_drv.c>

