// epro_drv.c - ���� callback-������� � ������� �������������� ���������
// ��������� ������ ������������ ����� 
// ��� ��������� KrotW32
//

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>


#include "int_unit.h"
#include "KrtAPI2.h"
#include "krtapi.h"
#include "krotnano.h"


#ifdef CALL_LOG

long debug_counter;

char tmp_log_str[1024];

char name_log_str[1024];

#define LOG_FILE "c:\\nano_log.txt"

void Log(char *LogString) {
FILE *call_log;

// call_log = fopen(name_log_str, "at");
 call_log = fopen(LOG_FILE, "at");
 fprintf(call_log, "%s", LogString);
 fclose(call_log);
}

#endif

HANDLE hMutex=NULL;
SECURITY_ATTRIBUTES sa;

char drvError[1024];

T_TRACE_LIST trace_list[MAX_TRACE];
long open_trace_counter;

char warnString[4096];
char *traceFile;

long global_flag_client=1;
STARTUPINFO startupInfo;
char Command_line[1024];
PROCESS_INFORMATION processInfo;
long Trace_runing_process=0;

//#include "krotnano.c"


//////////////////////////////////////////////////////////////////////////
//Callback - �������
//////////////////////////////////////////////////////////////////////////

const char* WINAPI krtDrvError(void){
   return drvError;
 };



// ������� ������� ������ ��������� � �������� datIndx �� ������� ��������� ������� spin 
// � ������ � �������� rowIndx ������� ��������� screen � rowData
__inline void putItemLine(
   T_OPENED_TRACE *trc, T_SPIN_INFO *spin, 
   long spinOffset, long rowIndx, long datIndx, long group, long length, 
   KRTDATA *screen,  KRTROW *rowData,
   long updateThickIndex
) 
{

   long i, baseScreenOffset, scanOffset, lineOffset, totalOffset, realIndx;
   long razvorot_skanera;
   T_INQUIRY *data;
   long max_i;

   (void) updateThickIndex;

    // ������� �������� ������ � ���������
    baseScreenOffset = length * rowIndx;

    // �������� � ������� ����� ������ ��������� � ����������� �� ������� �������
    scanOffset = trc->sensInGroup * group;

    // ��������� �� ������ ��������� datIndx
    data = &(spin->item[datIndx]);

    // �������� �������� �������� ����������� �������� �� ������ ��������� datIndx
    if (trc->isOdoNotUse) {
        lineOffset = 0;
    } else {
        lineOffset = data->prod_put - spin->odo.start;
    };

    if (lineOffset<0) lineOffset=0;

/*
    if (updateThickIndex >= 0) {
        thick = trc->thick.data;
        thickIndx = updateThickIndex + lineOffset;
        thickVal = thick[thickIndx];
        if (thickVal) {
           thickVal += data->Thick;
           thickVal /= 2;
        } else {
           thickVal = data->Thick;
        }
        thick[thickIndx] = thick[thickIndx+1] = thickVal;
    }

         if ( trc->idx_head.num_idx_in_table>= 54 )
         { 
            if (rowIndx > 797) {
               sprintf(drvError, "spinOffset %ld, rowIndx %ld, datIndx %ld, length %ld",
                     spinOffset, rowIndx, datIndx, length);
               MessageBox(NULL, drvError, "",MB_OK | MB_SYSTEMMODAL);
            };
         };
*/

    // ���� ��������� �� ������ ������ �������, �� ������� ������������ ������ ��� 
    // ���������� ������ �������.
    if (!rowData) return;

    razvorot_skanera = 0;
    if (group == 0) razvorot_skanera = trc->razvorot_1_skanera;
    if (group == 1) razvorot_skanera = trc->razvorot_2_skanera;
    if (group == 2) razvorot_skanera = trc->razvorot_3_skanera;

    if (spin->item[datIndx].direct_prod_put != 0) razvorot_skanera = !razvorot_skanera;

    // ��� ������� ������� � ������� � �������� group
    max_i = (long) ((double)(trc->sensInGroup) * trc->sens_step);
    for (i=0; i < max_i; i++)
    {
        // �������� ������ �������� �������� ������� �� ������ ������ ���������
        totalOffset = spinOffset + lineOffset + i;

        if (totalOffset >= length) break;

        // ���� ������ �������� � ���������
        if (totalOffset >= 0)  {
            // ������� ��� � ������ ���������

            // ������� ��������� ��������� � �����.������ ������� ���������
            if (razvorot_skanera !=0 ) {
                realIndx = scanOffset + (trc->sensInGroup - 1) - (long) ( (double)(i) / trc->sens_step);
            } else {
                realIndx = scanOffset +                          (long) ( (double)(i) / trc->sens_step);
            };

            screen[baseScreenOffset + totalOffset]  = (KRTDATA) (data->math_sens[realIndx] * KRT_PALLETE_SIZE / MAX_DAT_VAL);

            rowData[baseScreenOffset + totalOffset] = data->sens[realIndx];

            // ��������� ������ � �������� ��������
//            x = (long)((double)(i)/trc->sens_step); //
        }

    } // for (i=0; i < (long)((double)(trc->sensInGroup)*trc->sens_step); i++)

    return;
} // void putItemLine

