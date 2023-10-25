// krotepro.c - драйвер epro_drv.
// Объявление глобальных данных и тела инструментальных функций драйвера
// просмотра данных електронного блока "epro" программой KrotW32
//

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include "krtapi.h"
#include "krotepro.h"
#include "libdafil.h"
#include "heapinsp.h"

//////////////////////////////////////////////////////////////////////////
// Глобальные данные драйвера
//////////////////////////////////////////////////////////////////////////

char drvError[1024];

T_TRACE_LIST trace_list[MAX_TRACE];
long open_trace_counter;

char warnString[4096];
char *traceFile;


//////////////////////////////////////////////////////////////////////////
// Закончились глобальные данные драйвера
//////////////////////////////////////////////////////////////////////////

/* Функция инициализации сегмента данных драйвера */
void WINAPI initTraces(void) {
  open_trace_counter=0;
  strcpy(drvError, "");
};

void trcWarn(char *trcFile) {
  static int warnCount=0;
  char itemName[12];

  warnCount++;
  sprintf(itemName, "Warn%06d", warnCount);
  WritePrivateProfileString(EPRO_SECTION, itemName, warnString, trcFile);
}


long WINAPI set_sens_sort_144 (T_OPENED_TRACE * opened_trace) {

  long i, j;

   // ----------- первый сектор
   // последние (восьмые) датчики в каждой ласте 1 сектора
   opened_trace->sens_sort[0] = 7 ;
   opened_trace->sens_sort[1] = 15;
   opened_trace->sens_sort[2] = 23;
   opened_trace->sens_sort[3] = 31;
   opened_trace->sens_sort[4] = 39;
   opened_trace->sens_sort[5] = 47;
   opened_trace->sens_sort[6] = 55;
   opened_trace->sens_sort[7] = 63;
   opened_trace->sens_sort[8] = 71;

   // первые датчики в каждой ласте 1 сектора
   opened_trace->sens_sort[9 ] = 0 ;
   opened_trace->sens_sort[10] = 8 ;
   opened_trace->sens_sort[11] = 16;
   opened_trace->sens_sort[12] = 24;
   opened_trace->sens_sort[13] = 32;
   opened_trace->sens_sort[14] = 40;
   opened_trace->sens_sort[15] = 48;
   opened_trace->sens_sort[16] = 56;
   opened_trace->sens_sort[17] = 64;

   // вторые датчики в каждой ласте 1 сектора
   opened_trace->sens_sort[18] = 1 ;
   opened_trace->sens_sort[19] = 9 ;
   opened_trace->sens_sort[20] = 17;
   opened_trace->sens_sort[21] = 25;
   opened_trace->sens_sort[22] = 33;
   opened_trace->sens_sort[23] = 41;
   opened_trace->sens_sort[24] = 49;
   opened_trace->sens_sort[25] = 57;
   opened_trace->sens_sort[26] = 65;

   // третьи датчики в каждой ласте 1 сектора
   opened_trace->sens_sort[27] = 2 ;
   opened_trace->sens_sort[28] = 10;
   opened_trace->sens_sort[29] = 18;
   opened_trace->sens_sort[30] = 26;
   opened_trace->sens_sort[31] = 34;
   opened_trace->sens_sort[32] = 42;
   opened_trace->sens_sort[33] = 50;
   opened_trace->sens_sort[34] = 58;
   opened_trace->sens_sort[35] = 66;

   // четвертые датчики в каждой ласте 1 сектора
   opened_trace->sens_sort[36] = 3 ;
   opened_trace->sens_sort[37] = 11;
   opened_trace->sens_sort[38] = 19;
   opened_trace->sens_sort[39] = 27;
   opened_trace->sens_sort[40] = 35;
   opened_trace->sens_sort[41] = 43;
   opened_trace->sens_sort[42] = 51;
   opened_trace->sens_sort[43] = 59;
   opened_trace->sens_sort[44] = 67;

   // пятые датчики в каждой ласте 1 сектора
   opened_trace->sens_sort[45] = 4 ;
   opened_trace->sens_sort[46] = 12;
   opened_trace->sens_sort[47] = 20;
   opened_trace->sens_sort[48] = 28;
   opened_trace->sens_sort[49] = 36;
   opened_trace->sens_sort[50] = 44;
   opened_trace->sens_sort[51] = 52;
   opened_trace->sens_sort[52] = 60;
   opened_trace->sens_sort[53] = 68;

   // шестые датчики в каждой ласте 1 сектора
   opened_trace->sens_sort[54] = 5 ;
   opened_trace->sens_sort[55] = 13;
   opened_trace->sens_sort[56] = 21;
   opened_trace->sens_sort[57] = 29;
   opened_trace->sens_sort[58] = 37;
   opened_trace->sens_sort[59] = 45;
   opened_trace->sens_sort[60] = 53;
   opened_trace->sens_sort[61] = 61;
   opened_trace->sens_sort[62] = 69;

   // седьмые датчики в каждой ласте 1 сектора
   opened_trace->sens_sort[63] = 6 ;
   opened_trace->sens_sort[64] = 14;
   opened_trace->sens_sort[65] = 22;
   opened_trace->sens_sort[66] = 30;
   opened_trace->sens_sort[67] = 38;
   opened_trace->sens_sort[68] = 46;
   opened_trace->sens_sort[69] = 54;
   opened_trace->sens_sort[70] = 62;
   opened_trace->sens_sort[71] = 70;


   opened_trace->sens_shift[0] = 1;
   opened_trace->sens_shift[1] = 1;
   opened_trace->sens_shift[2] = 1;
   opened_trace->sens_shift[3] = 1;
   opened_trace->sens_shift[4] = 1;
   opened_trace->sens_shift[5] = 1;
   opened_trace->sens_shift[6] = 1;
   opened_trace->sens_shift[7] = 1;

   // Размножим сортировочные данные первого сектора на все датчики
   for (j=1; j<opened_trace->sektors_num; j++) {
      for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
          opened_trace->sens_sort[i+j*opened_trace->sens_num_in_sektor] = 
              opened_trace->sens_sort[i]+j*opened_trace->sens_num_in_sektor;
       };
    };
   // Размножили сортировочные данные первого сектора на все датчики

   return KRT_OK;
}; //long WINAPI set_sens_sort_144 (T_OPENED_TRACE * opened_trace) {

long WINAPI set_sens_sort_384 (T_OPENED_TRACE * opened_trace) {

   // ----------- первый сектор
   opened_trace->sens_sort[ 6] =  5;  
   opened_trace->sens_sort[ 7] = 11;  
   opened_trace->sens_sort[ 4] = 17;  
   opened_trace->sens_sort[ 5] = 23;  
   opened_trace->sens_sort[ 2] = 29;  
   opened_trace->sens_sort[ 3] = 35;  
   opened_trace->sens_sort[ 0] = 41;  
   opened_trace->sens_sort[ 1] = 47;

   opened_trace->sens_sort[14] = 53;  
   opened_trace->sens_sort[15] = 59;  
   opened_trace->sens_sort[12] = 65;  
   opened_trace->sens_sort[13] = 71;  
   opened_trace->sens_sort[10] = 77;  
   opened_trace->sens_sort[11] = 83;  
   opened_trace->sens_sort[ 8] = 89;  
   opened_trace->sens_sort[ 9] = 95;  
                                      
   opened_trace->sens_sort[22] =  0;  
   opened_trace->sens_sort[23] =  6;  
   opened_trace->sens_sort[20] = 12;  
   opened_trace->sens_sort[21] = 18;  
   opened_trace->sens_sort[18] = 24;  
   opened_trace->sens_sort[19] = 30;  
   opened_trace->sens_sort[16] = 36;  
   opened_trace->sens_sort[17] = 42;  
                                      
   opened_trace->sens_sort[30] = 48;  
   opened_trace->sens_sort[31] = 54;  
   opened_trace->sens_sort[28] = 60;  
   opened_trace->sens_sort[29] = 66;  
   opened_trace->sens_sort[26] = 72;  
   opened_trace->sens_sort[27] = 78;  
   opened_trace->sens_sort[24] = 84;  
   opened_trace->sens_sort[25] = 90;  
                                      
   opened_trace->sens_sort[38] =  1;  
   opened_trace->sens_sort[39] =  7;  
   opened_trace->sens_sort[36] = 13;  
   opened_trace->sens_sort[37] = 19;  
   opened_trace->sens_sort[34] = 25;  
   opened_trace->sens_sort[35] = 31;  
   opened_trace->sens_sort[32] = 37;  
   opened_trace->sens_sort[33] = 43;  
                                      
   opened_trace->sens_sort[46] = 49;  
   opened_trace->sens_sort[47] = 55;  
   opened_trace->sens_sort[44] = 61;  
   opened_trace->sens_sort[45] = 67;  
   opened_trace->sens_sort[42] = 73;  
   opened_trace->sens_sort[43] = 79;  
   opened_trace->sens_sort[40] = 85;  
   opened_trace->sens_sort[41] = 91;  
                                      
   opened_trace->sens_sort[54] =  2;  
   opened_trace->sens_sort[55] =  8;  
   opened_trace->sens_sort[52] = 14;  
   opened_trace->sens_sort[53] = 20;  
   opened_trace->sens_sort[50] = 26;  
   opened_trace->sens_sort[51] = 32;  
   opened_trace->sens_sort[48] = 38;  
   opened_trace->sens_sort[49] = 44;  
                                      
   opened_trace->sens_sort[62] = 50;  
   opened_trace->sens_sort[63] = 56;  
   opened_trace->sens_sort[60] = 62;  
   opened_trace->sens_sort[61] = 68;  
   opened_trace->sens_sort[58] = 74;  
   opened_trace->sens_sort[59] = 80;  
   opened_trace->sens_sort[56] = 86;  
   opened_trace->sens_sort[57] = 92;  
                                      
   opened_trace->sens_sort[70] =  3;  
   opened_trace->sens_sort[71] =  9;  
   opened_trace->sens_sort[68] = 15;  
   opened_trace->sens_sort[69] = 21;  
   opened_trace->sens_sort[66] = 27;  
   opened_trace->sens_sort[67] = 33;  
   opened_trace->sens_sort[64] = 39;  
   opened_trace->sens_sort[65] = 45;  
                                      
   opened_trace->sens_sort[78] = 51;  
   opened_trace->sens_sort[79] = 57;  
   opened_trace->sens_sort[76] = 63;  
   opened_trace->sens_sort[77] = 69;  
   opened_trace->sens_sort[74] = 75;  
   opened_trace->sens_sort[75] = 81;  
   opened_trace->sens_sort[72] = 87;  
   opened_trace->sens_sort[73] = 93;  
                                      
   opened_trace->sens_sort[86] =  4;  
   opened_trace->sens_sort[87] = 10;  
   opened_trace->sens_sort[84] = 16;  
   opened_trace->sens_sort[85] = 22;  
   opened_trace->sens_sort[82] = 28;  
   opened_trace->sens_sort[83] = 34;  
   opened_trace->sens_sort[80] = 40;  
   opened_trace->sens_sort[81] = 46;  
                                      
   opened_trace->sens_sort[94] = 52;  
   opened_trace->sens_sort[95] = 58;  
   opened_trace->sens_sort[92] = 64;  
   opened_trace->sens_sort[93] = 70;  
   opened_trace->sens_sort[90] = 76;  
   opened_trace->sens_sort[91] = 82;  
   opened_trace->sens_sort[88] = 88;  
   opened_trace->sens_sort[89] = 94;  
                                                 
   // ----------- второй сектор 
   opened_trace->sens_sort[ 96] = 101;
   opened_trace->sens_sort[ 97] = 107;
   opened_trace->sens_sort[ 98] = 113;
   opened_trace->sens_sort[ 99] = 119;
   opened_trace->sens_sort[100] = 125;
   opened_trace->sens_sort[101] = 131;
   opened_trace->sens_sort[102] = 137;
   opened_trace->sens_sort[103] = 143;
                                      
   opened_trace->sens_sort[104] = 149;
   opened_trace->sens_sort[105] = 155;
   opened_trace->sens_sort[106] = 161;
   opened_trace->sens_sort[107] = 167;
   opened_trace->sens_sort[108] = 173;
   opened_trace->sens_sort[109] = 179;
   opened_trace->sens_sort[110] = 185;
   opened_trace->sens_sort[111] = 191;
                                      
   opened_trace->sens_sort[112] =  96;
   opened_trace->sens_sort[113] = 102;
   opened_trace->sens_sort[114] = 108;
   opened_trace->sens_sort[115] = 114;
   opened_trace->sens_sort[116] = 120;
   opened_trace->sens_sort[117] = 126;
   opened_trace->sens_sort[118] = 132;
   opened_trace->sens_sort[119] = 138;
                                      
   opened_trace->sens_sort[120] = 144;
   opened_trace->sens_sort[121] = 150;
   opened_trace->sens_sort[122] = 156;
   opened_trace->sens_sort[123] = 162;
   opened_trace->sens_sort[124] = 168;
   opened_trace->sens_sort[125] = 174;
   opened_trace->sens_sort[126] = 180;
   opened_trace->sens_sort[127] = 186;
                                      
   opened_trace->sens_sort[128] =  97;
   opened_trace->sens_sort[129] = 103;
   opened_trace->sens_sort[130] = 109;
   opened_trace->sens_sort[131] = 115;
   opened_trace->sens_sort[132] = 121;
   opened_trace->sens_sort[133] = 127;
   opened_trace->sens_sort[134] = 133;
   opened_trace->sens_sort[135] = 139;
                                      
   opened_trace->sens_sort[136] = 145;
   opened_trace->sens_sort[137] = 151;
   opened_trace->sens_sort[138] = 157;
   opened_trace->sens_sort[139] = 163;
   opened_trace->sens_sort[140] = 169;
   opened_trace->sens_sort[141] = 175;
   opened_trace->sens_sort[142] = 181;
   opened_trace->sens_sort[143] = 187;
                                      
   opened_trace->sens_sort[144] =  98;
   opened_trace->sens_sort[145] = 104;
   opened_trace->sens_sort[146] = 110;
   opened_trace->sens_sort[147] = 116;
   opened_trace->sens_sort[148] = 122;
   opened_trace->sens_sort[149] = 128;
   opened_trace->sens_sort[150] = 134;
   opened_trace->sens_sort[151] = 140;
                                      
   opened_trace->sens_sort[152] = 146;
   opened_trace->sens_sort[153] = 152;
   opened_trace->sens_sort[154] = 158;
   opened_trace->sens_sort[155] = 164;
   opened_trace->sens_sort[156] = 170;
   opened_trace->sens_sort[157] = 176;
   opened_trace->sens_sort[158] = 182;
   opened_trace->sens_sort[159] = 188;
                                      
   opened_trace->sens_sort[160] =  99;
   opened_trace->sens_sort[161] = 105;
   opened_trace->sens_sort[162] = 111;
   opened_trace->sens_sort[163] = 117;
   opened_trace->sens_sort[164] = 123;
   opened_trace->sens_sort[165] = 129;
   opened_trace->sens_sort[166] = 135;
   opened_trace->sens_sort[167] = 141;
                                      
   opened_trace->sens_sort[168] = 147;
   opened_trace->sens_sort[169] = 153;
   opened_trace->sens_sort[170] = 159;
   opened_trace->sens_sort[171] = 165;
   opened_trace->sens_sort[172] = 171;
   opened_trace->sens_sort[173] = 177;
   opened_trace->sens_sort[174] = 183;
   opened_trace->sens_sort[175] = 189;
                                      
   opened_trace->sens_sort[176] = 100;
   opened_trace->sens_sort[177] = 106;
   opened_trace->sens_sort[178] = 112;
   opened_trace->sens_sort[179] = 118;
   opened_trace->sens_sort[180] = 124;
   opened_trace->sens_sort[181] = 130;
   opened_trace->sens_sort[182] = 136;
   opened_trace->sens_sort[183] = 142;
                                      
   opened_trace->sens_sort[184] = 148;
   opened_trace->sens_sort[185] = 154;
   opened_trace->sens_sort[186] = 160;
   opened_trace->sens_sort[187] = 166;
   opened_trace->sens_sort[188] = 172;
   opened_trace->sens_sort[189] = 178;
   opened_trace->sens_sort[190] = 184;
   opened_trace->sens_sort[191] = 190;
            
   // ----------- третий сектор 
   opened_trace->sens_sort[192] = 197;
   opened_trace->sens_sort[193] = 203;
   opened_trace->sens_sort[194] = 209;
   opened_trace->sens_sort[195] = 215;
   opened_trace->sens_sort[196] = 221;
   opened_trace->sens_sort[197] = 227;
   opened_trace->sens_sort[198] = 233;
   opened_trace->sens_sort[199] = 239;
                                      
   opened_trace->sens_sort[206] = 245;
   opened_trace->sens_sort[207] = 251;
   opened_trace->sens_sort[204] = 257;
   opened_trace->sens_sort[205] = 263;
   opened_trace->sens_sort[202] = 269;
   opened_trace->sens_sort[203] = 275;
   opened_trace->sens_sort[200] = 281;
   opened_trace->sens_sort[201] = 287;
                                      
   opened_trace->sens_sort[208] = 192;
   opened_trace->sens_sort[209] = 198;
   opened_trace->sens_sort[210] = 204;
   opened_trace->sens_sort[211] = 210;
   opened_trace->sens_sort[212] = 216;
   opened_trace->sens_sort[213] = 222;
   opened_trace->sens_sort[214] = 228;
   opened_trace->sens_sort[215] = 234;
                                      
   opened_trace->sens_sort[222] = 240;
   opened_trace->sens_sort[223] = 246;
   opened_trace->sens_sort[220] = 252;
   opened_trace->sens_sort[221] = 258;
   opened_trace->sens_sort[218] = 264;
   opened_trace->sens_sort[219] = 270;
   opened_trace->sens_sort[216] = 276;
   opened_trace->sens_sort[217] = 282;
                                      
   opened_trace->sens_sort[224] = 193;
   opened_trace->sens_sort[225] = 199;
   opened_trace->sens_sort[226] = 205;
   opened_trace->sens_sort[227] = 211;
   opened_trace->sens_sort[228] = 217;
   opened_trace->sens_sort[229] = 223;
   opened_trace->sens_sort[230] = 229;
   opened_trace->sens_sort[231] = 235;
                                      
   opened_trace->sens_sort[238] = 241;
   opened_trace->sens_sort[239] = 247;
   opened_trace->sens_sort[236] = 253;
   opened_trace->sens_sort[237] = 259;
   opened_trace->sens_sort[234] = 265;
   opened_trace->sens_sort[235] = 271;
   opened_trace->sens_sort[232] = 277;
   opened_trace->sens_sort[233] = 283;
                                      
   opened_trace->sens_sort[240] = 194;
   opened_trace->sens_sort[241] = 200;
   opened_trace->sens_sort[242] = 206;
   opened_trace->sens_sort[243] = 212;
   opened_trace->sens_sort[244] = 218;
   opened_trace->sens_sort[245] = 224;
   opened_trace->sens_sort[246] = 230;
   opened_trace->sens_sort[247] = 236;
                                      
   opened_trace->sens_sort[254] = 242;
   opened_trace->sens_sort[255] = 248;
   opened_trace->sens_sort[252] = 254;
   opened_trace->sens_sort[253] = 260;
   opened_trace->sens_sort[250] = 266;
   opened_trace->sens_sort[251] = 272;
   opened_trace->sens_sort[248] = 278;
   opened_trace->sens_sort[249] = 284;
                                      
   opened_trace->sens_sort[256] = 195;
   opened_trace->sens_sort[257] = 201;
   opened_trace->sens_sort[258] = 207;
   opened_trace->sens_sort[259] = 213;
   opened_trace->sens_sort[260] = 219;
   opened_trace->sens_sort[261] = 225;
   opened_trace->sens_sort[262] = 231;
   opened_trace->sens_sort[263] = 237;
                                      
   opened_trace->sens_sort[270] = 243;
   opened_trace->sens_sort[271] = 249;
   opened_trace->sens_sort[268] = 255;
   opened_trace->sens_sort[269] = 261;
   opened_trace->sens_sort[266] = 267;
   opened_trace->sens_sort[267] = 273;
   opened_trace->sens_sort[264] = 279;
   opened_trace->sens_sort[265] = 285;
                                      
   opened_trace->sens_sort[272] = 196;
   opened_trace->sens_sort[273] = 202;
   opened_trace->sens_sort[274] = 208;
   opened_trace->sens_sort[275] = 214;
   opened_trace->sens_sort[276] = 220;
   opened_trace->sens_sort[277] = 226;
   opened_trace->sens_sort[278] = 232;
   opened_trace->sens_sort[279] = 238;
                                      
   opened_trace->sens_sort[286] = 244;
   opened_trace->sens_sort[287] = 250;
   opened_trace->sens_sort[284] = 256;
   opened_trace->sens_sort[285] = 262;
   opened_trace->sens_sort[282] = 268;
   opened_trace->sens_sort[283] = 274;
   opened_trace->sens_sort[280] = 280;
   opened_trace->sens_sort[281] = 286;
          
          
   // ----------- четвертый сектор 
   opened_trace->sens_sort[294] = 293;
   opened_trace->sens_sort[295] = 299;
   opened_trace->sens_sort[292] = 305;
   opened_trace->sens_sort[293] = 311;
   opened_trace->sens_sort[290] = 317;
   opened_trace->sens_sort[291] = 323;
   opened_trace->sens_sort[288] = 329;
   opened_trace->sens_sort[289] = 335;
                                      
   opened_trace->sens_sort[302] = 341;
   opened_trace->sens_sort[303] = 347;
   opened_trace->sens_sort[300] = 353;
   opened_trace->sens_sort[301] = 359;
   opened_trace->sens_sort[298] = 365;
   opened_trace->sens_sort[299] = 371;
   opened_trace->sens_sort[296] = 377;
   opened_trace->sens_sort[297] = 383;
                                      
   opened_trace->sens_sort[310] = 288;
   opened_trace->sens_sort[311] = 294;
   opened_trace->sens_sort[308] = 300;
   opened_trace->sens_sort[309] = 306;
   opened_trace->sens_sort[306] = 312;
   opened_trace->sens_sort[307] = 318;
   opened_trace->sens_sort[304] = 324;
   opened_trace->sens_sort[305] = 330;
                                      
   opened_trace->sens_sort[318] = 336;
   opened_trace->sens_sort[319] = 342;
   opened_trace->sens_sort[316] = 348;
   opened_trace->sens_sort[317] = 354;
   opened_trace->sens_sort[314] = 360;
   opened_trace->sens_sort[315] = 366;
   opened_trace->sens_sort[312] = 372;
   opened_trace->sens_sort[313] = 378;
                                      
   opened_trace->sens_sort[326] = 289;
   opened_trace->sens_sort[327] = 295;
   opened_trace->sens_sort[324] = 301;
   opened_trace->sens_sort[325] = 307;
   opened_trace->sens_sort[322] = 313;
   opened_trace->sens_sort[323] = 319;
   opened_trace->sens_sort[320] = 325;
   opened_trace->sens_sort[321] = 331;
                                      
   opened_trace->sens_sort[334] = 337;
   opened_trace->sens_sort[335] = 343;
   opened_trace->sens_sort[332] = 349;
   opened_trace->sens_sort[333] = 355;
   opened_trace->sens_sort[330] = 361;
   opened_trace->sens_sort[331] = 367;
   opened_trace->sens_sort[328] = 373;
   opened_trace->sens_sort[329] = 379;
                                      
   opened_trace->sens_sort[342] = 290;
   opened_trace->sens_sort[343] = 296;
   opened_trace->sens_sort[340] = 302;
   opened_trace->sens_sort[341] = 308;
   opened_trace->sens_sort[338] = 314;
   opened_trace->sens_sort[339] = 320;
   opened_trace->sens_sort[336] = 326;
   opened_trace->sens_sort[337] = 332;
                                      
   opened_trace->sens_sort[350] = 338;
   opened_trace->sens_sort[351] = 344;
   opened_trace->sens_sort[348] = 350;
   opened_trace->sens_sort[349] = 356;
   opened_trace->sens_sort[346] = 362;
   opened_trace->sens_sort[347] = 368;
   opened_trace->sens_sort[344] = 374;
   opened_trace->sens_sort[345] = 380;
                                      
   opened_trace->sens_sort[358] = 291;
   opened_trace->sens_sort[359] = 297;
   opened_trace->sens_sort[356] = 303;
   opened_trace->sens_sort[357] = 309;
   opened_trace->sens_sort[354] = 315;
   opened_trace->sens_sort[355] = 321;
   opened_trace->sens_sort[352] = 327;
   opened_trace->sens_sort[353] = 333;
                                      
   opened_trace->sens_sort[366] = 339;
   opened_trace->sens_sort[367] = 345;
   opened_trace->sens_sort[364] = 351;
   opened_trace->sens_sort[365] = 357;
   opened_trace->sens_sort[362] = 363;
   opened_trace->sens_sort[363] = 369;
   opened_trace->sens_sort[360] = 375;
   opened_trace->sens_sort[361] = 381;
                                      
   opened_trace->sens_sort[374] = 292;
   opened_trace->sens_sort[375] = 298;
   opened_trace->sens_sort[372] = 304;
   opened_trace->sens_sort[373] = 310;
   opened_trace->sens_sort[370] = 316;
   opened_trace->sens_sort[371] = 322;
   opened_trace->sens_sort[368] = 328;
   opened_trace->sens_sort[369] = 334;
                                      
   opened_trace->sens_sort[382] = 340;
   opened_trace->sens_sort[383] = 346;
   opened_trace->sens_sort[380] = 352;
   opened_trace->sens_sort[381] = 358;
   opened_trace->sens_sort[378] = 364;
   opened_trace->sens_sort[379] = 370;
   opened_trace->sens_sort[376] = 376;
   opened_trace->sens_sort[377] = 382;


/*
   opened_trace->sens_shift[0] = 1;
   opened_trace->sens_shift[1] = 1;
   opened_trace->sens_shift[2] = 1;
   opened_trace->sens_shift[3] = 1;
   opened_trace->sens_shift[4] = 1;
   opened_trace->sens_shift[5] = 1;
   opened_trace->sens_shift[6] = 1;
   opened_trace->sens_shift[7] = 1;
*/

   return KRT_OK;
}; //long WINAPI set_sens_sort_384 (T_OPENED_TRACE * opened_trace) {



