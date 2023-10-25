
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <krtapi.h>
#include "navigate.h"


long Init_VogData(T_VOG_DATA *VogData, char * work_path, char * trc, char drvError[])
{
     VogData->file_data=NULL;

     // читаем из ini-файла путь на файл с навигациоддыми данными
     GetPrivateProfileString( DRIVER_DATA , RecVog_KEY, "",
                              VogData->file_name, sizeof(VogData->file_name),
                              trc);

     // попробуем открыть файл
     VogData->file_data = fopen(VogData->file_name, "rb");

     if ( VogData->file_data == NULL) {

        sprintf(VogData->file_name, "%srec.vog", work_path);
        VogData->file_data = fopen(VogData->file_name, "rb");
        if ( VogData->file_data == NULL) {
           return KRT_ERR;
        };
     };

     if ( VogData->file_data != NULL) 
     { // файл присутствует
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
            fclose(VogData->file_data);
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
            fclose(VogData->file_data);
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
            fclose(VogData->file_data);
            return KRT_ERR;
        };

     }; //    if ( fopen(VogData->file_name, "rb"))!=NULL) 

  return KRT_OK;
};// long Init_VogData(T_VOG_DATA *VogData, char * trc)


  // подготовим структуру работы с навигационными данными
long Init_navigete(T_VOG_DATA *VogData, char * work_path, char * trc, T_TRACEINFO *inf, char drvError[]){

   if (Init_VogData(VogData, work_path, trc, drvError) == KRT_ERR) 
   {
       strcat (drvError, "(Init_navigete)");
       return KRT_ERR;
   };


  if (VogData->file_data != NULL)
  {
      inf->vog=1;
  }; //if (trace_list[curent_trace].VogData.file_data!=NULL)

  return KRT_OK;
}; // long KRTAPI Init_navigete(T_TRACE_LIST * trace, T_TRACEINFO *inf)


 // вычисляем и читаем нужную запись из rec.vog
