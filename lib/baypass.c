
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <krtapi.h>
#include "baypass.h"


long Init_BPdata(T_BP_DATA *BPdata, char * work_path, char * trc, char drvError[])
{
     (void*) trc;

     BPdata->file_data=NULL;

     sprintf(BPdata->file_name, "%sbaypas.idx", work_path);
     BPdata->file_data = fopen(BPdata->file_name, "rb");
     if ( BPdata->file_data == NULL) {
        return KRT_ERR;
     };

     if ( BPdata->file_data != NULL) 
     { // файл присутствует
        // посчитаем его длинну (в записях)
        fseek(BPdata->file_data, 0, SEEK_END);
        BPdata->lengt_file_in_BP_rec = ftell(BPdata->file_data);
        BPdata->lengt_file_in_BP_rec /= sizeof(T_BYPASS_IDX);

        // заполним данные границ поиска и текущие данные
        BPdata->right_pos = BPdata->lengt_file_in_BP_rec-1;

        fseek(BPdata->file_data,
              BPdata->right_pos*sizeof(T_BYPASS_IDX),
              SEEK_SET
             );

        if (fread( &BPdata->right_data,
              1,  sizeof(T_BYPASS_IDX),
              BPdata->file_data
            ) != sizeof(T_BYPASS_IDX))
        {
            sprintf (drvError, "Ошибка чтения ВОГ данных %s(Init_BPdata)", BPdata->file_name);
            fclose(BPdata->file_data);
            return KRT_ERR;
        };

        BPdata->left_pos=0;
        fseek(BPdata->file_data,
              BPdata->left_pos*sizeof(T_BYPASS_IDX),
              SEEK_SET
             );

        if (fread( &BPdata->left_data,
              1,  sizeof(T_BYPASS_IDX),
              BPdata->file_data
            ) != sizeof(T_BYPASS_IDX))
        {
            sprintf (drvError, "Ошибка чтения ВОГ данных %s(Init_BPdata)", BPdata->file_name);
            fclose(BPdata->file_data);
            return KRT_ERR;
        };

        BPdata->cur_pos=0;
        fseek(BPdata->file_data,
              BPdata->cur_pos*sizeof(T_BYPASS_IDX),
              SEEK_SET
             );

        if (fread( &BPdata->cur_data,
              1,  sizeof(T_BYPASS_IDX),
              BPdata->file_data
            ) != sizeof(T_BYPASS_IDX))
        {
            sprintf (drvError, "Ошибка чтения ВОГ данных %s(Init_BPdata)", BPdata->file_name);
            fclose(BPdata->file_data);
            return KRT_ERR;
        };

     }; //    if ( fopen(BPdata->file_name, "rb"))!=NULL) 

  return KRT_OK;
};// long Init_BPdata(T_BP_DATA *BPdata, char * work_path, char * trc, char drvError[])


long Get_BPdata(long start, T_BP_DATA *BPdata, char drvError[])
{

  if (start!=BPdata->cur_data.Odometr) {
     if (start >= BPdata->left_data.Odometr &&
         start <= BPdata->right_data.Odometr)
      {
         // и так нужное значение входит в отрезок поиска
      } else {
         // обновим данные границ поиска

         if ( start > BPdata->right_data.Odometr)
         {
              BPdata->right_pos = BPdata->lengt_file_in_BP_rec-1;

              fseek(BPdata->file_data,
                    BPdata->right_pos*sizeof(T_BYPASS_IDX),
                    SEEK_SET
                   );

              if (fread( &(BPdata->right_data), 1, sizeof(T_BYPASS_IDX),
                    BPdata->file_data
                  ) != sizeof(T_BYPASS_IDX))
               {
                  sprintf (drvError, "Ошибка чтения байпасных данных %s.(GetBPdata)", BPdata->file_name);
                  return 1;
               };

              if (start > BPdata->right_data.Odometr) {
                 memcpy(&(BPdata->right_data), &(BPdata->cur_data), sizeof(T_BYPASS_IDX));
                 return 0;
               };
         };

         if ( start < BPdata->right_data.Odometr)
         {
             BPdata->left_pos=0;
             fseek(BPdata->file_data,
                   BPdata->left_pos*sizeof(T_BYPASS_IDX),
                   SEEK_SET
                  );

             if (fread( &(BPdata->left_data), 1,  sizeof(T_BYPASS_IDX),
                   BPdata->file_data
                 ) != sizeof(T_BYPASS_IDX))
              {
                 sprintf (drvError, "Ошибка чтения байпасных данных %s.(GetBPdata)", BPdata->file_name);
                 return 1;
              };
         };
      }; // if (start >= BPdata->left_data.Odometr &&

#pragma warning(disable : 4127)  // давим варнинг про константу в условии цикла

     while (1) {  // поиск нужного расстояния

#pragma warning(default:4127)

        if (start == BPdata->left_data.Odometr) {
            BPdata->cur_pos = BPdata->left_pos;
            memcpy(&(BPdata->cur_data), &(BPdata->left_data), sizeof(T_BYPASS_IDX));
            break;
         }; // if (start == BPdata->left_data.Odometr)

        if (start == BPdata->right_data.Odometr) {
            BPdata->cur_pos = BPdata->right_pos;
            memcpy(&(BPdata->cur_data), &(BPdata->right_data), sizeof(T_BYPASS_IDX));
            break;
         }; //if (start == BPdata->right_data.Odometr) {

        if (BPdata->right_pos - BPdata->left_pos < 2 ) {
             BPdata->cur_pos = BPdata->left_pos;
            memcpy(&(BPdata->cur_data), &(BPdata->left_data), sizeof(T_BYPASS_IDX));
            break;
         }; // if (BPdata->right_pos - BPdata->left_pos < 2 )

        // Сузим отрезок поиска
        BPdata->cur_pos
           = BPdata->left_pos + ((BPdata->right_pos - BPdata->left_pos)/2);

         fseek(BPdata->file_data,
               BPdata->cur_pos*sizeof(T_BYPASS_IDX),
               SEEK_SET
              );

         if (fread( &(BPdata->cur_data), 1, sizeof(T_BYPASS_IDX),
               BPdata->file_data
             ) != sizeof(T_BYPASS_IDX))
          {
             sprintf (drvError, "Ошибка чтения байпасных данных %s.(GetBPdata)", BPdata->file_name);
             return 1;
          };

         if (start >= BPdata->cur_data.Odometr)
          {
            // сдвигаем левую границу
            BPdata->left_pos = BPdata->cur_pos;
            memcpy(&(BPdata->left_data), &(BPdata->cur_data), sizeof(T_BYPASS_IDX));
          } else { // if (my_start_vog>=trace_list[curent_trace].BPdata.cur_data.Odometr &&
            // сдвигаем правую границу
            BPdata->right_pos = BPdata->cur_pos;
            memcpy(&(BPdata->right_data), &(BPdata->cur_data), sizeof(T_BYPASS_IDX));
          }; //  else  if (start >= BPdata->cur_data.Odometr &&
      }; //while (1) {  // поиск нужного расстояния
   }; //if (start != BPdata->cur_data.Odometr) {

  return 0;
}; // long Get_BPdata(long start, T_BP_DATA *BPdata, char drvError[])