long set_sens_sort_cor700 (T_OPENED_TRACE * opened_trace) {
   long i;

// 1 пояс, 1 ласта
   opened_trace->sens_sort[8 ]  = 135; 
   opened_trace->sens_sort[16]  = 134;
   opened_trace->sens_sort[24]  = 133;
   opened_trace->sens_sort[32]  = 132;
   opened_trace->sens_sort[40]  = 131;
   opened_trace->sens_sort[48]  = 130;
   opened_trace->sens_sort[56]  = 129;
   opened_trace->sens_sort[0 ]  = 128;
             
// 1 пояс, 2 ласта
   opened_trace->sens_sort[9 ]  = 143;
   opened_trace->sens_sort[17]  = 142;
   opened_trace->sens_sort[25]  = 141;
   opened_trace->sens_sort[33]  = 140;
   opened_trace->sens_sort[41]  = 139;
   opened_trace->sens_sort[49]  = 138;
   opened_trace->sens_sort[57]  = 137;
   opened_trace->sens_sort[1 ]  = 136;
             
// 1 пояс, 3 ласта
   opened_trace->sens_sort[10]  = 151;
   opened_trace->sens_sort[18]  = 150;
   opened_trace->sens_sort[26]  = 149;
   opened_trace->sens_sort[34]  = 148;
   opened_trace->sens_sort[42]  = 147;
   opened_trace->sens_sort[50]  = 146;
   opened_trace->sens_sort[58]  = 145;
   opened_trace->sens_sort[2 ]  = 144;
             
// 1 пояс, 4 ласта
   opened_trace->sens_sort[11]  = 159;
   opened_trace->sens_sort[19]  = 158;
   opened_trace->sens_sort[27]  = 157;
   opened_trace->sens_sort[35]  = 156;
   opened_trace->sens_sort[43]  = 155;
   opened_trace->sens_sort[51]  = 154;
   opened_trace->sens_sort[59]  = 153;
   opened_trace->sens_sort[3 ]  = 152;
             
// 1 пояс, 5 ласта
   opened_trace->sens_sort[12]  = 167;
   opened_trace->sens_sort[20]  = 166;
   opened_trace->sens_sort[28]  = 165;
   opened_trace->sens_sort[36]  = 164;
   opened_trace->sens_sort[44]  = 163;
   opened_trace->sens_sort[52]  = 162;
   opened_trace->sens_sort[60]  = 161;
   opened_trace->sens_sort[4 ]  = 160;
             
// 1 пояс, 6 ласта
   opened_trace->sens_sort[13]  = 175;
   opened_trace->sens_sort[21]  = 174;
   opened_trace->sens_sort[29]  = 173;
   opened_trace->sens_sort[37]  = 172;
   opened_trace->sens_sort[45]  = 171;
   opened_trace->sens_sort[53]  = 170;
   opened_trace->sens_sort[61]  = 169;
   opened_trace->sens_sort[5 ]  = 168;
             
// 1 пояс, 7 ласта
   opened_trace->sens_sort[14]  = 183;
   opened_trace->sens_sort[22]  = 182;
   opened_trace->sens_sort[30]  = 181;
   opened_trace->sens_sort[38]  = 180;
   opened_trace->sens_sort[46]  = 179;
   opened_trace->sens_sort[54]  = 178;
   opened_trace->sens_sort[62]  = 177;
   opened_trace->sens_sort[6 ]  = 176;
             
// 1 пояс, 8 ласта
   opened_trace->sens_sort[15]  = 191; 
   opened_trace->sens_sort[23]  = 190;
   opened_trace->sens_sort[31]  = 189;
   opened_trace->sens_sort[39]  = 188;
   opened_trace->sens_sort[47]  = 187;
   opened_trace->sens_sort[55]  = 186;
   opened_trace->sens_sort[63]  = 185;
   opened_trace->sens_sort[7 ]  = 184;
             
             
// 1 пояс, 9 ласта
   opened_trace->sens_sort[72 ] = 199; 
   opened_trace->sens_sort[80 ] = 198;
   opened_trace->sens_sort[88 ] = 197;
   opened_trace->sens_sort[96 ] = 196;
   opened_trace->sens_sort[104] = 195;
   opened_trace->sens_sort[112] = 194;
   opened_trace->sens_sort[120] = 193;
   opened_trace->sens_sort[64 ] = 192;
             
// 1 пояс, 10 ласта
   opened_trace->sens_sort[73 ] = 207;
   opened_trace->sens_sort[81 ] = 206;
   opened_trace->sens_sort[89 ] = 205;
   opened_trace->sens_sort[97 ] = 204;
   opened_trace->sens_sort[105] = 203;
   opened_trace->sens_sort[113] = 202;
   opened_trace->sens_sort[121] = 201;
   opened_trace->sens_sort[65 ] = 200;
             
// 1 пояс, 11 ласта
   opened_trace->sens_sort[74 ] = 215;
   opened_trace->sens_sort[82 ] = 214;
   opened_trace->sens_sort[90 ] = 213;
   opened_trace->sens_sort[98 ] = 212;
   opened_trace->sens_sort[106] = 211;
   opened_trace->sens_sort[114] = 210;
   opened_trace->sens_sort[122] = 209;
   opened_trace->sens_sort[66 ] = 208;
             
// 1 пояс, 12 ласта
   opened_trace->sens_sort[75 ] = 223;
   opened_trace->sens_sort[83 ] = 222;
   opened_trace->sens_sort[91 ] = 221;
   opened_trace->sens_sort[99 ] = 220;
   opened_trace->sens_sort[107] = 219;
   opened_trace->sens_sort[115] = 218;
   opened_trace->sens_sort[123] = 217;
   opened_trace->sens_sort[67 ] = 216;
             
// 1 пояс, 13 ласта
   opened_trace->sens_sort[76 ] = 231;
   opened_trace->sens_sort[84 ] = 230;
   opened_trace->sens_sort[92 ] = 229;
   opened_trace->sens_sort[100] = 228;
   opened_trace->sens_sort[108] = 227;
   opened_trace->sens_sort[116] = 226;
   opened_trace->sens_sort[124] = 225;
   opened_trace->sens_sort[68 ] = 224;
             
// 1 пояс, 14 ласта
   opened_trace->sens_sort[77 ] = 239;
   opened_trace->sens_sort[85 ] = 238;
   opened_trace->sens_sort[93 ] = 237;
   opened_trace->sens_sort[101] = 236;
   opened_trace->sens_sort[109] = 235;
   opened_trace->sens_sort[117] = 234;
   opened_trace->sens_sort[125] = 233;
   opened_trace->sens_sort[69 ] = 232;
             
// 1 пояс, 15 ласта
   opened_trace->sens_sort[78 ] = 247;
   opened_trace->sens_sort[86 ] = 246;
   opened_trace->sens_sort[94 ] = 245;
   opened_trace->sens_sort[102] = 244;
   opened_trace->sens_sort[110] = 243;
   opened_trace->sens_sort[118] = 242;
   opened_trace->sens_sort[126] = 241;
   opened_trace->sens_sort[70 ] = 240;
             
// 1 пояс, 16 ласта
   opened_trace->sens_sort[79 ] = 255;
   opened_trace->sens_sort[87 ] = 254;
   opened_trace->sens_sort[95 ] = 253;
   opened_trace->sens_sort[103] = 252;
   opened_trace->sens_sort[111] = 251;
   opened_trace->sens_sort[119] = 250;
   opened_trace->sens_sort[127] = 249;
   opened_trace->sens_sort[71 ] = 248;


// 1 пояс, 17 ласта
   opened_trace->sens_sort[136] = 7;  
   opened_trace->sens_sort[144] = 6;  
   opened_trace->sens_sort[152] = 5;  
   opened_trace->sens_sort[160] = 4;  
   opened_trace->sens_sort[168] = 3;  
   opened_trace->sens_sort[176] = 2;  
   opened_trace->sens_sort[184] = 1;  
   opened_trace->sens_sort[128] = 0;  
             
// 1 пояс, 18 ласта
   opened_trace->sens_sort[137] = 15; 
   opened_trace->sens_sort[145] = 14; 
   opened_trace->sens_sort[153] = 13; 
   opened_trace->sens_sort[161] = 12; 
   opened_trace->sens_sort[169] = 11; 
   opened_trace->sens_sort[177] = 10; 
   opened_trace->sens_sort[185] = 9 ; 
   opened_trace->sens_sort[129] = 8 ; 
             
// 1 пояс, 19 ласта
   opened_trace->sens_sort[138] = 23; 
   opened_trace->sens_sort[146] = 22; 
   opened_trace->sens_sort[154] = 21; 
   opened_trace->sens_sort[162] = 20; 
   opened_trace->sens_sort[170] = 19; 
   opened_trace->sens_sort[178] = 18; 
   opened_trace->sens_sort[186] = 17; 
   opened_trace->sens_sort[130] = 16; 
             
// 1 пояс, 20 ласта
   opened_trace->sens_sort[139] = 31; 
   opened_trace->sens_sort[147] = 30; 
   opened_trace->sens_sort[155] = 29; 
   opened_trace->sens_sort[163] = 28; 
   opened_trace->sens_sort[171] = 27; 
   opened_trace->sens_sort[179] = 26; 
   opened_trace->sens_sort[187] = 25; 
   opened_trace->sens_sort[131] = 24; 
             
// 1 пояс, 21 ласта
   opened_trace->sens_sort[140] = 39; 
   opened_trace->sens_sort[148] = 38; 
   opened_trace->sens_sort[156] = 37; 
   opened_trace->sens_sort[164] = 36; 
   opened_trace->sens_sort[172] = 35; 
   opened_trace->sens_sort[180] = 34; 
   opened_trace->sens_sort[188] = 33; 
   opened_trace->sens_sort[132] = 32; 
             
// 1 пояс, 22 ласта
   opened_trace->sens_sort[141] = 47; 
   opened_trace->sens_sort[149] = 46; 
   opened_trace->sens_sort[157] = 45; 
   opened_trace->sens_sort[165] = 44; 
   opened_trace->sens_sort[173] = 43; 
   opened_trace->sens_sort[181] = 42; 
   opened_trace->sens_sort[189] = 41; 
   opened_trace->sens_sort[133] = 40; 
             
// 1 пояс, 23 ласта
   opened_trace->sens_sort[142] = 55; 
   opened_trace->sens_sort[150] = 54; 
   opened_trace->sens_sort[158] = 53; 
   opened_trace->sens_sort[166] = 52; 
   opened_trace->sens_sort[174] = 51; 
   opened_trace->sens_sort[182] = 50; 
   opened_trace->sens_sort[190] = 49; 
   opened_trace->sens_sort[134] = 48; 
             
// 1 пояс, 24 ласта
   opened_trace->sens_sort[143] = 63; 
   opened_trace->sens_sort[151] = 62; 
   opened_trace->sens_sort[159] = 61; 
   opened_trace->sens_sort[167] = 60; 
   opened_trace->sens_sort[175] = 59; 
   opened_trace->sens_sort[183] = 58; 
   opened_trace->sens_sort[191] = 57; 
   opened_trace->sens_sort[135] = 56; 
             
             
// 1 пояс, 25 ласта
   opened_trace->sens_sort[200] = 71;  
   opened_trace->sens_sort[208] = 70;  
   opened_trace->sens_sort[216] = 69;  
   opened_trace->sens_sort[224] = 68;  
   opened_trace->sens_sort[232] = 67;  
   opened_trace->sens_sort[240] = 66;  
   opened_trace->sens_sort[248] = 65;  
   opened_trace->sens_sort[192] = 64; 
             
// 1 пояс, 26 ласта
   opened_trace->sens_sort[201] = 79;  
   opened_trace->sens_sort[209] = 78;  
   opened_trace->sens_sort[217] = 77;  
   opened_trace->sens_sort[225] = 76;  
   opened_trace->sens_sort[233] = 75;  
   opened_trace->sens_sort[241] = 74;  
   opened_trace->sens_sort[249] = 73;  
   opened_trace->sens_sort[193] = 72; 
             
// 1 пояс, 27 ласта
   opened_trace->sens_sort[202] = 87;  
   opened_trace->sens_sort[210] = 86;  
   opened_trace->sens_sort[218] = 85;  
   opened_trace->sens_sort[226] = 84;  
   opened_trace->sens_sort[234] = 83;  
   opened_trace->sens_sort[242] = 82;  
   opened_trace->sens_sort[250] = 81;  
   opened_trace->sens_sort[194] = 80; 
             
// 1 пояс, 28 ласта
   opened_trace->sens_sort[203] = 95;  
   opened_trace->sens_sort[211] = 94;  
   opened_trace->sens_sort[219] = 93;  
   opened_trace->sens_sort[227] = 92;  
   opened_trace->sens_sort[235] = 91;  
   opened_trace->sens_sort[243] = 90;  
   opened_trace->sens_sort[251] = 89;  
   opened_trace->sens_sort[195] = 88; 
             
// 1 пояс, 29 ласта
   opened_trace->sens_sort[204] = 103; 
   opened_trace->sens_sort[212] = 102; 
   opened_trace->sens_sort[220] = 101; 
   opened_trace->sens_sort[228] = 100; 
   opened_trace->sens_sort[236] = 99 ; 
   opened_trace->sens_sort[244] = 98 ; 
   opened_trace->sens_sort[252] = 97 ; 
   opened_trace->sens_sort[196] = 96 ; 
             
// 1 пояс, 30 ласта
   opened_trace->sens_sort[205] = 111; 
   opened_trace->sens_sort[213] = 110; 
   opened_trace->sens_sort[221] = 109; 
   opened_trace->sens_sort[229] = 108; 
   opened_trace->sens_sort[237] = 107; 
   opened_trace->sens_sort[245] = 106; 
   opened_trace->sens_sort[253] = 105; 
   opened_trace->sens_sort[197] = 104; 
             
// 1 пояс, 31 ласта
   opened_trace->sens_sort[206] = 119; 
   opened_trace->sens_sort[214] = 118; 
   opened_trace->sens_sort[222] = 117; 
   opened_trace->sens_sort[230] = 116; 
   opened_trace->sens_sort[238] = 115; 
   opened_trace->sens_sort[246] = 114; 
   opened_trace->sens_sort[254] = 113; 
   opened_trace->sens_sort[198] = 112; 
             
// 1 пояс, 32 ласта
   opened_trace->sens_sort[207] = 127; 
   opened_trace->sens_sort[215] = 126; 
   opened_trace->sens_sort[223] = 125; 
   opened_trace->sens_sort[231] = 124; 
   opened_trace->sens_sort[239] = 123; 
   opened_trace->sens_sort[247] = 122; 
   opened_trace->sens_sort[255] = 121; 
   opened_trace->sens_sort[199] = 120; 


// 2 пояс, 1 ласта
   opened_trace->sens_sort[265] = 323;
   opened_trace->sens_sort[273] = 322;
   opened_trace->sens_sort[281] = 321;
   opened_trace->sens_sort[257] = 320;

// 2 пояс, 2 ласта
   opened_trace->sens_sort[264] = 327;
   opened_trace->sens_sort[272] = 326;
   opened_trace->sens_sort[280] = 325;
   opened_trace->sens_sort[256] = 324;
             
// 2 пояс, 3 ласта
   opened_trace->sens_sort[267] = 331;
   opened_trace->sens_sort[275] = 330;
   opened_trace->sens_sort[283] = 329;
   opened_trace->sens_sort[259] = 328;
             
// 2 пояс, 4 ласта
   opened_trace->sens_sort[266] = 335;
   opened_trace->sens_sort[274] = 334;
   opened_trace->sens_sort[282] = 333;
   opened_trace->sens_sort[258] = 332;
             
// 2 пояс, 5 ласта
   opened_trace->sens_sort[269] = 339;
   opened_trace->sens_sort[277] = 338;
   opened_trace->sens_sort[285] = 337;
   opened_trace->sens_sort[261] = 336;
             
// 2 пояс, 6 ласта
   opened_trace->sens_sort[268] = 343;
   opened_trace->sens_sort[276] = 342;
   opened_trace->sens_sort[284] = 341;
   opened_trace->sens_sort[260] = 340;
             
// 2 пояс, 7 ласта
   opened_trace->sens_sort[271] = 347;
   opened_trace->sens_sort[279] = 346;
   opened_trace->sens_sort[287] = 345;
   opened_trace->sens_sort[263] = 344;
             
// 2 пояс, 8 ласта
   opened_trace->sens_sort[270] = 351;
   opened_trace->sens_sort[278] = 350;
   opened_trace->sens_sort[286] = 349;
   opened_trace->sens_sort[262] = 348;
             
// 2 пояс, 9 ласта
   opened_trace->sens_sort[297] = 355;
   opened_trace->sens_sort[305] = 354;
   opened_trace->sens_sort[313] = 353;
   opened_trace->sens_sort[289] = 352;
             
// 2 пояс, 10 ласта
   opened_trace->sens_sort[296] = 359;
   opened_trace->sens_sort[304] = 358;
   opened_trace->sens_sort[312] = 357;
   opened_trace->sens_sort[288] = 356;
             
// 2 пояс, 11 ласта
   opened_trace->sens_sort[299] = 363;
   opened_trace->sens_sort[307] = 362;
   opened_trace->sens_sort[315] = 361;
   opened_trace->sens_sort[291] = 360;
             
// 2 пояс, 12 ласта
   opened_trace->sens_sort[298] = 367;
   opened_trace->sens_sort[306] = 366;
   opened_trace->sens_sort[314] = 365;
   opened_trace->sens_sort[290] = 364;
             
// 2 пояс, 13 ласта
   opened_trace->sens_sort[301] = 371;
   opened_trace->sens_sort[309] = 370;
   opened_trace->sens_sort[317] = 369;
   opened_trace->sens_sort[293] = 368;
             
// 2 пояс, 14 ласта
   opened_trace->sens_sort[300] = 375;
   opened_trace->sens_sort[308] = 374;
   opened_trace->sens_sort[316] = 373;
   opened_trace->sens_sort[292] = 372;
             
// 2 пояс, 15 ласта
   opened_trace->sens_sort[303] = 379;
   opened_trace->sens_sort[311] = 378;
   opened_trace->sens_sort[319] = 377;
   opened_trace->sens_sort[295] = 376;
             
// 2 пояс, 16 ласта
   opened_trace->sens_sort[302] = 383;
   opened_trace->sens_sort[310] = 382;
   opened_trace->sens_sort[318] = 381;
   opened_trace->sens_sort[294] = 380;
             
             
// 2 пояс, 17 ласта
   opened_trace->sens_sort[329] = 259;
   opened_trace->sens_sort[337] = 258;
   opened_trace->sens_sort[345] = 257;
   opened_trace->sens_sort[321] = 256;
             
// 2 пояс, 18 ласта
   opened_trace->sens_sort[328] = 263;
   opened_trace->sens_sort[336] = 262;
   opened_trace->sens_sort[344] = 261;
   opened_trace->sens_sort[320] = 260;
             
// 2 пояс, 19 ласта
   opened_trace->sens_sort[331] = 267;
   opened_trace->sens_sort[339] = 266;
   opened_trace->sens_sort[347] = 265;
   opened_trace->sens_sort[323] = 264;
             
// 2 пояс, 20 ласта
   opened_trace->sens_sort[330] = 271;
   opened_trace->sens_sort[338] = 270;
   opened_trace->sens_sort[346] = 269;
   opened_trace->sens_sort[322] = 268;
             
// 2 пояс, 21 ласта
   opened_trace->sens_sort[333] = 275;
   opened_trace->sens_sort[341] = 274;
   opened_trace->sens_sort[349] = 273;
   opened_trace->sens_sort[325] = 272;
             
// 2 пояс, 22 ласта
   opened_trace->sens_sort[332] = 279;
   opened_trace->sens_sort[340] = 278;
   opened_trace->sens_sort[348] = 277;
   opened_trace->sens_sort[324] = 276;
             
// 2 пояс, 23 ласта
   opened_trace->sens_sort[335] = 283;
   opened_trace->sens_sort[343] = 282;
   opened_trace->sens_sort[351] = 281;
   opened_trace->sens_sort[327] = 280;
             
// 2 пояс, 24 ласта
   opened_trace->sens_sort[334] = 287;
   opened_trace->sens_sort[342] = 286;
   opened_trace->sens_sort[350] = 285;
   opened_trace->sens_sort[326] = 284;
             
// 2 пояс, 25 ласта
   opened_trace->sens_sort[361] = 291;
   opened_trace->sens_sort[369] = 290;
   opened_trace->sens_sort[377] = 289;
   opened_trace->sens_sort[353] = 288;
             
// 2 пояс, 26 ласта
   opened_trace->sens_sort[360] = 295;
   opened_trace->sens_sort[368] = 294;
   opened_trace->sens_sort[376] = 293;
   opened_trace->sens_sort[352] = 292;
             
// 2 пояс, 27 ласта
   opened_trace->sens_sort[363] = 299;
   opened_trace->sens_sort[371] = 298;
   opened_trace->sens_sort[379] = 297;
   opened_trace->sens_sort[355] = 296;
             
// 2 пояс, 28 ласта
   opened_trace->sens_sort[362] = 303;
   opened_trace->sens_sort[370] = 302;
   opened_trace->sens_sort[378] = 301;
   opened_trace->sens_sort[354] = 300;
             
// 2 пояс, 29 ласта
   opened_trace->sens_sort[365] = 307;
   opened_trace->sens_sort[373] = 306;
   opened_trace->sens_sort[381] = 305;
   opened_trace->sens_sort[357] = 304;
             
// 2 пояс, 31 ласта
   opened_trace->sens_sort[364] = 311;
   opened_trace->sens_sort[372] = 310;
   opened_trace->sens_sort[380] = 309;
   opened_trace->sens_sort[356] = 308;
             
// 2 пояс, 30 ласта
   opened_trace->sens_sort[367] = 315;
   opened_trace->sens_sort[375] = 314;
   opened_trace->sens_sort[383] = 313;
   opened_trace->sens_sort[359] = 312;
             
// 2 пояс, 32 ласта
   opened_trace->sens_sort[366] = 319;
   opened_trace->sens_sort[374] = 318;
   opened_trace->sens_sort[382] = 317;
   opened_trace->sens_sort[358] = 316;

// Выставим смещения датчиков
   for (i=0; i<8; i++) opened_trace->sens_shift[i] = 1;

   for (i=64; i<72; i++) opened_trace->sens_shift[i] = 1;

   for (i=128; i<136; i++) opened_trace->sens_shift[i] = 1;

   for (i=192; i<200; i++) opened_trace->sens_shift[i] = 1;

   for (i=256; i<384; i++) opened_trace->sens_shift[i] = 64;

   return KRT_OK;
}; //long set_sens_sort_cor700 (T_OPENED_TRACE * opened_trace) {



long WINAPI set_sens_sort_288 (T_OPENED_TRACE * opened_trace) {
 long i;
 long internal_cirkle_counter;
 long flag_phase;

   internal_cirkle_counter=0;
   flag_phase=1;
   for (i=0; i<96; i++) {
      if (flag_phase) {
          opened_trace->sens_shift[i] = 0;
       } else {
          opened_trace->sens_shift[i] = 10;
       };
      internal_cirkle_counter++;
      if (internal_cirkle_counter>=4) {
         flag_phase= (!flag_phase);
         internal_cirkle_counter=0;
       };
    };

   return KRT_OK;
}; //long WINAPI set_sens_sort_288 (T_OPENED_TRACE * opened_trace) {

long WINAPI set_sens_sort_prof500 (T_OPENED_TRACE * opened_trace) {

      opened_trace->sens_sort[0 ]  = 0 ;
      opened_trace->sens_sort[1 ]  = 1 ;
      opened_trace->sens_sort[2 ]  = 2 ;
      opened_trace->sens_sort[4 ]  = 3 ;
      opened_trace->sens_sort[5 ]  = 4 ;
      opened_trace->sens_sort[6 ]  = 5 ;
      opened_trace->sens_sort[8 ]  = 6 ;
      opened_trace->sens_sort[9 ]  = 7 ;
      opened_trace->sens_sort[10]  = 8 ;
      opened_trace->sens_sort[12]  = 9 ;
      opened_trace->sens_sort[13]  = 10;
      opened_trace->sens_sort[14]  = 11;
      opened_trace->sens_sort[16]  = 12;
      opened_trace->sens_sort[17]  = 13;
      opened_trace->sens_sort[18]  = 14;
      opened_trace->sens_sort[60]  = 15;
      opened_trace->sens_sort[61]  = 16;
      opened_trace->sens_sort[62]  = 17;
      opened_trace->sens_sort[64]  = 18;
      opened_trace->sens_sort[65]  = 19;
      opened_trace->sens_sort[66]  = 20;
      opened_trace->sens_sort[68]  = 21;
      opened_trace->sens_sort[69]  = 22;
      opened_trace->sens_sort[70]  = 23;
      opened_trace->sens_sort[72]  = 24;
      opened_trace->sens_sort[73]  = 25;
      opened_trace->sens_sort[74]  = 26;
      opened_trace->sens_sort[76]  = 27;
      opened_trace->sens_sort[77]  = 28;
      opened_trace->sens_sort[78]  = 29;
      opened_trace->sens_sort[3 ]  = 30;
      opened_trace->sens_sort[7 ]  = 31;
      opened_trace->sens_sort[11]  = 32;
      opened_trace->sens_sort[15]  = 33;
      opened_trace->sens_sort[19]  = 34;
      opened_trace->sens_sort[20]  = 35;
      opened_trace->sens_sort[21]  = 36;
      opened_trace->sens_sort[22]  = 37;
      opened_trace->sens_sort[23]  = 38;
      opened_trace->sens_sort[24]  = 39;
      opened_trace->sens_sort[25]  = 40;
      opened_trace->sens_sort[26]  = 41;
      opened_trace->sens_sort[27]  = 42;
      opened_trace->sens_sort[28]  = 43;
      opened_trace->sens_sort[29]  = 44;
      opened_trace->sens_sort[30]  = 45;
      opened_trace->sens_sort[31]  = 46;
      opened_trace->sens_sort[32]  = 47;
      opened_trace->sens_sort[33]  = 48;
      opened_trace->sens_sort[34]  = 49;
      opened_trace->sens_sort[35]  = 50;
      opened_trace->sens_sort[36]  = 51;
      opened_trace->sens_sort[37]  = 52;
      opened_trace->sens_sort[38]  = 53;
      opened_trace->sens_sort[39]  = 54;
      opened_trace->sens_sort[63]  = 55;
      opened_trace->sens_sort[67]  = 56;
      opened_trace->sens_sort[71]  = 57;
      opened_trace->sens_sort[75]  = 58;
      opened_trace->sens_sort[79]  = 59;
      opened_trace->sens_sort[40]  = 60;
      opened_trace->sens_sort[41]  = 61;
      opened_trace->sens_sort[42]  = 62;
      opened_trace->sens_sort[43]  = 63;
      opened_trace->sens_sort[44]  = 64;
      opened_trace->sens_sort[45]  = 65;
      opened_trace->sens_sort[46]  = 66;
      opened_trace->sens_sort[47]  = 67;
      opened_trace->sens_sort[48]  = 68;
      opened_trace->sens_sort[49]  = 69;
      opened_trace->sens_sort[50]  = 70;
      opened_trace->sens_sort[51]  = 71;
      opened_trace->sens_sort[52]  = 72;
      opened_trace->sens_sort[53]  = 73;
      opened_trace->sens_sort[54]  = 74;
      opened_trace->sens_sort[55]  = 75;
      opened_trace->sens_sort[56]  = 76;
      opened_trace->sens_sort[57]  = 77;
      opened_trace->sens_sort[58]  = 78;
      opened_trace->sens_sort[59]  = 79;

   return KRT_OK;
}; //long WINAPI set_sens_sort_prof500 (T_OPENED_TRACE * opened_trace) {

