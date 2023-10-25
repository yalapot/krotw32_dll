// navigate.c - тела функций для работы с навигацией
// при просмотре данных електронного блока "epro" 
// для программы KrotW32
//
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>


//#include "krtapi.h"
//#include "krotepro.h"
//#include "libdafil.h"
//#include "heapinsp.h"
#include "navigate.h"

 // вычисляем и читаем нужную запись из rec.mat
long WINAPI GetNavData(long start, T_NAVIGATION_DATA *NavData) {
  if (start!=NavData->cur_data.Dist) {
     if (start >= NavData->left_data.Dist &&
         start <= NavData->right_data.Dist)
      {
         // и так нужное значение входит в отрезок поиска
      } else {
         // обновим данные границ поиска
         NavData->right_pos = NavData->lengt_file_in_nav_rec-1;

         fseek(NavData->file_data,
               NavData->right_pos*sizeof(T_NAVIGATION_RECORD),
               SEEK_SET
              );

         if (fread( &(NavData->right_data), 1, sizeof(T_NAVIGATION_RECORD),
               NavData->file_data
             ) != sizeof(T_NAVIGATION_RECORD))
          {
             sprintf (drvError, "Ошибка чтения навигационных данных %s.(GetNavData)", NavData->file_name);
             return 1;
          };

         NavData->left_pos=0;
         fseek(NavData->file_data,
               NavData->left_pos*sizeof(T_NAVIGATION_RECORD),
               SEEK_SET
              );

         if (fread( &(NavData->left_data), 1,  sizeof(T_NAVIGATION_RECORD),
               NavData->file_data
             ) != sizeof(T_NAVIGATION_RECORD))
          {
             sprintf (drvError, "Ошибка чтения навигационных данных %s.(GetNavData)", NavData->file_name);
             return 1;
          };
      }; // if (start >= NavData->left_data.Dist &&

     while (1) {  // поиск нужного расстояния
        if (start == NavData->left_data.Dist) {
            NavData->cur_pos = NavData->left_pos;
            memcpy(&(NavData->cur_data), &(NavData->left_data), sizeof(T_NAVIGATION_RECORD));
            break;
         }; // if (start == NavData->left_data.Dist)

        if (start == NavData->right_data.Dist) {
            NavData->cur_pos = NavData->right_pos;
            memcpy(&(NavData->cur_data), &(NavData->right_data), sizeof(T_NAVIGATION_RECORD));
            break;
         }; //if (start == NavData->right_data.Dist) {

        if (NavData->right_pos - NavData->left_pos < 2 ) {
             NavData->cur_pos = NavData->left_pos;
            memcpy(&(NavData->cur_data), &(NavData->left_data), sizeof(T_NAVIGATION_RECORD));
            break;
         }; // if (NavData->right_pos - NavData->left_pos < 2 )

        // Сузим отрезок поиска
        NavData->cur_pos
           = NavData->left_pos + ((NavData->right_pos - NavData->left_pos)/2);

         fseek(NavData->file_data,
               NavData->cur_pos*sizeof(T_NAVIGATION_RECORD),
               SEEK_SET
              );

         if (fread( &(NavData->cur_data), 1, sizeof(T_NAVIGATION_RECORD),
               NavData->file_data
             ) != sizeof(T_NAVIGATION_RECORD))
          {
             sprintf (drvError, "Ошибка чтения навигационных данных %s.(GetNavData)", NavData->file_name);
             return 1;
          };

         if (start >= NavData->cur_data.Dist)
          {
            // сдвигаем левую границу
            NavData->left_pos = NavData->cur_pos;
            memcpy(&(NavData->left_data), &(NavData->cur_data), sizeof(T_NAVIGATION_RECORD));
          } else { // if (my_start_vog>=trace_list[curent_trace].NavData.cur_data.Dist &&
            // сдвигаем правую границу
            NavData->right_pos = NavData->cur_pos;
            memcpy(&(NavData->right_data), &(NavData->cur_data), sizeof(T_NAVIGATION_RECORD));
          }; //  else  if (start >= NavData->cur_data.Dist &&
      }; //while (1) {  // поиск нужного расстояния
   }; //if (start != NavData->cur_data.Dist) {

  return 0;
}; // long WINAPI GetNavData(long start, T_NAVIGATION_DATA *NavData)


 // вычисляем и читаем нужную запись из rec.vog
long WINAPI GetVogData(long start, T_VOG_DATA *VogData) {
  if (start!=VogData->cur_data.Dist) {
     if (start >= VogData->left_data.Dist &&
         start <= VogData->right_data.Dist)
      {
         // и так нужное значение входит в отрезок поиска
      } else {
         // обновим данные границ поиска
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
      }; // if (start >= VogData->left_data.Dist &&

     while (1) {  // поиск нужного расстояния
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
               VogData->cur_pos*sizeof(T_VOG_RECORD),
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

  return 0;
}; // long WINAPI GetVogData(long start, T_VOG_DATA *VogData)

long get_orient_from_VOG(long start,
                         T_VOG_DATA *VogData,
                         long num_sens)
{
  long res_orient;
  double tmp,tmp2;
 
    if (VogData->file_data==NULL) {
        return 0;
     };

    if (GetVogData(start, VogData)!=0) {
        return 0;
     };

    tmp = num_sens;
    tmp = 2 * PI / tmp;

    tmp2 = VogData->cur_data.Gamma;

    while (tmp2>(2 * PI)) {
       tmp2 -= (2 * PI);
     };

    while (tmp2<0) {
       tmp2  += (2 * PI);
     };

    res_orient = (long) (tmp2/tmp);

    return res_orient;
}; // long get_orient_from_VOG(long start,


/// а это get_orient_from_NAV
long get_orient_from_NAV(long start,
                         T_NAVIGATION_DATA *NavData,
                         long num_sens)
{
  double sA, cA, ArcTg2;

    if (NavData->file_data==NULL) {
        return 0;
     };

    if (GetNavData(start, NavData)!=0) {
        return 0;
     };


/*
    sA=NavData->cur_data.AccelY;
    cA=NavData->cur_data.AccelZ;

    if (abs(cA / sqrt(sA*sA + cA*cA) ) > 0.707)
       {
            if (cA < 0)
              {
                ArcTg0 = PI - atan(sA / cA);
              } else {
                if (sA>0)
                  {
                    ArcTg0 = 2 * PI - atan(sA / cA);
                  } else {
                    ArcTg0 = -atan(sA / cA);
                  };
              };
         } else {
             if (sA < 0)
               {
                 ArcTg0 = PI/2 + atan(cA / sA);
               } else {
                 ArcTg0 = 3 * PI/2 + atan(cA / sA);
               };
         };

    ArcTg0 *= num_sens;
    ArcTg0 /= (2*PI);
*/

    sA=NavData->cur_data.AccelY;
    cA=NavData->cur_data.AccelZ;

    if (cA == 0) {
        if (sA < 0) {
            ArcTg2 = 1.5 * PI;
         } else {
            ArcTg2 = 0.5 * PI;
         };
     } else {
         if (cA < 0) {
             ArcTg2 =  PI + atan(sA / cA);
          } else {
             if (sA < 0) {
                 ArcTg2 = 2 * PI + atan(sA / cA);
              } else {
                 ArcTg2 = atan(sA / cA);
              };
          };
     };

    ArcTg2*=(num_sens-1);
    ArcTg2/=(2*PI);

  return (long) ArcTg2;
}; // long get_orient_from_NAV(long start,