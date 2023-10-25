
#ifndef _NAVIGATE_2_H_
#define _NAVIGATE_2_H_


  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)

typedef struct {   // ��������� ������������� ������ (Rec.mat2)
   long  Time;
   long  Dist; // ����������� � �� !!!

   long OdometerTime;
   long OdometerDist;

   float VogX;
   float VogY;
   float VogZ;

   float AccelX;
   float AccelY;
   float AccelZ;

} T_NAVIGATION_RECORD_2;

// ������������ � ������������ �� ���������
#pragma pack ()

typedef struct {   // ��������� ������������� ������ (Rec.mat)
   char  file_name[_MAX_FNAME];  // ��� ����� ������������� ������
   FILE *file_data;              // �������� ���� ������������� ������
   long  lengt_file_in_nav_rec;  // ���������� ������������� ������ � �����

   long  cur_pos;     // ������� ������� ������ � �����
   long  left_pos;    // ������� ����� ������� ������� ������ ������ � �����
   long  right_pos;   // ������� ������ ������� ������� ������ ������ � �����

   T_NAVIGATION_RECORD_2 cur_data;   // ������� ������
   T_NAVIGATION_RECORD_2 left_data;  // ������ ����� ������� ������� ������
   T_NAVIGATION_RECORD_2 right_data; // ������ ������ ������� ������� ������

} T_NAVIGATION_DATA_2;


extern long Init_NavData_2(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[]);
extern long Serch_navigete(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[]);
extern long GetNavData(long start, T_NAVIGATION_DATA *NavData, char drvError[]);

#endif