long WINAPI set_sens_sort_prof700 (T_OPENED_TRACE * opened_trace) {

      opened_trace->sens_sort[0 ]  = 0 ;
      opened_trace->sens_sort[1 ]  = 1 ;
      opened_trace->sens_sort[4 ]  = 2 ;
      opened_trace->sens_sort[5 ]  = 3 ;
      opened_trace->sens_sort[8 ]  = 4 ;
      opened_trace->sens_sort[9 ]  = 5 ;
      opened_trace->sens_sort[12]  = 6 ;
      opened_trace->sens_sort[13]  = 7 ;
      opened_trace->sens_sort[16]  = 8 ;
      opened_trace->sens_sort[17]  = 9 ;
      opened_trace->sens_sort[20]  = 10;
      opened_trace->sens_sort[21]  = 11;
      opened_trace->sens_sort[24]  = 12;
      opened_trace->sens_sort[25]  = 13;
      opened_trace->sens_sort[28]  = 14;
      opened_trace->sens_sort[29]  = 15;
      opened_trace->sens_sort[32]  = 16;
      opened_trace->sens_sort[33]  = 17;
      opened_trace->sens_sort[36]  = 18;
      opened_trace->sens_sort[37]  = 19;

      opened_trace->sens_sort[40]  = 20;
      opened_trace->sens_sort[41]  = 21;
      opened_trace->sens_sort[44]  = 22;
      opened_trace->sens_sort[45]  = 23;
      opened_trace->sens_sort[48]  = 24;
      opened_trace->sens_sort[49]  = 25;
      opened_trace->sens_sort[52]  = 26;
      opened_trace->sens_sort[53]  = 27;
      opened_trace->sens_sort[56]  = 28;
      opened_trace->sens_sort[57]  = 29;
      opened_trace->sens_sort[60]  = 30;
      opened_trace->sens_sort[61]  = 31;
      opened_trace->sens_sort[64]  = 32;
      opened_trace->sens_sort[65]  = 33;
      opened_trace->sens_sort[68]  = 34;
      opened_trace->sens_sort[69]  = 35;
      opened_trace->sens_sort[72]  = 36;
      opened_trace->sens_sort[73]  = 37;
      opened_trace->sens_sort[76]  = 38;
      opened_trace->sens_sort[77]  = 39;


      opened_trace->sens_sort[2 ]  = 40;
      opened_trace->sens_sort[3 ]  = 41;
      opened_trace->sens_sort[6 ]  = 42;
      opened_trace->sens_sort[7 ]  = 43;
      opened_trace->sens_sort[10]  = 44;
      opened_trace->sens_sort[11]  = 45;
      opened_trace->sens_sort[14]  = 46;
      opened_trace->sens_sort[15]  = 47;
      opened_trace->sens_sort[18]  = 48;
      opened_trace->sens_sort[19]  = 49;
      opened_trace->sens_sort[22]  = 50;
      opened_trace->sens_sort[23]  = 51;
      opened_trace->sens_sort[26]  = 52;
      opened_trace->sens_sort[27]  = 53;
      opened_trace->sens_sort[30]  = 54;
      opened_trace->sens_sort[31]  = 55;
      opened_trace->sens_sort[34]  = 56;
      opened_trace->sens_sort[35]  = 57;
      opened_trace->sens_sort[38]  = 58;
      opened_trace->sens_sort[39]  = 59;

      opened_trace->sens_sort[42]  = 60;
      opened_trace->sens_sort[43]  = 61;
      opened_trace->sens_sort[46]  = 62;
      opened_trace->sens_sort[47]  = 63;
      opened_trace->sens_sort[50]  = 64;
      opened_trace->sens_sort[51]  = 65;
      opened_trace->sens_sort[54]  = 66;
      opened_trace->sens_sort[55]  = 67;
      opened_trace->sens_sort[58]  = 68;
      opened_trace->sens_sort[59]  = 69;
      opened_trace->sens_sort[62]  = 70;
      opened_trace->sens_sort[63]  = 71;
      opened_trace->sens_sort[66]  = 72;
      opened_trace->sens_sort[67]  = 73;
      opened_trace->sens_sort[70]  = 74;
      opened_trace->sens_sort[71]  = 75;
      opened_trace->sens_sort[74]  = 76;
      opened_trace->sens_sort[75]  = 77;
      opened_trace->sens_sort[78]  = 78;
      opened_trace->sens_sort[79]  = 79;

   return KRT_OK;
}; //long WINAPI set_sens_sort_prof700 (T_OPENED_TRACE * opened_trace) {

long WINAPI set_sens_sort_STRS_1200 (T_OPENED_TRACE * opened_trace) {
 long i;

   // ----------- первый сектор

   for (i=0; i<72; i++) {
      opened_trace->sens_shift[i] = 70;
    };

   return KRT_OK;
}; //long WINAPI set_sens_sort_STRS_1200 (T_OPENED_TRACE * opened_trace) {

long WINAPI set_sens_sort_STRS_500 (T_OPENED_TRACE * opened_trace) {
 long i,j;
 long internal_cirkle_counter;
 long flag_phase;
 long res, res1;

   internal_cirkle_counter=0;
   flag_phase=1;
   for (i=0; i<144; i++) {
      if (flag_phase) {
          opened_trace->sens_shift[i] = 5;
       } else {
          opened_trace->sens_shift[i] = 0;
       };
      internal_cirkle_counter++;
      if (internal_cirkle_counter>=8) {
         flag_phase= (!flag_phase);
         internal_cirkle_counter=0;
       };
    };

   for (i=144; i<288; i++) {
      if (flag_phase) {
          opened_trace->sens_shift[i] = 103;
       } else {
          opened_trace->sens_shift[i] = 98;
       };
      internal_cirkle_counter++;
      if (internal_cirkle_counter>=8) {
         flag_phase= (!flag_phase);
         internal_cirkle_counter=0;
       };
    };

   for (i=288; i<432; i++) {
      if (flag_phase) {
          opened_trace->sens_shift[i] = 5;
       } else {
          opened_trace->sens_shift[i] = 0;
       };
      internal_cirkle_counter++;
      if (internal_cirkle_counter>=8) {
         flag_phase= (!flag_phase);
         internal_cirkle_counter=0;
       };
    };

   for (i=432; i<576; i++) {
      if (flag_phase) {
          opened_trace->sens_shift[i] = 103;
       } else {
          opened_trace->sens_shift[i] = 98;
       };
      internal_cirkle_counter++;
      if (internal_cirkle_counter>=8) {
         flag_phase= (!flag_phase);
         internal_cirkle_counter=0;
       };
    };

   for (i=0; i<144/8; i++) {
       for (j=0; j<8; j++) {
		  res=i*8+j;
		  res1=i*8+j;  //(7-j);
          opened_trace->sens_sort[res]=res1;

		  res=432+i*8+j;
		  res1=144+i*8+j;  //(7-j);
          opened_trace->sens_sort[res]=res1;

		  res=144+i*8+j;
		  res1=288+i*8+j;  //(7-j);
          opened_trace->sens_sort[res]=res1;

		  res=288+i*8+j;
		  res1=432+i*8+j;  //(7-j);
          opened_trace->sens_sort[res]=res1;
        };
    };

   return KRT_OK;
}; //long WINAPI set_sens_sort_STRS_500 (T_OPENED_TRACE * opened_trace) {


long set_sens_sort_cor_273 (T_OPENED_TRACE * opened_trace) {
 long i;
 long internal_cirkle_counter;
 long flag_phase;

   internal_cirkle_counter=0;
   flag_phase=0;
   for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
      if (flag_phase) {
          opened_trace->sens_shift[i] = 4;
       } else {
          opened_trace->sens_shift[i] = 0;
       };
      internal_cirkle_counter++;
      if (internal_cirkle_counter>=4) {
         flag_phase= (!flag_phase);
         internal_cirkle_counter=0;
       };
    };

   return KRT_OK;
}; // long set_sens_sort_cor_273 (T_OPENED_TRACE * opened_trace) {

long WINAPI set_sens_sort_sit_1000 (T_OPENED_TRACE * opened_trace) {

   opened_trace->sens_sort[0 ]=0  ;
   opened_trace->sens_sort[1 ]=8  ;
   opened_trace->sens_sort[2 ]=16 ;
   opened_trace->sens_sort[3 ]=24 ;
   opened_trace->sens_sort[4 ]=32 ;
   opened_trace->sens_sort[5 ]=40 ;
   opened_trace->sens_sort[6 ]=48 ;
   opened_trace->sens_sort[7 ]=56 ;
   opened_trace->sens_sort[8 ]=64 ;
   opened_trace->sens_sort[9 ]=72 ;
   opened_trace->sens_sort[10]=80 ;
   opened_trace->sens_sort[11]=88 ;
   opened_trace->sens_sort[12]=96 ;
   opened_trace->sens_sort[13]=104;
   opened_trace->sens_sort[14]=112;
   opened_trace->sens_sort[15]=120;

   opened_trace->sens_sort[16]=4  ;
   opened_trace->sens_sort[17]=12 ;
   opened_trace->sens_sort[18]=20 ;
   opened_trace->sens_sort[19]=28 ;
   opened_trace->sens_sort[20]=36 ;
   opened_trace->sens_sort[21]=44 ;
   opened_trace->sens_sort[22]=52 ;
   opened_trace->sens_sort[23]=60 ;
   opened_trace->sens_sort[24]=68 ;
   opened_trace->sens_sort[25]=76 ;
   opened_trace->sens_sort[26]=84 ;
   opened_trace->sens_sort[27]=92 ;
   opened_trace->sens_sort[28]=100;
   opened_trace->sens_sort[29]=108;
   opened_trace->sens_sort[30]=116;
   opened_trace->sens_sort[31]=124;

   opened_trace->sens_sort[32]=1  ;
   opened_trace->sens_sort[33]=9  ;
   opened_trace->sens_sort[34]=17 ;
   opened_trace->sens_sort[35]=25 ;
   opened_trace->sens_sort[36]=33 ;
   opened_trace->sens_sort[37]=41 ;
   opened_trace->sens_sort[38]=49 ;
   opened_trace->sens_sort[39]=57 ;
   opened_trace->sens_sort[40]=65 ;
   opened_trace->sens_sort[41]=73 ;
   opened_trace->sens_sort[42]=81 ;
   opened_trace->sens_sort[43]=89 ;
   opened_trace->sens_sort[44]=97 ;
   opened_trace->sens_sort[45]=105;
   opened_trace->sens_sort[46]=113;
   opened_trace->sens_sort[47]=121;
               
   opened_trace->sens_sort[48]=5  ;
   opened_trace->sens_sort[49]=13 ;
   opened_trace->sens_sort[50]=21 ;
   opened_trace->sens_sort[51]=29 ;
   opened_trace->sens_sort[52]=37 ;
   opened_trace->sens_sort[53]=45 ;
   opened_trace->sens_sort[54]=53 ;
   opened_trace->sens_sort[55]=61 ;
   opened_trace->sens_sort[56]=69 ;
   opened_trace->sens_sort[57]=77 ;
   opened_trace->sens_sort[58]=85 ;
   opened_trace->sens_sort[59]=93 ;
   opened_trace->sens_sort[60]=101;
   opened_trace->sens_sort[61]=109;
   opened_trace->sens_sort[62]=117;
   opened_trace->sens_sort[63]=125;

   opened_trace->sens_sort[64]=2  ;
   opened_trace->sens_sort[65]=10 ; 
   opened_trace->sens_sort[66]=18 ;
   opened_trace->sens_sort[67]=26 ;
   opened_trace->sens_sort[68]=34 ;
   opened_trace->sens_sort[69]=42 ;
   opened_trace->sens_sort[70]=50 ;
   opened_trace->sens_sort[71]=58 ;
   opened_trace->sens_sort[72]=66 ;
   opened_trace->sens_sort[73]=74 ;
   opened_trace->sens_sort[74]=82 ;
   opened_trace->sens_sort[75]=90 ;
   opened_trace->sens_sort[76]=98 ;
   opened_trace->sens_sort[77]=106;
   opened_trace->sens_sort[78]=114;
   opened_trace->sens_sort[79]=122;

   opened_trace->sens_sort[80]=6  ;
   opened_trace->sens_sort[81]=14 ;
   opened_trace->sens_sort[82]=22 ;
   opened_trace->sens_sort[83]=30 ;
   opened_trace->sens_sort[84]=38 ;
   opened_trace->sens_sort[85]=46 ;
   opened_trace->sens_sort[86]=54 ;
   opened_trace->sens_sort[87]=62 ;
   opened_trace->sens_sort[88]=70 ;
   opened_trace->sens_sort[89]=78 ;
   opened_trace->sens_sort[90]=86 ;
   opened_trace->sens_sort[91]=94 ;
   opened_trace->sens_sort[92]=102;
   opened_trace->sens_sort[93]=110;
   opened_trace->sens_sort[94]=118;
   opened_trace->sens_sort[95]=126;

   opened_trace->sens_sort[96 ]=3  ;
   opened_trace->sens_sort[97 ]=11 ;
   opened_trace->sens_sort[98 ]=19 ;
   opened_trace->sens_sort[99 ]=27 ;
   opened_trace->sens_sort[100]=35 ;
   opened_trace->sens_sort[101]=43 ;
   opened_trace->sens_sort[102]=51 ;
   opened_trace->sens_sort[103]=59 ;
   opened_trace->sens_sort[104]=67 ;
   opened_trace->sens_sort[105]=75 ;
   opened_trace->sens_sort[106]=83 ;
   opened_trace->sens_sort[107]=91 ;
   opened_trace->sens_sort[108]=99 ;
   opened_trace->sens_sort[109]=107;
   opened_trace->sens_sort[110]=115;
   opened_trace->sens_sort[111]=123;
                
   opened_trace->sens_sort[112]=7  ;
   opened_trace->sens_sort[113]=15 ;
   opened_trace->sens_sort[114]=23 ;
   opened_trace->sens_sort[115]=31 ;
   opened_trace->sens_sort[116]=39 ;
   opened_trace->sens_sort[117]=47 ;
   opened_trace->sens_sort[118]=55 ;
   opened_trace->sens_sort[119]=63 ;
   opened_trace->sens_sort[120]=71 ;
   opened_trace->sens_sort[121]=79 ;
   opened_trace->sens_sort[122]=87 ;
   opened_trace->sens_sort[123]=95 ;
   opened_trace->sens_sort[124]=103;
   opened_trace->sens_sort[125]=111;
   opened_trace->sens_sort[126]=119;
   opened_trace->sens_sort[127]=127;

   return KRT_OK;
}; //long WINAPI set_sens_sort_sit_1000 (T_OPENED_TRACE * opened_trace) {

long set_sens_sort_stress_700 (T_OPENED_TRACE * opened_trace) {
 long i;

   // меняем местами сектора 2 и 3
   for (i=0; i<128; i++) {
      opened_trace->sens_sort[128+i]=256+i;
      opened_trace->sens_sort[256+i]=128+i;
    };

   // смещение вo 2 и 4 секторах
   for (i=0; i<128; i++) {
      opened_trace->sens_shift[i+128] = 256;
      opened_trace->sens_shift[384+i] = 256;
    };

   return KRT_OK;
}; //long set_sens_sort_stress_700 (T_OPENED_TRACE * opened_trace) {

long set_sens_sort_cor460 (T_OPENED_TRACE * opened_trace) {
 long i;


   opened_trace->sens_sort[288]=303;
   opened_trace->sens_sort[289]=304;
   opened_trace->sens_sort[290]=305;
   opened_trace->sens_sort[291]=306;
   opened_trace->sens_sort[292]=307;
   opened_trace->sens_sort[293]=308;
   opened_trace->sens_sort[294]=309;
   opened_trace->sens_sort[295]=310;
   opened_trace->sens_sort[296]=311;
   opened_trace->sens_sort[297]=312;
   opened_trace->sens_sort[298]=313; 
   opened_trace->sens_sort[299]=314; 
   opened_trace->sens_sort[300]=315;
   opened_trace->sens_sort[301]=316;
   opened_trace->sens_sort[302]=317;
   opened_trace->sens_sort[303]=318;
   opened_trace->sens_sort[304]=319;
   opened_trace->sens_sort[305]=320;
   opened_trace->sens_sort[306]=321;
   opened_trace->sens_sort[307]=322;
   opened_trace->sens_sort[308]=323;
   opened_trace->sens_sort[309]=324;
   opened_trace->sens_sort[310]=325;
   opened_trace->sens_sort[311]=326;
   opened_trace->sens_sort[312]=327;
   opened_trace->sens_sort[313]=328;
   opened_trace->sens_sort[314]=329;
   opened_trace->sens_sort[315]=330;
   opened_trace->sens_sort[316]=331;
   opened_trace->sens_sort[317]=332;
   opened_trace->sens_sort[318]=333;
   opened_trace->sens_sort[319]=334;
   opened_trace->sens_sort[320]=335;
   opened_trace->sens_sort[321]=336;
   opened_trace->sens_sort[322]=337;
   opened_trace->sens_sort[323]=338;
   opened_trace->sens_sort[324]=339;
   opened_trace->sens_sort[325]=340;
   opened_trace->sens_sort[326]=341;
   opened_trace->sens_sort[327]=342;
   opened_trace->sens_sort[328]=343;
   opened_trace->sens_sort[329]=344;
   opened_trace->sens_sort[330]=345;
   opened_trace->sens_sort[331]=346;
   opened_trace->sens_sort[332]=347;
   opened_trace->sens_sort[333]=348;
   opened_trace->sens_sort[334]=349;
   opened_trace->sens_sort[335]=350;
   opened_trace->sens_sort[336]=351;
   opened_trace->sens_sort[337]=352;
   opened_trace->sens_sort[338]=353;
   opened_trace->sens_sort[339]=354;
   opened_trace->sens_sort[340]=355;
   opened_trace->sens_sort[341]=356;
   opened_trace->sens_sort[342]=357;
   opened_trace->sens_sort[343]=358;
   opened_trace->sens_sort[344]=359;
   opened_trace->sens_sort[345]=288;
   opened_trace->sens_sort[346]=289;
   opened_trace->sens_sort[347]=290;
   opened_trace->sens_sort[348]=291;
   opened_trace->sens_sort[349]=292;
   opened_trace->sens_sort[350]=293;
   opened_trace->sens_sort[351]=294;
   opened_trace->sens_sort[352]=295;
   opened_trace->sens_sort[353]=296;
   opened_trace->sens_sort[354]=297;
   opened_trace->sens_sort[355]=298;
   opened_trace->sens_sort[356]=299;
   opened_trace->sens_sort[357]=300;
   opened_trace->sens_sort[358]=301;
   opened_trace->sens_sort[359]=302;

   // смещение в 1 поясе
   for (i=0; i<288; i++) {
      opened_trace->sens_shift[i] = 170;
    };

   return KRT_OK;
}; //long set_sens_sort_cor460 (T_OPENED_TRACE * opened_trace) {


// сортировка и смещение датчиков для корозионника 508 (Иран)
long set_sens_sort_cor_508 (T_OPENED_TRACE * opened_trace) {
 long i;

   // смещение во 2 поясе
   for (i=352; i<528; i++) {
      opened_trace->sens_shift[i] = 170; // смещение назад в измерениях
    };

   return KRT_OK;
}; //long set_sens_sort_cor_508 (T_OPENED_TRACE * opened_trace) {

// сортировка и смещение датчиков для корозионника 426
long set_sens_sort_cor_426 (T_OPENED_TRACE * opened_trace) {
 long i;

   // смещение во 2 поясе
   for (i=0; i<288; i++) {
      opened_trace->sens_shift[i] = 344; // смещение назад в измерениях
    };

   return KRT_OK;
}; //long set_sens_sort_cor_508 (T_OPENED_TRACE * opened_trace) {


// сортировка и смещение датчиков для стресс 1400
long set_sens_sort_stress_1400 (T_OPENED_TRACE * opened_trace) {
 long i, j;

 long tmp_sens_sort[MAX_CORROZION_NUM];

   // меняем местами ласты в парах ласт
   for (i=0; i<40; i++) {
      for (j=0; j<12; j++) {
         tmp_sens_sort[ (i*24) + j      ] = (i*24) + (12+j) ;
         tmp_sens_sort[ (i*24) + (12+j) ] = (i*24) + j      ;
       };
    };

   // ставим 1 сектор на место 1
   for (j=0; j<120; j++) {
       opened_trace->sens_sort[ j ] = tmp_sens_sort[ j ];
    };

   // ставим 5 сектор на место 2
   for (j=0; j<120; j++) {
       opened_trace->sens_sort[ (4*120)+j ] = tmp_sens_sort[ (1*120)+j ];
    };

   // ставим 2 сектор на место 3
   for (j=0; j<120; j++) {
       opened_trace->sens_sort[ (1*120)+j ] = tmp_sens_sort[ (2*120)+j ];
    };

   // ставим 6 сектор на место 4
   for (j=0; j<120; j++) {
       opened_trace->sens_sort[ (5*120)+j ] = tmp_sens_sort[ (3*120)+j ];
    };

   // ставим 3 сектор на место 5
   for (j=0; j<120; j++) {
       opened_trace->sens_sort[ (2*120)+j ] = tmp_sens_sort[ (4*120)+j ];
    };

   // ставим 7 сектор на место 6
   for (j=0; j<120; j++) {
       opened_trace->sens_sort[ (6*120)+j ] = tmp_sens_sort[ (5*120)+j ];
    };

   // ставим 4 сектор на место 7
   for (j=0; j<120; j++) {
       opened_trace->sens_sort[ (3*120)+j ] = tmp_sens_sort[ (6*120)+j ];
    };

   // ставим 8 сектор на место 8
   for (j=0; j<120; j++) {
       opened_trace->sens_sort[ (7*120)+j ] = tmp_sens_sort[ (7*120)+j ];
    };

   // разворачиваем датчики в секторах
   for (i=0; i<8; i++) {
      for (j=0; j<60; j++) {
         tmp_sens_sort[0] = opened_trace->sens_sort[ (i*120) + j ];
         opened_trace->sens_sort[ (i*120) + j ] = 
              opened_trace->sens_sort[ (i*120) + (119 - j) ];
         opened_trace->sens_sort[ (i*120) + (119 - j) ] = tmp_sens_sort[0];
       };
    };

   // смещение во 2 поясе
   for (i=0; i<120; i++) {
      opened_trace->sens_shift[i] = 420; // смещение назад в измерениях
    };

   for (i=240; i<360; i++) {
      opened_trace->sens_shift[i] = 420; // смещение назад в измерениях
    };

   for (i=480; i<600; i++) {
      opened_trace->sens_shift[i] = 420; // смещение назад в измерениях
    };

   for (i=720; i<840; i++) {
      opened_trace->sens_shift[i] = 420; // смещение назад в измерениях
    };

   return KRT_OK;
}; // long set_sens_sort_stress_1400 (T_OPENED_TRACE * opened_trace) {

// сортировка и смещение датчиков для корозионника 1400
long set_sens_sort_coross_1400 (T_OPENED_TRACE * opened_trace) {
 long i, j;


   j = 0;
   for (i=0; i<864; i++) {
      opened_trace->sens_sort[ j ] = i;
      i++; j++;
      opened_trace->sens_sort[ j ] = i;
      i++; j++;
      opened_trace->sens_sort[ j ] = i;
      i++; j++;
      opened_trace->sens_sort[ j ] = i;
      i++; j++;
      opened_trace->sens_sort[ j ] = i;
      i++; j++;
      opened_trace->sens_sort[ j ] = i;
      j+=3;
    };

   j = 6;
   for (i=864; i<1152; i++) {
      opened_trace->sens_sort[ j ] = i;
      i++; j++;
      opened_trace->sens_sort[ j ] = i;
      j+=7;
    };


   return KRT_OK;
}; // long set_sens_sort_coross_1400 (T_OPENED_TRACE * opened_trace) {

// сортировка и смещение датчиков для профиля 1400
long set_sens_sort_prof_1400 (T_OPENED_TRACE * opened_trace) {
 long k, i, j1, j2;


   j1 = 0;
   j2 = 40;

   for (k=0; k<5; k++) {
      for (i=0; i<8; i++) {
         opened_trace->sens_sort[ i+k*16 ] = j1;
         j1++;

         opened_trace->sens_sort[ i+8+k*16 ] = j2;
         j2++;

       };

    };

   j1 = 80;
   j2 = 120;

   for (k=0; k<5; k++) {
      for (i=0; i<8; i++) {
         opened_trace->sens_sort[ 80+i+k*16 ] = j1;
         j1++;

         opened_trace->sens_sort[ 80+i+8+k*16 ] = j2;
         j2++;

       };

    };

   for (i=40; i<80; i++) {
      opened_trace->sens_shift[i] = 200; // смещение назад в измерениях
    };

   for (i=120; i<160; i++) {
      opened_trace->sens_shift[i] = 200; // смещение назад в измерениях
    };

   return KRT_OK;
}; // long set_sens_sort_prof_1400 (T_OPENED_TRACE * opened_trace) {