long GetVogData(long start, T_VOG_DATA *VogData, char drvError[]) {
  if (start!=VogData->cur_data.Dist) {
     if (start >= VogData->left_data.Dist &&
         start <= VogData->right_data.Dist)
      {
         // и так нужное значение входит в отрезок поиска
      } else {
         // обновим данные границ поиска

         if ( start > VogData->right_data.Dist)
         {
              VogData->right_pos = VogData->lengt_file_in_nav_rec-1;

              fseek(VogData->file_data,
                    VogData->right_pos*sizeof(T_VOG_RECORD),
                    SEEK_SET
                   );

              if (fread( &(VogData->right_data), 1, sizeof(T_VOG_RECORD),
                    VogData->file_data
                  ) != sizeof(T_VOG_RECORD))
               {
                  sprintf (drvError, "Ошибка чтения навигационных данных %s.(GetVogData)", VogData->file_name);
                  return 1;
               };

              if (start > VogData->right_data.Dist) {
                 memcpy(&(VogData->right_data), &(VogData->cur_data), sizeof(T_VOG_RECORD));
                 return 0;
               };
         };

         if ( start < VogData->right_data.Dist)
         {
             VogData->left_pos=0;
             fseek(VogData->file_data,
                   VogData->left_pos*sizeof(T_VOG_RECORD),
                   SEEK_SET
                  );

             if (fread( &(VogData->left_data), 1,  sizeof(T_VOG_RECORD),
                   VogData->file_data
                 ) != sizeof(T_VOG_RECORD))
              {
                 sprintf (drvError, "Ошибка чтения навигационных данных %s.(GetVogData)", VogData->file_name);
                 return 1;
              };
         };
      }; // if (start >= VogData->left_data.Dist &&

#pragma warning(disable : 4127)  // давим варнинг про константу в условии цикла

     while (1) {  // поиск нужного расстояния

#pragma warning(default:4127)

        if (start == VogData->left_data.Dist) {
            VogData->cur_pos = VogData->left_pos;
            memcpy(&(VogData->cur_data), &(VogData->left_data), sizeof(T_VOG_RECORD));
            break;
         }; // if (start == VogData->left_data.Dist)

        if (start == VogData->right_data.Dist) {
            VogData->cur_pos = VogData->right_pos;
            memcpy(&(VogData->cur_data), &(VogData->right_data), sizeof(T_VOG_RECORD));
            break;
         }; //if (start == VogData->right_data.Dist) {

        if (VogData->right_pos - VogData->left_pos < 2 ) {
             VogData->cur_pos = VogData->left_pos;
            memcpy(&(VogData->cur_data), &(VogData->left_data), sizeof(T_VOG_RECORD));
            break;
         }; // if (VogData->right_pos - VogData->left_pos < 2 )

        // Сузим отрезок поиска
        VogData->cur_pos
           = VogData->left_pos + ((VogData->right_pos - VogData->left_pos)/2);

         fseek(VogData->file_data,
               VogData->cur_pos * sizeof(T_VOG_RECORD),
               SEEK_SET
              );

         if (fread( &(VogData->cur_data), 1, sizeof(T_VOG_RECORD),
               VogData->file_data
             ) != sizeof(T_VOG_RECORD))
          {
             sprintf (drvError, "Ошибка чтения навигационных данных %s.(GetVogData)", VogData->file_name);
             return 1;
          };

         if (start >= VogData->cur_data.Dist)
          {
            // сдвигаем левую границу
            VogData->left_pos = VogData->cur_pos;
            memcpy(&(VogData->left_data), &(VogData->cur_data), sizeof(T_VOG_RECORD));
          } else { // if (my_start_vog>=trace_list[curent_trace].VogData.cur_data.Dist &&
            // сдвигаем правую границу
            VogData->right_pos = VogData->cur_pos;
            memcpy(&(VogData->right_data), &(VogData->cur_data), sizeof(T_VOG_RECORD));
          }; //  else  if (start >= VogData->cur_data.Dist &&
      }; //while (1) {  // поиск нужного расстояния
   }; //if (start != VogData->cur_data.Dist) {

  { // проверка данных на разрыв
      if (VogData->cur_data.Dist == VogData->left_data.Dist)
      {
         VogData->right_pos = VogData->left_pos + 1;
         fseek(VogData->file_data,
               VogData->right_pos * sizeof(T_VOG_RECORD),
               SEEK_SET
              );

         fread( &(VogData->right_data), 1, sizeof(T_VOG_RECORD),VogData->file_data);

      } else {
         VogData->left_pos = VogData->right_pos - 1;
         fseek(VogData->file_data,
               VogData->left_pos * sizeof(T_VOG_RECORD),
               SEEK_SET
              );

         fread( &(VogData->left_data), 1, sizeof(T_VOG_RECORD),VogData->file_data);
      };

      // проверяем есть ли пропуск в данных
      if (VogData->right_data.Dist - VogData->left_data.Dist > 100)
      {

          // если есть интерполируем данные
          long d_track = VogData->right_data.Dist - VogData->left_data.Dist;


          if ( VogData->right_data.VogX > VogData->left_data.VogX )
              VogData->cur_data.VogX  = VogData->left_data.VogX + (VogData->right_data.VogX - VogData->left_data.VogX) * (start - VogData->left_data.Dist) / d_track;
          else
              VogData->cur_data.VogX  = VogData->left_data.VogX - (VogData->left_data.VogX - VogData->right_data.VogX) * (start - VogData->left_data.Dist) / d_track;

          if ( VogData->right_data.VogY > VogData->left_data.VogY )
              VogData->cur_data.VogY  = VogData->left_data.VogY + (VogData->right_data.VogY - VogData->left_data.VogY) * (start - VogData->left_data.Dist) / d_track;
          else
              VogData->cur_data.VogY  = VogData->left_data.VogY - (VogData->left_data.VogY - VogData->right_data.VogY) * (start - VogData->left_data.Dist) / d_track;

          if ( VogData->right_data.VogZ > VogData->left_data.VogZ )
              VogData->cur_data.VogZ  = VogData->left_data.VogY + (VogData->right_data.VogY - VogData->left_data.VogY) * (start - VogData->left_data.Dist) / d_track;
          else
              VogData->cur_data.VogZ  = VogData->left_data.VogZ - (VogData->left_data.VogZ - VogData->right_data.VogZ) * (start - VogData->left_data.Dist) / d_track;

          if ( VogData->right_data.Psi > VogData->left_data.Psi )
              VogData->cur_data.Psi  = VogData->left_data.Psi + (VogData->right_data.Psi - VogData->left_data.Psi) * (start - VogData->left_data.Dist) / d_track;
          else
              VogData->cur_data.Psi  = VogData->left_data.Psi - (VogData->left_data.Psi - VogData->right_data.Psi) * (start - VogData->left_data.Dist) / d_track;

          if ( VogData->right_data.Teta > VogData->left_data.Teta )
              VogData->cur_data.Teta  = VogData->left_data.Teta + (VogData->right_data.Teta - VogData->left_data.Teta) * (start - VogData->left_data.Dist) / d_track;
          else
              VogData->cur_data.Teta  = VogData->left_data.Teta - (VogData->left_data.Teta - VogData->right_data.Teta) * (start - VogData->left_data.Dist) / d_track;

          if ( VogData->right_data.Gamma > VogData->left_data.Gamma )
              VogData->cur_data.Gamma  = VogData->left_data.Gamma + (VogData->right_data.Gamma - VogData->left_data.Gamma) * (start - VogData->left_data.Dist) / d_track;
          else
              VogData->cur_data.Gamma  = VogData->left_data.Gamma - (VogData->left_data.Gamma - VogData->right_data.Gamma) * (start - VogData->left_data.Dist) / d_track;
      };
  };

  return 0;
}; // long GetVogData(long start, T_VOG_DATA *VogData)

