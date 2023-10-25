
#include "bps_porshen.h"

char drvError[1024];

T_TRACE_LIST trace_list[MAX_TRACE];
long open_trace_counter;


/* ������� ������������� �������� ������ �������� */
void WINAPI initTraces(void) {
  open_trace_counter=0;
  strcpy(drvError, "");

};



/**********************************************/
BOOL WINAPI DllMain (
    HINSTANCE hinstDLL,  // DLL module handle
    DWORD fdwReason,     // reason called
    LPVOID lpvReserved)  // reserved
{
 (void) hinstDLL;
 (void) lpvReserved;

 switch (fdwReason) {
   case DLL_PROCESS_ATTACH:
   {
      initTraces();
      break;
   };

   case DLL_PROCESS_DETACH: {
      break;
   };

   default:
      break;
   };

 return TRUE;
};

//////////////////////////////////////////////////////////////////////////
//Callback - �������
//////////////////////////////////////////////////////////////////////////


const char* WINAPI krtDrvError(void){
  return drvError;
};

long WINAPI krtDrvFillData( KRTHANDLE handle, long group, long start,
                           long length, KRTDATA *screen, long *rowData)
{
  long i;
  long my_length = length;
  long cur_trace;

  (void) group;
  (void) start;
  (void) rowData;

  if (open_trace_counter==0) {
     sprintf (drvError, "��� �������� �����(krtDrvFillData)");
     return KRT_ERR;
  };

  // ������ �������� ������ � ������:
  for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
     if (handle==trace_list[cur_trace].handle) break;
  };

  if (cur_trace >= open_trace_counter) {
     sprintf(drvError, "�� ������ handle (krtDrvFillData)");
     return KRT_ERR; 
  };

  // �������� �����
  for (i=0; i < trace_list[cur_trace].sens_num * my_length; i++) {
        screen[i]=0;
  };

  return KRT_OK;

}; // krtDrvFillData