long set_sens_sort_prof_700 (T_OPENED_TRACE * opened_trace) {

   opened_trace->sens_sort[60]=0 ;
   opened_trace->sens_sort[61]=1 ;
   opened_trace->sens_sort[62]=2 ;
   opened_trace->sens_sort[64]=3 ;
   opened_trace->sens_sort[65]=4 ;
   opened_trace->sens_sort[66]=5 ;
   opened_trace->sens_sort[68]=6 ;
   opened_trace->sens_sort[69]=7 ;
   opened_trace->sens_sort[70]=8 ;
   opened_trace->sens_sort[72]=9 ;
   opened_trace->sens_sort[73]=10;
   opened_trace->sens_sort[74]=11;
   opened_trace->sens_sort[76]=12;
   opened_trace->sens_sort[77]=13;
   opened_trace->sens_sort[78]=14;
   opened_trace->sens_sort[0 ]=15;
   opened_trace->sens_sort[1 ]=16;
   opened_trace->sens_sort[2 ]=17;
   opened_trace->sens_sort[4 ]=18;
   opened_trace->sens_sort[5 ]=19;
   opened_trace->sens_sort[6 ]=20;
   opened_trace->sens_sort[8 ]=21;
   opened_trace->sens_sort[9 ]=22;
   opened_trace->sens_sort[10]=23;
   opened_trace->sens_sort[12]=24;
   opened_trace->sens_sort[13]=25;
   opened_trace->sens_sort[14]=26;
   opened_trace->sens_sort[16]=27;
   opened_trace->sens_sort[17]=28;
   opened_trace->sens_sort[18]=29;
                                 
   opened_trace->sens_sort[40]=30;
   opened_trace->sens_sort[41]=31;
   opened_trace->sens_sort[42]=32;
   opened_trace->sens_sort[43]=33;
   opened_trace->sens_sort[44]=34;
   opened_trace->sens_sort[45]=35;
   opened_trace->sens_sort[46]=36;
   opened_trace->sens_sort[47]=37;
   opened_trace->sens_sort[48]=38;
   opened_trace->sens_sort[49]=39;
   opened_trace->sens_sort[50]=40;
   opened_trace->sens_sort[51]=41;
   opened_trace->sens_sort[52]=42;
   opened_trace->sens_sort[53]=43;
   opened_trace->sens_sort[54]=44;
   opened_trace->sens_sort[55]=45;
   opened_trace->sens_sort[56]=46;
   opened_trace->sens_sort[57]=47;
   opened_trace->sens_sort[58]=48;
   opened_trace->sens_sort[59]=49;
                                 
   opened_trace->sens_sort[20]=50;
   opened_trace->sens_sort[21]=51;
   opened_trace->sens_sort[22]=52;
   opened_trace->sens_sort[23]=53;
   opened_trace->sens_sort[24]=54;
   opened_trace->sens_sort[25]=55;
   opened_trace->sens_sort[26]=56;
   opened_trace->sens_sort[27]=57;
   opened_trace->sens_sort[28]=58;
   opened_trace->sens_sort[29]=59;
   opened_trace->sens_sort[30]=60;
   opened_trace->sens_sort[31]=61;
   opened_trace->sens_sort[32]=62;
   opened_trace->sens_sort[33]=63;
   opened_trace->sens_sort[34]=64;
   opened_trace->sens_sort[35]=65;
   opened_trace->sens_sort[36]=66;
   opened_trace->sens_sort[37]=67;
   opened_trace->sens_sort[38]=68;
   opened_trace->sens_sort[39]=69;
                                 
   opened_trace->sens_sort[63]=70;
   opened_trace->sens_sort[67]=71;
   opened_trace->sens_sort[71]=72;
   opened_trace->sens_sort[75]=73;
   opened_trace->sens_sort[79]=74;
   opened_trace->sens_sort[3 ]=75;
   opened_trace->sens_sort[7 ]=76;
   opened_trace->sens_sort[11]=77;
   opened_trace->sens_sort[15]=78;
   opened_trace->sens_sort[19]=79;
              

   return KRT_OK;
}; // long set_sens_sort_prof_700 (T_OPENED_TRACE * opened_trace) {



long set_sens_sort_cor700m(T_OPENED_TRACE * opened_trace) {
   long i, j;

   long tmp_sens_sort[2048];

   // разворачиваем датчики в ластах
   for (i=0; i<32; i++) {
      for (j=0; j<4; j++) {
         tmp_sens_sort[0] = opened_trace->sens_sort[ (i*8) + j ];

         opened_trace->sens_sort[ (i*8) + j ] = 
              opened_trace->sens_sort[ (i*8) + (7 - j) ];

         opened_trace->sens_sort[ (i*8) + (7 - j) ] = tmp_sens_sort[0];
       };
    };


   return KRT_OK;
}; // set_sens_sort_cor700m(T_OPENED_TRACE * opened_trace)


