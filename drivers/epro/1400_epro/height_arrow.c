
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <krtapi.h>
#include "height_arrow.h"

T_arrow_file_head arrow_file_head;

T_arrow_DATA * arrowData = NULL;

long PigL0=0;

long Init_arrow_hd_Data(char * trc)
{
     char work_path[1024];
     char PigL0_str[1024];

     // читаем из trc-файла L0
     GetPrivateProfileString("Trace" , "PigL0", "", PigL0_str, sizeof(PigL0_str), trc);
     PigL0 = atoi(PigL0_str);
     PigL0 /= 10;


     // вычленим строку пути до trc-файла (без имени самого файла)
     strcpy (work_path, trc);

     while((strlen(work_path)>0) && (work_path[strlen(work_path)-1]!='\\')) {
       work_path[strlen(work_path)-1]=0;
     };

     arrowData = malloc(sizeof(T_arrow_DATA));

     arrowData->file_data=NULL;

     // попробуем открыть файл
     sprintf(arrowData->file_name, "%sarrow.hd", work_path);
     arrowData->file_data = fopen(arrowData->file_name, "rb");

     if ( arrowData->file_data != NULL) 
     { // файл присутствует

        fread( &arrow_file_head, 1,  sizeof(arrow_file_head), arrowData->file_data);

        // посчитаем его длинну (в записях навигации)
        fseek(arrowData->file_data, 0, SEEK_END);
        arrowData->lengt_file_in_nav_rec = ftell(arrowData->file_data);
        arrowData->lengt_file_in_nav_rec = 
                 (arrowData->lengt_file_in_nav_rec - sizeof(arrow_file_head))
                 / sizeof(T_arrow_hd);

        // заполним данные границ поиска и текущие данные
        arrowData->right_pos = arrowData->lengt_file_in_nav_rec-1;

        fseek(arrowData->file_data,
              arrowData->right_pos*sizeof(T_arrow_hd),
              SEEK_SET
             );


        if (fread( &arrowData->right_data,
              1,  sizeof(T_arrow_hd),
              arrowData->file_data
            ) != sizeof(T_arrow_hd))
        {
            sprintf (drvError, "Ошибка чтения данных %s(Init_arrowData)", arrowData->file_name);
            fclose(arrowData->file_data);
            return KRT_ERR;
        };

        arrowData->left_pos=0;
        fseek(arrowData->file_data,
              arrowData->left_pos*sizeof(T_arrow_hd) + sizeof(arrow_file_head),
              SEEK_SET
             );

        if (fread( &arrowData->left_data,
              1,  sizeof(T_arrow_hd),
              arrowData->file_data
            ) != sizeof(T_arrow_hd))
        {
            sprintf (drvError, "Ошибка чтения данных %s(Init_arrowData)", arrowData->file_name);
            fclose(arrowData->file_data);
            return KRT_ERR;
        };

        arrowData->cur_pos=0;
        fseek(arrowData->file_data,
              arrowData->cur_pos*sizeof(T_arrow_hd) + sizeof(arrow_file_head),
              SEEK_SET
             );

        if (fread( &arrowData->cur_data,
              1,  sizeof(T_arrow_hd),
              arrowData->file_data
            ) != sizeof(T_arrow_hd))
        {
            sprintf (drvError, "Ошибка чтения данных %s(Init_arrowData)", arrowData->file_name);
            fclose(arrowData->file_data);
            return KRT_ERR;
        };

     }; //    if ( fopen(arrowData->file_name, "rb"))!=NULL) 

  return KRT_OK;
};// long Init_arrowData(T_arrow_DATA *arrowData, char * trc)


 // вычисляем и читаем нужную запись 
