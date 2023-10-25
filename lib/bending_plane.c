
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <krtapi.h>
#include "bending_plane.h"

char drvError[1024];

T_bending_plane_file_head bending_plane_file_head;

T_bending_plane_DATA * bending_plane_data = NULL;

long Dist2long(float srcDist)
{
    return (long) (srcDist * 100);
}

long Init_bending_plane_Data(char * trc)
{
     char work_path[1024];

     // вычленим строку пути до trc-файла (без имени самого файла)
     strcpy (work_path, trc);

     while((strlen(work_path)>0) && (work_path[strlen(work_path)-1]!='\\')) {
        work_path[strlen(work_path)-1]=0;
     };

     bending_plane_data = malloc(sizeof(T_bending_plane_DATA));

     bending_plane_data->file_data=NULL;

     // попробуем открыть файл
     sprintf(bending_plane_data->file_name, "%sBendingPlane.bpa", work_path);
     bending_plane_data->file_data = fopen(bending_plane_data->file_name, "rb");

     if ( bending_plane_data->file_data != NULL) 
     { // файл присутствует

        fread( &bending_plane_file_head, 1,  sizeof(bending_plane_file_head), bending_plane_data->file_data);

        // посчитаем его длинну
        fseek(bending_plane_data->file_data, 0, SEEK_END);
        bending_plane_data->lengt_file_in_nav_rec = ftell(bending_plane_data->file_data);
        bending_plane_data->lengt_file_in_nav_rec = 
                 (bending_plane_data->lengt_file_in_nav_rec - sizeof(bending_plane_file_head))
                 / sizeof(T_bending_plane);

        // заполним данные границ поиска и текущие данные
        bending_plane_data->right_pos = bending_plane_data->lengt_file_in_nav_rec-1;
        fseek(bending_plane_data->file_data,
              bending_plane_data->right_pos*sizeof(T_bending_plane),
              SEEK_SET
             );

        if (fread( &bending_plane_data->right_data,
              1,  sizeof(T_bending_plane),
              bending_plane_data->file_data
            ) != sizeof(T_bending_plane))
        {
            sprintf (drvError, "Ошибка чтения данных %s(Init_bending_plane_data)", bending_plane_data->file_name);
            fclose(bending_plane_data->file_data);
            return KRT_ERR;
        };

        bending_plane_data->left_pos=0;
        fseek(bending_plane_data->file_data,
              bending_plane_data->left_pos*sizeof(T_bending_plane) + sizeof(bending_plane_file_head),
              SEEK_SET
             );

        if (fread( &bending_plane_data->left_data,
              1,  sizeof(T_bending_plane),
              bending_plane_data->file_data
            ) != sizeof(T_bending_plane))
        {
            sprintf (drvError, "Ошибка чтения данных %s(Init_bending_plane_data)", bending_plane_data->file_name);
            fclose(bending_plane_data->file_data);
            return KRT_ERR;
        };

        bending_plane_data->cur_pos=0;
        fseek(bending_plane_data->file_data,
              bending_plane_data->cur_pos*sizeof(T_bending_plane) + sizeof(bending_plane_file_head),
              SEEK_SET
             );

        if (fread( &bending_plane_data->cur_data,
              1,  sizeof(T_bending_plane),
              bending_plane_data->file_data
            ) != sizeof(T_bending_plane))
        {
            sprintf (drvError, "Ошибка чтения данных %s(Init_bending_plane_data)", bending_plane_data->file_name);
            fclose(bending_plane_data->file_data);
            return KRT_ERR;
        };
     }; //    if ( fopen(bending_plane_data->file_name, "rb"))!=NULL) 

  return KRT_OK;
};// long Init_bending_plane_data(T_bending_plane_DATA *bending_plane_data, char * trc)


 // вычисляем и читаем нужную запись 
