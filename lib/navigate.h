
#ifndef _NAVIGATE_H_
#define _NAVIGATE_H_


#define RecVog_KEY                   "RecVog"
#define RecMat_KEY                   "RecMat"

#define PI  3.14159265359

  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)

typedef struct {   // ��������� ������������� ������ (Rec.mat2)
   long  Time;
   long  Dist; // � Rec.mat2 ����������� � �� !!!
               // � Rec.mat ����������� � �� !!!

   long OdometerTime; // ����������� � Rec.mat
   long OdometerDist; // ����������� � Rec.mat


   float VogX;
   float VogY;
   float VogZ;

   float AccelX;
   float AccelY;
   float AccelZ;
} T_NAVIGATION_RECORD;

typedef struct {   // ��������� ��������� ������ (Rec.vog)
   long  Time; // ������������
   long  Dist;

   long VogX;  // ��������, ��
   long VogY;  // ���������, ��
   long VogZ;  // ��������, ��

   float Psi;   // ������, ���
   float Teta;  // ������, ���
   float Gamma; // ����, ���
} T_VOG_RECORD;

// ������������ � ������������ �� ���������
#pragma pack ()

#define REC_NAV   1
#define REC_NAV2  2

typedef struct {   // ��������� ������������� ������ (Rec.mat)
   char  file_name[_MAX_FNAME];  // ��� ����� ������������� ������
   FILE *file_data;              // �������� ���� ������������� ������
   long  lengt_file_in_nav_rec;  // ���������� ������������� ������ � �����

   long nav_file_version;
   unsigned long  nav_rec_len;

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

extern long Init_VogData(T_VOG_DATA *VogData, char * work_path, char * trc, char drvError[]);
extern long Init_navigete(T_VOG_DATA *VogData, char * work_path, char * trc, T_TRACEINFO *inf, char drvError[]);
extern long GetVogData(long start, T_VOG_DATA *VogData, char drvError[]);
extern long Init_NavData(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[]);
extern long Serch_navigete(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[]);
extern long GetNavData(long start, T_NAVIGATION_DATA *NavData, char drvError[]);
extern long get_orient_from_VOG(long start, T_VOG_DATA *VogData, long num_sens);

#endif