long get_orient_from_VOG(long start,
                         T_VOG_DATA *VogData,
                         long num_sens)
{
  long res_orient;
  double tmp,tmp2;
  char tmp_drv_err[1024];

 
    if (VogData->file_data==NULL) {
        return 0;
     };

    if (GetVogData(start, VogData, tmp_drv_err)!=0) {
        return 0;
     };

//    tmp = num_sens;
//    tmp = 2 * PI / tmp;

    // НОРМАЛИЗУЕМ КРЕН
    tmp2 = VogData->cur_data.Gamma;

    while (tmp2>(2 * PI)) {
       tmp2 -= (2 * PI);
     };

    while (tmp2<0) {
       tmp2  += (2 * PI);
     };

    tmp = tmp2 * num_sens / (2 * PI);

    res_orient = (long) (tmp);

    return res_orient;
}; // long get_orient_from_VOG(long start,


#define RIGHT_POS  1
#define CUR_POS    0
#define LEFT_POS  -1

long read_nav_record(T_NAVIGATION_DATA *rec_nav, long RLC_pos)
{
    T_NAVIGATION_RECORD *cur_nav_place = &rec_nav->cur_data;

    switch (RLC_pos) {

       case (RIGHT_POS): {
           fseek(rec_nav->file_data, rec_nav->right_pos * rec_nav->nav_rec_len, SEEK_SET );
           cur_nav_place = &rec_nav->right_data;

           break;
       };

       case (CUR_POS): {
           fseek(rec_nav->file_data, rec_nav->cur_pos * rec_nav->nav_rec_len, SEEK_SET );
           cur_nav_place = &rec_nav->cur_data;

           break;
       };

       case (LEFT_POS): {
           fseek(rec_nav->file_data, rec_nav->left_pos * rec_nav->nav_rec_len, SEEK_SET );
           cur_nav_place = &rec_nav->left_data;

           break;
       };
    }; // switch (RLC_pos)

    if (rec_nav->nav_file_version == REC_NAV )
    {
        // читаем поля long  Time; и long  Dist;
        if (fread( cur_nav_place, 1, 8, rec_nav->file_data ) != 8)
        {
            return KRT_ERR;
        };
        // пропускаем поля long OdometerTime; и long OdometerDist;
        cur_nav_place->OdometerTime = 0;
        cur_nav_place->OdometerDist = 0;
        // но дочитываем данные навигации
        if (fread( &(cur_nav_place->VogX), 1, 4*6, rec_nav->file_data ) != 4*6)
        {
            return KRT_ERR;
        };
        return KRT_OK;
    };

    if (rec_nav->nav_file_version == REC_NAV2 )
    {
        if (fread( cur_nav_place, 1, rec_nav->nav_rec_len, rec_nav->file_data ) == rec_nav->nav_rec_len)
        {
            cur_nav_place->Dist /= 10;
            return KRT_OK;
        };
    };

    return KRT_ERR;

}; //long read_nav_record(