// ������� ������� ������ ������� spin ������� � �������� group � ������ trc
// ��� ������� start:length � ������ ��������� screen � rowData 
// �������� isPrevSpinComplete ���������, ��� �� ���������� ������ ������
void putSpin(
  T_OPENED_TRACE *trc, T_SPIN_INFO *spin, short isPrevSpinComplete, 
  long group, long start, long length, 
  KRTDATA *screen, KRTROW *rowData
)
{

   long i, spinOffset, dataIndx, updateThick, l, rowNum, blackSpace, rowIndx;

    // �������� �������� ������� �� ������ ������ ���������
    spinOffset = spin->odo.start - start;

    updateThick = -1;
    l = spin->item[spin->itemNum - 1].prod_put - spin->odo.start;

/*
    for (i=0; i < l; i++) {
       if (trc->thick.data[spin->odo.start + i] == 0) {
          updateThick = spin->odo.start;
          trc->thick.isChanged = 1;
        break;
       }
    }
*/


    assert(trc->virtSens>0);

    // ��� ������ ������ ������ ���������
    for (i=0; i < trc->virtSens; i++)
    {
         // ��������� ��������������� �� ������ � ������� ��������� �������
         rowNum = 0;

         // ������������� ����� ������ � ������ ������� ������� �����
         // � �������� �� ���-�������, ���� 2 ������
         if (group == 0)
         {
             rowNum = (i - trc->topShift + trc->virtSens) % trc->virtSens;
         };

         if (group == 1)
         {
             rowNum = (trc->secondScanShift + i - trc->topShift + trc->virtSens) % trc->virtSens;
         };

         if (group == 2)
         {
             rowNum = (trc->thirdScanShift + i - trc->topShift + trc->virtSens) % trc->virtSens;
         };

         if (spin->isComplete) {
             // ���� ������ ������, �� ��������������� ������ ������ � ������ ���������
             dataIndx = (long) (((double) rowNum) * ((double)spin->itemNum) / ((double)trc->virtSens));
         } else {
             // ���� ������ �� ������, �� �������������� ������ � ����������� �� ����,
             // ��� �� ������ ���������� ������
             if (isPrevSpinComplete) {
                if (rowNum > spin->itemNum) {
                   dataIndx = -1;
                 } else {
                   dataIndx = rowNum;
                 };
             } else {
                 blackSpace = trc->virtSens - spin->itemNum;

                 if (blackSpace < 0) blackSpace = 0;
                 if (rowNum < blackSpace) dataIndx = -1;
                                     else dataIndx = rowNum - blackSpace;
             }
         }

         if (dataIndx >= 0) {
             // ��������, ��� ����������� ������ �� ����� �� ������� ������� ���������
             while (dataIndx >= spin->itemNum) dataIndx--;
             // �������� '���������' ���������, ��� ���� ������� �����
             dataIndx = spin->itemNum - 1 - dataIndx;
         }

         assert(dataIndx < spin->itemNum);

         if (dataIndx >= 0)
         {
            // ������� ��������� ��������� � �����.������ ������� ���������
//           if (trc->orient_direct_count!=0) {
//                rowIndx = trc->virtSens - i - 1;
//            } else {
            rowIndx =  i;
//            };
            putItemLine(trc, spin, spinOffset, rowIndx, dataIndx, group,  length, screen, rowData, updateThick);

         } // if (dataIndx >= 0)

    } // for (i=0; i < trc->virtSens; i++)

    return;
} // void putSpin

