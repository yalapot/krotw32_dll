#include <windows.h>
#include <stdio.h>
#include <stdlib.h>


#include "krtapi.h"


#define MAX_TRACE       8

#define MAX_GROUP_NUM   1   // максимально возможное кол-во поясов для данного драйвера                  


typedef struct {
   long handle;

   long nodeType;
   long nodeIndex;
   long nodePos;
   double controlSize;

   long  trace_len;

   char trc_file_name[_MAX_PATH];

   int row_header;
   int column_header;
   long row_num;
   long column_num;
   long * table;

   long Amlification;
   long Max_value;
   long Min_value;
   char FloatDelimiter;
   long VirtualDiameter;
   long trace_step;

} T_TRACE_LIST;
