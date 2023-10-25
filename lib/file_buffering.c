// file_buffering.c 
// Инструментарий буферизации файлов данных
//

#include "file_buffering.h"

// Metods for T_File_Buffer --------------------------------------------------

void Init_File_Buffer( T_File_Buffer *File_Buffer)
{
       File_Buffer->Data_ready = 0;
       File_Buffer->file_size = 0;
       File_Buffer->data = NULL;

}

long Read_full_file(char * File_name, T_File_Buffer *File_Buffer)
{
    long file_length;
    FILE * data_file = NULL;

    // Вычитаем весь файл в память
    data_file = fopen(File_name, "rb");
    if (data_file == NULL) {
        sprintf(drvError, "Ошибка открытия файла %s.", File_name);
        return KRT_ERR;
    };

    fseek(data_file, 0, SEEK_END);
    file_length = ftell(data_file);

    File_Buffer->data = malloc(file_length);
    if (File_Buffer->data == NULL) {
        sprintf(drvError, "Ошибка выделения памяти %s.", File_name);
        return KRT_ERR;
    };

    fseek(data_file, 0, SEEK_SET);
    fread(File_Buffer->data, 1, file_length, data_file);
    fclose(data_file);

    File_Buffer->file_size = file_length;
    File_Buffer->Data_ready = 1;

    return KRT_OK;
};

void Free_File_Buffer( T_File_Buffer *File_Buffer)
{
   File_Buffer->Data_ready = 0;
   if (File_Buffer->data!=NULL) free(File_Buffer->data);
   File_Buffer->data = NULL;
}




// Metods for T_All_FileData --------------------------------------------------

void Init_All_FileData(T_All_FileData * All_FileData)
{
    int i;

    All_FileData->First_file_loaded = 0;
    All_FileData->Num_file_loaded = 0;

    for (i=0; i < MAX_File_In_Trace; i++)
    {
       Init_File_Buffer( &(All_FileData->file[i]) );
    }
}

// Метод вычитывает заданные файлы в трассу
long load_files_data( T_All_FileData * All_FileData,
                      int first_file,
                      int last_file,
                      char *Data_path,
                      char *file_name_template)
{
    int f_count;
    char file_name[1024];


    if (last_file >= MAX_File_In_Trace)
    {
        sprintf(drvError, "Слишком много файлов в трассе");
        return KRT_ERR;
    };

    // Освобождаем данные файлов от 0 до первого запрошенного файла
    for (f_count = 0; f_count < first_file; f_count++)
    {
        if (All_FileData->file[f_count].Data_ready == 1)
        {
            Free_File_Buffer( &(All_FileData->file[f_count]) );
            All_FileData->Num_file_loaded--;
        } // if (file[f_count].Data_ready != true)
    } // for (f_count = first_file; f_count < First_file_loaded; f_count++)
    All_FileData->First_file_loaded = first_file;

    // Освобождаем данные файлов за последним запрошенным до конца
    for (f_count = last_file+1; f_count < MAX_File_In_Trace; f_count++)
    {
        if (All_FileData->file[f_count].Data_ready == 1)
        {
            Free_File_Buffer( &(All_FileData->file[f_count]) );
            All_FileData->Num_file_loaded--;
        } // if (file[f_count].Data_ready != true)
    } // for (f_count = )

    // Загружаем данные запрошенных файлов
    for (f_count = first_file; f_count <= last_file; f_count++)
    {
        if (All_FileData->file[f_count].Data_ready != 1)
        {
            sprintf(file_name, file_name_template, Data_path, f_count);

            Read_full_file( file_name, &(All_FileData->file[f_count]));

            All_FileData->file[f_count].Data_ready = 1;
        } // if (file[f_count].Data_ready != true)
    } // for (f_count = first_file; f_count <= last_file; f_count++)
    All_FileData->Num_file_loaded = last_file - first_file;

    return KRT_OK;

} // public void load_files_data(C_Trace trace, int first_file, int last_file) 

// Метод освобождает все файлы
void free_files_data(T_All_FileData * All_FileData)
{
    int f_count;

    f_count = All_FileData->First_file_loaded;

    while(All_FileData->Num_file_loaded > 0)
    {
        if (All_FileData->file[f_count].Data_ready == 1)
        {
            Free_File_Buffer( &(All_FileData->file[f_count]) );
            All_FileData->Num_file_loaded--;
        } // if (file[f_count].Data_ready != true)

        f_count++;

    } // for (f_count = first_file; f_count < First_file_loaded; f_count++)

    All_FileData->First_file_loaded = 0;

} // void free_files_data() 