long Get_arrow_hd_Data(long start, T_arrow_hd *arrow_hd)//, char drvError[])
{
  start -= PigL0;
  if (start < 0 ) start = 0;

  if (start!=arrowData->cur_data.Dist) {
     if (start >= arrowData->left_data.Dist &&
         start <= arrowData->right_data.Dist)
      {
         // и так нужное значение входит в отрезок поиска
      } else {
         // обновим данные границ поиска

         if ( start > arrowData->right_data.Dist)
         {
              arrowData->right_pos = arrowData->lengt_file_in_nav_rec-1;

              fseek(arrowData->file_data,
                    arrowData->right_pos * sizeof(T_arrow_hd) + sizeof(arrow_file_head),
                    SEEK_SET
                   );

              if (fread( &(arrowData->right_data), 1, sizeof(T_arrow_hd),
                    arrowData->file_data
                  ) != sizeof(T_arrow_hd))
               {
                  sprintf (drvError, "Ошибка чтения данных %s.(GetarrowData)", arrowData->file_name);
                  return 1;
               };

              if (start > arrowData->right_data.Dist) {
                 memcpy(&(arrowData->right_data), &(arrowData->cur_data), sizeof(T_arrow_hd));
                 return 0;
               };
         };

         if ( start < arrowData->right_data.Dist)
         {
             arrowData->left_pos=0;
             fseek(arrowData->file_data,
                   arrowData->left_pos * sizeof(T_arrow_hd) + sizeof(arrow_file_head),
                   SEEK_SET
                  );

             if (fread( &(arrowData->left_data), 1,  sizeof(T_arrow_hd),
                   arrowData->file_data
                 ) != sizeof(T_arrow_hd))
              {
                 sprintf (drvError, "Ошибка чтения %s.(GetarrowData)", arrowData->file_name);
                 return 1;
              };
         };
      }; // if (start >= arrowData->left_data.Dist &&

#pragma warning(disable : 4127)  // давим варнинг про константу в условии цикла

     while (1) {  // поиск нужного расстояния

#pragma warning(default:4127)

        if (start == arrowData->left_data.Dist) {
            arrowData->cur_pos = arrowData->left_pos;
            memcpy(&(arrowData->cur_data), &(arrowData->left_data), sizeof(T_arrow_hd));
            break;
         }; // if (start == arrowData->left_data.Dist)

        if (start == arrowData->right_data.Dist) {
            arrowData->cur_pos = arrowData->right_pos;
            memcpy(&(arrowData->cur_data), &(arrowData->right_data), sizeof(T_arrow_hd));
            break;
         }; //if (start == arrowData->right_data.Dist) {

        if (arrowData->right_pos - arrowData->left_pos < 2 ) {
            arrowData->cur_pos = arrowData->left_pos;
            memcpy(&(arrowData->cur_data), &(arrowData->left_data), sizeof(T_arrow_hd));
            break;
         }; // if (arrowData->right_pos - arrowData->left_pos < 2 )

        // Сузим отрезок поиска
        arrowData->cur_pos
           = arrowData->left_pos + ((arrowData->right_pos - arrowData->left_pos)/2);

         fseek(arrowData->file_data,
               arrowData->cur_pos * sizeof(T_arrow_hd) + sizeof(arrow_file_head),
               SEEK_SET
              );

         if (fread( &(arrowData->cur_data), 1, sizeof(T_arrow_hd),
               arrowData->file_data
             ) != sizeof(T_arrow_hd))
          {
             sprintf (drvError, "Ошибка чтения данных %s.(GetarrowData)", arrowData->file_name);
             return 1;
          };

         if (start >= arrowData->cur_data.Dist)
          {
            // сдвигаем левую границу
            arrowData->left_pos = arrowData->cur_pos;
            memcpy(&(arrowData->left_data), &(arrowData->cur_data), sizeof(T_arrow_hd));
          } else { // if (my_start_arrow>=trace_list[curent_trace].arrowData.cur_data.Dist &&
            // сдвигаем правую границу
            arrowData->right_pos = arrowData->cur_pos;
            memcpy(&(arrowData->right_data), &(arrowData->cur_data), sizeof(T_arrow_hd));
          }; //  else  if (start >= arrowData->cur_data.Dist &&
      }; //while (1) {  // поиск нужного расстояния
   }; //if (start != arrowData->cur_data.Dist) {

   memcpy(arrow_hd, &(arrowData->cur_data), sizeof(T_arrow_hd));

   return 0;
};

