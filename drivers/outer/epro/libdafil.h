// libdafil.h - заголовк  для модуля libdafil.c.
// Объявление инструментальных функций работы с файлами *.da для драйвера 
// просмотра данных електронного блока "epro" программой KrotW32
//

#ifndef _LIBDAFIL_H_
#define _LIBDAFIL_H_

#include "krotepro.h"

extern long unarc_lzw 
  (
    word *arc_data,
    int arc_size,
    T_INDEX_SEAM *unarc_data,
    long corros_num
  );


// функцияувеличение имени номера файла вида "XXnnnnnХXX..X",
// где Х    -любой символ;
//     nnnnn-номер, который функция увеличивает
int inc_file_name
  (
     char *file_name // на первый символ имени файла вида "XXnnnnnХXX..X"
  );

// функция пересчитывающая количество файлов с непрерывно возрастающими
// номерами вида "XXnnnnnХXX..X", начиная с имени первого файла
extern long enumerate_work_files
  (
     char *first_File,   // указатель на имя первого файла (с полным путем)
     long *data_path_len,// указатель на длинну пути до данных без имени файла
     long *files_num     // кол-во найденных рабочих файлов
  ); 

// функция пересчета условных швов в файле данных
// в структуре T_INDEX_FILE должно быть имя файла (поле file_name)
extern long enumerate_seam_in_files
  ( 
     T_INDEX_FILE *index_file
  );

// пересчет индексов по файлу с заданным номером
// в структуре трассы должны быть уже заполнены все имена файлов и т.п.
extern long calkulate_index_files_and_sems
  (
     T_OPENED_TRACE *opened_trace, // открытая трасса
     long file_counter             // номер файла для индексации
  );

extern long get_data
  (
     T_OPENED_TRACE *opened_trace,
     long start,
     long length
  );

#endif