long WINAPI init_bort_factor_data (T_OPENED_TRACE * opened_trace,
                                   char *target_name,
                                   long file_counter)
 {
   long i,j;
   char key_name[1024];
   char key_value[1024];

   (void) file_counter;

    // проинициализируем данные зависящие от количества датчиков коррозии
   switch (opened_trace->corosion_sens_num) 
    {

     case (144) : {  // вроде как пятисотка

        opened_trace->trace_step = 10;     // шаг опроса 10 мм
        opened_trace->group_num  = 1;      // один пояс

        opened_trace->real_number_sensor_in_group[0]=
        opened_trace->linesense_size[0] =    // единственный пояс
            opened_trace->corosion_sens_num; // включает все датчики

        if (opened_trace->Amplification_Group[0]==0) 
            opened_trace->Amplification_Group[0] = 10;

        opened_trace->sektors_num=2;
        opened_trace->sens_num_in_sektor=72;

        opened_trace->max_data_code=65535;

        opened_trace->orientation_mul_factor = 1.12;
        opened_trace->Orientation_OFF = 0;
        opened_trace->Orinteation_Direct_count=1;
        opened_trace->Orientation_shift=0;
        opened_trace->Orientation_shift_2=0;

        opened_trace->sens_for_thick=0;
        opened_trace->sens_for_thick_count=1;

        // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_NAV_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.mat

        // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_VOG_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.vog

        opened_trace->VOG_koeff_umn=100;
        opened_trace->ACCEL_koeff_umn=1000;

        if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=8;

        // Выставим инвертирование для нужных датчиков
        // (в нашем случае для всех НЕ НАДО)
        if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( opened_trace->invert_sens_data_text, "");

               for (i=0; i<MAX_CORROZION_NUM; i++) {
                  opened_trace->invert_sens_data[i]=0;
                };
             };
         };
        // Выставили инвертирование для нужных датчиков

        // Пропишем в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля
        if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0.002448");   // АЦП Игоря
               WritePrivateProfileString(EPRO_SECTION,
                                         adc2tesla_koef_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
        // Прописали в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля

        set_sens_sort_144(opened_trace);

        break;
      }; //case (144) : {

     case (288) : {  // вроде как новая пятисотка (500 корозионник)

        opened_trace->trace_step = 5;     // шаг опроса 10 мм
        opened_trace->group_num  = 1;      // один пояс

        opened_trace->real_number_sensor_in_group[0]=
        opened_trace->linesense_size[0] =    // единственный пояс
            opened_trace->corosion_sens_num; // включает все датчики

        if (opened_trace->Amplification_Group[0]==0) 
            opened_trace->Amplification_Group[0] = 4;

        opened_trace->sektors_num=3;
        opened_trace->sens_num_in_sektor=96;

        if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

        opened_trace->orientation_mul_factor = 2.28;
        opened_trace->Orientation_OFF = 0;
        opened_trace->Orinteation_Direct_count=1;
        opened_trace->Orientation_shift=53;
        opened_trace->Orientation_shift_2=0;

        opened_trace->sens_for_thick=0;
        opened_trace->sens_for_thick_count=1;

        // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_NAV_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.mat

        // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_VOG_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.vog

        opened_trace->VOG_koeff_umn=100;
        opened_trace->ACCEL_koeff_umn=1000;

        if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=8;

        // Выставим инвертирование для нужных датчиков
        // (в нашем случае для всех НАДО)
        if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( opened_trace->invert_sens_data_text, "0-287");

               for (i=0; i<MAX_CORROZION_NUM; i++) {
                  opened_trace->invert_sens_data[i]=1;
                };
             };
         };
        // Выставили инвертирование для нужных датчиков

        // Пропишем в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля
        if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0.0208896");   // АДУК
               WritePrivateProfileString(EPRO_SECTION,
                                         adc2tesla_koef_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
        // Прописали в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля


        // Выставим удаление для нужных датчиков
        if (GetPrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {

               WritePrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY,
                                         "0-15,32-63,80-111,128-159,176-207,224-255,272-287",
                                         opened_trace->trc_file_name
                                        );

               for (i=0; i<16; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };

               for (i=32; i<64; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };

               for (i=80; i<112; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };

               for (i=128; i<160; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };

               for (i=176; i<208; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };

               for (i=224; i<256; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };

               for (i=272; i<288; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };

             };
         };
        // Выставили удаление для нужных датчиков

        opened_trace->real_number_sensor_in_group[0]=96;

        set_sens_sort_288(opened_trace);

        break;
      }; //case (288) : {

     case (360) : {  // вроде как 460 корозионник
        if (strcmp(target_name, TARGET_NAME_CORROS460)==0) {
            // Значится 460
            opened_trace->trace_step = 5;     // шаг опроса 5 мм
            opened_trace->group_num  = 2;      // два пояс

            opened_trace->real_number_sensor_in_group[0]=
            opened_trace->linesense_size[0] = 288;

            opened_trace->real_number_sensor_in_group[1]=
            opened_trace->linesense_size[1] =  72;

            if (opened_trace->Amplification_Group[0]==0) 
                opened_trace->Amplification_Group[0] = 4;
            if (opened_trace->Amplification_Group[1]==0) 
                opened_trace->Amplification_Group[1] = 4;

            opened_trace->sektors_num=1;
            opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

            if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

            opened_trace->orientation_mul_factor = 2.28;
            opened_trace->Orientation_OFF = 0;
            opened_trace->Orinteation_Direct_count=0;
            opened_trace->Orientation_shift=-50;
            opened_trace->Orientation_shift_2=0;

            opened_trace->sens_for_thick=0;
            opened_trace->sens_for_thick_count=1;

            // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
            if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0");
                   WritePrivateProfileString(EPRO_SECTION,
                                             Get_Orient_from_NAV_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            // Прописали в trc-файл флаг использования ориентации с файла rec.mat

            // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
            if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0");
                   WritePrivateProfileString(EPRO_SECTION,
                                             Get_Orient_from_VOG_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            // Прописали в trc-файл флаг использования ориентации с файла rec.vog


            opened_trace->VOG_koeff_umn=100;
            opened_trace->ACCEL_koeff_umn=1000;

            if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=8;
            if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=8;

            // Выставим инвертирование для нужных датчиков
            // (в нашем случае для всех НАДО)
            if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( opened_trace->invert_sens_data_text, "0-359");

                   for (i=0; i<MAX_CORROZION_NUM; i++) {
                      opened_trace->invert_sens_data[i]=1;
                    };
                 };
             };

            // Выставили инвертирование для нужных датчиков
    
            // Пропишем в trc-файл коэффициент преревода из значений АЦП
            // в милитеслы магнитного поля
            if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0.0208896");   // АДУК
                   WritePrivateProfileString(EPRO_SECTION,
                                             adc2tesla_koef_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
            // Прописали в trc-файл коэффициент преревода из значений АЦП
            // в милитеслы магнитного поля

            set_sens_sort_cor460(opened_trace);

            break;
         };

        // значит неизвестно что, уходим на default
      }; //case (360) : {


     case (384) : {
        if (strcmp(target_name, TARGET_NAME_COR1400sit)==0) {
            // вроде как СИТ 1400
            opened_trace->trace_step = 10;     // шаг опроса 10 мм
            opened_trace->group_num  = 1;      // один пояса

            opened_trace->real_number_sensor_in_group[0]=
            opened_trace->linesense_size[0] = opened_trace->corosion_sens_num; // первый пояс

            opened_trace->Amplification_Group[0] = 10;

            opened_trace->sektors_num=1;
            opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

            opened_trace->max_data_code=65535;

            opened_trace->orientation_mul_factor = 3.02;
            opened_trace->Orientation_OFF = 0;
            opened_trace->Orinteation_Direct_count=0;
            opened_trace->Orientation_shift=110;
            opened_trace->Orientation_shift_2=0;

            opened_trace->sens_for_thick=0;
            opened_trace->sens_for_thick_count=1;

            // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
            if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0");
                   WritePrivateProfileString(EPRO_SECTION,
                                             Get_Orient_from_NAV_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            // Прописали в trc-файл флаг использования ориентации с файла rec.mat

            // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
            if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0");
                   WritePrivateProfileString(EPRO_SECTION,
                                             Get_Orient_from_VOG_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            // Прописали в trc-файл флаг использования ориентации с файла rec.vog

            opened_trace->VOG_koeff_umn=100;
            opened_trace->ACCEL_koeff_umn=1000;

            set_sens_sort_384(opened_trace);
            if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=8;

            // Выставим инвертирование для нужных датчиков
            // (в нашем случае для всех НЕ НАДО)
            if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( opened_trace->invert_sens_data_text, "");

                   for (i=0; i<MAX_CORROZION_NUM; i++) {
                      opened_trace->invert_sens_data[i]=0;
                    };
                 };
             };
            // Выставили инвертирование для нужных датчиков

            // Пропишем в trc-файл коэффициент преревода из значений АЦП
            // в милитеслы магнитного поля
            if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0.002448");   // АЦП Игоря
                   WritePrivateProfileString(EPRO_SECTION,
                                             adc2tesla_koef_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
            // Прописали в trc-файл коэффициент преревода из значений АЦП
            // в милитеслы магнитного поля

            break;
         };

            // значится арабска семисотка
            opened_trace->trace_step = 10;     // шаг опроса 5 мм
            opened_trace->group_num  = 2;      // два пояса

            opened_trace->real_number_sensor_in_group[0]=
            opened_trace->linesense_size[0] = 256; // первый пояс

            opened_trace->real_number_sensor_in_group[1]=
            opened_trace->linesense_size[1] = 128; // второй пояс

            opened_trace->Amplification_Group[0] = 20;
            opened_trace->Amplification_Group[1] = 10;

            opened_trace->sektors_num=1;
            opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

            opened_trace->max_data_code=65535;

            opened_trace->orientation_mul_factor = 2.0;
            opened_trace->Orientation_OFF = 0;
            opened_trace->Orinteation_Direct_count=0;
            opened_trace->Orientation_shift=10;
            opened_trace->Orientation_shift_2=0;

            opened_trace->sens_for_thick=0;
            opened_trace->sens_for_thick_count=1;

            // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
            if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0");
                   WritePrivateProfileString(EPRO_SECTION,
                                             Get_Orient_from_NAV_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            // Прописали в trc-файл флаг использования ориентации с файла rec.mat

            // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
            if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0");
                   WritePrivateProfileString(EPRO_SECTION,
                                             Get_Orient_from_VOG_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            // Прописали в trc-файл флаг использования ориентации с файла rec.vog

            opened_trace->VOG_koeff_umn=100;
            opened_trace->ACCEL_koeff_umn=1000;

            if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;
            if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;

            // Выставим инвертирование для нужных датчиков
            // (в нашем случае для всех НЕ НАДО)
            if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( opened_trace->invert_sens_data_text, "");

                   for (i=0; i<MAX_CORROZION_NUM; i++) {
                      opened_trace->invert_sens_data[i]=0;
                    };
                 };
             };
            // Выставили инвертирование для нужных датчиков

            // Пропишем в trc-файл коэффициент преревода из значений АЦП
            // в милитеслы магнитного поля
            if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0.002448");   // АЦП Игоря
                   WritePrivateProfileString(EPRO_SECTION,
                                             adc2tesla_koef_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
            // Прописали в trc-файл коэффициент преревода из значений АЦП
            // в милитеслы магнитного поля

            set_sens_sort_cor700(opened_trace);

            break;
      }; //case (384) : {

     case (480) : { // вроде как стресс 1000
        opened_trace->trace_step = 10;     // шаг опроса 10 мм
        opened_trace->group_num  = 1;      // один пояс

        opened_trace->real_number_sensor_in_group[0]=
        opened_trace->linesense_size[0] =    // единственный пояс
            opened_trace->corosion_sens_num; // включает все датчики

        opened_trace->Amplification_Group[0] = 10;

        opened_trace->sektors_num=6;
        opened_trace->sens_num_in_sektor=80;

        opened_trace->max_data_code=65535;

        opened_trace->orientation_mul_factor = 3.8;
        opened_trace->Orientation_OFF = 0;
        opened_trace->Orinteation_Direct_count=1;
        opened_trace->Orientation_shift=0;
        opened_trace->Orientation_shift_2=0;

        opened_trace->sens_for_thick=0;
        opened_trace->sens_for_thick_count=1;

        // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_NAV_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.mat

        // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_VOG_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.vog

        opened_trace->VOG_koeff_umn=100;
        opened_trace->ACCEL_koeff_umn=1000;

        if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=8;

        // Выставим инвертирование для нужных датчиков
        // (в нашем случае для всех НЕ НАДО)
        if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( opened_trace->invert_sens_data_text, "");

               for (i=0; i<MAX_CORROZION_NUM; i++) {
                  opened_trace->invert_sens_data[i]=0;
                };
             };
         };
        // Выставили инвертирование для нужных датчиков

        // Пропишем в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля
        if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0.002448");   // АЦП Игоря
               WritePrivateProfileString(EPRO_SECTION,
                                         adc2tesla_koef_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
        // Прописали в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля

        break;
      }; //case (480) : {

     case (80) : { // вроде как профиль 500 или 700

        if (strcmp(target_name, TARGET_NAME_PROFIL700)==0) {
            // Значится профиль 700
            opened_trace->trace_step = 5;     // шаг опроса 10 мм
            opened_trace->group_num  = 2;      // два пояса

            opened_trace->real_number_sensor_in_group[0]=
            opened_trace->linesense_size[0] = opened_trace->corosion_sens_num/2;

            opened_trace->real_number_sensor_in_group[1]=
            opened_trace->linesense_size[1] = opened_trace->corosion_sens_num/2;

            opened_trace->Amplification_Group[0] = 10;
            opened_trace->Amplification_Group[1] = 15;

            opened_trace->sektors_num=1;
            opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

            opened_trace->max_data_code=4095;

            opened_trace->orientation_mul_factor = 1.0;
            opened_trace->Orientation_OFF = 0;
            opened_trace->Orinteation_Direct_count=1;
            opened_trace->Orientation_shift=24;
            opened_trace->Orientation_shift_2=10;

            opened_trace->sens_for_thick=0;
            opened_trace->sens_for_thick_count=1;

            // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
            if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0");
                   WritePrivateProfileString(EPRO_SECTION,
                                             Get_Orient_from_NAV_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            // Прописали в trc-файл флаг использования ориентации с файла rec.mat

            // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
            if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( key_value, "0");
                   WritePrivateProfileString(EPRO_SECTION,
                                             Get_Orient_from_VOG_KEY,
                                             key_value,
                                             opened_trace->trc_file_name
                                            );
                 };
             };
            // Прописали в trc-файл флаг использования ориентации с файла rec.vog

            opened_trace->VOG_koeff_umn=100;
            opened_trace->ACCEL_koeff_umn=1000;

            if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=8;
            if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;


            // Выставим инвертирование для нужных датчиков
            // (в нашем случае для всех НЕ НАДО)
            if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {
                   strcpy( opened_trace->invert_sens_data_text, "");

                   for (i=0; i<MAX_CORROZION_NUM; i++) {
                      opened_trace->invert_sens_data[i]=0;
                    };
                 };
             };
            // Выставили инвертирование для нужных датчиков

            // Выставим удаление для нужных датчиков
            if (GetPrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY, "нет", key_value,
                           sizeof(key_value), opened_trace->trc_file_name)!=0)
             {
                if (strcmp( key_value, "нет") == 0) {

                   WritePrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY,
                                             "30-39,70-79",
                                             opened_trace->trc_file_name
                                            );

                   for (i=30; i<39; i++) {
                      opened_trace->Delete_sens_data[i]=1;
                    };
                   for (i=70; i<79; i++) {
                      opened_trace->Delete_sens_data[i]=1;
                    };

                 };
             };
            // Выставили удаление для нужных датчиков

            opened_trace->real_number_sensor_in_group[0]=30;
            opened_trace->real_number_sensor_in_group[1]=30;

            set_sens_sort_prof_700(opened_trace);

            break;
         }; //if (strcmp(target_name, TARGET_NAME_PROFIL700)==0) {


        if (strcmp(target_name, TARGET_NAME_PROFIL1400)==0 ||
            strcmp(target_name, TARGET_NAME_PROFIL1400D)==0)
         {
           // Значится Профиль 1400
           opened_trace->trace_step = 5;           // шаг опроса 5 мм
           opened_trace->group_num  = 4;           // 4 пояса

           opened_trace->corosion_sens_num = 
                        opened_trace->corosion_sens_num * 2;

           opened_trace->real_number_sensor_in_group[0] =
                  opened_trace->linesense_size[0] = 
                       opened_trace->corosion_sens_num / 4;
           opened_trace->real_number_sensor_in_group[1] =
                  opened_trace->linesense_size[1] = 
                       opened_trace->corosion_sens_num / 4;
           opened_trace->real_number_sensor_in_group[2] =
                  opened_trace->linesense_size[2] = 
                       opened_trace->corosion_sens_num / 4;
           opened_trace->real_number_sensor_in_group[3] =
                  opened_trace->linesense_size[3] = 
                       opened_trace->corosion_sens_num / 4;


           // Выставим усиление по поясам :
           if (opened_trace->Amplification_Group[0]==0) 
               opened_trace->Amplification_Group[0] = 10;

           if (opened_trace->Amplification_Group[1]==0) 
               opened_trace->Amplification_Group[1] = 10;

           if (opened_trace->Amplification_Group[2]==0) 
               opened_trace->Amplification_Group[2] = 10;

           if (opened_trace->Amplification_Group[3]==0) 
               opened_trace->Amplification_Group[3] = 10;

           opened_trace->sektors_num=1;
           opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

           if (opened_trace->max_data_code==0) opened_trace->max_data_code=4096;

           opened_trace->orientation_mul_factor = 1.0;
           opened_trace->Orientation_OFF = 0;
           opened_trace->Orinteation_Direct_count=0;
           opened_trace->Orientation_shift=38;
           opened_trace->Orientation_shift_2=40;

           opened_trace->sens_for_thick=0;
           opened_trace->sens_for_thick_count=1;

           // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_NAV_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.mat

           // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_VOG_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.vog

           opened_trace->VOG_koeff_umn=100;
           opened_trace->ACCEL_koeff_umn=1000;

           // Выставим инвертирование для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( opened_trace->invert_sens_data_text, "");

                  for (i=0; i<MAX_CORROZION_NUM; i++) {
                     opened_trace->invert_sens_data[i]=0;
                   };

                };
            };
           // Выставили инвертирование для нужных датчиков

           // Пропишем в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля
           if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0.0208896");   // АДУК
                  WritePrivateProfileString(EPRO_SECTION,
                                            adc2tesla_koef_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
           // Прописали в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля

           // Выставим удаление для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {

                  WritePrivateProfileString(
                     EPRO_SECTION, Delete_sens_data_KEY,
                     "",
                      opened_trace->trc_file_name
                   );

                };

            };
           // Выставили удаление для нужных датчиков

           if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;
           if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;
           if (opened_trace->smooth_win_length[2]==0) opened_trace->smooth_win_length[2]=4;
           if (opened_trace->smooth_win_length[3]==0) opened_trace->smooth_win_length[3]=4;

           set_sens_sort_prof_1400(opened_trace);

           break;
         };


        // Значится профиль 500
        opened_trace->trace_step = 10;     // шаг опроса 10 мм
        opened_trace->group_num  = 2;      // два пояса

        opened_trace->real_number_sensor_in_group[0]=
        opened_trace->linesense_size[0] = opened_trace->corosion_sens_num/2;

        opened_trace->real_number_sensor_in_group[1]=
        opened_trace->linesense_size[1] = opened_trace->corosion_sens_num/2;

        opened_trace->Amplification_Group[0] = 10;
        opened_trace->Amplification_Group[1] = 15;

        opened_trace->sektors_num=1;
        opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

        opened_trace->max_data_code=4095;

        opened_trace->orientation_mul_factor = 1.0;
        opened_trace->Orientation_OFF = 0;
        opened_trace->Orinteation_Direct_count=0;
        opened_trace->Orientation_shift=9;
        opened_trace->Orientation_shift_2=0;

        opened_trace->sens_for_thick=0;
        opened_trace->sens_for_thick_count=1;

        // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "1");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_NAV_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.mat

        // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_VOG_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.vog

        opened_trace->VOG_koeff_umn=100;
        opened_trace->ACCEL_koeff_umn=1000;

        if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=8;
        if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;

        // Выставим инвертирование для нужных датчиков
        // (в нашем случае для всех НЕ НАДО)
        if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( opened_trace->invert_sens_data_text, "");

               for (i=0; i<MAX_CORROZION_NUM; i++) {
                  opened_trace->invert_sens_data[i]=0;
                };
             };
         };
        // Выставили инвертирование для нужных датчиков

        // Выставим удаление для нужных датчиков
        if (GetPrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {

               WritePrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY,
                                         "30-39,70-79",
                                         opened_trace->trc_file_name
                                        );

               for (i=30; i<39; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };
               for (i=70; i<79; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };

             };
         };
        // Выставили удаление для нужных датчиков

        opened_trace->real_number_sensor_in_group[0]=30;
        opened_trace->real_number_sensor_in_group[1]=30;

        set_sens_sort_prof500(opened_trace);

        break;
      }; //case (80) : {

     case (576) : {  // вроде как стресс 1200 или стресс 500

        if (strcmp(target_name, TARGET_NAME_STRESS500)==0) {
            // Значится стресс 500
           opened_trace->trace_step = 10;     // шаг опроса 10 мм
           opened_trace->group_num  = 1;      // один пояс

           opened_trace->real_number_sensor_in_group[0]=
           opened_trace->linesense_size[0] =    // единственный пояс
               opened_trace->corosion_sens_num; // включает все датчики

           if (opened_trace->Amplification_Group[0]==0) 
               opened_trace->Amplification_Group[0] = 4;

           opened_trace->sektors_num=1;
           opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

           if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

           opened_trace->orientation_mul_factor = (double) opened_trace->corosion_sens_num /
                                                   121.0;
           opened_trace->Orientation_OFF = 0;
           opened_trace->Orinteation_Direct_count=0;
           opened_trace->Orientation_shift=37;
           opened_trace->Orientation_shift_2=0;

           opened_trace->sens_for_thick=0;
           opened_trace->sens_for_thick_count=1;

           // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_NAV_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.mat

           // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_VOG_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.vog

           opened_trace->VOG_koeff_umn=100;
           opened_trace->ACCEL_koeff_umn=1000;

           if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;

           // Выставим инвертирование для нужных датчиков
           // (в нашем случае для всех НАДО)
           if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( opened_trace->invert_sens_data_text,"0-575");

                  for (i=0; i<MAX_CORROZION_NUM; i++) {
                     opened_trace->invert_sens_data[i]=1;
                   };
                };
            };
           // Выставили инвертирование для нужных датчиков

           // Пропишем в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля
           if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0.0208896");   // АДУК
                  WritePrivateProfileString(EPRO_SECTION,
                                            adc2tesla_koef_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
           // Прописали в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля

           set_sens_sort_STRS_500(opened_trace);

           break;
         };

        // Значится стресс 1200
        opened_trace->trace_step = 10;     // шаг опроса 10 мм
        opened_trace->group_num  = 1;      // один пояс

        opened_trace->real_number_sensor_in_group[0]=
        opened_trace->linesense_size[0] =    // единственный пояс
            opened_trace->corosion_sens_num; // включает все датчики

        if (opened_trace->Amplification_Group[0]==0) 
            opened_trace->Amplification_Group[0] = 10;

        opened_trace->sektors_num=4;
        opened_trace->sens_num_in_sektor=144;

        if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

        opened_trace->orientation_mul_factor = (double) opened_trace->corosion_sens_num /
                                                125.0;
        opened_trace->Orientation_OFF = 0;
        opened_trace->Orinteation_Direct_count=0;
        opened_trace->Orientation_shift=48;
        opened_trace->Orientation_shift_2=0;

        opened_trace->sens_for_thick=0;
        opened_trace->sens_for_thick_count=1;

        // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_NAV_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.mat

        // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_VOG_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.vog

        opened_trace->VOG_koeff_umn=100;
        opened_trace->ACCEL_koeff_umn=1000;

        if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;

        // Выставим инвертирование для нужных датчиков
        // (в нашем случае для всех НАДО)
        if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( opened_trace->invert_sens_data_text, "0-575");

               for (i=0; i<MAX_CORROZION_NUM; i++) {
                  opened_trace->invert_sens_data[i]=1;
                };
             };
         };
        // Выставили инвертирование для нужных датчиков

        // Пропишем в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля
        if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0.0208896");   // АДУК
               WritePrivateProfileString(EPRO_SECTION,
                                         adc2tesla_koef_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
        // Прописали в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля

         set_sens_sort_STRS_1200(opened_trace);

        break;
      }; //case (576) : {

     case (256) : {  // вроде как трехсотка или 700 корозионники

        if (strcmp(target_name, TARGET_NAME_CORROS300)==0) {

             opened_trace->trace_step = 10;     // шаг опроса 10 мм
             opened_trace->group_num  = 1;      // один пояс

             opened_trace->real_number_sensor_in_group[0]=
             opened_trace->linesense_size[0] =    // единственный пояс
                 opened_trace->corosion_sens_num; // включает все датчики

             if (opened_trace->Amplification_Group[0]==0) 
                 opened_trace->Amplification_Group[0] = 7;

             opened_trace->sektors_num=1;
             opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

             if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

             opened_trace->orientation_mul_factor = 1.0;
             opened_trace->Orientation_OFF = 0;
             opened_trace->Orinteation_Direct_count=0;
             opened_trace->Orientation_shift=0;
             opened_trace->Orientation_shift_2=0;

             opened_trace->sens_for_thick=0;
             opened_trace->sens_for_thick_count=1;

             // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
             if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                            sizeof(key_value), opened_trace->trc_file_name)!=0)
              {
                 if (strcmp( key_value, "нет") == 0) {
                    strcpy( key_value, "0");
                    WritePrivateProfileString(EPRO_SECTION,
                                              Get_Orient_from_NAV_KEY,
                                              key_value,
                                              opened_trace->trc_file_name
                                             );
                  };
              };
             // Прописали в trc-файл флаг использования ориентации с файла rec.mat

             // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
             if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                            sizeof(key_value), opened_trace->trc_file_name)!=0)
              {
                 if (strcmp( key_value, "нет") == 0) {
                    strcpy( key_value, "0");
                    WritePrivateProfileString(EPRO_SECTION,
                                              Get_Orient_from_VOG_KEY,
                                              key_value,
                                              opened_trace->trc_file_name
                                             );
                  };
              };
             // Прописали в trc-файл флаг использования ориентации с файла rec.vog

             opened_trace->VOG_koeff_umn=100;
             opened_trace->ACCEL_koeff_umn=1000;

             // Выставим инвертирование для нужных датчиков
             // (в нашем случае для всех НАДО)
             if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                            sizeof(key_value), opened_trace->trc_file_name)!=0)
              {
                 if (strcmp( key_value, "нет") == 0) {
                    strcpy( opened_trace->invert_sens_data_text, "0-255");

                    for (i=0; i<MAX_CORROZION_NUM; i++) {
                       opened_trace->invert_sens_data[i]=1;
                     };
                  };
              };
             // Выставили инвертирование для нужных датчиков

             // Пропишем в trc-файл коэффициент преревода из значений АЦП
             // в милитеслы магнитного поля
             if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                            sizeof(key_value), opened_trace->trc_file_name)!=0)
              {
                 if (strcmp( key_value, "нет") == 0) {
                    strcpy( key_value, "0.0208896");   // АДУК
                    WritePrivateProfileString(EPRO_SECTION,
                                              adc2tesla_koef_KEY,
                                              key_value,
                                              opened_trace->trc_file_name
                                             );
                  };
              };
             WritePrivateProfileString("MagnetSystem","Tesla1",
                             key_value, opened_trace->trc_file_name);
             // Прописали в trc-файл коэффициент преревода из значений АЦП
             // в милитеслы магнитного поля

             if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;

             break;
         }; // if (strcmp(target_name, #define TARGET_NAME_CORROS300)==0)

        // значится 700 корозионник
             opened_trace->trace_step = 5;     // шаг опроса 5 мм
             opened_trace->group_num  = 1;      // один пояс

             opened_trace->real_number_sensor_in_group[0]=
             opened_trace->linesense_size[0] =    // единственный пояс
                 opened_trace->corosion_sens_num; // включает все датчики

             if (opened_trace->Amplification_Group[0]==0) 
                 opened_trace->Amplification_Group[0] = 7;

             opened_trace->sektors_num=1;
             opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

             if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

             opened_trace->orientation_mul_factor = 1.0;
             opened_trace->Orientation_OFF = 0;
             opened_trace->Orinteation_Direct_count=0;
             opened_trace->Orientation_shift=69;
             opened_trace->Orientation_shift_2=0;

             opened_trace->sens_for_thick=0;
             opened_trace->sens_for_thick_count=1;

             // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
             if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                            sizeof(key_value), opened_trace->trc_file_name)!=0)
              {
                 if (strcmp( key_value, "нет") == 0) {
                    strcpy( key_value, "0");
                    WritePrivateProfileString(EPRO_SECTION,
                                              Get_Orient_from_NAV_KEY,
                                              key_value,
                                              opened_trace->trc_file_name
                                             );
                  };
              };
             // Прописали в trc-файл флаг использования ориентации с файла rec.mat

             // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
             if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                            sizeof(key_value), opened_trace->trc_file_name)!=0)
              {
                 if (strcmp( key_value, "нет") == 0) {
                    strcpy( key_value, "0");
                    WritePrivateProfileString(EPRO_SECTION,
                                              Get_Orient_from_VOG_KEY,
                                              key_value,
                                              opened_trace->trc_file_name
                                             );
                  };
              };
             // Прописали в trc-файл флаг использования ориентации с файла rec.vog

             opened_trace->VOG_koeff_umn=100;
             opened_trace->ACCEL_koeff_umn=1000;

             // Выставим инвертирование для нужных датчиков
             // (в нашем случае для всех НАДО)
             if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                            sizeof(key_value), opened_trace->trc_file_name)!=0)
              {
                 if (strcmp( key_value, "нет") == 0) {
                    strcpy( opened_trace->invert_sens_data_text, "0-255");

                    for (i=0; i<MAX_CORROZION_NUM; i++) {
                       opened_trace->invert_sens_data[i]=1;
                     };
                  };
              };
             // Выставили инвертирование для нужных датчиков

             // Пропишем в trc-файл коэффициент преревода из значений АЦП
             // в милитеслы магнитного поля
             if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                            sizeof(key_value), opened_trace->trc_file_name)!=0)
              {
                 if (strcmp( key_value, "нет") == 0) {
                    strcpy( key_value, "0.0208896");   // АДУК
                    WritePrivateProfileString(EPRO_SECTION,
                                              adc2tesla_koef_KEY,
                                              key_value,
                                              opened_trace->trc_file_name
                                             );
                  };
              };
             WritePrivateProfileString("MagnetSystem","Tesla1",
                             key_value, opened_trace->trc_file_name);
             // Прописали в trc-файл коэффициент преревода из значений АЦП
             // в милитеслы магнитного поля

             if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;

             set_sens_sort_cor700m(opened_trace);

             return KRT_OK;

             break;

      }; //case (256) : {

     case (128) : {  // вроде как 273 или сит 1000

        if (strcmp(target_name, TARGET_NAME_COR1000sit)==0) {
           // Значится сит 1000
           opened_trace->trace_step = 10;     // шаг опроса 10 мм
           opened_trace->group_num  = 1;      // один пояс

           opened_trace->real_number_sensor_in_group[0]=
           opened_trace->linesense_size[0] =    // единственный пояс
               opened_trace->corosion_sens_num; // включает все датчики

           if (opened_trace->Amplification_Group[0]==0) 
               opened_trace->Amplification_Group[0] = 10;

           opened_trace->sektors_num=1;
           opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

           if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

           opened_trace->orientation_mul_factor = 1.0;
           opened_trace->Orientation_OFF = 0;
           opened_trace->Orinteation_Direct_count=0;
           opened_trace->Orientation_shift=35;
           opened_trace->Orientation_shift_2=0;

           opened_trace->sens_for_thick=0;
           opened_trace->sens_for_thick_count=1;

           // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_NAV_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.mat

           // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_VOG_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.vog

           opened_trace->VOG_koeff_umn=10;
           opened_trace->ACCEL_koeff_umn=100;

           // Выставим инвертирование для нужных датчиков
           // (в нашем случае для всех НЕ НАДО)
           if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( opened_trace->invert_sens_data_text, "");

                  for (i=0; i<MAX_CORROZION_NUM; i++) {
                     opened_trace->invert_sens_data[i]=0;
                   };
                };
            };
           // Выставили инвертирование для нужных датчиков

           // Пропишем в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля
           if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0.00384");   // Diamond-32
                  WritePrivateProfileString(EPRO_SECTION,
                                            adc2tesla_koef_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
           // Прописали в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля

           if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;

           set_sens_sort_sit_1000(opened_trace);


           break;
         };

        // Значится 273

        opened_trace->trace_step = 5;     // шаг опроса 5 мм
        opened_trace->group_num  = 1;      // один пояс

        opened_trace->real_number_sensor_in_group[0]=
        opened_trace->linesense_size[0] =    // единственный пояс
            opened_trace->corosion_sens_num; // включает все датчики

        if (opened_trace->Amplification_Group[0]==0) 
            opened_trace->Amplification_Group[0] = 20;

        opened_trace->sektors_num=1;
        opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

        if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

        opened_trace->orientation_mul_factor = 1.0;
        opened_trace->Orientation_OFF = 0;
        opened_trace->Orinteation_Direct_count=0;
        opened_trace->Orientation_shift=5;
        opened_trace->Orientation_shift_2=0;

        opened_trace->sens_for_thick=0;
        opened_trace->sens_for_thick_count=1;

        // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_NAV_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.mat

        // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_VOG_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.vog

        opened_trace->VOG_koeff_umn=100;
        opened_trace->ACCEL_koeff_umn=1000;

        // Выставим инвертирование для нужных датчиков
        // (в нашем случае для всех НАДО)
        if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( opened_trace->invert_sens_data_text, "0-127");

               for (i=0; i<MAX_CORROZION_NUM; i++) {
                  opened_trace->invert_sens_data[i]=1;
                };
             };
         };
        // Выставили инвертирование для нужных датчиков

        // Пропишем в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля
        if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0.0208896");   // АДУК
               WritePrivateProfileString(EPRO_SECTION,
                                         adc2tesla_koef_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
        // Прописали в trc-файл коэффициент преревода из значений АЦП
        // в милитеслы магнитного поля

        if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=2;

        set_sens_sort_cor_273(opened_trace);

        break;
      }; //case (128) : {

     case (528) : {  // вроде как Корозионник 508 (Иран)

        if (strcmp(target_name, TARGET_NAME_CORROS508)==0) {
           // Значится Корозионник 508 (Иран)
           opened_trace->trace_step = 5;           // шаг опроса 5 мм
           opened_trace->group_num  = 2;           // два пояс

           opened_trace->real_number_sensor_in_group[0]=
           opened_trace->linesense_size[0] = 352;  // первый пояс

           opened_trace->real_number_sensor_in_group[1]=
           opened_trace->linesense_size[1] = 176;  // второй пояс

           // Выставим усиление по поясам :
           if (opened_trace->Amplification_Group[0]==0) 
               opened_trace->Amplification_Group[0] = 10;
           if (opened_trace->Amplification_Group[1]==0) 
               opened_trace->Amplification_Group[1] = 10;

           opened_trace->sektors_num=1;
           opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

           if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

           opened_trace->orientation_mul_factor = 1.0;
           opened_trace->Orientation_OFF = 0;
           opened_trace->Orinteation_Direct_count=0;
           opened_trace->Orientation_shift=282;
           opened_trace->Orientation_shift_2=0;

           opened_trace->sens_for_thick=0;
           opened_trace->sens_for_thick_count=1;

           // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_NAV_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.mat

           // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_VOG_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.vog

           opened_trace->VOG_koeff_umn=100;
           opened_trace->ACCEL_koeff_umn=1000;

           // Выставим инвертирование для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( opened_trace->invert_sens_data_text, "0-527");

                  for (i=0; i<MAX_CORROZION_NUM; i++) {
                     opened_trace->invert_sens_data[i]=1;
                   };

                };
            };
           // Выставили инвертирование для нужных датчиков

           // Пропишем в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля
           if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0.0208896");   // АДУК
                  WritePrivateProfileString(EPRO_SECTION,
                                            adc2tesla_koef_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
           // Прописали в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля

           // Выставим удаление для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {

                  WritePrivateProfileString(
                     EPRO_SECTION, Delete_sens_data_KEY,
                     "64-87, 152-175, 240-263, 328-351, 416-439, 504-527",
                      opened_trace->trc_file_name
                   );

                  for (i=64; i<87; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                  for (i=152; i<175; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                  for (i=240; i<263; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                  for (i=328; i<351; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };

                  for (i=416; i<439; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                  for (i=504; i<527; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                };

            };
           opened_trace->real_number_sensor_in_group[0]=256;
           opened_trace->real_number_sensor_in_group[1]=128;
           // Выставили удаление для нужных датчиков

           if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;
           if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;

           set_sens_sort_cor_508(opened_trace);

           break;
         };
        // Значится неизвестно что пусть дойдет до дефаулта

      }; //case (528) : {

     case (432) : {  // вроде как Корозионник 426

        if (strcmp(target_name, TARGET_NAME_CORROS426)==0) {
           // Значится Корозионник 426
           opened_trace->trace_step = 5;           // шаг опроса 5 мм
           opened_trace->group_num  = 2;           // два пояс

           opened_trace->real_number_sensor_in_group[0]=
           opened_trace->linesense_size[0] = 288;  // первый пояс

           opened_trace->real_number_sensor_in_group[1]=
           opened_trace->linesense_size[1] = 144;  // второй пояс

           // Выставим усиление по поясам :
           if (opened_trace->Amplification_Group[0]==0) 
               opened_trace->Amplification_Group[0] = 10;
           if (opened_trace->Amplification_Group[1]==0) 
               opened_trace->Amplification_Group[1] = 3;

           opened_trace->sektors_num=1;
           opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

           if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

           opened_trace->orientation_mul_factor = 1.0;
           opened_trace->Orientation_OFF = 0;
           opened_trace->Orinteation_Direct_count=0;
           opened_trace->Orientation_shift=120;
           opened_trace->Orientation_shift_2=55;

           opened_trace->sens_for_thick=0;
           opened_trace->sens_for_thick_count=1;

           // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_NAV_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.mat

           // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_VOG_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.vog

           opened_trace->VOG_koeff_umn=100;
           opened_trace->ACCEL_koeff_umn=1000;

           // Выставим инвертирование для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( opened_trace->invert_sens_data_text, "0-432");

                  for (i=0; i<MAX_CORROZION_NUM; i++) {
                     opened_trace->invert_sens_data[i]=1;
                   };

                };
            };
           // Выставили инвертирование для нужных датчиков

           // Пропишем в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля
           if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0.0208896");   // АДУК
                  WritePrivateProfileString(EPRO_SECTION,
                                            adc2tesla_koef_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
           // Прописали в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля

           // Выставим удаление для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {

                  WritePrivateProfileString(
                     EPRO_SECTION, Delete_sens_data_KEY,
                     "64-71,136-143,208-215,280-287,352-359,424-431",
                      opened_trace->trc_file_name
                   );

                  for (i=64; i<72; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                  for (i=136; i<144; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                  for (i=208; i<216; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                  for (i=280; i<288; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                  for (i=352; i<360; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                  for (i=424; i<432; i++) {
                     opened_trace->Delete_sens_data[i]=1;
                   };
                };

            };
           opened_trace->real_number_sensor_in_group[0]=256;
           opened_trace->real_number_sensor_in_group[1]=144;
           // Выставили удаление для нужных датчиков

           if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;
           if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;

           set_sens_sort_cor_426(opened_trace);

           break;
         };
        // Значится неизвестно что пусть дойдет до дефаулта

      }; //case (432) : {

     case (20) : {  // вроде как Профиль 426

        if (strcmp(target_name, TARGET_NAME_PROFIL426)==0) {
           // Значится Профиль 426
           opened_trace->trace_step = 5;           // шаг опроса 5 мм
           opened_trace->group_num  = 2;           // 2 пояса

           opened_trace->corosion_sens_num = 
                        opened_trace->corosion_sens_num * 2;

           opened_trace->real_number_sensor_in_group[0] =
                  opened_trace->linesense_size[0] = 
                       opened_trace->corosion_sens_num / 2;
           opened_trace->real_number_sensor_in_group[1] =
                  opened_trace->linesense_size[1] = 
                       opened_trace->corosion_sens_num / 2;


           // Выставим усиление по поясам :
           if (opened_trace->Amplification_Group[0]==0) 
               opened_trace->Amplification_Group[0] = 10;

           if (opened_trace->Amplification_Group[1]==0) 
               opened_trace->Amplification_Group[1] = 10;

           opened_trace->sektors_num=1;
           opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

           if (opened_trace->max_data_code==0) opened_trace->max_data_code=65535;

           opened_trace->orientation_mul_factor = 1.0;
           opened_trace->Orientation_OFF = 0;
           opened_trace->Orinteation_Direct_count=0;
           opened_trace->Orientation_shift=0;
           opened_trace->Orientation_shift_2=0;

           opened_trace->sens_for_thick=0;
           opened_trace->sens_for_thick_count=1;

           // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_NAV_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.mat

           // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_VOG_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.vog

           opened_trace->VOG_koeff_umn=100;
           opened_trace->ACCEL_koeff_umn=1000;

           // Выставим инвертирование для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( opened_trace->invert_sens_data_text, "");

                  for (i=0; i<MAX_CORROZION_NUM; i++) {
                     opened_trace->invert_sens_data[i]=0;
                   };

                };
            };
           // Выставили инвертирование для нужных датчиков

           // Пропишем в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля
           if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0.0208896");   // АДУК
                  WritePrivateProfileString(EPRO_SECTION,
                                            adc2tesla_koef_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
           // Прописали в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля

           // Выставим удаление для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {

                  WritePrivateProfileString(
                     EPRO_SECTION, Delete_sens_data_KEY,
                     "",
                      opened_trace->trc_file_name
                   );

                };

            };
           // Выставили удаление для нужных датчиков

           if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;
           if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;

//           set_sens_sort_prof_426(opened_trace);

           break;
         };
        // Значится неизвестно что пусть дойдет до дефаулта

      }; //case (20) : {

     case (32) : {  // вроде как Самописец

        opened_trace->trace_step = 10;     // шаг опроса 5 мм
        opened_trace->group_num  = 2;      // два пояса

        opened_trace->real_number_sensor_in_group[0]=
        opened_trace->linesense_size[0] = 16;

        opened_trace->real_number_sensor_in_group[1]=
        opened_trace->linesense_size[1] = 16; 

        if (opened_trace->Amplification_Group[0]==0) 
            opened_trace->Amplification_Group[0] = 20;

        if (opened_trace->Amplification_Group[1]==0) 
            opened_trace->Amplification_Group[1] = 20;

        opened_trace->sektors_num=1;
        opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

        if (opened_trace->max_data_code==0) opened_trace->max_data_code=65535;

        opened_trace->orientation_mul_factor = 1.0;
        opened_trace->Orientation_OFF = 1;
        opened_trace->Orinteation_Direct_count=0;
        opened_trace->Orientation_shift=0;
        opened_trace->Orientation_shift_2=0;

        opened_trace->sens_for_thick=0;
        opened_trace->sens_for_thick_count=1;

        // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_NAV_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.mat

        // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_VOG_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.vog

        opened_trace->VOG_koeff_umn=100;
        opened_trace->ACCEL_koeff_umn=1000;

        // Выставим инвертирование для нужных датчиков
        // (в нашем случае для всех НЕ НАДО)
        if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( opened_trace->invert_sens_data_text, "");

               for (i=0; i<MAX_CORROZION_NUM; i++) {
                  opened_trace->invert_sens_data[i]=0;
                };
             };
         };
        // Выставили инвертирование для нужных датчиков

        // Выставим удаление для нужных датчиков
        if (GetPrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {

               WritePrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY,
                                         "12-15",
                                         opened_trace->trc_file_name
                                        );

               for (i=12; i<15; i++) {
                  opened_trace->Delete_sens_data[i]=1;
                };
//               for (i=20; i<31; i++) {
//                  opened_trace->Delete_sens_data[i]=1;
//                };

             };
         };
        // Выставили удаление для нужных датчиков

        opened_trace->real_number_sensor_in_group[0]=12;

        if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;
        if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;

        break;

      }; //case (32) : {

     case (64) : {  // вроде как Самописец

        opened_trace->trace_step = 10;     // шаг опроса 1 мм
        opened_trace->group_num  = 2;      // два пояса

        opened_trace->real_number_sensor_in_group[0]=
        opened_trace->linesense_size[0] = 32;

        opened_trace->real_number_sensor_in_group[0]=
        opened_trace->linesense_size[1] = 32; 

        if (opened_trace->Amplification_Group[0]==0) 
            opened_trace->Amplification_Group[0] = 20;

        if (opened_trace->Amplification_Group[1]==0) 
            opened_trace->Amplification_Group[1] = 20;

        opened_trace->sektors_num=1;
        opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

        if (opened_trace->max_data_code==0) opened_trace->max_data_code=65535;

        opened_trace->orientation_mul_factor = 1.0;
        opened_trace->Orientation_OFF = 0;
        opened_trace->Orinteation_Direct_count=0;
        opened_trace->Orientation_shift=0;
        opened_trace->Orientation_shift_2=0;

        opened_trace->sens_for_thick=0;
        opened_trace->sens_for_thick_count=1;

        // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_NAV_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.mat

        // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_VOG_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.vog

        opened_trace->VOG_koeff_umn=100;
        opened_trace->ACCEL_koeff_umn=1000;

        // Выставим инвертирование для нужных датчиков
        // (в нашем случае для всех НЕ НАДО)
        if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( opened_trace->invert_sens_data_text, "");

               for (i=0; i<MAX_CORROZION_NUM; i++) {
                  opened_trace->invert_sens_data[i]=0;
                };
             };
         };
        // Выставили инвертирование для нужных датчиков

        // Выставим удаление для нужных датчиков
        if (GetPrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {

               WritePrivateProfileString(EPRO_SECTION, Delete_sens_data_KEY,
                                         "",
                                         opened_trace->trc_file_name
                                        );

             };

         };
        // Выставили удаление для нужных датчиков

        opened_trace->real_number_sensor_in_group[0];
        opened_trace->real_number_sensor_in_group[1];


        if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;
        if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;

        break;

      }; //case (64) : {

     case (960) : {  // вроде как СТРЕСС 1400

        if (strcmp(target_name, TARGET_NAME_STRESS1400)==0) {
           // стресс 1400
           opened_trace->trace_step = 5;     // шаг опроса 5 мм
           opened_trace->group_num  = 1;      // один пояс

           opened_trace->real_number_sensor_in_group[0]=
           opened_trace->linesense_size[0] =    // единственный пояс
               opened_trace->corosion_sens_num; // включает все датчики

           if (opened_trace->Amplification_Group[0]==0) 
               opened_trace->Amplification_Group[0] = 10;

           opened_trace->sektors_num=1;
           opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

           if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

           opened_trace->orientation_mul_factor = 1.0;
           opened_trace->Orientation_OFF = 0;
           opened_trace->Orinteation_Direct_count=0;
           opened_trace->Orientation_shift=-307;
           opened_trace->Orientation_shift_2=0;

           opened_trace->sens_for_thick=130;
           opened_trace->sens_for_thick_count=50;

           // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_NAV_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.mat

           // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_VOG_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.vog

           opened_trace->VOG_koeff_umn=100;
           opened_trace->ACCEL_koeff_umn=1000;

           // Выставим инвертирование для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( opened_trace->invert_sens_data_text, "0-959");

                  for (i=0; i<MAX_CORROZION_NUM; i++) {
                     opened_trace->invert_sens_data[i]=1;
                   };

                };
            };
           // Выставили инвертирование для нужных датчиков

           // Пропишем в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля
           if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0.0208896");   // АДУК
                  WritePrivateProfileString(EPRO_SECTION,
                                            adc2tesla_koef_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
           // Прописали в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля

           if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;

           set_sens_sort_stress_1400(opened_trace);
           break;
         } else {
           // Значится неизвестно что пусть дойдет до дефаулта
         };
      }; //case (960) : {

     case (1152) : {  // вроде как КОРОЗИОННИК 1400

        if (strcmp(target_name, TARGET_NAME_COROSS1400)==0) {
           // корозионник 1400
           opened_trace->trace_step = 5;     // шаг опроса 5 мм
           opened_trace->group_num  = 2;     // 2 пояса

           opened_trace->real_number_sensor_in_group[0]=
           opened_trace->linesense_size[0] = 864;

           opened_trace->real_number_sensor_in_group[1]=
           opened_trace->linesense_size[1] = 288;   

           if (opened_trace->Amplification_Group[0]==0) 
               opened_trace->Amplification_Group[0] = 10;

           if (opened_trace->Amplification_Group[1]==0) 
               opened_trace->Amplification_Group[1] = 10;

           opened_trace->sektors_num=1;
           opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

           if (opened_trace->max_data_code==0) opened_trace->max_data_code=4095;

           opened_trace->orientation_mul_factor = 1.0;
           opened_trace->Orientation_OFF = 0;
           opened_trace->Orinteation_Direct_count=0;
           opened_trace->Orientation_shift=-465;
           opened_trace->Orientation_shift_2=21;

           opened_trace->sens_for_thick=0;
           opened_trace->sens_for_thick_count=100;

           // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_NAV_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.mat

           // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
           if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0");
                  WritePrivateProfileString(EPRO_SECTION,
                                            Get_Orient_from_VOG_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           // Прописали в trc-файл флаг использования ориентации с файла rec.vog

           opened_trace->VOG_koeff_umn=100;
           opened_trace->ACCEL_koeff_umn=1000;

           // Выставим инвертирование для нужных датчиков
           if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( opened_trace->invert_sens_data_text,
                          "0-1151");
/*,864,866,868,870,872,874,876,878,880,882,\
884,886,888,890,892,894,896,898,900,902,\
904,906,908,910,912,914,916,918,920,922,\
924,926,928,930,932,934,936,938,940,942,\
944,946,948,950,952,954,956,958,960,962,\
964,966,968,970,972,974,976,978,980,982,\
984,986,988,990,992,994,996,998,1000,1002,\
1004,1006,1008,1010,1012,1014,1016,1018,1020,1022,\
1024,1026,1028,1030,1032,1034,1036,1038,1040,1042,\
1044,1046,1048,1050,1052,1054,1056,1058,1060,1062,\
1064,1066,1068,1070,1072,1074,1076,1078,1080,1082,\
1084,1086,1088,1090,1092,1094,1096,1098,1100,1102,\
1104,1106,1108,1110,1112,1114,1116,1118,1120,1122,\
1124,1126,1128,1130,1132,1134,1136,1138,1140,1142,\
1144,1146,1148,1150");*/

                  for (i=0; i<1151; i++) {
                     opened_trace->invert_sens_data[i]=1;
                   };

//                  for (i=864; i<MAX_CORROZION_NUM; i+=2) {
//                     opened_trace->invert_sens_data[i]=1;
//                   };

                };
            };
           // Выставили инвертирование для нужных датчиков

           // Пропишем в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля
           if (GetPrivateProfileString(EPRO_SECTION, adc2tesla_koef_KEY, "нет", key_value,
                          sizeof(key_value), opened_trace->trc_file_name)!=0)
            {
               if (strcmp( key_value, "нет") == 0) {
                  strcpy( key_value, "0.0208896");   // АДУК
                  WritePrivateProfileString(EPRO_SECTION,
                                            adc2tesla_koef_KEY,
                                            key_value,
                                            opened_trace->trc_file_name
                                           );
                };
            };
           WritePrivateProfileString("MagnetSystem","Tesla1",
                        key_value, opened_trace->trc_file_name);
           // Прописали в trc-файл коэффициент преревода из значений АЦП
           // в милитеслы магнитного поля

           if (opened_trace->smooth_win_length[0]==0) opened_trace->smooth_win_length[0]=4;
           if (opened_trace->smooth_win_length[1]==0) opened_trace->smooth_win_length[1]=4;

           set_sens_sort_coross_1400(opened_trace);
           break;
         } else {
           // Значится неизвестно что пусть дойдет до дефаулта
         };
      }; //case (1152) : {


     default: {
//        sprintf(drvError, "Неизвестный тип снаряда(write_data_to_trc)");
        // вываливаться с ошибкой пока не станем просто будем считать что
        // один пояс и все датчики входят в него, вот

        opened_trace->trace_step = 10;     // шаг опроса 10 мм
        opened_trace->group_num  = 1;      // один пояс
        opened_trace->linesense_size[0] =    // единственный пояс
            opened_trace->corosion_sens_num; // включает все датчики
        opened_trace->Amplification_Group[0] = 10;

        opened_trace->sektors_num=1;
        opened_trace->sens_num_in_sektor=opened_trace->corosion_sens_num;

        opened_trace->max_data_code=65535;

        opened_trace->orientation_mul_factor = (double) opened_trace->corosion_sens_num /
                                                128.0;
        opened_trace->Orientation_OFF = 1;
        opened_trace->Orinteation_Direct_count=1;
        opened_trace->Orientation_shift=0;
        opened_trace->Orientation_shift_2=0;

        opened_trace->sens_for_thick=0;
        opened_trace->sens_for_thick_count=1;

        // Пропишем в trc-файл флаг использования ориентации с файла rec.mat
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_NAV_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_NAV_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.mat

        // Пропишем в trc-файл флаг использования ориентации с файла rec.vog
        if (GetPrivateProfileString(EPRO_SECTION, Get_Orient_from_VOG_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( key_value, "0");
               WritePrivateProfileString(EPRO_SECTION,
                                         Get_Orient_from_VOG_KEY,
                                         key_value,
                                         opened_trace->trc_file_name
                                        );
             };
         };
        // Прописали в trc-файл флаг использования ориентации с файла rec.vog

        opened_trace->smooth_win_length[0]=8;

        opened_trace->VOG_koeff_umn=100;
        opened_trace->ACCEL_koeff_umn=1000;

        // Выставим инвертирование для нужных датчиков
        // (в нашем случае для всех НЕ НАДО)
        if (GetPrivateProfileString(EPRO_SECTION, Invert_sens_data_KEY, "нет", key_value,
                       sizeof(key_value), opened_trace->trc_file_name)!=0)
         {
            if (strcmp( key_value, "нет") == 0) {
               strcpy( opened_trace->invert_sens_data_text,"");

               for (i=0; i<MAX_CORROZION_NUM; i++) {
                  opened_trace->invert_sens_data[i]=0;
                };
             };
         };
        // Выставили инвертирование для нужных датчиков

      }; // default:

    }; //  switch (trace_list[reg_trc].trace->corosion_sens_num) {


   // читаем из trc-файла сортировочные данные первого сектора
   for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
      sprintf(key_name, "%s%i", SENS_SORT_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                                  sizeof(key_value), opened_trace->trc_file_name) != 0)
       {
         opened_trace->sens_sort[i]=atoi(key_value);
       };
    }; // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
   // прочитали из trc-файла сортировочные данные первого сектора

   // Размножим сортировочные данные первого сектора на все датчики
   for (j=1; j<opened_trace->sektors_num; j++) {
      for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
          opened_trace->sens_sort[i+j*opened_trace->sens_num_in_sektor] = 
              opened_trace->sens_sort[i]+j*opened_trace->sens_num_in_sektor;
       };
    };
   // Размножили сортировочные данные первого сектора на все датчики


  return KRT_OK;
}; // long WINAPI init_bort_factor_data (T_OPENED_TRACE * opened_trace) {


