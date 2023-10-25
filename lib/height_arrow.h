
#ifndef _height_arrow_H_
#define _height_arrow_H_


#define arrow_hd_KEY                   "arrow_hd"

  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)

typedef struct 
{
   char ver[8];
   int ver_n;
   char h_3diam[14];
   float h_3;
   char h_5diam[14];
   float h_5;
   char h_10diam[14];
   float h_10;
   char h_100diam[14];
   float h_100;
} T_arrow_file_head;

typedef struct { 
   float height;
   long  Dist;
} T_arrow_hd;

typedef struct { 
   char  file_name[_MAX_FNAME];  // ��� ����� ������
   FILE *file_data;              // �������� ���� ������
   long  lengt_file_in_nav_rec;  // ���������� ������� ������ � �����

   long  cur_pos;     // ������� ������� ������ � �����
   long  left_pos;    // ������� ����� ������� ������� ������ ������ � �����
   long  right_pos;   // ������� ������ ������� ������� ������ ������ � �����

   T_arrow_hd cur_data;   // ������� ������
   T_arrow_hd left_data;  // ������ ����� ������� ������� ������
   T_arrow_hd right_data; // ������ ������ ������� ������� ������

} T_arrow_DATA;


// ������������ � ������������ �� ���������
#pragma pack ()


extern long Init_arrow_hd_Data(char * trc);//, char drvError[]);
extern long Get_arrow_hd_Data(long start, T_arrow_hd *arrow_hd);//, char drvError[]);
extern T_arrow_DATA * arrowData;

#endif

