// libdafil.h - ��������  ��� ������ libdafil.c.
// ���������� ���������������� ������� ������ � ������� *.da ��� �������� 
// ��������� ������ ������������ ����� "epro" ���������� KrotW32
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


// ����������������� ����� ������ ����� ���� "XXnnnnn�XX..X",
// ��� �    -����� ������;
//     nnnnn-�����, ������� ������� �����������
int inc_file_name
  (
     char *file_name // �� ������ ������ ����� ����� ���� "XXnnnnn�XX..X"
  );

// ������� ��������������� ���������� ������ � ���������� �������������
// �������� ���� "XXnnnnn�XX..X", ������� � ����� ������� �����
extern long enumerate_work_files
  (
     char *first_File,   // ��������� �� ��� ������� ����� (� ������ �����)
     long *data_path_len,// ��������� �� ������ ���� �� ������ ��� ����� �����
     long *files_num     // ���-�� ��������� ������� ������
  ); 

// ������� ��������� �������� ���� � ����� ������
// � ��������� T_INDEX_FILE ������ ���� ��� ����� (���� file_name)
extern long enumerate_seam_in_files
  ( 
     T_INDEX_FILE *index_file
  );

// �������� �������� �� ����� � �������� �������
// � ��������� ������ ������ ���� ��� ��������� ��� ����� ������ � �.�.
extern long calkulate_index_files_and_sems
  (
     T_OPENED_TRACE *opened_trace, // �������� ������
     long file_counter             // ����� ����� ��� ����������
  );

extern long get_data
  (
     T_OPENED_TRACE *opened_trace,
     long start,
     long length
  );

#endif