long Get_bending_plane_Data(long start, T_bending_plane *bending_plane)//, char drvError[])
{
  if (start < 0 ) start = 0;

  if (start != Dist2long(bending_plane_data->cur_data.Dist)) {
     if (start >= Dist2long(bending_plane_data->left_data.Dist) &&
         start <= Dist2long(bending_plane_data->right_data.Dist))
      {
         // и так нужное значение входит в отрезок поиска
      } else {
         // обновим данные границ поиска

         if ( start > Dist2long(bending_plane_data->right_data.Dist))
         {
              bending_plane_data->right_pos = bending_plane_data->lengt_file_in_nav_rec-1;

              fseek(bending_plane_data->file_data,
                    bending_plane_data->right_pos * sizeof(T_bending_plane) + sizeof(bending_plane_file_head),
                    SEEK_SET
                   );

              if (fread( &(bending_plane_data->right_data), 1, sizeof(T_bending_plane),
                    bending_plane_data->file_data
                  ) != sizeof(T_bending_plane))
              {
                  sprintf (drvError, "Ошибка чтения данных %s.(Getbending_plane_data)", bending_plane_data->file_name);
                  return 1;
              };

              memcpy(&(bending_plane_data->cur_data), &(bending_plane_data->right_data), sizeof(T_bending_plane));

              if (start >= Dist2long(bending_plane_data->right_data.Dist)) {
                 memcpy(&(bending_plane_data->cur_data), &(bending_plane_data->right_data), sizeof(T_bending_plane));
                 memcpy(bending_plane, &(bending_plane_data->cur_data), sizeof(T_bending_plane));
                 return 0;
              };
         };

         if ( start < Dist2long(bending_plane_data->left_data.Dist))
         {
             bending_plane_data->left_pos=0;
             fseek(bending_plane_data->file_data,
                   bending_plane_data->left_pos * sizeof(T_bending_plane) + sizeof(bending_plane_file_head),
                   SEEK_SET
                  );

             if (fread( &(bending_plane_data->left_data), 1,  sizeof(T_bending_plane),
                   bending_plane_data->file_data
                 ) != sizeof(T_bending_plane))
             {
                 sprintf (drvError, "Ошибка чтения %s.(Getbending_plane_data)", bending_plane_data->file_name);
                 return 1;
             };

             memcpy(&(bending_plane_data->cur_data), &(bending_plane_data->left_data), sizeof(T_bending_plane));
         };
      }; // if (start >= bending_plane_data->left_data.Dist &&

#pragma warning(disable : 4127)  // давим варнинг про константу в условии цикла

     while (1) {  // поиск нужного расстояния

#pragma warning(default:4127)

        if (start == Dist2long(bending_plane_data->left_data.Dist)) {
            bending_plane_data->cur_pos = bending_plane_data->left_pos;
            memcpy(&(bending_plane_data->cur_data), &(bending_plane_data->left_data), sizeof(T_bending_plane));
            break;
        }; // if (start == bending_plane_data->left_data.Dist)

        if (start == Dist2long(bending_plane_data->right_data.Dist)) {
            bending_plane_data->cur_pos = bending_plane_data->right_pos;
            memcpy(&(bending_plane_data->cur_data), &(bending_plane_data->right_data), sizeof(T_bending_plane));
            break;
        }; //if (start == bending_plane_data->right_data.Dist) {

        if (bending_plane_data->right_pos - bending_plane_data->left_pos < 2 ) {
            bending_plane_data->cur_pos = bending_plane_data->left_pos;
            memcpy(&(bending_plane_data->cur_data), &(bending_plane_data->left_data), sizeof(T_bending_plane));
            break;
        }; // if (bending_plane_data->right_pos - bending_plane_data->left_pos < 2 )

        // Сузим отрезок поиска
        bending_plane_data->cur_pos
           = bending_plane_data->left_pos + ((bending_plane_data->right_pos - bending_plane_data->left_pos)/2);

         fseek(bending_plane_data->file_data,
               bending_plane_data->cur_pos * sizeof(T_bending_plane) + sizeof(bending_plane_file_head),
               SEEK_SET
              );

         if (fread( &(bending_plane_data->cur_data), 1, sizeof(T_bending_plane),
               bending_plane_data->file_data
             ) != sizeof(T_bending_plane))
         {
             sprintf (drvError, "Ошибка чтения данных %s.(Getbending_plane_data)", bending_plane_data->file_name);
             return 1;
         };

         if (start >= Dist2long(bending_plane_data->cur_data.Dist))
         {
            // сдвигаем левую границу
            bending_plane_data->left_pos = bending_plane_data->cur_pos;
            memcpy(&(bending_plane_data->left_data), &(bending_plane_data->cur_data), sizeof(T_bending_plane));
         } else {
            // сдвигаем правую границу
            bending_plane_data->right_pos = bending_plane_data->cur_pos;
            memcpy(&(bending_plane_data->right_data), &(bending_plane_data->cur_data), sizeof(T_bending_plane));
         }; //  else  if (start >= bending_plane_data->cur_data.Dist &&
     }; //while (1) {  // поиск нужного расстояния
  }; //if (start != bending_plane_data->cur_data.Dist) {

  memcpy(bending_plane, &(bending_plane_data->cur_data), sizeof(T_bending_plane));

  return 0;
};

