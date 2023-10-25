
#ifndef _BAYPASS_H_
#define _BAYPASS_H_


#define PI  3.14159265359

  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)

typedef struct {
   short abs_pressure;
   short diff_pressure;
   short speed;                            
   signed char motor_state;                      
   byte board_state;                      
   byte choke_curr_position_ticks;        
   byte choke_curr_position_angle;        
   signed char choke_position;                   
   short motor_battary_current;            
   byte motor_battary_voltage;            
   byte chek_sum;                            

   long Odometr;

} T_BYPASS_IDX;

// ������������ � ������������ �� ���������
#pragma pack ()

typedef struct {
   char  file_name[_MAX_FNAME];  // ��� ����� BP ������
   FILE *file_data;              // �������� ���� BP ������
   long  lengt_file_in_BP_rec;  // ���������� BP ������ � �����

   long  cur_pos;     // ������� ������� ������ � �����
   long  left_pos;    // ������� ����� ������� ������� ������ ������ � �����
   long  right_pos;   // ������� ������ ������� ������� ������ ������ � �����

   T_BYPASS_IDX cur_data;   // ������� ������
   T_BYPASS_IDX left_data;  // ������ ����� ������� ������� ������
   T_BYPASS_IDX right_data; // ������ ������ ������� ������� ������

} T_BP_DATA;

extern long Init_BPdata(T_BP_DATA *BPdata, char * work_path, char * trc, char drvError[]);
extern long Get_BPdata(long start, T_BP_DATA *BPdata, char drvError[]);

#endif

