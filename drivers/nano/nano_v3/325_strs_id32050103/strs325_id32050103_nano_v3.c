#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>
#include <krotnano_v3.h>
#include <tracetool.h>


#define THIS_PROFIL           0
#define PROFIL_MM_SHIFT_UP    0
#define PROFIL_MM_INVERSE     0
#define PROFIL_SENS_IS_ENCODER 0
#define PROFIL_ROW_INVERSE     0

#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

#define _TRACE_STEP_           5

#define MAGN_SENSORS          192
#define FIRST_SENSLINE_SIZE   192
#define THECOND_SENSLINE_SIZE  0
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         4095

// это калибровка для ID 3205010340
double Orient_dAy_value =     510.409;
double Orient_KAy_value =    -240.232;
double Orient_dAz_value =     507.826;
double Orient_KAz_value =     244.713;

int Orientation_shift_direct = 1;

int Orientation_shift_value   = -72;
int Orientation_shift_2_value = 0;

#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0
#define Invert_sens_string  "0-191"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = 192;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

void create_sens_sort ( long *sens_sort)
{

    sens_sort[0]= 96 ;
    sens_sort[1]= 97 ;
    sens_sort[2]= 98 ;
    sens_sort[3]= 99 ;
    sens_sort[4]= 100;
    sens_sort[5]= 101;
    sens_sort[6]= 102;
    sens_sort[7]= 103;
    sens_sort[8]= 104;
    sens_sort[9]= 105;
    sens_sort[10]=106;
    sens_sort[11]=107;
    sens_sort[12]=108;
    sens_sort[13]=109;
    sens_sort[14]=110;
    sens_sort[15]=111;
    sens_sort[16]=112;
    sens_sort[17]=113;
    sens_sort[18]=114;
    sens_sort[19]=115;
    sens_sort[20]=116;
    sens_sort[21]=117;
    sens_sort[22]=118;
    sens_sort[23]=119;
    sens_sort[24]=120;
    sens_sort[25]=121;
    sens_sort[26]=122;
    sens_sort[27]=123;
    sens_sort[28]=124;
    sens_sort[29]=125;
    sens_sort[30]=126;
    sens_sort[31]=127;
    sens_sort[32]=128;
    sens_sort[33]=129;
    sens_sort[34]=130;
    sens_sort[35]=131;
    sens_sort[36]=132;
    sens_sort[37]=133;
    sens_sort[38]=134;
    sens_sort[39]=135;
    sens_sort[40]=136;
    sens_sort[41]=137;
    sens_sort[42]=138;
    sens_sort[43]=139;
    sens_sort[44]=140;
    sens_sort[45]=141;
    sens_sort[46]=142;
    sens_sort[47]=143;
    sens_sort[48]=48 ;
    sens_sort[49]=49 ;
    sens_sort[50]=50 ;
    sens_sort[51]=51 ;
    sens_sort[52]=52 ;
    sens_sort[53]=53 ;
    sens_sort[54]=54 ;
    sens_sort[55]=55 ;
    sens_sort[56]=56 ;
    sens_sort[57]=57 ;
    sens_sort[58]=58 ;
    sens_sort[59]=59 ;
    sens_sort[60]=60 ;
    sens_sort[61]=61 ;
    sens_sort[62]=62 ;
    sens_sort[63]=63 ;
    sens_sort[64]=64 ;
    sens_sort[65]=65 ;
    sens_sort[66]=66 ;
    sens_sort[67]=67 ;
    sens_sort[68]=68 ;
    sens_sort[69]=69 ;
    sens_sort[70]=70 ;
    sens_sort[71]=71 ;
    sens_sort[72]=72 ;
    sens_sort[73]=73 ;
    sens_sort[74]=74 ;
    sens_sort[75]=75 ;
    sens_sort[76]=76 ;
    sens_sort[77]=77 ;
    sens_sort[78]=78 ;
    sens_sort[79]=79 ;
    sens_sort[80]=80 ;
    sens_sort[81]=81 ;
    sens_sort[82]=82 ;
    sens_sort[83]=83 ;
    sens_sort[84]=84 ;
    sens_sort[85]=85 ;
    sens_sort[86]=86 ;
    sens_sort[87]=87 ;
    sens_sort[88]=88 ;
    sens_sort[89]=89 ;
    sens_sort[90]=90 ;
    sens_sort[91]=91 ;
    sens_sort[92]=92 ;
    sens_sort[93]=93 ;
    sens_sort[94]=94 ;
    sens_sort[95]=95 ;
    sens_sort[96]= 144;
    sens_sort[97]= 145;
    sens_sort[98]= 146;
    sens_sort[99]= 147;
    sens_sort[100]=148;
    sens_sort[101]=149;
    sens_sort[102]=150;
    sens_sort[103]=151;
    sens_sort[104]=152;
    sens_sort[105]=153;
    sens_sort[106]=154;
    sens_sort[107]=155;
    sens_sort[108]=156;
    sens_sort[109]=157;
    sens_sort[110]=158;
    sens_sort[111]=159;
    sens_sort[112]=160;
    sens_sort[113]=161;
    sens_sort[114]=162;
    sens_sort[115]=163;
    sens_sort[116]=164;
    sens_sort[117]=165;
    sens_sort[118]=166;
    sens_sort[119]=167;
    sens_sort[120]=168;
    sens_sort[121]=169;
    sens_sort[122]=170;
    sens_sort[123]=171;
    sens_sort[124]=172;
    sens_sort[125]=173;
    sens_sort[126]=174;
    sens_sort[127]=175;
    sens_sort[128]=176;
    sens_sort[129]=177;
    sens_sort[130]=178;
    sens_sort[131]=179;
    sens_sort[132]=180;
    sens_sort[133]=181;
    sens_sort[134]=182;
    sens_sort[135]=183;
    sens_sort[136]=184;
    sens_sort[137]=185;
    sens_sort[138]=186;
    sens_sort[139]=187;
    sens_sort[140]=188;
    sens_sort[141]=189;
    sens_sort[142]=190;
    sens_sort[143]=191;
    sens_sort[144]=0  ;
    sens_sort[145]=1  ;
    sens_sort[146]=2  ;
    sens_sort[147]=3  ;
    sens_sort[148]=4  ;
    sens_sort[149]=5  ;
    sens_sort[150]=6  ;
    sens_sort[151]=7  ;
    sens_sort[152]=8  ;
    sens_sort[153]=9  ;
    sens_sort[154]=10 ;
    sens_sort[155]=11 ;
    sens_sort[156]=12 ;
    sens_sort[157]=13 ;
    sens_sort[158]=14 ;
    sens_sort[159]=15 ;
    sens_sort[160]=16 ;
    sens_sort[161]=17 ;
    sens_sort[162]=18 ;
    sens_sort[163]=19 ;
    sens_sort[164]=20 ;
    sens_sort[165]=21 ;
    sens_sort[166]=22 ;
    sens_sort[167]=23 ;
    sens_sort[168]=24 ;
    sens_sort[169]=25 ;
    sens_sort[170]=26 ;
    sens_sort[171]=27 ;
    sens_sort[172]=28 ;
    sens_sort[173]=29 ;
    sens_sort[174]=30 ;
    sens_sort[175]=31 ;
    sens_sort[176]=32 ;
    sens_sort[177]=33 ;
    sens_sort[178]=34 ;
    sens_sort[179]=35 ;
    sens_sort[180]=36 ;
    sens_sort[181]=37 ;
    sens_sort[182]=38 ;
    sens_sort[183]=39 ;
    sens_sort[184]=40 ;
    sens_sort[185]=41 ;
    sens_sort[186]=42 ;
    sens_sort[187]=43 ;
    sens_sort[188]=44 ;
    sens_sort[189]=45 ;
    sens_sort[190]=46 ;
    sens_sort[191]=47 ;
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   for (i=0; i<48; i++) {
       sens_shift[i + 48*1] = 180; // смещение назад в измерениях
       sens_shift[i + 48*3] = 180; // смещение назад в измерениях
   };

}

long Calculate_profil_mm(long src_data, long prof_sens_num, T_OPENED_TRACE *P_trace)
{
   (void) src_data;
   (void) prof_sens_num;
   (void) P_trace;

   return 0;
};


long check_file_ID(char* target_name)
{
      if  ( strncmp(target_name, "32050103", 8)==0 )
      {
         return KRT_OK;
      }

      if  ( strncmp(target_name, "32150103", 8)==0 )
      {

         Orient_dAy_value =     510.409;
         Orient_KAy_value =    -240.232;
         Orient_dAz_value =     507.826;
         Orient_KAz_value =     244.713;

         Orientation_shift_direct = 1; 
                                       
         Orientation_shift_value   = -67;
         Orientation_shift_2_value = 0;

         return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер стресс 325 id 32050103 (Nano v3)","Драйвер Стресс-коррозионник 325 (Nano v3)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;
}

long calc_termo(long adc)
{

   // 325_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_v1_v3.c>