long WINAPI write_data_to_trc(T_OPENED_TRACE * opened_trace)
{
   char key_name[1024];
   char key_value[1024];
   long i;


   sprintf(key_name, "%s", VogMat_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "нет", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)!=0)
    {
       if (strcmp( key_value, "нет") == 0) {
          WritePrivateProfileString(EPRO_SECTION, key_name, "rec.mat",
                                     opened_trace->trc_file_name);
        };
    };

   sprintf(key_name, "%s", VogNav_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "нет", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)!=0)
    {
       if (strcmp( key_value, "нет") == 0) {
          WritePrivateProfileString(EPRO_SECTION, key_name, "rec.vog",
                                     opened_trace->trc_file_name);
        };
    };

   sprintf(key_name, "%s", VOG_koeff_umn_KEY);
   sprintf(key_value, "%i", opened_trace->VOG_koeff_umn);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);

   sprintf(key_name, "%s", ACCEL_koeff_umn_KEY);
   sprintf(key_value, "%i", opened_trace->ACCEL_koeff_umn);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);


   // запишем в trc-файл длинну трассы в отсчетах одометра
   sprintf(key_name, "%s", TRACE_LEN_KEY);
   sprintf(key_value, "%i", opened_trace->trace_len);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл длинну трассы в отсчетах одометра

   // запишем в trc-файл длинну трассы необходимую для просмотра
   sprintf(key_name, "%s", VIEW_LEN_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->trace_len);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл длинну трассы необходимую для просмотра


   // запишем в trc-файл шаг одометра
   sprintf(key_name, "%s", TRACE_STEP_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->trace_step);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл шаг одометра

   // запишем в trc-файл время работы на трассе в милисек.
   sprintf(key_name, "%s", TRACE_TIME_KEY);
   sprintf(key_value, "%i", opened_trace->trace_time);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл время работы на трассе в милисек.

   // запишем в trc-файл путь на рабочий каталог
   sprintf(key_name, "%s", PATH_DATA_KEY);
   sprintf(key_value, "%s", opened_trace->path_data);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл путь на рабочий каталог

   // запишем в trc-файл имя первого файла записи
   sprintf(key_name, "%s", FIRST_FILE_NAME_KEY);
   sprintf(key_value, "%s", opened_trace->first_file_name);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл имя первого файла записи

   // запишем в trc-файл кол-во файлов данных
   sprintf(key_name, "%s", NUM_FILE_DATA_KEY);
   sprintf(key_value, "%i", opened_trace->num_file_data);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл кол-во файлов данных

   // запишем в trc-файл имя индексного файла вместе с полным путем
   sprintf(key_name, "%s", INDEX_FILE_NAME_KEY);
   sprintf(key_value, "%s", opened_trace->idx_file_name);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл имя индексного файла вместе с полным путем

   // запишем в trc-файл путь на профильный ini-файл
   sprintf(key_name, "%s", PROFIL_INI_FILE_NAME_KEY);
   sprintf(key_value, "");
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл путь на профильный ini-файл

   // запишем в trc-файл общее кол-во датчиков коррозии в снаряде
   sprintf(key_name, "%s", CORROSION_SENS_NUM_KEY);
   sprintf(key_value, "%i", opened_trace->corosion_sens_num);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл общее кол-во датчиков коррозии в снаряде

   // запишем в trc-файл максимальное возможное показание магнитных данных
   sprintf(key_name, "%s", MAX_DATA_CODE_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->max_data_code);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл максимальное возможное показание магнитных данных

   // запишем в trc-файл кол-во поясов датчиков в снаряде
   sprintf(key_name, "%s", GROUP_NUM_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->group_num);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл кол-во поясов датчиков в снаряде

   // запишем в trc-файл кол-во датчиков коррозии в каждом поясе
   for (i=0; i<opened_trace->group_num; i++) {
      sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                     sizeof(key_value), opened_trace->trc_file_name)==0)
       {
         // на всякий случай перечитали значение,
         // если оно изменилось перед повторной регистрацией,
         // но его там нет
         sprintf(key_value, "%i", opened_trace->linesense_size[i]);
       }; 
      WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                               opened_trace->trc_file_name);
    }; // for (i=0; i<opened_trace->group_num; i++) {
   // записали в trc-файл кол-во датчиков коррозии в каждом поясе

   // запишем в trc-файл усиление в каждом поясе
   for (i=0; i<opened_trace->group_num; i++) {
      sprintf(key_name, "%s%i", Amplification_Group_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                     sizeof(key_value), opened_trace->trc_file_name)==0)
       {
         // на всякий случай перечитали значение,
         // если оно изменилось перед повторной регистрацией,
         // но его там нет
         sprintf(key_value, "%i", opened_trace->Amplification_Group[i]);
       }; 
      WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                               opened_trace->trc_file_name);
    }; // for (i=0; i<opened_trace->group_num; i++) {
   // записали в trc-файл усиление в каждом поясе

   // запишем в trc-файл кол-во секторов с датчиками коррозии
   sprintf(key_name, "%s", SEKTORS_NUM_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->sektors_num);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл кол-во  секторов с датчиками коррозии

   // запишем в trc-файл кол-во датчиков коррозии в секторе
   sprintf(key_name, "%s", SENS_NUM_IN_SEKTOR_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->sens_num_in_sektor);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл кол-во датчиков коррозии в секторе

   // запишем в trc-файл коэффициент умножения ориентации
   sprintf(key_name, "%s", ORIENTATION_MUL_FACTOR_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%f", opened_trace->orientation_mul_factor);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл  коэффициент умножения ориентации

   // запишем в trc-файл признак отключения ориентации
   sprintf(key_name, "%s", Orientation_OFF_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->Orientation_OFF);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл признак отключения ориентации

   // запишем в trc-файл направление пересчета ориентации
   sprintf(key_name, "%s", Orinteation_Direct_count_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->Orinteation_Direct_count);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл  направление пересчета ориентации

   // запишем в trc-файл поправку ориентации
   sprintf(key_name, Orientation_shift_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%d", opened_trace->Orientation_shift);
    };
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                             opened_trace->trc_file_name);
   // записали в trc-файл поправку ориентации

   // запишем в trc-файл поправку ориентации второго пояса относ. первого
   sprintf(key_name, Orientation_shift_2_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%d", opened_trace->Orientation_shift_2);
    };
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                             opened_trace->trc_file_name);
   // записали в trc-файл поправку ориентации второго пояса относ. первого


   // запишем в trc-файл признак отключения ориентации
   sprintf(key_name, "%s", Smooth_data_OFF_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->Smooth_data_OFF);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл признак отключения ориентации


   // запишем в trc-файл признак пересчета ориентации с файла rec.mat
   sprintf(key_name, "%s", Get_Orient_from_NAV_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->Get_Orient_from_NAV);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл признак пересчета ориентации с файла rec.mat

   // запишем в trc-файл признак пересчета ориентации с файла rec.vog
   sprintf(key_name, "%s", Get_Orient_from_VOG_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%i", opened_trace->Get_Orient_from_VOG);
    }; 
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                            opened_trace->trc_file_name);
   // записали в trc-файл признак пересчета ориентации с файла rec.vog


   // запишем в trc-файл длинну окна сглаживания для каждого пояса
   for (i=0; i<opened_trace->group_num; i++) {
      sprintf(key_name, "%s%i", Smooth_win_length_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                     sizeof(key_value), opened_trace->trc_file_name)==0)
       {
         // на всякий случай перечитали значение,
         // если оно изменилось перед повторной регистрацией,
         // но его там нет
         sprintf(key_value, "%d", opened_trace->smooth_win_length[i]);
       };
      WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                                opened_trace->trc_file_name);
    };
   // записали в trc-файл длинну окна сглаживания для каждого пояса

   // запишем в trc-файл номер датчика по которому считать толщину
   sprintf(key_name, sens_for_thick_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%d", opened_trace->sens_for_thick);
    };
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                             opened_trace->trc_file_name);
   // записали в trc-файл номер датчика по которому считать толщину

   // запишем в trc-файл количество датчиков по которым считать толщину
   sprintf(key_name, sens_for_thick_count_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "%d", opened_trace->sens_for_thick_count);
    };
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                             opened_trace->trc_file_name);
   // записали в trc-файл количество датчиков по которым считать толщину


   // запишем в trc-файл таблицу инвертирования сигнало датчиков
   // читаем из trc-файла таблицу инвертирования сигнало датчиков
   // чтобы не затереть существующее значение
   sprintf(key_name, Invert_sens_data_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, opened_trace->invert_sens_data_text);
    } else {
      strcpy(opened_trace->invert_sens_data_text, key_value);
    };
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                             opened_trace->trc_file_name);
   // записали в trc-файл таблицу инвертирования сигнало датчиков

   // запишем в trc-файл таблицу удаляемых из развертки датчиков
   // читаем из trc-файла таблицу удаляемых из развертки датчиков
   // чтобы не затереть существующее значение
   sprintf(key_name, Delete_sens_data_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "");
    };
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                             opened_trace->trc_file_name);
   // записали в trc-файл таблицу удаляемых из развертки датчиков

   // запишем в trc-файл таблицу пропущенных в фифошке датчиков
   // читаем из trc-файла таблицу пропущенных в фифошке датчиков
   // чтобы не затереть существующее значение
   sprintf(key_name, Sckip_sens_data_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      // на всякий случай перечитали значение,
      // если оно изменилось перед повторной регистрацией,
      // но его там нет
      sprintf(key_value, "");
    };
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                             opened_trace->trc_file_name);
   // записали в trc-файл таблицу пропущенных в фифошке датчиков


   // запишем в trc-файл сортировочные данные первого сектора
   for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
      sprintf(key_name, "%s%d", SENS_SORT_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                     sizeof(key_value), opened_trace->trc_file_name)==0)
       {
         // на всякий случай перечитали значение,
         // если оно изменилось перед повторной регистрацией,
         // но его там нет
         sprintf(key_value, "%i", opened_trace->sens_sort[i]);
       }; 
      WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                               opened_trace->trc_file_name);
    };
   // записали в trc-файл сортировочные данные первого сектора

   // запишем в trc-файл продольное смещение датчиков первого сектора
   for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
      sprintf(key_name, "%s%d", SENS_SHIFT_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                     sizeof(key_value), opened_trace->trc_file_name)==0)
       {
         // на всякий случай перечитали значение,
         // если оно изменилось перед повторной регистрацией,
         // но его там нет
         sprintf(key_value, "%i", opened_trace->sens_shift[i]);
       }; 
      WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                               opened_trace->trc_file_name);
    };
   // записали в trc-файл продольное смещение датчиков первого сектора

   // запишем в trc-файл максимальную температуру
   sprintf(key_name, MaxTermo_KEY);
   sprintf(key_value, "%d", opened_trace->MaxTermo);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                             opened_trace->trc_file_name);
   // записали в trc-файл максимальную температуру

   // запишем в trc-файл минимальную температуру
   sprintf(key_name, MinTermo_KEY);
   sprintf(key_value, "%d", opened_trace->MinTermo);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                             opened_trace->trc_file_name);
   // записали в trc-файл минимальную температуру

   return KRT_OK;
}; // long WINAPI write_data_to_trc