long WINAPI krtDrvGetFirstNode ( KRTHANDLE handle, T_NODE *node,        
                                long start, long sensType, long sensIndex,
                                long length, long controlSize )
{
   long cur_trace;
   long my_start;


   if (open_trace_counter==0) {
      sprintf (drvError, "��� �������� �����(krtDrvGetFirstNode)");
      return KRT_ERR;
    };

   // ������ �������� ������ � ������:
   for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
      if (handle==trace_list[cur_trace].handle) break;
    };
   if (cur_trace >= open_trace_counter) {
      sprintf(drvError, "�� ������ handle (krtDrvGetFirstNode)");
      return KRT_ERR; 
    };

   my_start = start/trace_list[cur_trace].trace_step;

   // �������� controlSize
   if (controlSize>0 && controlSize<length) {
      trace_list[cur_trace].controlSize=(double)(length)/(double)(controlSize);
    } else {
      trace_list[cur_trace].controlSize = trace_list[cur_trace].trace_step;
    };

   if (trace_list[cur_trace].controlSize < trace_list[cur_trace].trace_step)
    {
      trace_list[cur_trace].controlSize = trace_list[cur_trace].trace_step;
    };
   // ��������� controlSize � ������ �������� ��������� ���� ��� krtDrvGetNextNode
   trace_list[cur_trace].nodeType = sensType;
   trace_list[cur_trace].nodeIndex = sensIndex;
   trace_list[cur_trace].nodePos = start;
   // �������� ��������� ���� ��� krtDrvGetNextNode

   switch (sensType) {

      case (KRT_SENS_ODO): {     // �������
         node->Val=start;
         node->Pos=start;
         break;
      };

      case (KRT_SENS_TIMER): { // ������
         node->Val=start;
         node->Pos=start;
         break;
      };

      case (KRT_SENS_ORIENT): {  // ����������
         switch (sensIndex) {
            case(-1L):
            case(0): {
              node->Val = 0;
              node->Pos = start;
              break;
            };
         };
         break;
      };


      case (KRT_SENS_EXT): {    // ���������������
         if (my_start >= trace_list[cur_trace].trace_len) break;
         switch (sensIndex) {

//������� ��� ����������� t = (A*3.2258-500)/10 ��.C
//������� ��� ��������������� �������� ������� MLH02KPSP01B (2000PSI=137.8951���=1.378951���) � MLH100BSL03B A = (Aold-186) * 1.3789

            case (0): { // ���������� ��������
               // P = (A-186)*3300/(0.00024*1023) ��� - 186 ��� ������� 4�� ��� ������� �������� (MLH100BSL03B (100���=1���))
               node->Val=(long) (trace_list[cur_trace].bps_idx[my_start].abs_pressure - 186) * 
                                    3300 *100/24 / 1023 ;


               node->Pos = start;
               break;
            };

            case (1): { // ���������������� ��������

               // dP = A*3300/(10.8*0.282*1023) ���
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].diff_pressure * 
                                3300 / 3139;
               node->Pos = start;
               break;
            };

            case (2): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].speed * 5;
               node->Pos = start;
               break;
            };

            case (3): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].motor_state;
               node->Pos = start;
               break;
            };


            case (4): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].choke_curr_position_ticks;
               node->Pos = start;
               break;
            };

            case (5): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].choke_curr_position_angle;
               node->Pos = start;
               break;
            };

            case (6): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].choke_position;
               node->Pos = start;
               break;
            };

            case (7): { // ��� ���������
               node->Val=(long) ( trace_list[cur_trace].bps_idx[my_start].motor_battary_current *
                                  1018) / 1000;
//               battary_current *= 0.0010175;

               node->Pos = start;
               break;
            };

            case (8): {  // ����������

               node->Val=(long) (trace_list[cur_trace].bps_idx[my_start].motor_battary_voltage *
                                 127451) / 1000;

               node->Pos = start;
               break;
            };

            case (9): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].Odometr/2;
               node->Pos = start;
               break;
            };

            default:{
               sprintf(drvError, "bad sensIndex parameter(krtDrvGetFirstNode)");
               return KRT_ERR;
             };
          }; // switch (sensIndex)

          break;
      };  // case (KRT_SENS_EXT):    // ���������������

      default : {
        node->Val=start;
        node->Pos=start;
        sprintf(drvError, "bad sensType parameter(krtDrvGetFirstNode)");
        return KRT_ERR;
      };
   };

   return KRT_OK;
}; // krtDrvGetFirstNode


long WINAPI krtDrvGetNextNode ( KRTHANDLE handle, T_NODE *node) {

   long cur_trace;

   if (open_trace_counter==0) {
      sprintf (drvError, "��� �������� �����(krtDrvGetNextNode)");
      return KRT_ERR;
    };

   // ������ �������� ������ � ������:
   for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
      if (handle==trace_list[cur_trace].handle) break;
    };
   if (cur_trace >= open_trace_counter) {
      sprintf(drvError, "�� ������ handle (krtDrvGetNextNode)");
      return KRT_ERR; 
    };

   trace_list[cur_trace].nodePos += (long)
               trace_list[cur_trace].controlSize;

   if (krtDrvGetFirstNode (handle, node, trace_list[cur_trace].nodePos,
                           trace_list[cur_trace].nodeType,
                           trace_list[cur_trace].nodeIndex, (long) trace_list[cur_trace].controlSize, 1
                          )
       == KRT_ERR)
    {
      strcat(drvError, "(krtDrvGetNextNode)");
      return KRT_ERR; 
    };

   return KRT_OK;
}; /* krtDrvGetNextNode */


long WINAPI krtDrvGetFirstNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node,
                                      long start, long sensGroup,
                                      long length, long controlSize )
{
   (void) handle;
   (void) node;
   (void) start;
   (void) sensGroup;
   (void) length;
   (void) controlSize;

   return KRT_OK;
}; // krtDrvGetFirstNodeGroup


long WINAPI krtDrvGetNextNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node)
{
   (void) handle;
   (void) node;

   return KRT_OK;
}; // krtDrvGetNextNodeGroup