long WINAPI krtDrvFillData( KRTHANDLE handle, long group, long start,
                           long length, KRTDATA *screen, long *rowData)
{
  long my_start  = start;

  long cur_trace;
  long i;

  long spin_num;

  long screenEnd;
  short isPrevSpinComplete;

  static T_SPIN_INFO * spin;
  static long num_spin_need;
  static long first_spin_num;
  static long last_spin_num = 0;

  static long last_start = -1;
  static long last_length = -1;
  static long pred_trace_length = -1;


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

    // �������� ��������� �� �������� group
    if (group >= trace_list[cur_trace].trace->group_num) {
       sprintf(drvError, "group ������������ (krtDrvFillData)");
       return KRT_ERR;
    };

    my_start = (long)(((double) start) / trace_list[cur_trace].trace->trace_step);

    if (my_start >= 12) {
       my_start = my_start - 12;
    };

    // �������� ��������� �� ����������� ��������� ��������� start 
    if (( my_start > trace_list[cur_trace].trace->trace_len ) ||
        (trace_list[cur_trace].trace->trace_len <= 0 ))
    {
       // �������� ������, �.�. ��� ������ ������, ������ ���������
        for (i=0; i<trace_list[cur_trace].trace->sensInGroup * length; i++) {
           screen[i]=0;
         };

       return KRT_OK;
    };

    if ( (last_start != start) || (last_length != length) || (pred_trace_length != trace_list[cur_trace].trace->trace_len))
    {

        for (spin_num = 0; spin_num < num_spin_need; spin_num++)
        {
           if (spin[spin_num].item != NULL) spin[spin_num].item = free_inquiry(spin[spin_num].item);
        };
        if (spin != NULL) free(spin);

        last_start = start;
        last_length = length;
        pred_trace_length = trace_list[cur_trace].trace->trace_len;
        // ��������� ����� ������ ��������� � �������� ����������� ��������
        screenEnd = start + length;

        // ���� �� �������� ��� ������ ������ ������
        for (first_spin_num=0; first_spin_num < trace_list[cur_trace].trace->idx_head.num_idx_in_table-1; first_spin_num++)
        {
           if ( trace_list[cur_trace].trace->idx_trc[first_spin_num].beg_trace >= my_start) break;
        };

        if (trace_list[cur_trace].trace->idx_trc[first_spin_num].beg_trace > my_start) first_spin_num--;

        // ���� ��������� ������ ������
        for  ( last_spin_num = first_spin_num;
               last_spin_num < trace_list[cur_trace].trace->idx_head.num_idx_in_table-1;
               last_spin_num++
             )
        {
           if ( screenEnd < trace_list[cur_trace].trace->idx_trc[last_spin_num].beg_trace * 10
                          + trace_list[cur_trace].trace->sensInGroup
              )
           {
              break;
           }
        }

        num_spin_need = last_spin_num - first_spin_num + 1;

        spin = malloc ( sizeof(T_SPIN_INFO) * num_spin_need );

        spin_num = first_spin_num;

        // ���� ��������� ������ �� ��� ���������� ������� ���������� ������, ���� ���������� �����������
        if ((spin_num > 0) )
        {
            if (Gary_not_arc(trace_list[cur_trace].trace, spin_num-1, &spin[0]) != KRT_OK)
            {
               strcat(drvError, "(krtDrvFillData)");
               return KRT_ERR;
            };

           if (spin[0].item != NULL) spin[0].item = free_inquiry(spin[0].item);

        };
        // ���� ��������� ������ �� ��� ���������� ������� ���������� ������, ���� ���������� �����������

        for (spin_num = 0;
             spin_num < num_spin_need;
    	     spin_num++)
        {
            spin[spin_num].item = NULL;

            if (Gary_not_arc(trace_list[cur_trace].trace, spin_num + first_spin_num, &(spin[spin_num])) != KRT_OK)
            {
               strcat(drvError, "(krtDrvFillData)");
               for (spin_num = 0; spin_num < num_spin_need; spin_num++)
               {
                   if (spin[spin_num].item != NULL) spin[spin_num].item = free_inquiry(spin[spin_num].item);
               };
               free(spin);
               return KRT_ERR;
            };
        };
    };

    isPrevSpinComplete = NOT_FULL_SPIN;

    for (spin_num = 0; spin_num < num_spin_need; spin_num++)
    {
       putSpin(trace_list[cur_trace].trace, &spin[spin_num], isPrevSpinComplete, group, start, length, screen, rowData);
       isPrevSpinComplete = spin[spin_num].isComplete;
    }

    return KRT_OK;
}; // krtDrvFillData