long WINAPI read_data_from_trc(T_OPENED_TRACE * opened_trace)
{
   char key_name[1024];
   char key_value[1024];

   char tmp_str[1024];

   char seps[]   = " ,\t\n";
   char sub_seps[]   = " -\t\n";
   char *token;
   char *sub_token;
   long low_range, high_range, next_token; 

   long i, j;
   long min_sens_shift;

   long curr_delete;
   long new_group_beg_sens;
   long cur_group;


   sprintf(key_name, "%s", ACCEL_koeff_umn_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения коэффициента умножения акселерометров из файла %s.", opened_trace->trc_file_name);
    };
   opened_trace->ACCEL_koeff_umn=atoi(key_value);


   sprintf(key_name, "%s", VOG_koeff_umn_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения коэффициента умножения гироскопов из файла %s.", opened_trace->trc_file_name);
    };
   opened_trace->VOG_koeff_umn=atoi(key_value);

   // читаем из trc-файла длинну трассы в отсчетах одометра
   sprintf(key_name, "%s", TRACE_LEN_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения длинны трассы из файла %s.", opened_trace->trc_file_name);
      return KRT_ERR;
    };
   opened_trace->trace_len=atoi(key_value);
   // прочитали из trc-файла длинну трассы в отсчетах одометра

   // читаем из trc-файла длинну трассы в отсчетах одометра
   sprintf(key_name, "%s", VIEW_LEN_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
       opened_trace->view_len = opened_trace->trace_len;
    } else {
       opened_trace->view_len = atoi(key_value);
    };
   // прочитали из trc-файла длинну трассы в отсчетах одометра


   // читаем из trc-файла шаг одометра
   sprintf(key_name, "%s", TRACE_STEP_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения шага одометра из файла %s.", opened_trace->trc_file_name);
      return KRT_ERR;
    };
   opened_trace->trace_step=atoi(key_value);
   // прочитали из trc-файла шаг одометра

   // читаем из trc-файла  время работы на трассе в милисек.
   sprintf(key_name, "%s", TRACE_TIME_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения времени из файла %s.", opened_trace->trc_file_name);
      return KRT_ERR;
    };
   opened_trace->trace_time=atoi(key_value);
   // прочитали из trc-файла  время работы на трассе в милисек.

   // читаем из trc-файла путь на рабочий каталог
   sprintf(key_name, "%s", PATH_DATA_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      // вычленим строку пути до trc-файла (без имени самого файла)
      strcpy(key_value, opened_trace->trc_file_name);

      while((strlen(key_value)>0) && (key_value[strlen(key_value)-1]!='\\')) {
        key_value[strlen(key_value)-1]=0;
      };
    };
   strcpy(opened_trace->path_data, key_value);
   // прочитли из trc-файла путь на рабочий каталог

   // читаем из trc-файла имя первого файла записи
   sprintf(key_name, "%s", FIRST_FILE_NAME_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения имени первого файла из файла %s.", opened_trace->trc_file_name);
      return KRT_ERR;
    };
   strcpy(opened_trace->first_file_name, key_value);
   // прочитли из trc-файла имя первого файла записи

   // читаем из trc-файла кол-во файлов данных
   sprintf(key_name, "%s", NUM_FILE_DATA_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения кол-ва файлов из файла %s.", opened_trace->trc_file_name);
      return KRT_ERR;
    };
   opened_trace->num_file_data=atoi(key_value);
   // прочитали из trc-файла кол-во файлов данных

   // читаем из trc-файла имя индексного файла вместе с полным путем
   sprintf(key_name, "%s", INDEX_FILE_NAME_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      // вычленим строку пути до trc-файла (без имени самого файла)
      strcpy(key_value, opened_trace->trc_file_name);

      while((strlen(key_value)>0) && (key_value[strlen(key_value)-1]!='\\')) {
        key_value[strlen(key_value)-1]=0;
      };
    };

   strcpy(opened_trace->idx_file_name, key_value);
   strcat(opened_trace->idx_file_name, IDX_FILE_NAME);

   strcpy(opened_trace->index_extend_sens.file_name, key_value);
   strcat(opened_trace->index_extend_sens.file_name, EXT_IDX_FILE_NAME);

   strcpy(opened_trace->index_power_lines.file_name, key_value);
   strcat(opened_trace->index_power_lines.file_name, PWR_IDX_FILE_NAME);

   strcpy(opened_trace->index_bypass.file_name, key_value);
   strcat(opened_trace->index_bypass.file_name, BPS_IDX_FILE_NAME);
   // прочитли из trc-файла имя индексного файла вместе с полным путем

   // прочитаем из trc-файла ключ PigL3
   opened_trace->PigL3 = 0;
   if (GetPrivateProfileString("Trace", "PigL3", "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      opened_trace->PigL3 = 0;
    } else {
      opened_trace->PigL3 = atoi(key_value);
    };
   // прочитали из trc-файла ключ PigL3

   // читаем из trc-файла общее кол-во датчиков коррозии в снаряде
   sprintf(key_name, "%s", CORROSION_SENS_NUM_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения кол-ва датчиков из файла %s.", opened_trace->trc_file_name);
      return KRT_ERR;
    };
   opened_trace->corosion_sens_num=atoi(key_value);
   // прочитали из trc-файла общее кол-во датчиков коррозии в снаряде

   // читаем из trc-файла максимальное возможное показание магнитных данных
   sprintf(key_name, "%s", MAX_DATA_CODE_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения кол-ва датчиков из файла %s.", opened_trace->trc_file_name);
      opened_trace->max_data_code=3993;
    } else {
      opened_trace->max_data_code=atoi(key_value);
    };
   // прочитали из trc-файла максимальное возможное показание магнитных данных

   // читаем из trc-файла кол-во поясов датчиков в снаряде
   sprintf(key_name, "%s", GROUP_NUM_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения кол-ва поясов из файла %s.", opened_trace->trc_file_name);
      return KRT_ERR;
    };
   opened_trace->group_num=atoi(key_value);
   // прочитали из trc-файла кол-во поясов датчиков в снаряде

   // читаем из trc-файла кол-во датчиков коррозии в каждом поясе
   for (i=0; i<opened_trace->group_num; i++) {
      sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                                  sizeof(key_value), opened_trace->trc_file_name) == 0)
       {
         sprintf (drvError, "Ошибка чтения кол-ва датчиков в поясах из файла %s.", opened_trace->trc_file_name);
         break;
       };
      opened_trace->linesense_size[i]=atoi(key_value);
    }; // for (i=0; i<opened_trace->group_num; i++)
   // прочитали из trc-файла кол-во датчиков коррозии в каждом поясе

   // читаем из trc-файла усиление в каждом поясе
   for (i=0; i<opened_trace->group_num; i++) {
      sprintf(key_name, "%s%i", Amplification_Group_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                                  sizeof(key_value), opened_trace->trc_file_name) == 0)
       {
         sprintf (drvError, "Ошибка чтения кол-ва датчиков в поясах из файла %s.", opened_trace->trc_file_name);
         break;
       };
      opened_trace->Amplification_Group[i]=atoi(key_value);
    }; // for (i=0; i<opened_trace->group_num; i++)
   // прочитали из trc-файла усиление в каждом поясе

   // читаем из trc-файла кол-во секторов с датчиками коррозии
   sprintf(key_name, "%s", SEKTORS_NUM_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения кол-ва секторов из файла %s.", opened_trace->trc_file_name);
      return KRT_ERR;
    };
   opened_trace->sektors_num=atoi(key_value);
   // прочитали из trc-файла кол-во секторов с датчиками коррозии

   // читаем из trc-файла кол-во датчиков коррозии в секторе
   sprintf(key_name, "%s", SENS_NUM_IN_SEKTOR_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения кол-ва датчиков в секторе из файла %s.", opened_trace->trc_file_name);
      return KRT_ERR;
    };
   opened_trace->sens_num_in_sektor=atoi(key_value);
   // прочитали из trc-файла кол-во датчиков коррозии в секторе

   // читаем из trc-файла  коеффициент умножения ориентации
   sprintf(key_name, "%s", ORIENTATION_MUL_FACTOR_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения коеффициент умножения ориентации %s.", opened_trace->trc_file_name);
      opened_trace->orientation_mul_factor = 1;
    } else {
      opened_trace->orientation_mul_factor=atof(key_value);
    };
   // прочитали из trc-файла  коеффициент умножения ориентации

   // читаем из trc-файла признак отключения ориентации
   sprintf(key_name, "%s", Orientation_OFF_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения признак отключения ориентации %s.", opened_trace->trc_file_name);
      opened_trace->Orientation_OFF=0;
    } else {
      opened_trace->Orientation_OFF=atoi(key_value);
    };
   // прочитали из trc-файла  признак отключения ориентации

   // читаем из trc-файла направления пересчета ориентации
   sprintf(key_name, "%s", Orinteation_Direct_count_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения признак отключения ориентации %s.", opened_trace->trc_file_name);
      opened_trace->Orinteation_Direct_count=0;
    } else {
      opened_trace->Orinteation_Direct_count=atoi(key_value);
    };
   // прочитали из trc-файла направления пересчета ориентации

   // читаем из trc-файла поправку ориентации
   sprintf(key_name, "%s", Orientation_shift_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения признак отключения ориентации %s.", opened_trace->trc_file_name);
      opened_trace->Orientation_shift=0;
    } else {
      opened_trace->Orientation_shift=atoi(key_value);
    };
   // прочитали из trc-файла поправку ориентации

   // читаем из trc-файла поправку ориентации второго пояса относ. первого
   sprintf(key_name, "%s", Orientation_shift_2_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения признак отключения ориентации %s.", opened_trace->trc_file_name);
      opened_trace->Orientation_shift_2=0;
    } else {
      opened_trace->Orientation_shift_2=atoi(key_value);
    };
   // прочитали из trc-файла поправку ориентации второго пояса относ. первого

   // читаем из trc-файл признак пересчета ориентации с файла rec.mat
   sprintf(key_name, "%s", Get_Orient_from_NAV_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения признак отключения ориентации %s.", opened_trace->trc_file_name);
      opened_trace->Get_Orient_from_NAV=0;
    } else {
      opened_trace->Get_Orient_from_NAV=atoi(key_value);
    };
   // прочитали из trc-файл признак пересчета ориентации с файла rec.mat


   // читаем из trc-файл признак пересчета ориентации с файла rec.vog
   sprintf(key_name, "%s", Get_Orient_from_VOG_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения признак отключения ориентации %s.", opened_trace->trc_file_name);
      opened_trace->Get_Orient_from_VOG=0;
    } else {
      opened_trace->Get_Orient_from_VOG=atoi(key_value);
    };
   // прочитали из trc-файл признак пересчета ориентации с файла rec.vog


   // читаем из trc-файла признак отключения ориентации
   sprintf(key_name, "%s", Smooth_data_OFF_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения признак отключения сглаживания данных %s.", opened_trace->trc_file_name);
      opened_trace->Smooth_data_OFF=0;
    } else {
      opened_trace->Smooth_data_OFF=atoi(key_value);
    };
   // прочитали из trc-файла  признак отключения ориентации

   // читаем из trc-файла длинну окна сглаживания
   for (i=0; i<opened_trace->group_num; i++) {
      sprintf(key_name, "%s%i", Smooth_win_length_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                                  sizeof(key_value), opened_trace->trc_file_name) == 0)
       {
         sprintf (drvError, "Ошибка чтения окна сглаживания %s.", opened_trace->trc_file_name);
         opened_trace->smooth_win_length[i]=8;
       } else {
         opened_trace->smooth_win_length[i]=atoi(key_value);
       };
      if (opened_trace->smooth_win_length[i]<2) opened_trace->smooth_win_length[i]=8;
    };
   // прочитали из trc-файла длинну окна сглаживания

   // читаем из trc-файла  номер датчика по которому считать толщину
   sprintf(key_name, "%s", sens_for_thick_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      opened_trace->sens_for_thick=0;
    } else {
      opened_trace->sens_for_thick=atoi(key_value);
    };
   // прочитали из trc-файла  номер датчика по которому считать толщину

   // читаем из trc-файла кол-во датчиков по которым считать толщину
   sprintf(key_name, "%s", sens_for_thick_count_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      opened_trace->sens_for_thick_count=1;
    } else {
      opened_trace->sens_for_thick_count=atoi(key_value);
    };
   // прочитали из trc-файла кол-во датчиков по которым считать толщину


   // читаем из trc-файла таблицу инвертирования сигнало датчиков
   sprintf(key_name, Invert_sens_data_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      sprintf (drvError, "Ошибка чтения коеффициент умножения ориентации %s.", opened_trace->trc_file_name);
    } else {
      strcpy(opened_trace->invert_sens_data_text, key_value);
      strcpy(tmp_str, key_value);
      token = strtok(key_value, seps );
      next_token=1;
      while (token!=NULL) {
         sub_token = strtok(token, sub_seps );
         if (sub_token==NULL) {
             low_range=0;
          } else {
             low_range=atoi(sub_token);
          };
         sub_token = strtok(NULL, seps );
         if (sub_token==NULL) {
             high_range=low_range;
          } else {
             high_range=atoi(sub_token);
          };
         if (high_range>=low_range) {
             for (i=low_range; i<=high_range; i++) {
                opened_trace->invert_sens_data[i]=1;
             };
          };
         strcpy(key_value, tmp_str);
         token = strtok(key_value, seps );
         for (i=0; i<next_token; i++) {
            token = strtok(NULL, seps);
          };
         next_token++;
       };
    };
   // прочитали таблицу инвертирования сигнало датчиков

   // читаем из trc-файла таблицу удаления датчиков из записи
   for (i=0; i<opened_trace->corosion_sens_num; i++) {
      opened_trace->Delete_sens_data[i] = 0;
    };

   sprintf(key_name, Delete_sens_data_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
      for (i=0; i<opened_trace->group_num; i++) {
         opened_trace->real_number_sensor_in_group[i] =
                                      opened_trace->linesense_size[i];
       };
    } else {
      for (i=0; i<opened_trace->group_num; i++) {
         opened_trace->real_number_sensor_in_group[i] =
                                      opened_trace->linesense_size[i];
       };

      strcpy(tmp_str, key_value);
      token = strtok(key_value, seps );
      next_token=1;
      while (token!=NULL) {
         sub_token = strtok(token, sub_seps );
         if (sub_token==NULL) {
             low_range=0;
          } else {
             low_range=atoi(sub_token);
          };
         sub_token = strtok(NULL, seps );
         if (sub_token==NULL) {
             high_range=low_range;
          } else {
             high_range=atoi(sub_token);
          };
         if (high_range>=low_range) {
             for (i=low_range; i<=high_range; i++) {
                opened_trace->Delete_sens_data[i]=1;
             };
          };
         strcpy(key_value, tmp_str);
         token = strtok(key_value, seps );
         for (i=0; i<next_token; i++) {
            token = strtok(NULL, seps);
          };
         next_token++;
       };

      cur_group=0;
      curr_delete=0;
      new_group_beg_sens = opened_trace->linesense_size[cur_group];

      for (i=0; i<opened_trace->corosion_sens_num; i++) {
         if (i==new_group_beg_sens) {
            cur_group++;
            curr_delete=0;
            new_group_beg_sens += opened_trace->linesense_size[cur_group];
          };
         if (opened_trace->Delete_sens_data[i]==1) {
            curr_delete++;
            opened_trace->real_number_sensor_in_group[cur_group]--;
            opened_trace->Delete_sens_data[i] = SENSE_DELETE_FLAG;
          } else {
            opened_trace->Delete_sens_data[i]+=curr_delete;
          };
       };
    };
   // прочитали таблицу  удаления датчиков из записи

   // читаем из trc-файла таблицу пропуска датчиков в фифошке
   for (i=0; i<opened_trace->corosion_sens_num; i++) {
      opened_trace->Sckip_sens_data[i] = 0;
    };

   sprintf(key_name, Sckip_sens_data_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                  sizeof(key_value), opened_trace->trc_file_name)==0)
    {
    } else {
      strcpy(tmp_str, key_value);
      token = strtok(key_value, seps );
      next_token=1;
      while (token!=NULL) {
         sub_token = strtok(token, sub_seps );
         if (sub_token==NULL) {
             low_range=0;
          } else {
             low_range=atoi(sub_token);
          };
         sub_token = strtok(NULL, seps );
         if (sub_token==NULL) {
             high_range=low_range;
          } else {
             high_range=atoi(sub_token);
          };
         if (high_range>=low_range) {
             for (i=low_range; i<=high_range; i++) {
                opened_trace->Sckip_sens_data[i]=1;
             };
          };
         strcpy(key_value, tmp_str);
         token = strtok(key_value, seps );
         for (i=0; i<next_token; i++) {
            token = strtok(NULL, seps);
          };
         next_token++;
       };
    };
   // прочитали из trc-файла таблицу пропуска датчиков в фифошке


   // читаем из trc-файла сортировочные данные первого сектора
   for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
      sprintf(key_name, "%s%i", SENS_SORT_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                                  sizeof(key_value), opened_trace->trc_file_name) == 0)
       {
         sprintf (drvError, "Ошибка чтения сортировки из файла %s.", opened_trace->trc_file_name);
         return KRT_ERR;
       };
      opened_trace->sens_sort[i]=atoi(key_value);
    }; // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
   // прочитали из trc-файла сортировочные данные первого сектора

   // Размножим сортировочные данные первого сектора на все датчики
   for (j=1; j<opened_trace->sektors_num; j++) {
      for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
          opened_trace->sens_sort[i+j*opened_trace->sens_num_in_sektor] = 
              opened_trace->sens_sort[i]+j*opened_trace->sens_num_in_sektor;
       };
    };
   // Размножили сортировочные данные первого сектора на все датчики

   // читаем из trc-файла продольное смещение датчиков первого сектора
   for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
      sprintf(key_name, "%s%i", SENS_SHIFT_KEY, i);
      if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                                  sizeof(key_value), opened_trace->trc_file_name) == 0)
       {
         sprintf (drvError, "Ошибка чтения смещений из файла %s.", opened_trace->trc_file_name);
         return KRT_ERR;
       };
      opened_trace->sens_shift[i]=atoi(key_value);
    }; // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
   // прочитали из trc-файла продольное смещение датчиков первого сектора

   // вычислим максимум и минимум смещений
   opened_trace->max_sens_shift = -0xFFFF;
   min_sens_shift = 0xFFFF;
   for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
       if (opened_trace->max_sens_shift<opened_trace->sens_shift[i]) {
           opened_trace->max_sens_shift=opened_trace->sens_shift[i];
        };  
       if (min_sens_shift>opened_trace->sens_shift[i]) {
           min_sens_shift=opened_trace->sens_shift[i];
        };  
    };
   // вычислили максимум и минимум смещений

   // если минимум не == 0 надо поправить
   if (min_sens_shift != 0) {
      for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
         opened_trace->sens_shift[i]-=min_sens_shift;
       };
      opened_trace->max_sens_shift -= min_sens_shift;
    }; // if (opened_trace->min_sens_shift < 0) {
   // убирали все отрицательные значения

   // Размножим продольное смещение датчиков первого сектора на все датчики
   for (j=1; j<opened_trace->sektors_num; j++) {
      for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
          opened_trace->sens_shift[i+j*opened_trace->sens_num_in_sektor] = 
              opened_trace->sens_shift[i];
       };
    };
   // Размножили продольное смещение датчиков первого сектора на все датчики


   // читаем из trc-файла максимальную температуру
   sprintf(key_name, "%s", MaxTermo_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения максимальную температуру %s.", opened_trace->trc_file_name);
      opened_trace->MaxTermo=100;
    } else {
      opened_trace->MaxTermo=atoi(key_value);
    };
   // прочитали из trc-файла  максимальную температуру

   // читаем из trc-файла минимальную температуру
   sprintf(key_name, "%s", MinTermo_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      sprintf (drvError, "Ошибка чтения минимальную температуру %s.", opened_trace->trc_file_name);
      opened_trace->MinTermo=-100;
    } else {
      opened_trace->MinTermo=atoi(key_value);
    };
   // прочитали из trc-файла  минимальную температуру

   return KRT_OK;
}; // long WINAPI read_data_from_trc


long read_data_profil_ini(T_OPENED_TRACE * opened_trace)
{
   char key_name[1024];
   char key_value[1024];
   char profil_ini_file_name[1024];

   long i, j, k;

   char seps[]   = " ,\t\n";
   char *token;
   long next_token; 

   FILE *prf_calibrate;


   // начальная инициализация массива на всякий случай
   k=1000;
   for (j=0; j < MAX_PROFILE_CALIBRATE; j++) {
      for (i=0; i<  MAX_PROFILE_NUM_SENS; i++) {
         opened_trace->profil_calibrate[i][j]=k;
       };
      k+=100;
    };

   // читаем из trc-файла путь на профильный ini-файл
   sprintf(key_name, "%s", PROFIL_INI_FILE_NAME_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value), opened_trace->trc_file_name) == 0)
    {
      // вычленим строку пути до trc-файла (без имени самого файла)
      strcpy(key_value, opened_trace->trc_file_name);

      while((strlen(key_value)>0) && (key_value[strlen(key_value)-1]!='\\')) {
        key_value[strlen(key_value)-1]=0;
      };
      strcat(key_value, PROFIL_INI_FILE_NAME);
    };
   strcpy(profil_ini_file_name, key_value);
   // прочитли из trc-файла путь на профильный ini-файл

   prf_calibrate=fopen(profil_ini_file_name, "rb");
   if (prf_calibrate == NULL) {
         sprintf(drvError, "Нет калибровки профильных датчиков(read_data_profil_ini)");
         return KRT_ERR;
    };
   fclose(prf_calibrate);

   // читаем из trc-файла калибровку профильных датчиков
   for (i=0; i < opened_trace->corosion_sens_num/2; i++) {
      sprintf(key_name, "%s%i", Profil_calibrate_KEY, i);
      if (GetPrivateProfileString(PROFILE_SECTION, key_name, "", key_value,
                                  sizeof(key_value), profil_ini_file_name) != 0)
       {
         next_token=0;
         token = strtok(key_value, seps);
         while (token!=NULL) {
            opened_trace->profil_calibrate[i][next_token]=atoi(token);

/*            opened_trace->profil_calibrate[i][next_token] = 

                  ~opened_trace->profil_calibrate[i][next_token];

             opened_trace->profil_calibrate[i][next_token] &= 0x0fff;
*/
            next_token++;
            token = strtok(NULL, seps);
          };

         for (j=next_token; j < MAX_PROFILE_CALIBRATE; j++) {
            opened_trace->profil_calibrate[i][j] = 
                    opened_trace->profil_calibrate[i][j-1] - 100;
          };
//         opened_trace->profil_calibrate[i][next_token]=opened_trace->max_data_code;
       };
    };

   // прочитали из trc-файла калибровку профильных датчиков

   // запишем в trc-файл пути на навигационные данные
   sprintf(key_name, "%s", VogMat_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value),  opened_trace->trc_file_name) == 0)
    {
      // читаем из файла калибровки профиля пути на навигационные данные
      if (GetPrivateProfileString(Profile_orient_SECTION, key_name, "", key_value,
                                  sizeof(key_value), profil_ini_file_name) == 0)
       {
         // вычленим строку пути до trc-файла (без имени самого файла)
         strcpy(key_value, opened_trace->trc_file_name);

         while((strlen(key_value)>0) && (key_value[strlen(key_value)-1]!='\\')) {
           key_value[strlen(key_value)-1]=0;
         };
         strcat(key_value, VogMat_FILE_NAME);
       };

      WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                                opened_trace->trc_file_name);
    };

   // прочитаем из trc-файл пути на навигационные данные
   sprintf(key_name, "%s", VogNav_KEY);
   if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                               sizeof(key_value),  opened_trace->trc_file_name) == 0)
    {
      if (GetPrivateProfileString(Profile_orient_SECTION, key_name, "", key_value,
                                  sizeof(key_value), profil_ini_file_name) == 0)
       {
         // вычленим строку пути до trc-файла (без имени самого файла)
         strcpy(key_value, opened_trace->trc_file_name);

         while((strlen(key_value)>0) && (key_value[strlen(key_value)-1]!='\\')) {
           key_value[strlen(key_value)-1]=0;
         };
         strcat(key_value, VogNav_FILE_NAME);
       };

      WritePrivateProfileString(EPRO_SECTION, key_name, key_value,
                                opened_trace->trc_file_name);
   // прочитали из файла калибровки профиля пути на навигационные данные
    };

   return KRT_OK;
};

// Функция выделения памяти под структуру открытой трассы 
//(типа конструктор T_OPENED_TRACE)
T_OPENED_TRACE * WINAPI init_opened_trace() {

  T_OPENED_TRACE *space_for_trace;
  long i;

  space_for_trace = (T_OPENED_TRACE *) heap_alloc(sizeof(T_OPENED_TRACE));
  if (space_for_trace == NULL) {
     sprintf(drvError, "Нет памяти под открытую трассу(init_opened_trace)");
     return space_for_trace;
   };

  // обнулим поля тока что выделенной структуры (на всякий случай)
  space_for_trace->trace_len=0;
  space_for_trace->trace_step=0;
  space_for_trace->trace_time=0;
  strcpy(space_for_trace->path_data, ""); 
  strcpy(space_for_trace->first_file_name, ""); 
  strcpy(space_for_trace->trc_file_name, ""); 
  strcpy(space_for_trace->idx_file_name, ""); 
  space_for_trace->num_file_data=0;

  space_for_trace->corosion_sens_num=0;
  space_for_trace->group_num=0;

  space_for_trace->max_data_code=0;

  space_for_trace->Smooth_data_OFF=0;

  for (i=0; i<MAX_GROUP_NUM; i++) {
     space_for_trace->linesense_size[i]=0;
     space_for_trace->Amplification_Group[i]=0;
     space_for_trace->smooth_win_length[i] = 0;
   };

  space_for_trace->sektors_num=0;
  space_for_trace->sens_num_in_sektor=0;

  space_for_trace->max_sens_shift=0;

  for (i=0; i<MAX_CORROZION_NUM; i++) {
     space_for_trace->sens_shift[i]=0;
     space_for_trace->sens_sort[i]=i;
     space_for_trace->invert_sens_data[i]=0;
   };

  space_for_trace->orientation_mul_factor = 1.0;
  space_for_trace->Orientation_OFF=0;
  space_for_trace->Orientation_shift=0;
  space_for_trace->Orientation_shift_2=0;
  space_for_trace->Orinteation_Direct_count=0;
  space_for_trace->Get_Orient_from_NAV=0;
  space_for_trace->Get_Orient_from_VOG=0;

  space_for_trace->MaxTermo=-100;
  space_for_trace->MinTermo=100;

  space_for_trace->file_index=NULL;

  space_for_trace->list_loaded_data=NULL;

  space_for_trace->nodeType=0; 
  space_for_trace->nodeIndex=0;            
  space_for_trace->nodePos=0;
  space_for_trace->controlSize=0;

  space_for_trace->index_extend_sens.map_area_mem=NULL;
  space_for_trace->index_extend_sens.hFileMap=NULL;
  space_for_trace->index_extend_sens.file_data=NULL;

  space_for_trace->sens_for_thick=0;
  space_for_trace->sens_for_thick_count=1;


  space_for_trace->index_power_lines.map_area_mem=NULL;
  space_for_trace->index_power_lines.hFileMap=NULL;
  space_for_trace->index_power_lines.file_data=NULL;

  return space_for_trace;
}; // T_OPENED_TRACE * WINAPI init_opened_trace()

// Функция освобождения памяти под структурой открытой трассы
T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free) {

  if (p_free != NULL) {
      if ( p_free->file_index != NULL) {
         p_free->file_index = free_index_files(p_free->file_index, p_free->num_file_data);
       };

      p_free->list_loaded_data = free_list_loaded_data(p_free->list_loaded_data);

      if (p_free->index_extend_sens.file_data!=NULL) {
         fclose(p_free->index_extend_sens.file_data);
         p_free->index_extend_sens.file_data=NULL;
       };


      if (p_free->index_power_lines.file_data!=NULL) {
         fclose(p_free->index_power_lines.file_data);
         p_free->index_power_lines.file_data=NULL;
       };

      if (p_free->index_bypass.map_area_mem!=NULL) {
         UnmapViewOfFile(p_free->index_bypass.map_area_mem);
       };
      if (p_free->index_bypass.hFileMap!=NULL) {
         CloseHandle(p_free->index_bypass.hFileMap);
       };
      if (p_free->index_bypass.file_data!=NULL) {
         CloseHandle(p_free->index_bypass.file_data);
         p_free->index_bypass.file_data=NULL;
       };

      p_free = ( T_OPENED_TRACE *) heap_free(p_free);
   }; // if ((*p_free)!=NULL) {

  return p_free;
}; //  T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free)


// Функция выделения памяти под структуру индексов файлов в открытой трассе
// (типа конструктор T_INDEX_FILE)
T_INDEX_FILE*  WINAPI init_index_files(long num_file_data)
{
  long i;

  T_INDEX_FILE *file_index;

  file_index = (T_INDEX_FILE *) heap_alloc(sizeof(T_INDEX_FILE)*num_file_data);
  if (file_index == NULL) {
     sprintf(drvError, "Нет памяти под индексы файлов(init_index_files)");
     return file_index;
   };

  for (i=0; i<num_file_data; i++) {
     strcpy(file_index[i].file_name, "");
     file_index[i].beg_track=0;
     file_index[i].end_track=0;
     file_index[i].num_condition_seam=0;

     file_index[i].index_seam=NULL;

     file_index[i].file_data=NULL;
   };

  return file_index;
}; // T_INDEX_FILE*  WINAPI init_index_files(long num_file_data,

// функция прописывания имен в индексы файлов
long WINAPI init_name_files(T_OPENED_TRACE *p_trace,
                             char *first_file_name, long data_path_len) 
{
  long i;
  char cur_file_name[_MAX_PATH];
  T_INDEX_FILE* file_index;

  file_index = p_trace->file_index;

  strcpy(cur_file_name, first_file_name);

  for (i=0; i<p_trace->num_file_data; i++) {
     strcpy(file_index[i].file_name, cur_file_name);

     if (inc_file_name(&cur_file_name[data_path_len])==KRT_ERR) {
        strcat(drvError, "(init_name_files)");
        return KRT_ERR;
      };
   };

  return KRT_OK;
}; // long WINAPI init_name_files(


// Функция освобождения памяти под массив индексов файлов в открытой трассе
T_INDEX_FILE* WINAPI free_index_files(T_INDEX_FILE* p_free, long num_file_data) {
  long i;

  if (p_free != NULL) {
     for (i=0; i<num_file_data; i++) {
        if (p_free[i].index_seam != NULL) {
            p_free[i].index_seam =
                free_index_seams(p_free[i].index_seam, p_free[i].num_condition_seam);
         };

        if (p_free[i].file_data != NULL) {
            fclose(p_free[i].file_data);
            p_free[i].file_data=NULL;
         };
      };
     p_free = (T_INDEX_FILE*) heap_free(p_free);
   };

  return p_free;
}; // T_INDEX_FILE* WINAPI free_index_files(


// Функция выделения памяти под массив индексов условных швов в индексах файлов
// (типа конструктор T_INDEX_SEAM)
T_INDEX_SEAM * WINAPI init_index_seams(long num_condition_seam)
{
  long i;
  T_INDEX_SEAM *index_seam;

  index_seam = (T_INDEX_SEAM *) heap_alloc(sizeof(T_INDEX_SEAM) * num_condition_seam);
  if (index_seam == NULL) 
   {
     sprintf(drvError, "Нет памяти под индексы усл.швов(init_index_seams)");
     return index_seam;
   };

  for (i=0; i<num_condition_seam; i++) {
    index_seam[i].beg_track=0;
    index_seam[i].end_track=0;
    index_seam[i].shift_in_file=0;
    index_seam[i].beg_time=0;
    index_seam[i].end_time=0;
    index_seam[i].smooth_orientation_beg=0;

//    index_seam[i].smooth_data_beg=NULL;

    index_seam[i].head_of_condition_seam=NULL;
    index_seam[i].inquiry=NULL;
   }; //  for (i=0; i< p_init->num_condition_seam; i++) {

  return index_seam;
}; // long WINAPI init_index_seams(T_INDEX_FILE* p_init)


// Функция освобождения памяти под массив индексов условных швов в индексах файлов
T_INDEX_SEAM * WINAPI free_index_seams(T_INDEX_SEAM *p_free, long num_condition_seam) {
  long i;

  if (p_free != NULL) {
     for (i=0; i<num_condition_seam; i++) {

        if (p_free[i].inquiry != NULL) {
            p_free[i].inquiry = free_inquiry( p_free[i].inquiry);
         };

        if (p_free[i].head_of_condition_seam != NULL) {
           p_free[i].head_of_condition_seam = 
                free_condition_seam(p_free[i].head_of_condition_seam);
         };

//        if (p_free[i].smooth_data_beg != NULL) {
//            p_free[i].smooth_data_beg = 
//                free_smooth_data_beg(p_free[i].smooth_data_beg);
//         };

      };
     p_free = (T_INDEX_SEAM *) heap_free(p_free);
   };

  return p_free;
}; // T_INDEX_SEAM * WINAPI free_index_seams(

