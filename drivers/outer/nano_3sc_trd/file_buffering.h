// file_buffering.h
// ��������� ����������� ������ ������
//

#ifndef _FILE_BUFFERING_H_
#define _FILE_BUFFERING_H_



// ���������� � ������ ���������� �����
typedef struct 
{
    int Data_ready; // ���� ��� ���������� ����� ���������
    long file_size;
    byte * data;    // ���������� �����

} T_File_Buffer;


#define MAX_File_In_Trace 2000L     // ������������ ���������� ������ � ������

// ���������� � ������ ���������� ������ ������
// ����� �������� ����������� "�����" �  �� 
typedef struct 
{
    int First_file_loaded;   // ����� ������� ������������ �����
    int Num_file_loaded;     // ���������� ����������� ������

    T_File_Buffer file[MAX_File_In_Trace];

} T_All_FileData;


extern long load_files_data(T_All_FileData * All_FileData, int first_file, int last_file, char *Data_path);
extern void free_files_data(T_All_FileData * All_FileData);


#endif