long WINAPI krtDrvGetFirstNode ( KRTHANDLE handle, T_NODE *node,        
                                long start, long sensType, long sensIndex,
                                long length, long controlSize )
 {

  long my_start  = start;

  long cur_trace;

  long spin_num;


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

   // �������� controlSize
   if (controlSize>0 && controlSize<length) {
      trace_list[cur_trace].trace->controlSize=(double)(length)/(double)(controlSize);
    } else {
      trace_list[cur_trace].trace->controlSize=trace_list[cur_trace].trace->trace_step;
    };

   my_start = (start/trace_list[cur_trace].trace->trace_step);

   if (trace_list[cur_trace].trace->controlSize<trace_list[cur_trace].trace->trace_step)
    {
      trace_list[cur_trace].trace->controlSize=trace_list[cur_trace].trace->trace_step;
    };
   // ��������� controlSize � ������ �������� ��������� ���� ��� krtDrvGetNextNode
   trace_list[cur_trace].trace->nodeType = sensType;
   trace_list[cur_trace].trace->nodeIndex = sensIndex;
   trace_list[cur_trace].trace->nodePos = start;
   // �������� ��������� ���� ��� krtDrvGetNextNode

    // �������� ��������� �� ����������� ��������� ��������� start 
   if ( my_start >= trace_list[cur_trace].trace->trace_len) 
    {
      sprintf(drvError, "�� �������� start=%i � ������ (krtDrvGetFirstNode)",start);
      my_start = trace_list[cur_trace].trace->trace_len-1;
      // return KRT_ERR;
    };

   switch (sensType) {

      case (KRT_SENS_ODO): {     // �������
         node->Val=start;
         node->Pos=start;
         break;
      };

      case (KRT_SENS_TIMER): {   // ������
         node->Val = start;
         node->Pos = start;
         break;
      };


     case (KRT_SENS_THICK): {   // �������
        node->Val = 0;
        node->Pos = start;
        break;
      };

     case (KRT_SENS_EXT): {    // ���������������


        // ���� �� �������� ��� ������ ������ ������
        for (spin_num=0; spin_num < trace_list[cur_trace].trace->idx_head.num_idx_in_table-1; spin_num++)
        {
           if ( trace_list[cur_trace].trace->idx_trc[spin_num].beg_trace >= my_start) break;
        };

        switch (sensIndex) {
           case (0): { 
              node->Val=(long) spin_num;
              node->Pos = start;
              break;
            }; /* case  0 */
           case (1): {
              node->Val=(long) trace_list[cur_trace].trace->idx_trc[spin_num].file_num;
              node->Pos = start;
              break;
            }; /* case  1 */

           default:{
              sprintf(drvError, "bad sensIndex parameter(krtDrvGetFirstNode)");
              return KRT_ERR;
            };
         }; // switch (sensIndex) {
       break;
     };  // case (KRT_SENS_EXT): {    // ���������������

     default : {
        node->Val=0;
        node->Pos=start;
        sprintf(drvError, "bad sensType parameter(krtDrvGetFirstNode)");
        return KRT_ERR;
     };
   };

   return KRT_OK;
 }; /* krtDrvGetFirstNode */


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

   trace_list[cur_trace].trace->nodePos += (long)
               trace_list[cur_trace].trace->controlSize;

   if (krtDrvGetFirstNode (handle, node, trace_list[cur_trace].trace->nodePos,
                           trace_list[cur_trace].trace->nodeType,
                           trace_list[cur_trace].trace->nodeIndex, (long) trace_list[cur_trace].trace->controlSize, 1
                          )
       == KRT_ERR)
    {
      strcat(drvError, "(krtDrvGetNextNode)");
      return KRT_ERR; 
    };

   return KRT_OK;
 }; /* krtDrvGetNextNode */