long KRTAPI krtDrvRegister (
 const char * datFile, 
 const char * trcFile, 
 char **errText, 
 long (KRTAPI *userBreak) (short percentDone)
 ) 
{
   FILE * data_file;
   char file_name[1024];

   long data_path_len;
   char data_path[_MAX_PATH]; // ���� �� ������ � �������

   FILE *idx_file_data;
   char idx_file_name[1024];

   long file_counter, persent_value, read_len;

   struct T_BYPASS_HEADER bypas_header;

   struct T_BYPASS_INFO bypass_info;


   (void) errText;
   (void) userBreak;

   strcpy(file_name, &datFile[strlen(datFile)-9]);
   file_name[5]=0;
   file_counter = atoi(file_name);

   // ������� ���� �� ������ � ������� �� ������� ���� �� ������� �����
   strcpy(data_path, datFile);
   data_path_len=strlen(data_path);

   while ((data_path_len>0) && (data_path[data_path_len-1]!='\\')) {
     data_path[data_path_len - 1] = 0;
     data_path_len--;
   };

   sprintf(idx_file_name, "%sbaypas.idx", data_path);

   idx_file_data = fopen(idx_file_name, "wb");
   if (idx_file_data==NULL) {
       sprintf(drvError, "������ �������� ����� %s. \n", idx_file_name);
       return KRT_ERR;
   };


   sprintf(file_name, "%sC%05ld.BPR", data_path, file_counter);

   while ( (data_file = fopen(file_name, "rb")) != NULL) {

       read_len = fread( &bypas_header, 1, sizeof(struct T_BYPASS_HEADER), data_file);
       if (read_len != sizeof(struct T_BYPASS_HEADER)) {
          fclose(data_file);
          break;
       };

       persent_value = file_counter;
       if (persent_value<0)  persent_value=0;
       if (persent_value>99) persent_value=99;

       // �������� �� �������� �� ������������ �������� ��� ������������� � 
       // ������ ��������� ������� ����������� ������
       if (userBreak((short) persent_value ) ) {
          sprintf (drvError, "�������� ������������� (krtDrvRegister)");

          fclose(data_file);
          data_file=NULL;

          fclose(idx_file_data);
          idx_file_data=NULL;
          return KRT_ERR;
       };


       while (fread( &bypass_info, 1, sizeof(struct T_BYPASS_INFO), data_file) 
           == sizeof(struct T_BYPASS_INFO))
       {
            fwrite(&(bypass_info.abs_pressure), 1, sizeof(bypass_info.abs_pressure), idx_file_data);
            fwrite(&(bypass_info.diff_pressure), 1, sizeof(bypass_info.diff_pressure), idx_file_data);
            fwrite(&(bypass_info.speed), 1, sizeof(bypass_info.speed), idx_file_data);
            fwrite(&(bypass_info.motor_state), 1, sizeof(bypass_info.motor_state), idx_file_data);
            fwrite(&(bypass_info.choke_curr_position_ticks), 1, sizeof(bypass_info.choke_curr_position_ticks), idx_file_data);
            fwrite(&(bypass_info.choke_curr_position_angle), 1, sizeof(bypass_info.choke_curr_position_angle), idx_file_data);
            fwrite(&(bypass_info.choke_position), 1, sizeof(bypass_info.choke_position), idx_file_data);
            fwrite(&(bypass_info.motor_battery_current), 1, sizeof(bypass_info.motor_battery_current), idx_file_data);
            fwrite(&(bypass_info.motor_battery_voltage), 1, sizeof(bypass_info.motor_battery_voltage), idx_file_data);
            fwrite(&(bypass_info.Odometr), 1, sizeof(bypass_info.Odometr), idx_file_data);

       }; //  while (fread( &bypass_info, 1, sizeof(struct T_BYPASS_INFO), data_file) 


       fclose(data_file);
       data_file=NULL;

       file_counter++;

       sprintf(file_name, "%sC%05ld.BPR",  data_path, file_counter);

   }; //   while ( (data_file = fopen(file_name, "rb")) != NULL)

   fclose(idx_file_data);

   WritePrivateProfileString(DRIVER_DATA, "WORK_FILE_NAME", idx_file_name, trcFile);

   WritePrivateProfileString(DRIVER_DATA, "DEVICE_ID", bypas_header.id_str, trcFile);


   return KRT_OK;
}; // krtDrvRegister