long Init_NavData(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[])
{
  NavData->nav_rec_len = sizeof(T_NAVIGATION_RECORD);

  sprintf(NavData->file_name, "%srec.mat2", work_path);
  NavData->nav_file_version = REC_NAV2;
  NavData->file_data = fopen(NavData->file_name, "rb");

  if ( NavData->file_data == NULL) {
      sprintf(NavData->file_name, "%srec.mat", work_path);
      NavData->nav_file_version = REC_NAV;
      NavData->nav_rec_len = sizeof(T_NAVIGATION_RECORD) - 8;
      NavData->file_data = fopen(NavData->file_name, "rb");

      if ( NavData->file_data == NULL) {
           // читаем из ini-файла путь на файл с навигациоддыми данными
          GetPrivateProfileString( DRIVER_DATA , RecMat_KEY, "",
                                   NavData->file_name, sizeof(NavData->file_name),
                                   trc);
          if (NavData->file_name[strlen(NavData->file_name)-1] == '2')
          {
              NavData->nav_file_version = REC_NAV2;
              NavData->nav_rec_len = sizeof(T_NAVIGATION_RECORD);
          } else {
              NavData->nav_file_version = REC_NAV;
              NavData->nav_rec_len = sizeof(T_NAVIGATION_RECORD) - 8;
          }

          NavData->file_data = fopen(NavData->file_name, "rb");

          if ( NavData->file_data == NULL) {
              return KRT_ERR;
          };
      };
  };

  if (NavData->file_data != NULL) 
  { // файл присутствует

     // посчитаем его длинну (в записях навигации)
     fseek(NavData->file_data, 0, SEEK_END);
     NavData->lengt_file_in_nav_rec = ftell(NavData->file_data);

     if (NavData->lengt_file_in_nav_rec < 0)
     {
         sprintf (drvError, "Ошибка чтения навигационных данных %s(Init_NavData)", NavData->file_name);
         fclose(NavData->file_data);
         NavData->file_data =NULL;
         return KRT_ERR;
     };

     NavData->lengt_file_in_nav_rec /= NavData->nav_rec_len;

     // заполним данные границ поиска и текущие данные
     NavData->right_pos = NavData->lengt_file_in_nav_rec-1;

     if ( read_nav_record(NavData, RIGHT_POS) == KRT_ERR )
     {
         sprintf (drvError, "Ошибка чтения навигационных данных %s(Init_NavData)", NavData->file_name);
         fclose(NavData->file_data);
         NavData->file_data =NULL;
         return KRT_ERR;
     };

     NavData->left_pos=0;

     if ( read_nav_record(NavData, LEFT_POS) == KRT_ERR )
     {
         sprintf (drvError, "Ошибка чтения навигационных данных %s(Init_NavData)", NavData->file_name);
         fclose(NavData->file_data);
         NavData->file_data =NULL;
         return KRT_ERR;
     };

     NavData->cur_pos = NavData->left_pos;
     memcpy(&(NavData->cur_data), &(NavData->left_data), NavData->nav_rec_len);

     return KRT_OK;
  }; //    if ( fopen(NavData->file_name, "rb"))!=NULL) 

  return KRT_OK;
};// long Init_NavData(T_NAVIGATION_DATA *NavData, char * trc)


 // Ищем навигационные данные