/* ������� ����������� ������ */
long KRTAPI krtDrvRegister (
 const char * outIniFile, 
 const char * trcFile, 
 const char * indxPath,
 char **errText, 
 long (KRTAPI *informUser) (short percentDone, const char *msg)
 ) {

   char data_path[_MAX_PATH]; // ���� �� ������ � �������

   long i;
   char key_name[1024];
   char key_value[1024];

   long sens_sort[MAX_CORROZION_NUM];


//-------------------------------------------------------------------
  long recordLength, virtSens, topInMinutes;
  long NotUseOdo, trace_step, max_data_code;
//  , orient_direct_count;
  long Amplification_Group0, Amplification_Group1, Amplification_Group2;
  char Invert_sens_data[1024];
  long razvorot_1_skanera,razvorot_2_skanera,razvorot_3_skanera, Smooth_win_length;
  long Skan_2_Shift, Skan_3_Shift;
  char Sens_step[32];

  char *sym;

  (void) informUser;
  (void) indxPath;

// ���� �� ������� � ������� 
 getDriveDir(trcFile, data_path);  // �� ��������� ������� trc �����
 sym = getIniItem(outIniFile, INI_SECT, INI_DATA, "");
 if (*sym) strcpy(data_path, sym);
 sym = & data_path[strlen(data_path)-1]; // �������� ���������� ����, ���� ����
 if (*sym == '\\') { *sym = 0; }
 
 if (!isFolderExist(data_path)) {
  sprintf(drvError, 
   "��������� � ����� %s ([%s]:%s) ������� %s �� ����������.",
   outIniFile, 
   INI_SECT, 
   INI_DATA,
   data_path
   );
   *errText = &(drvError[0]);
   return KRT_ERR;
 }

 // ����������� ����� ������ 
 recordLength = getIniInt(outIniFile, INI_SECT, INI_DATALEN, INI_DATALEN_DFLT);
 // ���-�� ����������� ��������
 virtSens = getIniInt(outIniFile, INI_SECT, INI_SENSNUM, INI_SENSNUM_DFLT);
 // ��������� ���
 topInMinutes = getIniInt(outIniFile, INI_SECT, INI_TOPSHIFT, TOP_SHIFT_MINUTES);


 NotUseOdo=getIniInt(outIniFile, INI_SECT, KEY_VERT, 0);
 trace_step=getIniInt(outIniFile, INI_SECT, TRACE_STEP_KEY, OUTER_STEP);
 max_data_code=getIniInt(outIniFile, INI_SECT, MAX_DATA_CODE_KEY, MAX_DAT_VAL);
 Amplification_Group0=getIniInt(outIniFile, INI_SECT, Amplification_Group0_KEY, 4);
 Amplification_Group1=getIniInt(outIniFile, INI_SECT, Amplification_Group1_KEY, 8);
 Amplification_Group2=getIniInt(outIniFile, INI_SECT, Amplification_Group2_KEY, 4);
 Smooth_win_length=getIniInt(outIniFile, INI_SECT, Smooth_win_length_KEY, 8);

 sym=getIniItem(outIniFile, INI_SECT, Invert_sens_data_KEY, "");
 strcpy(Invert_sens_data, sym);

 razvorot_1_skanera=getIniInt(outIniFile, INI_SECT, razvorot_1_skanera_KEY, 0);
 razvorot_2_skanera=getIniInt(outIniFile, INI_SECT, razvorot_2_skanera_KEY, 0);
 razvorot_3_skanera=getIniInt(outIniFile, INI_SECT, razvorot_3_skanera_KEY, 0);

 Skan_2_Shift=getIniInt(outIniFile, INI_SECT, Skan_2_Shift_KEY, 0);
 Skan_3_Shift=getIniInt(outIniFile, INI_SECT, Skan_3_Shift_KEY, 0);

 sym=getIniItem(outIniFile, INI_SECT, KEY_SENS_STEP, "2.5");
 strcpy(Sens_step, sym);

 /////////////////////////////////////////////////////////
 // ������ ����������� ���������� � �������� trc-����
 /////////////////////////////////////////////////////////
 setTrcInt(trcFile, KEY_DATLEN, recordLength);
 setTrcInt(trcFile, KEY_SENSNUM, virtSens);
 sym = isFileInDir(trcFile, data_path) ? "" : data_path;
 setTrcItem(trcFile, KEY_DATA, sym);
 setTrcInt(trcFile, INI_TOPSHIFT, topInMinutes);
 setTrcInt(trcFile, KEY_VERT, NotUseOdo);

 setTrcInt(trcFile, TRACE_STEP_KEY, trace_step);
 setTrcItem(trcFile, FIRST_FILE_NAME_KEY, "d00000.cmp");
 setTrcInt(trcFile, MAX_DATA_CODE_KEY, max_data_code);
 setTrcInt(trcFile, Amplification_Group0_KEY, Amplification_Group0);
 setTrcInt(trcFile, Amplification_Group1_KEY, Amplification_Group1);
 setTrcInt(trcFile, Amplification_Group2_KEY, Amplification_Group2);

 setTrcItem(trcFile, Invert_sens_data_KEY, Invert_sens_data);
 setTrcInt(trcFile, razvorot_1_skanera_KEY, razvorot_1_skanera);
 setTrcInt(trcFile, razvorot_2_skanera_KEY, razvorot_2_skanera);
 setTrcInt(trcFile, razvorot_3_skanera_KEY, razvorot_3_skanera);

 setTrcInt(trcFile, Skan_2_Shift_KEY, Skan_2_Shift);
 setTrcInt(trcFile, Skan_3_Shift_KEY, Skan_3_Shift);

 setTrcItem(trcFile, KEY_SENS_STEP, Sens_step);

 setTrcInt(trcFile, Smooth_data_OFF_KEY, 0);
 setTrcInt(trcFile, Smooth_win_length_KEY, Smooth_win_length);
 setTrcInt(trcFile, Median_smooth_KEY, 0);

 // �������� ����������
 for (i=0; i<144; i++) {
   sens_sort[i] = i+1;
 };
 sens_sort[47] =  0;
 sens_sort[95] = 48;
 sens_sort[143] = 96;
 // �������� ����������

 // ������� � trc-���� �������������
 for (i=0; i<144; i++) {
    sprintf(key_name, "%s%d", SENS_SORT_KEY, i);
    sprintf(key_value, "%i", sens_sort[i]);
    setTrcItem(trcFile, key_name, key_value);
  };
 // �������� � trc-���� �������������


 strcpy(key_name, data_path);
 strcat(key_name, "trace.idx");
 DeleteFile(key_name);

 strcpy(key_name, data_path);
 strcat(key_name, "thick.idx");
 DeleteFile(key_name);
//---------------------------------------------------------------------------------


  // ������� � trc-���� ���� �� ������� �������
  sprintf(key_name, "%s", PATH_DATA_KEY);
//  sprintf(key_value, "%s", data_path);
  WritePrivateProfileString(EPRO_SECTION, key_name, "",trcFile);

  // ������� � trc-���� ������ ������� �����
  sprintf(key_name, "%s", FIRST_FILE_INDEX_KEY);
  sprintf(key_value, "%ld", 0);
  WritePrivateProfileString(EPRO_SECTION, key_name, key_value,trcFile);

  // ������� � trc-���� ������ ������ � ���������� ����������� ��������
  sprintf(key_name, "%s", TRACE_LEN_KEY);
  sprintf(key_value, "%ld", 0);
  WritePrivateProfileString(EPRO_SECTION, key_name, key_value,trcFile);

  // ������� � trc-���� ��� ��������
  sprintf(key_name, "%s", TRACE_STEP_KEY);
  if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value, sizeof(key_value), trcFile)==0)
  {
     // �� ������ ������ ���������� ��������, ���� ��� ���������� ����� ��������� ������������,�� ��� ��� ���
     sprintf(key_value, "%i", OUTER_STEP);
  }; 
  WritePrivateProfileString(EPRO_SECTION, key_name, key_value, trcFile);
  // �������� � trc-���� ��� ��������

  // ������� � trc-���� ����� ���������� ��������
  sprintf(key_name, "%s", CORROSION_SENS_NUM_KEY);
  sprintf(key_value, "%ld", 144);
  WritePrivateProfileString(EPRO_SECTION, key_name, key_value,trcFile);

  // ������� � trc-���� ���������� ������
  sprintf(key_name, "%s", GROUP_NUM_KEY);
  if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value, sizeof(key_value), trcFile)==0)
  {
     // �� ������ ������ ���������� ��������, ���� ��� ���������� ����� ��������� ������������,�� ��� ��� ���
     sprintf(key_value, "%i", 3);
  }; 
  WritePrivateProfileString(EPRO_SECTION, key_name, key_value, trcFile);
  // �������� � trc-���� ���������� ������

  return KRT_OK;
}; /* krtDrvRegister */