// Функция выделения памяти под массив индексов выравнивания измерений
// инициализация поля smooth_data_beg в структуре T_INDEX_SEAM
long * WINAPI init_smooth_data_beg(long  cor_num)
{
   long * space_smooth_data_beg;

   // выделим место под массив индексов выравнивания измерений
   space_smooth_data_beg = (long *)
                  heap_alloc (sizeof(long) * cor_num);
   if (space_smooth_data_beg == NULL) {
      sprintf(drvError, "Нет памяти под массив индексов выравнивания измерений(init_smooth_data_beg)");
      return space_smooth_data_beg;
    };

  return space_smooth_data_beg;
}; // long * WINAPI init_smooth_data_beg(long  cor_num)


// Функция освобождения памяти под массив  индексов выравнивания измерений
long * WINAPI free_smooth_data_beg(long *p_free) {
                  
  if (p_free != NULL) {
     p_free = (long *)heap_free(p_free);
   };

  return p_free;
}; // long * WINAPI free_smooth_data_beg(long *p_free) {


// Функция выделения памяти под дескриптор
// (типа конструктор T_CONDITION_SEAM)
T_CONDITION_SEAM * WINAPI init_condition_seam() {

  T_CONDITION_SEAM *descriptor;

  descriptor = (T_CONDITION_SEAM *) heap_alloc (sizeof(T_CONDITION_SEAM));
  if (descriptor == NULL) {
     sprintf(drvError, "Нет памяти под дескриптор(init_condition_seam)");
     return descriptor;
   };

  return descriptor;
}; // T_CONDITION_SEAM * WINAPI init_condition_seam() {

// Функция освобождения памяти под дескриптором
// (типа деструктор T_CONDITION_SEAM)
T_CONDITION_SEAM * WINAPI free_condition_seam(T_CONDITION_SEAM *p_free) {

  if (p_free != NULL) {
     p_free = (T_CONDITION_SEAM *) heap_free(p_free);
   };

  return p_free;
}; // T_CONDITION_SEAM * WINAPI free_index_seams(T_CONDITION_SEAM *p_free)


// Функция выделения памяти под массив измерений
// (типа конструктор T_RECORD_OF_ONE_CYCLE_INQUIRY)
T_RECORD_OF_ONE_CYCLE_INQUIRY * WINAPI init_inquiry(long  cor_num,
                                                    long  dim_num)
{
   long i;
   T_RECORD_OF_ONE_CYCLE_INQUIRY *inquiry;


   // выделим место под массив измерений
   inquiry = (T_RECORD_OF_ONE_CYCLE_INQUIRY *)
                  heap_alloc (sizeof(T_RECORD_OF_ONE_CYCLE_INQUIRY) * dim_num);
   if (inquiry == NULL) {
      sprintf(drvError, "Нет памяти под массив измерений(init_inquiry)");
      return inquiry;
    };

   // выделим место под массив корозионных измерений
   inquiry->sens = (EPRO_CORROSION_SENS_TYPE *) heap_alloc (sizeof(EPRO_CORROSION_SENS_TYPE)*cor_num * dim_num);
   if (inquiry->sens == NULL) {
      sprintf(drvError, "Нет памяти под массив корозионных измерений(init_inquiry)");
      inquiry= (T_RECORD_OF_ONE_CYCLE_INQUIRY *) heap_free(inquiry);
      return inquiry;
    };

   // выделим место под массив ОБМАТЕМАЧЕННЫХ корозионных измерений
   inquiry->math_sens = (EPRO_CORROSION_SENS_TYPE *) heap_alloc (sizeof(EPRO_CORROSION_SENS_TYPE)*cor_num * dim_num);
   if (inquiry->sens == NULL) {
      sprintf(drvError, "Нет памяти под массив  ОБМАТЕМАЧЕННЫХ корозионных измерений(init_inquiry)");
      inquiry= (T_RECORD_OF_ONE_CYCLE_INQUIRY *) heap_free(inquiry);
      return inquiry;
    };

   // проинициализируем поля sens и math_sens в inquiry_data,
   // заодно обнулим толщину
   for (i=1; i<dim_num; i++) {
      inquiry[i].sens = inquiry[i-1].sens + cor_num;
      inquiry[i].math_sens = inquiry[i-1].math_sens + cor_num;
      inquiry[i].Thick = 0;
    };

   return inquiry;
}; // T_RECORD_OF_ONE_CYCLE_INQUIRY * WINAPI init_inquiry(long  cor_num,

// Функция освобождения памяти под массивом измерений
// (типа деструктор T_DESCRIPTOR_TEMPLATE)
T_RECORD_OF_ONE_CYCLE_INQUIRY * WINAPI free_inquiry(T_RECORD_OF_ONE_CYCLE_INQUIRY *p_free) {

  if (p_free != NULL) {

     if (p_free->sens != NULL) {
       p_free->sens = (EPRO_CORROSION_SENS_TYPE *) heap_free(p_free->sens);
      };

     if (p_free->math_sens != NULL) {
       p_free->math_sens = (EPRO_CORROSION_SENS_TYPE *) heap_free(p_free->math_sens);
      };

     p_free = (T_RECORD_OF_ONE_CYCLE_INQUIRY *) heap_free(p_free);
   };

  return p_free;
}; //T_RECORD_OF_ONE_CYCLE_INQUIRY * WINAPI free_inquiry(


// функция записи индексных данных в файл
long WINAPI save_index_info(T_OPENED_TRACE * P_trace) {
  FILE * idx_file;
  long res_write;

  long file_counter;
  long seam_counter;

  idx_file = fopen(P_trace->idx_file_name, "wb");
  if (idx_file == NULL) {
     sprintf(drvError, "Не могу открыть файл %s (save_index_info)", P_trace->idx_file_name);
     return KRT_ERR;
   };

  // запишем все индексы открытой трассы
  for (file_counter=0; file_counter<P_trace->num_file_data; file_counter++) {

     // запишем структуру индекса по файлу
     res_write = fwrite(&P_trace->file_index[file_counter],
                        1, sizeof(T_INDEX_FILE), idx_file);

     if (res_write != sizeof(T_INDEX_FILE) ) {
         sprintf(drvError, "Ошибка записи file_index[%d] (save_index_info)", file_counter);
         fclose(idx_file);
         return KRT_ERR;
      };

     for (seam_counter = 0; 
          seam_counter < P_trace->file_index[file_counter].num_condition_seam;
          seam_counter++) 
      {

         // запишем структуру индекса по условному шву
         res_write = fwrite(&P_trace->file_index[file_counter].index_seam[seam_counter],
                            1, sizeof(T_INDEX_SEAM), idx_file);

         if (res_write != sizeof(T_INDEX_SEAM) ) {
             sprintf(drvError, "Ошибка записи file_index[%d].index_seam[%d] (save_index_info)", 
                                file_counter, seam_counter
                    );
             fclose(idx_file);
             return KRT_ERR;
          };

         // запишем массив начальных средних по датчикам условного шва
//         res_write = fwrite(&P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0],
//                            1,P_trace->corosion_sens_num * sizeof(P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0]),
//                            idx_file
//                           );
//
//         if (res_write != P_trace->corosion_sens_num * (long) sizeof(P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0]) ) {
//             sprintf(drvError, "Ошибка записи file_index[%d].index_seam[%d].smooth_data_beg (save_index_info)", 
//                                file_counter, seam_counter
//                    );
//             fclose(idx_file);
//             return KRT_ERR;
//          };

      }; // for (seam_counter=0; seam_counter<P_trace->num_file_data ;seam_counter++)
   }; //   for (file_counter=0; file_counter<P_trace->num_file_data ;file_counter++)


  fclose(idx_file);

  return KRT_OK;
}; // long WINAPI save_index_info(T_OPENED_TRACE * P_trace)



// функция создания открытой трассы с загрузкой индексных данных из файла
T_OPENED_TRACE * WINAPI creation_trace_with_a_loading_index_info
           (
             char *trc_file
           )
{
  T_OPENED_TRACE * new_trace;
  
  char current_path[_MAX_PATH];
  long path_length;

  long res_read;
  FILE * idx_file;

  long file_counter;
  long seam_counter;
  long max_count_opened_file;

  T_FILE_HEADER file_header;

  new_trace = init_opened_trace();
  if (new_trace == NULL) {
     strcat(drvError, "(creation_trace_with_a_loading_index_info)");
     return  NULL;
   };

  // запомним для себя в открытой трассе путь на trc-файл
  strcpy(new_trace->trc_file_name, trc_file);


    // читаем из trc-файла данные
  if (read_data_from_trc(new_trace) == KRT_ERR)
   {
     strcat(drvError, "(creation_trace_with_a_loading_index_info)");
     new_trace = free_opened_trace(new_trace);
     return NULL;
   };

  idx_file = fopen(new_trace->idx_file_name, "rb");
  if (idx_file == NULL) {
     sprintf(drvError, "Не могу открыть файл %s (creation_trace_with_a_loading_index_info)", new_trace->idx_file_name);
     new_trace = free_opened_trace(new_trace);
     return NULL;
   };

  // теперь проинициализируем индексы по файлам
  new_trace->file_index = init_index_files(new_trace->num_file_data);
  if (new_trace->file_index == NULL) {
     strcat(drvError, "(creation_trace_with_a_loading_index_info)");
     fclose(idx_file);
     new_trace = free_opened_trace(new_trace);
     return NULL;
   };

  // прочитаем все индексы трассы
  for (file_counter=0; file_counter<new_trace->num_file_data; file_counter++) {

     // прочитаем структуру индекса по файлу
     res_read = fread(&new_trace->file_index[file_counter],
                        1, sizeof(T_INDEX_FILE), idx_file);

     if (res_read != sizeof(T_INDEX_FILE) ) {
         sprintf(drvError, "Ошибка чтения file_index[%d] (creation_trace_with_a_loading_index_info)", file_counter);
         fclose(idx_file);
         new_trace = free_opened_trace(new_trace);
         return NULL;
      };

     // теперь проинициализируем индексы по усл. швам
     new_trace->file_index[file_counter].index_seam = 
        init_index_seams(new_trace->file_index[file_counter].num_condition_seam);
     if ( new_trace->file_index[file_counter].index_seam == NULL) 
      {
        strcat(drvError, "(creation_trace_with_a_loading_index_info)");
        fclose(idx_file);
        new_trace = free_opened_trace(new_trace);
        return NULL;
      }; //if (init_index_seams(&trace_list[reg_trc].trace->file_index[file_counter])

     for (seam_counter = 0; 
          seam_counter < new_trace->file_index[file_counter].num_condition_seam;
          seam_counter++) 
      {
         // прочитаем структуру индекса по условному шву
         res_read = fread(&new_trace->file_index[file_counter].index_seam[seam_counter],
                            1, sizeof(T_INDEX_SEAM), idx_file);

         if (res_read != sizeof(T_INDEX_SEAM) ) {
             sprintf(drvError,
                     "Ошибка чтения file_index[%d].index_seam[%d] (creation_trace_with_a_loading_index_info)",
                     file_counter, seam_counter
                    );
             fclose(idx_file);
             new_trace = free_opened_trace(new_trace);
             return NULL;
          };

//        new_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg = 
//                         init_smooth_data_beg(new_trace->corosion_sens_num);
//
//         // прочитаем массив начальных средних по датчикам условного шва
//         res_read = fread(&new_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0],
//                          1, new_trace->corosion_sens_num * sizeof(new_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0]),
//                          idx_file
//                         );
//
//         if (res_read != new_trace->corosion_sens_num * (long) sizeof(new_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0]) ) {
//             sprintf(drvError,
//                     "Ошибка чтения file_index[%d].index_seam[%d].smooth_data_beg (creation_trace_with_a_loading_index_info)",
//                     file_counter, seam_counter
//                    );
//             fclose(idx_file);
//             new_trace = free_opened_trace(new_trace);
//             return NULL;
//          };

      }; // for (seam_counter=0; seam_counter<P_trace->num_file_data ;seam_counter++)
   }; //   for (file_counter=0; file_counter<P_trace->num_file_data ;file_counter++)

  fclose(idx_file);
  // ну вот все данные из индексного файла выкачали

  // откроем и смапируем файл с данными дополнительных датчиков
   new_trace->index_extend_sens.file_data = fopen(new_trace->index_extend_sens.file_name, "rb");

   if (new_trace->index_extend_sens.file_data==NULL) {
      sprintf (drvError,
               "Ошибка открытия файла %s(creation_trace_with_a_loading_index_info).",
               new_trace->index_extend_sens.file_name);
      new_trace = free_opened_trace(new_trace);
      return NULL;
    };
  // открыли и смапировали файл с данными дополнительных датчиков

  // откроем и смапируем файл с данными по линиям питания
   new_trace->index_power_lines.file_data = fopen(new_trace->index_power_lines.file_name, "rb");

   if (new_trace->index_power_lines.file_data==NULL) {
      new_trace->index_power_lines.map_area_mem=NULL;
      new_trace->index_power_lines.hFileMap=NULL;
    };
  // открыли и смапировали файл с данными по линиям питания


  // откроем и смапируем файл с данными байпаса
   new_trace->index_bypass.file_data = CreateFile (
      new_trace->index_bypass.file_name,
      GENERIC_READ,
      FILE_SHARE_READ,
      NULL,
      OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL+FILE_FLAG_SEQUENTIAL_SCAN,
      0
    );

   if (new_trace->index_bypass.file_data==NULL) {
      new_trace->index_bypass.map_area_mem=NULL;
      new_trace->index_bypass.hFileMap=NULL;
    } else {
      new_trace->index_bypass.hFileMap = 
              CreateFileMapping(new_trace->index_bypass.file_data,
                                NULL, PAGE_READONLY, 0, 0, NULL);
      if (new_trace->index_bypass.hFileMap == NULL) {

          CloseHandle(new_trace->index_bypass.file_data);

          new_trace->index_bypass.map_area_mem=NULL;
          new_trace->index_bypass.hFileMap=NULL;
          new_trace->index_bypass.file_data=NULL;
       } else {
          new_trace->index_bypass.map_area_mem = (char *)
                  MapViewOfFile(new_trace->index_bypass.hFileMap, FILE_MAP_READ, 0,0,0);
          if (new_trace->index_bypass.map_area_mem == NULL) {
             sprintf (drvError,
                      "Ошибка 2 мапинга файла %s(creation_trace_with_a_loading_index_info).",
                      new_trace->index_bypass.file_name);
             new_trace = free_opened_trace(new_trace);
             return NULL;
           };
       };
    };
  // открыли и смапировали файл с данными байпаса


  // добавим ко всем именам файлов путь до них
  strcpy(current_path, new_trace->path_data);
  strcat(current_path, new_trace->first_file_name);
  path_length=strlen(new_trace->path_data);

  if (init_name_files(new_trace, current_path, path_length) == KRT_ERR) 
   {
     strcat(drvError, "(creation_trace_with_a_loading_index_info)");
     new_trace = free_opened_trace(new_trace);
     return NULL;
   };

  // откроем почти все файлы для чтения
  if (new_trace->num_file_data>100) {
      max_count_opened_file=100;
   } else {
      max_count_opened_file=new_trace->num_file_data;
   };

  file_counter = 0;
  new_trace->file_index[file_counter].file_data = 
         fopen(new_trace->file_index[file_counter].file_name, "rb");
  if (new_trace->file_index[file_counter].file_data ==NULL) {
    sprintf (drvError, "Ошибка открытия файла %s(creation_trace_with_a_loading_index_info)",
             new_trace->file_index[file_counter].file_name
            );
    new_trace = free_opened_trace(new_trace);
    return NULL;
   };


  // прочитаем заголовок файла
  if (fread(&file_header, 1, sizeof(T_FILE_HEADER),
            new_trace->file_index[0].file_data)
      != sizeof(T_FILE_HEADER)
     ) 
   {
    sprintf (drvError, "Ошибка чтения заголовка файла %s(creation_trace_with_a_loading_index_info)", new_trace->file_index[file_counter].file_name);
    new_trace = free_opened_trace(new_trace);
    return NULL;
   };

  // заполним поле количества датчиков и частоту процессора:
  // возможно надо его еще и анализировать, вдруг меняется
  // на протяжении трассы, но пока и так пойдет.
//  new_trace->corosion_sens_num = file_header.cor_num;
  new_trace->frequency_processor = (dword) file_header.proc_frequency;
  strcpy(new_trace->target_name, file_header.target_name);

  return new_trace;
}; // T_OPENED_TRACE * P_trace WINAPI creation_trace_with_a_loading_index_info


// Функция выделения памяти под под поле загруженных данных
// (типа конструктор T_LOADED_DATA)
T_LOADED_DATA *init_loaded_data () {
  T_LOADED_DATA * new_loaded_data;

  new_loaded_data = (T_LOADED_DATA *) heap_alloc (sizeof(T_LOADED_DATA));
  if (new_loaded_data == NULL) {
     sprintf(drvError, "Нет памяти под ...(init_loaded_data)");
     return new_loaded_data;
   };

  new_loaded_data->file=0;
  new_loaded_data->seam=0;

  new_loaded_data->Next_element=NULL;

  return new_loaded_data;
}; // T_LOADED_DATA *init_loaded_data () {

// Функция освобождения памяти под полем загруженных данных
// (типа деструктор T_LOADED_DATA )
T_LOADED_DATA *free_loaded_data (T_LOADED_DATA * p_free) {

  if (p_free != NULL) {
     p_free = (T_LOADED_DATA *) heap_free(p_free);
   };

  return  p_free;
};// T_LOADED_DATA *free_loaded_data (T_LOADED_DATA * p_free) {


// Функция добавления поля загруженных данных в конец списка
long add_loaded_data_in_list(T_LOADED_DATA * list, long file, long seam) {
  T_LOADED_DATA * cur_item;

  // перейдем в конец списка
  cur_item = list;

  while (cur_item->Next_element != NULL) {
     cur_item = cur_item->Next_element;
   };
  // перешли в конец списка

  cur_item->Next_element = init_loaded_data();
  if (cur_item->Next_element == NULL) {
     strcat(drvError, "(add_loaded_data_in_list)");
     return KRT_ERR;
   };

  cur_item->Next_element->file = file;
  cur_item->Next_element->seam = seam;

 return KRT_OK;
}; // long add_loaded_data_in_list(T_LOADED_DATA * list, long file, long seam)

// Функция удаления поле загруженных данных из конца списка
T_LOADED_DATA * del_loaded_data_in_list(T_LOADED_DATA * list) {
  T_LOADED_DATA * cur_item;

  // перейдем в конец списка
  if (list!=NULL) {
     if (list->Next_element != NULL) {
        cur_item = list;

        while (cur_item->Next_element->Next_element != NULL) {
           cur_item = cur_item->Next_element;
         };
        // перешли в конец списка

        cur_item->Next_element = (T_LOADED_DATA *) heap_free(cur_item->Next_element);
        if (cur_item->Next_element != NULL) {
           strcat(drvError, "(del_loaded_data_in_list)");
           return list;
         };

      } else {
        list = (T_LOADED_DATA *) heap_free(list);
        if (list != NULL) {
           strcat(drvError, "(del_loaded_data_in_list)");
           return list;
         };
      };
   };

 return list;
};// long del_loaded_data_in_list(T_LOADED_DATA * list) {


// Функция освобождения памяти под списком загруженных данных
// (типа деструктор цепочки T_LOADED_DATA )
T_LOADED_DATA *free_list_loaded_data (T_LOADED_DATA * p_free) {

  T_LOADED_DATA * next_item;

  while (p_free != NULL) {
     next_item = p_free ->Next_element;
     p_free = (T_LOADED_DATA *) heap_free(p_free);
     p_free = next_item;
   };

  return  p_free;
};// T_LOADED_DATA *free_loaded_data (T_LOADED_DATA * p_free) {


 // Ищем навигационные данные
long Serch_navigete(T_TRACE_LIST * p_trace_list){

  p_trace_list->NavData.file_data=NULL;
    // читаем из ini-файла путь на файл с навигациоддыми данными
  if (GetPrivateProfileString(DRIVER_DATA , NAVIGATION_FILE_KEY, "",
                              p_trace_list->NavData.file_name,
                              sizeof(p_trace_list->NavData.file_name),
                              p_trace_list->trace->trc_file_name
                             )!=0
     )
   { // Ну, путь на данные прописан
     // попробуем открыть файл
     if ( (p_trace_list->NavData.file_data=
           fopen(p_trace_list->NavData.file_name, "rb")
          )!=NULL) 
      { // файл присутствует
         fclose(p_trace_list->NavData.file_data);
         return KRT_OK;
      };
   };

  return KRT_ERR;
}; //long Serch_navigete(T_TRACE_LIST * p_trace_list){

long Init_NavData(T_TRACE_LIST * p_trace_list)
{

  T_NAVIGATION_DATA * NavData = &(p_trace_list->NavData);

  NavData->file_data=NULL;

  NavData->file_data = fopen(NavData->file_name, "rb");
  if ( NavData->file_data == NULL) {
     sprintf(NavData->file_name, "%srec.mat", p_trace_list->trace->path_data);
     NavData->file_data = fopen(NavData->file_name, "rb");
  };

  if (NavData->file_data != NULL) 
  {  // файл присутствует
     // посчитаем его длинну (в записях навигации)


        // посчитаем его длинну (в записях навигации)
        fseek(NavData->file_data, 0, SEEK_END);
        NavData->lengt_file_in_nav_rec = ftell(NavData->file_data);
        NavData->lengt_file_in_nav_rec /= sizeof(T_NAVIGATION_RECORD);

        // заполним данные границ поиска и текущие данные
        NavData->right_pos = NavData->lengt_file_in_nav_rec-1;

        fseek(NavData->file_data,
              NavData->right_pos*sizeof(T_NAVIGATION_RECORD),
              SEEK_SET
             );

        if (fread( &NavData->right_data,
              1,  sizeof(T_NAVIGATION_RECORD),
              NavData->file_data
            ) != sizeof(T_NAVIGATION_RECORD))
         {
            sprintf (drvError, "Ошибка чтения навигационных данных %s(Init_NavData)", NavData->file_name);
            return KRT_ERR;
         };

        NavData->left_pos=0;
        fseek(NavData->file_data,
              NavData->left_pos*sizeof(T_NAVIGATION_RECORD),
              SEEK_SET
             );

        if (fread( &NavData->left_data,
              1,  sizeof(T_NAVIGATION_RECORD),
              NavData->file_data
            ) != sizeof(T_NAVIGATION_RECORD))
         {
            sprintf (drvError, "Ошибка чтения навигационных данных %s(Init_NavData)", NavData->file_name);
            return KRT_ERR;
         };

        NavData->cur_pos=0;
        fseek(NavData->file_data,
              NavData->cur_pos*sizeof(T_NAVIGATION_RECORD),
              SEEK_SET
             );

        if (fread( &NavData->cur_data,
              1,  sizeof(T_NAVIGATION_RECORD),
              NavData->file_data
            ) != sizeof(T_NAVIGATION_RECORD))
         {
            sprintf (drvError, "Ошибка чтения навигационных данных %s(Init_NavData)", NavData->file_name);
            return KRT_ERR;
         };

   }; 

  return KRT_OK;
};// long Init_NavData(T_NAVIGATION_DATA *NavData, char * trc)



long Init_VogData(T_TRACE_LIST * p_trace_list)
{

  T_VOG_DATA * VogData = & (p_trace_list->VogData);


  VogData->file_data=NULL;

  // читаем из ini-файла путь на файл с навигациоддыми данными
  GetPrivateProfileString( DRIVER_DATA , VOG_FILE_KEY, "",
                           VogData->file_name, sizeof(VogData->file_name),
                           p_trace_list->trace->trc_file_name);

  // попробуем открыть файл
  VogData->file_data = fopen(VogData->file_name, "rb");
  if ( VogData->file_data == NULL) {
     sprintf(VogData->file_name, "%srec.vog", p_trace_list->trace->path_data);
     VogData->file_data = fopen(VogData->file_name, "rb");
  };

  if ( VogData->file_data != NULL) 
  {  // файл присутствует
     // посчитаем его длинну (в записях навигации)

        fseek(VogData->file_data, 0, SEEK_END);
        VogData->lengt_file_in_nav_rec = ftell(VogData->file_data);
        VogData->lengt_file_in_nav_rec /= sizeof(T_VOG_RECORD);

        // заполним данные границ поиска и текущие данные
        VogData->right_pos = VogData->lengt_file_in_nav_rec-1;

        fseek(VogData->file_data,
              VogData->right_pos*sizeof(T_VOG_RECORD),
              SEEK_SET
             );

        if (fread( &VogData->right_data,
              1,  sizeof(T_VOG_RECORD),
              VogData->file_data
            ) != sizeof(T_VOG_RECORD))
         {
            sprintf (drvError, "Ошибка чтения ВОГ данных %s(Init_VogData)", VogData->file_name);
            return KRT_ERR;
         };

        VogData->left_pos=0;
        fseek(VogData->file_data,
              VogData->left_pos*sizeof(T_VOG_RECORD),
              SEEK_SET
             );

        if (fread( &VogData->left_data,
              1,  sizeof(T_VOG_RECORD),
              VogData->file_data
            ) != sizeof(T_VOG_RECORD))
         {
            sprintf (drvError, "Ошибка чтения ВОГ данных %s(Init_VogData)", VogData->file_name);
            return KRT_ERR;
         };

        VogData->cur_pos=0;
        fseek(VogData->file_data,
              VogData->cur_pos*sizeof(T_VOG_RECORD),
              SEEK_SET
             );

        if (fread( &VogData->cur_data,
              1,  sizeof(T_VOG_RECORD),
              VogData->file_data
            ) != sizeof(T_VOG_RECORD))
         {
            sprintf (drvError, "Ошибка чтения ВОГ данных %s(Init_VogData)", VogData->file_name);
            return KRT_ERR;
         };

   };

  return KRT_OK;
};// long Init_VogData(T_VOG_DATA *VogData, char * trc)


  // подготовим структуру работы с навигационными данными
long Init_navigete(T_TRACE_LIST * p_trace_list, T_TRACEINFO *inf){

   if (Init_NavData(p_trace_list)
       ==KRT_ERR) 
    {
       strcat (drvError, "(Init_navigete)");
       return KRT_ERR;
    };


   if (Init_VogData(p_trace_list)
       ==KRT_ERR) 
    {
       strcat (drvError, "(Init_navigete)");
       return KRT_ERR;
    };


  if (p_trace_list->VogData.file_data!=NULL)
   {
      inf->vog=1;
   }; //if (trace_list[curent_trace].VogData.file_data!=NULL)

  return KRT_OK;
}; // long KRTAPI Init_navigete(T_TRACE_LIST * trace, T_TRACEINFO *inf){