long Serch_navigete(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[]){

    if (Init_NavData(NavData, work_path, trc, drvError) == KRT_ERR) 
    {
        strcat (drvError, "(Init_navigete)");
        return KRT_ERR;
    };

    return KRT_OK;
}; //long Serch_navigete(T_TRACE_LIST * p_trace_list){


 // вычисляем и читаем нужную запись из rec.mat
long GetNavData(long start, T_NAVIGATION_DATA *NavData, char drvError[])
{
  if (start != NavData->cur_data.Dist) {
     if (start >= NavData->left_data.Dist && start <= NavData->right_data.Dist)
     {
         // и так нужное значение входит в отрезок поиска
     } else {
         // обновим данные границ поиска
         NavData->right_pos = NavData->lengt_file_in_nav_rec-1;

         if ( read_nav_record(NavData, RIGHT_POS) == KRT_ERR )
         {
             sprintf (drvError, "Ошибка чтения навигационных данных %s(GetNavData)", NavData->file_name);
             fclose(NavData->file_data);
             return KRT_ERR;
         };

         NavData->left_pos=0;

         if ( read_nav_record(NavData, LEFT_POS) == KRT_ERR )
         {
             sprintf (drvError, "Ошибка чтения навигационных данных %s(GetNavData)", NavData->file_name);
             fclose(NavData->file_data);
             return KRT_ERR;
         };
     }; // if (start >= NavData->left_data.Dist &&

#pragma warning(disable : 4127)  // давим варнинг про константу в условии цикла

     while (1) {  // поиск нужного расстояния

#pragma warning(default:4127)

         if ( (start == NavData->left_data.Dist) || (NavData->right_pos - NavData->left_pos < 2) )
         {
             NavData->cur_pos = NavData->left_pos;
             memcpy(&(NavData->cur_data), &(NavData->left_data), NavData->nav_rec_len);
             break;
          };

         if (start == NavData->right_data.Dist) {
             NavData->cur_pos = NavData->right_pos;
             memcpy(&(NavData->cur_data), &(NavData->right_data), NavData->nav_rec_len);
             break;
          }; //if (start == NavData->right_data.Dist) {

         // Сузим отрезок поиска
         NavData->cur_pos = NavData->left_pos + ((NavData->right_pos - NavData->left_pos)/2);

         if ( read_nav_record(NavData, CUR_POS) == KRT_ERR )
         {
             sprintf (drvError, "Ошибка чтения навигационных данных %s(Init_NavData)", NavData->file_name);
             fclose(NavData->file_data);
             return KRT_ERR;
         };

         if (start >= NavData->cur_data.Dist)
         {
            // сдвигаем левую границу
            NavData->left_pos = NavData->cur_pos;
            memcpy(&(NavData->left_data), &(NavData->cur_data), NavData->nav_rec_len);
         } else { // if (my_start_vog>=trace_list[curent_trace].NavData.cur_data.Dist &&
            // сдвигаем правую границу
            NavData->right_pos = NavData->cur_pos;
            memcpy(&(NavData->right_data), &(NavData->cur_data), NavData->nav_rec_len);
         }; //  else  if (start >= NavData->cur_data.Dist &&
      }; //while (1) {  // поиск нужного расстояния
   }; //if (start != NavData->cur_data.Dist) {

  return 0;
}; // long GetNavData(long start, T_NAVIGATION_DATA *NavData)