//////////////////////////////////////////////////////////////////////////
// ����������� Callback - �������
//////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////
// ������� �������������� ���������
//////////////////////////////////////////////////////////////////////////
// ������������ ������� �������� ������
long EXPORT KRTAPI krtOpenTrace(
const char * traceFile,
KRTHANDLE handle, 
T_TRACEINFO *inf, 
long draft
){
T_OPENED_TRACE * trc;
//char thickFile[1024];

HMODULE module_handle;
DWORD get_path_res;
char lpFilename[1024];
long str_length;

char Krot_name[1024];

 // ������ ����� ( draft == 1 )
 if (draft) {
  inf->sensGroups = 3;  // ����� ������ ���������
  inf->extSensors = 2;  // �������������� �������� 2
  return KRT_OK;
 }

 // ������ ����� ( draft == 0 )
 inf->krtDrvError = krtDrvError; // � ����� ��. ����, ���� ��������� �������

 trc = createTrace(traceFile, handle);
 if (!trc) { return KRT_ERR; }

#ifdef KROT_DEBUG
 trc->log = fopen("c:\\outer.log", "wt");
 fprintf(trc->log, "Start\n");
#endif

 // ����� ����������� ��������� ����/������
 trc->isOdoNotUse = getTrcInt(trc->file, KEY_VERT, 0);
 // ����������� ����� ������ (� �������� ����� � ������)
 trc->virtLength = getTrcInt(trc->file, KEY_DATLEN, INI_DATALEN_DFLT) * 1000;
 // ���-�� ����������� �������� 
 trc->virtSens = getTrcInt(trc->file, KEY_SENSNUM, INI_SENSNUM_DFLT);
 // ����� ������� ������� �����
 trc->topShift = getTrcInt(trc->file, INI_TOPSHIFT, TOP_SHIFT_MINUTES);
 // ��������� �������� ������� ������� ����� � ��������
 trc->topShift = trc->virtSens * (FULL_CIRCLE - trc->topShift) / FULL_CIRCLE;

 // ��������� �������� ������� ������� ������������ ������� � ��������
 trc->secondScanShift = (trc->virtSens + trc->Skan_2_Shift) * (FULL_CIRCLE / 2) / FULL_CIRCLE;
 trc->thirdScanShift = (trc->virtSens + trc->Skan_3_Shift) * (FULL_CIRCLE / 2) / FULL_CIRCLE;

 trc->sensInGroup = 48;
 trc->group_num = 3;

 // �������� ��� �������� ������ �� ����������� ������
 inf->askMetod   = SENS_ASK_DIST;
 inf->stepSize   = 1;

 // �������� ��������� ������� �������
 inf->group[0].num       = trc->virtSens; //trace_list[curent_trace].trace->corosion_sens_num;
 inf->group[0].type      = SENS_TYPE_HOLL;
 inf->group[0].minValue  = 0;
 inf->group[0].maxValue  = KRT_PALLETE_SIZE;

 inf->group[0].isRow     = 1; // 1/0 ���� 0 ����� ������ �� ��������������
 inf->group[0].minRowVal = 0; // ����������� �������� ����� ������ 
 inf->group[0].maxRowVal = trc->max_data_code; // ������������ �������� ����� ������ 

 // �������� ��������� ������� �������
 inf->group[1].num       = trc->virtSens; //trace_list[curent_trace].trace->corosion_sens_num;
 inf->group[1].type      = SENS_TYPE_HOLL;
 inf->group[1].minValue  = 0;
 inf->group[1].maxValue  = KRT_PALLETE_SIZE;

 inf->group[1].isRow     = 1; // 1/0 ���� 0 ����� ������ �� ��������������
 inf->group[1].minRowVal = 0; // ����������� �������� ����� ������ 
 inf->group[1].maxRowVal = trc->max_data_code; // ������������ �������� ����� ������ 

 // �������� ��������� 3-�� �������
 inf->group[2].num       = trc->virtSens; //trace_list[curent_trace].trace->corosion_sens_num;
 inf->group[2].type      = SENS_TYPE_HOLL;
 inf->group[2].minValue  = 0;
 inf->group[2].maxValue  = KRT_PALLETE_SIZE;

 inf->group[2].isRow     = 1; // 1/0 ���� 0 ����� ������ �� ��������������
 inf->group[2].minRowVal = 0; // ����������� �������� ����� ������ 
 inf->group[2].maxRowVal = trc->max_data_code; // ������������ �������� ����� ������ 

 inf->length             = trc->virtLength;
 inf->time               = trc->trace_time = trc->virtLength;

 inf->timerNum           = 1;
 inf->timerStep          = inf->stepSize;

 inf->odoNum             = 1;
 inf->odoStep            = inf->stepSize;

 // ���� ������ ������� 
 inf->wallThickNum       = 1; // ���������� �������
 inf->wallThickMin       = 0; // ����������� �������� ������ 
 inf->wallThickMax       = trc->max_data_code; // ������������ �������� ������ 

 inf->speedMin = 0;
 inf->speedMax = 100;

 inf->extSens[0].minValue = 0;
 inf->extSens[0].maxValue = 1000000;
 strncpy (
  inf->extSens[0].name, 
  "������� ���", 
  EXT_SENS_NAME_LENGTH
 );

 inf->extSens[1].minValue = 0;
 inf->extSens[1].maxValue = 1000;
 strncpy (
  inf->extSens[1].name, 
  "����� .cmp", 
  EXT_SENS_NAME_LENGTH
 );

 // �������������� ��������� �� Callback - ������� 
 inf->krtDrvFillData          = krtDrvFillData;
 inf->krtDrvGetFirstNode      = krtDrvGetFirstNode;
 inf->krtDrvGetNextNode       = krtDrvGetNextNode;
//  inf->krtDrvGetFirstNodeGroup = krtDrvGetFirstNodeGroup;
//  inf->krtDrvGetNextNodeGroup  = krtDrvGetNextNodeGroup;

 // ������� ���� � inf, ������� �� ����������� ����� ���������
 inf->vog=0;

 inf->orientNum=0;
 inf->orientStep=0;

 inf->shakeNum=0;
 inf->shakeStep=0;

 inf->pressNum=0;
 inf->pressStep=0;
                     
 inf->tempNum=0;
 inf->tempStep=0;

 inf->angleNum=0;
 inf->angleStep=0;

 inf->shakeMin=0;
 inf->shakeMax=0;

 inf->pressMin=0;
 inf->pressMax=0;

 inf->tempMin=0;
 inf->tempMax=0;

 inf->angleMin=0;
 inf->angleMax=0;
 // �������� ���� � inf, ������� �� ����������� ����� ���������


 // �������������� � ��������� ��������� ���� ������� ������ �����
// getDriveDir(trc->file, thickFile);
// strcat(thickFile, "\\thick.idx");
// if (initThick(thickFile, trc->virtLength / trc->trace_step, &(trc->thick))) { return KRT_ERR; }

 module_handle=GetModuleHandle(NULL);

 get_path_res=GetModuleFileName(module_handle, lpFilename, 1024);

 getDriveDir(lpFilename,Krot_name );
 str_length=strlen(Krot_name);

 strncpy(Krot_name, &lpFilename[str_length+1], 7);
 Krot_name[7]=0;

 if ((strcmp(Krot_name, "krotw32") != 0) ) {
        return KRT_OK;
  };

 if (isFileExist("C:\\Program Files\\KrotW32\\out\\client_nano.exe") == 0) {
     return KRT_OK;
  };

 if (global_flag_client == 0) {
     return KRT_OK;
  };

 ZeroMemory( &startupInfo, sizeof(STARTUPINFO) );

 if (
      MessageBox(NULL, " ��������� client_nano.exe ? \n", "Outer open trace",MB_YESNO | MB_ICONQUESTION | MB_SYSTEMMODAL)
      ==6
    ) 
  {
     sa.nLength = sizeof(sa);
     sa.lpSecurityDescriptor = NULL;
     sa.bInheritHandle = FALSE; // ������ ������������ ��������� �� �����������

     hMutex = CreateMutex(&sa, FALSE, "Client_Close");

     strcpy(Command_line, "C:\\Program Files\\KrotW32\\out\\client_nano.exe ");
     strcat(Command_line, "\"");
     strcat(Command_line, traceFile);
     strcat(Command_line, "\"");

     while((strlen(Command_line)>0) && (Command_line[strlen(Command_line)-1]!='\\')) {
        Command_line[strlen(Command_line)-1]=0;
      };

     if (CreateProcess( NULL,
                        Command_line,
                        NULL,
                        NULL,
                        FALSE,
                        NORMAL_PRIORITY_CLASS | CREATE_NEW_CONSOLE,
                        NULL,
                        NULL,
                        &startupInfo,
                        &processInfo
                      ) == TRUE
        )
      {
        Trace_runing_process=handle;
      }; 

  } else {
     global_flag_client = 0; // �������� �� ���� �������, �������� �� �������
  };


  return KRT_OK;
} // krtOpenTrace

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

