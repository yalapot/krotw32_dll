// navigat.h - ���������  ��� ������ navigate.c.
// ���������� ��������, ������ � ���������������� ������� ������ � ����������
// ��� ��������� ������ ������������ ����� "epro" ���������� KrotW32
//

#ifndef _NAVIGATE_H_
#define _NAVIGATE_H_

#define VOG_FILE_KEY          "VogNav"
#define NAVIGATION_FILE_KEY   "VogMat"
#define VOG_KOEFF_UMN         100
#define ACCEL_KOEFF_UMN       1000

#define PI  3.14159265359

#pragma warning(disable : 4996) // for VC 8.00

  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)  

typedef struct {   // ��������� ������������� ������ (Rec.mat)
   long  Time;
   long  Dist;

   float VogX;
   float VogY;
   float VogZ;

   float AccelX;
   float AccelY;
   float AccelZ;
} T_NAVIGATION_RECORD;

typedef struct {   // ��������� ��������� ������ (Rec.vog)
   long  Time;
   long  Dist;

   long VogX;  // ��������, ��
   long VogY;  // ���������, ��
   long VogZ;  // ��������, ��

   float Psi;   // ������, ���
   float Teta;  // ������, ���
   float Gamma; // ����, ���
} T_VOG_RECORD;

#pragma pack ()
  // ������������ � ������������ �� ���������


typedef struct {   // ��������� ������������� ������ (Rec.mat)
   char  file_name[_MAX_FNAME];  // ��� ����� ������������� ������
   FILE *file_data;              // �������� ���� ������������� ������
   long  lengt_file_in_nav_rec;  // ���������� ������������� ������ � �����

   long  cur_pos;     // ������� ������� ������ � �����
   long  left_pos;    // ������� ����� ������� ������� ������ ������ � �����
   long  right_pos;   // ������� ������ ������� ������� ������ ������ � �����

   T_NAVIGATION_RECORD cur_data;   // ������� ������
   T_NAVIGATION_RECORD left_data;  // ������ ����� ������� ������� ������
   T_NAVIGATION_RECORD right_data; // ������ ������ ������� ������� ������

} T_NAVIGATION_DATA;

typedef struct {   // ��������� ������������� ������ (Rec.mat)
   char  file_name[_MAX_FNAME];  // ��� ����� ������������� ������
   FILE *file_data;              // �������� ���� ������������� ������
   long  lengt_file_in_nav_rec;  // ���������� ������������� ������ � �����

   long  cur_pos;     // ������� ������� ������ � �����
   long  left_pos;    // ������� ����� ������� ������� ������ ������ � �����
   long  right_pos;   // ������� ������ ������� ������� ������ ������ � �����

   T_VOG_RECORD cur_data;   // ������� ������
   T_VOG_RECORD left_data;  // ������ ����� ������� ������� ������
   T_VOG_RECORD right_data; // ������ ������ ������� ������� ������

} T_VOG_DATA;

extern char drvError[];

 // ��������� � ������ ������ ������ �� rec.mat
extern long WINAPI GetNavData(long start, T_NAVIGATION_DATA *NavData);

 // ��������� � ������ ������ ������ �� rec.vog
extern long WINAPI GetVogData(long start, T_VOG_DATA *VogData);


extern long get_orient_from_VOG(long start,
                                T_VOG_DATA *VogData,
                                long num_sens);

extern long get_orient_from_NAV(long start,
                                T_NAVIGATION_DATA *NavData,
                                long num_sens);
#endif