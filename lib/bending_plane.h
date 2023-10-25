
#ifndef _bending_plane_H_
#define _bending_plane_H_


#define bending_plane_KEY                   "bending_plane"

  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)

typedef struct 
{
    // ���������� �� �������� ������� �� ��������, ��
    long L0;
    // ���������� �� ������ ������� �� ��������, ��
    long L1;
    // ������� ������������, ��
    long D;
    // ���������� ��������, ���������� �������� �� �������� �������
    float LimR;
    // �������� � ����������� ��������, ���������� ������� �������������� � ��������
    float dLimR;
} T_bending_plane_file_head;

typedef struct { 
    // ���������, �
    float Dist;
    // ������, D
    float Radius;
    // ���� ��������� ������, �
    float Angle;
} T_bending_plane;

typedef struct {
   char  file_name[_MAX_FNAME];  // ��� ����� ������
   FILE *file_data;              // �������� ���� ������
   long  lengt_file_in_nav_rec;  // ���������� ������� � �����

   long  cur_pos;     // ������� ������� ������ � �����
   long  left_pos;    // ������� ����� ������� ������� ������ ������ � �����
   long  right_pos;   // ������� ������ ������� ������� ������ ������ � �����

   T_bending_plane cur_data;   // ������� ������
   T_bending_plane left_data;  // ������ ����� ������� ������� ������
   T_bending_plane right_data; // ������ ������ ������� ������� ������

} T_bending_plane_DATA;


// ������������ � ������������ �� ���������
#pragma pack ()


extern long Init_bending_plane_Data(char * trc);//, char drvError[]);
extern long Get_bending_plane_Data(long start, T_bending_plane *bending_plane);//, char drvError[]);
extern T_bending_plane_DATA * bending_plane_data;

#endif

