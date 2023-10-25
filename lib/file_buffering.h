// file_buffering.h
// Структуры буферизации файлов данных
//

#ifndef _FILE_BUFFERING_H_
#define _FILE_BUFFERING_H_

#pragma warning(disable : 4996) // for VC 8.00

#include <krtapi.h>
#include <stdio.h>
#include <stdlib.h>

extern char drvError[1024];

// Информация с полным содержимым файла
typedef struct 
{
    int Data_ready; // Флаг что информация файла загружена
    long file_size;
    unsigned char * data;    // информация файла

} T_File_Buffer;


#define MAX_File_In_Trace 2000L     // Максимальное количество файлов в трассе

// Информация с полным содержимым файлов трассы
// файлы грузятся непрерывным "окном" с  по 
typedef struct 
{
    int First_file_loaded;   // номер первого загруженного фыйла
    int Num_file_loaded;     // Количество загруженных файлов

    T_File_Buffer file[MAX_File_In_Trace];

} T_All_FileData;

extern void Init_All_FileData(T_All_FileData * All_FileData);
extern long load_files_data(T_All_FileData * All_FileData, int first_file, int last_file, char *Data_path, char *file_name_template);
extern void free_files_data(T_All_FileData * All_FileData);


#endif