//	freeThick(&(trace_list[curent_trace].trace->thick));
        if ( free_opened_trace(trace_list[curent_trace].trace) != NULL) {
           sprintf (drvError, "������ �������� ������(krtCloseTrace)");
           return KRT_ERR;
         };

        open_trace_counter--;

        trace_list[curent_trace].handle = trace_list[open_trace_counter].handle;
        trace_list[curent_trace].trace  = trace_list[open_trace_counter].trace;

        trace_list[open_trace_counter].handle = 0;
        trace_list[open_trace_counter].trace  = NULL; 

        if (processInfo.hProcess>0 && Trace_runing_process==handle ) {


//            sa.nLength = sizeof(sa);
//            sa.lpSecurityDescriptor = NULL;
//            sa.bInheritHandle = FALSE; // ������ ������������ ��������� �� �����������
//
//            hMutex = CreateMutex(&sa, FALSE, "Client_Close");
//            Sleep(5000);

              CloseHandle(hMutex);

            // Close process and thread handles.
//            CloseHandle( processInfo.hProcess );
//            CloseHandle( processInfo.hThread );

//            TerminateProcess(processInfo.hProcess,NO_ERROR); // ������ �������
            Trace_runing_process=0;
         };

        return KRT_OK;
      };
   };


  sprintf(drvError, "�� ������ handle (krtCloseTrace)");
  return KRT_ERR; 

}; // krtCloseTrace 