//////////////////////////////////////////////////////////////////////////
// ����������� Callback - �������
//////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////
// ������� �������������� ���������
//////////////////////////////////////////////////////////////////////////

long EXPORT KRTAPI krtDriverInfo (T_DRVINFO *drv ) {
  if (drv==NULL) return KRT_ERR;

  drv->apiVer = KRT_APIVER;
  drv->krtDrvRegister = krtDrvRegister;
  return KRT_OK;

}; // krtDriverInfo (T_DRVINFO *drv )


long EXPORT KRTAPI krtOpenTrace(const char * traceFile, KRTHANDLE handle, T_TRACEINFO *inf, long draft){

   char bps_file_name[1024];
   FILE *bps_file;

   long file_length;

   long curent_trace;

   char data_path[1024];
   long data_path_len;
   char file_path[1024];

   long ext_sens_index;

   struct T_BYPASS_HEADER Bypas_header;


   inf->krtDrvError = krtDrvError; // � ����� ��. ����, ���� ��������� �������

     // �������� �� ������������ handle
    if (handle<=0) {
       sprintf (drvError, "handle �� ������ ����(krtOpenTrace)");
       return KRT_ERR;
     };


    if (draft) {
       if (open_trace_counter>=MAX_TRACE) {
          sprintf (drvError, "��� ������� ������� ����� �����.(krtOpenTrace)");
          return KRT_ERR;
       };

       for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
          if (handle==trace_list[curent_trace].handle) {
             sprintf (drvError, "��������� ������������� handle.(krtOpenTrace)");
             return KRT_ERR;
          };
       };

       curent_trace = open_trace_counter;

       trace_list[curent_trace].handle=handle;

       if (GetPrivateProfileString(DRIVER_DATA, "WORK_FILE_NAME", "", bps_file_name, sizeof(bps_file_name), traceFile) == 0)
       {
          sprintf (drvError, "������ ������ ����� �������� ����� %s.", traceFile);
          return KRT_ERR;
       };

       bps_file = fopen(bps_file_name, "rb");

       if (bps_file == NULL)
       {
           // ������� ���� �� ������ � ������� �� ������� ����
           strcpy(data_path, traceFile);

           data_path_len=strlen(data_path);

           while ((data_path_len>0) && (data_path[data_path_len-1]!='\\')) {
              data_path[data_path_len - 1] = 0;
              data_path_len--;
           };

           sprintf(file_path, "%s%s", data_path, bps_file_name);
           bps_file = fopen(file_path, "rb");
           if (bps_file == NULL)
           {
               sprintf (drvError, "������ �������� �������� ����� %s.", file_path);
               return KRT_ERR;
           }
       }

       fseek(bps_file, 0, SEEK_END);
       file_length = ftell(bps_file);

       GetPrivateProfileString(DRIVER_DATA, "DEVICE_ID", "", Bypas_header.id_str, 16, traceFile);
       strncpy(trace_list[curent_trace].device_ID, Bypas_header.id_str, 8);


       fseek(bps_file, 0, SEEK_SET);
       trace_list[curent_trace].bps_idx = malloc(file_length);
       fread (trace_list[curent_trace].bps_idx, 1, file_length, bps_file);

       fclose (bps_file);

       trace_list[curent_trace].trace_len = file_length / sizeof(trace_list[curent_trace].bps_idx[0]);
       trace_list[curent_trace].sens_num = 16;
       trace_list[curent_trace].trace_step = 100;

       open_trace_counter++;

       inf->sensGroups = 1; 
       inf->extSensors = 10;

       return KRT_OK;
    }; //   if (draft) {


    // �! � ��� ��� ��������� ����� krtOpenTrace � draft == 0
    if (open_trace_counter==0) {
       sprintf (drvError, "��� �������� �����(krtOpenTrace)");
       return KRT_ERR;
    };

    // ������ �������� ������ � ������:
    for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
       if (handle==trace_list[curent_trace].handle) break;
    };

    if (curent_trace >= open_trace_counter) {
       sprintf(drvError, "�� ������ handle (krtOpenTrace)");
       return KRT_ERR; 
    };


    inf->sensGroups = 1;
    inf->askMetod   = SENS_ASK_DIST;
    inf->stepSize   = trace_list[curent_trace].trace_step;

    inf->group[0].num     = trace_list[curent_trace].sens_num;
    inf->group[0].type    = SENS_TYPE_HOLL;
    inf->group[0].minValue= 0;
    inf->group[0].maxValue= KRT_PALLETE_SIZE;

    inf->group[0].isRow    = 1; // 1/0 ���� 0 ����� ������ �� ��������������
    inf->group[0].minRowVal= 0; // ����������� �������� ����� ������ 
    inf->group[0].maxRowVal= 65535; // ������������ �������� ����� ������ 

    inf->length   = trace_list[curent_trace].trace_len * trace_list[curent_trace].trace_step;

    inf->time     = 10000;

    inf->orientNum  = 1;
    inf->orientStep = trace_list[curent_trace].trace_step;

    inf->timerNum  = 1;
    inf->timerStep = trace_list[curent_trace].trace_step;  

    inf->odoNum  = 1;
    inf->odoStep = trace_list[curent_trace].trace_step;

    inf->speedMin = -100;
    inf->speedMax =  100;

    ext_sens_index=0;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 100000;
    strncpy (inf->extSens[ext_sens_index].name, "���������� ��������, ���", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = -4096;
    inf->extSens[ext_sens_index].maxValue =  4096;
    strncpy (inf->extSens[ext_sens_index].name, "������� ��������, ���", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 4096;
    strncpy (inf->extSens[ext_sens_index].name, "��������, ��/���", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = -127;
    inf->extSens[ext_sens_index].maxValue = 127;
    strncpy (inf->extSens[ext_sens_index].name, "��������� ������", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 255;
    strncpy (inf->extSens[ext_sens_index].name, "������� �������� � �����", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 255;
    strncpy (inf->extSens[ext_sens_index].name, "������� ��������", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = -1;
    inf->extSens[ext_sens_index].maxValue = 20;
    strncpy (inf->extSens[ext_sens_index].name, "��������� ������� ��������", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 4095;
    strncpy (inf->extSens[ext_sens_index].name, "��� ������, mA", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 30000;
    strncpy (inf->extSens[ext_sens_index].name, "����������, mV", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 15000000 ;
    strncpy (inf->extSens[ext_sens_index].name, "���������� �� ��������, ��", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;


       // �������������� ��������� �� Callback - ������� 
    inf->krtDrvFillData          = krtDrvFillData;
    inf->krtDrvGetFirstNode      = krtDrvGetFirstNode;
    inf->krtDrvGetNextNode       = krtDrvGetNextNode;
   // inf->krtDrvGetFirstNodeGroup = krtDrvGetFirstNodeGroup;
   // inf->krtDrvGetNextNodeGroup  = krtDrvGetNextNodeGroup;

    return KRT_OK;
}; // krtOpenTrace

long EXPORT KRTAPI krtCloseTrace ( KRTHANDLE handle) {
  int curent_trace; 

  if (open_trace_counter==0) {
     sprintf (drvError, "��� �������� �����(krtCloseTrace)");
     return KRT_ERR;
   };

  // ������ �������� ������ � ������:
  for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
     if (handle==trace_list[curent_trace].handle) {
        // � ������� ��
        if ( trace_list[curent_trace].bps_idx != NULL) {
           free(trace_list[curent_trace].bps_idx);
           trace_list[curent_trace].bps_idx = NULL;
        };

        open_trace_counter--;

        trace_list[curent_trace].handle = trace_list[open_trace_counter].handle;

        trace_list[open_trace_counter].handle = 0;

        return KRT_OK;
      };
   };


  sprintf(drvError, "�� ������ handle (krtCloseTrace)");
  return KRT_ERR; 
}; // krtCloseTrace 
