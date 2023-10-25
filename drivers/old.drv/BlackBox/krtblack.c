// Krot384e.c - �������� �������� 384e_drv (� 384e_reg).
// ���������� ���������� ������ � ���� ���������������� ������� ��������
// ��������� ������ ������������ ����� "384 epro" ���������� KrotW32
//

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <KrtAPI.h>
#include "krtblack.h"

//////////////////////////////////////////////////////////////////////////
// ���������� ������ ��������
//////////////////////////////////////////////////////////////////////////

char drvError[256];

T_TRACE_LIST trace_list[MAX_TRACE];
char *traceFile;

int open_trace_counter;

//////////////////////////////////////////////////////////////////////////
// ����������� ���������� ������ ��������
//////////////////////////////////////////////////////////////////////////

/* ������� ������������� �������� ������ �������� */
void WINAPI initTraces(void) {
  open_trace_counter=0;
  strcpy(drvError, "");
 };

/* ������� ��� ������ ���������� ��������� */
void debugPoint(char *msg) {
 MessageBox (
  NULL,
  msg,
  "krotDebug",
  (MB_APPLMODAL|MB_ICONINFORMATION|MB_OK)
 );
}