/////////////////////////////////////////////////////
// ������� ���������� � �������� - �������� ��� ������� ������
long EXPORT KRTAPI krtDriverInfo (T_DRVINFO *drv ) {
  if (drv==NULL) return KRT_ERR;

  drv->apiVer = DRIVER_API_VER;
  drv->krtDrvRegister = NULL;
  return KRT_OK;

}; /* krtDriverInfo (T_DRVINFO *drv ) */

/////////////////////////////////////////////////////
// ������� ��������� ����������� ��������� � ����������� ����� ������
// ���� NULL, �� ������������ ���������� � ����������� ������ �� ��������������.
// ���� ���������� newDataRegistered ������� ���������� � ����� ������������ 
// ��� ����������� ����� ������, ������ ���������� 1.
// ���� ���������� �� ����������, ������ ���������� 0. 
long KRTAPI krtOnline (
  // ���������� �������, ��� �������� ��������������� ����������
  KRTHANDLE handle, 
  // ��������� �� callback �������, ���������� ��������� ��� ����������� ����� ������.
  // ���������� 1 ���� ���� ����� ������ ��������� � ������ � 
  // 0 ���� ���� ����� ������ �� ��������� � � ��� ���������� �������� �������
  // ��� ����� ������ ��� ��������� ������.
  // �������� newData �������� ���������� �� ���������, ����������� ���� ����������� ������.
  long (KRTAPI *newDataRegistered) (T_ArrivedData *newData)
  ) {

T_OPENED_TRACE *trc;

 trc = getTrace(handle);
 if (trc == NULL) { return 0; }
 return newDataRegistered ? startDataRecieve(trc, newDataRegistered) : stopDataRecieve(trc);
}


/////////////////////////////////////////////////////
// ������� ���������� � �������� - �������� ���������� ��� ������� ������
long EXPORT KRTAPI krtDriverInfoExt (long apiVer, void *drvInfoStruct) {
T_DRVINFO2 *drv2;

 (void) apiVer;

 drv2 = (T_DRVINFO2 *) drvInfoStruct;

 drv2->apiVer = KRT_APIVER2;
 drv2->pigType = PIG_SPIRAL;

 strcpy(drv2->drvSign,   "OUTER");
 strcpy(drv2->drvName,   "������������� ������� ����");
 strcpy(drv2->drvCopyRt, "(C) 2005-2006 by Dmitry Svintsov & Vitaly Bogomolov");

 drv2->drvVerMax = DRIVER_VER_MAX;
 drv2->drvVerMin = DRIVER_VER_MIN;
 drv2->krtDrvRegister = NULL;
 drv2->krtOnline = krtOnline;

 drv2->krtDrvRegister = krtDrvRegister;

 return KRT_OK;
}