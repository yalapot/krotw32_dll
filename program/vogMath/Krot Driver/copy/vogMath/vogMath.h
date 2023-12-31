#include "krtBase.h"

#define TURN_GOR   0          // ������� � ������������ ��������
#define TURN_VER   1          // ������� � ���������� (������������) ��������
#define TURN_3D    8          // ����������� 3D �������
#define TURN_START 2          // �������� �� ����� ������� � ������ ��������
#define TURN_END   4          // �������� �� ����� ������� � ����� ��������

#define MATCH_MODE_SHIFT 1    // �������������� ������
#define MATCH_MODE_SCALE 2    // �������������� ����������/������
#define MATCH_MODE_ROTATE 4   // �������������� ��������

typedef struct {

 long  radius;                // ������ �������� � ��.
 float angle;                 // ���� �������� � ��������

} T_TURNDATA;

//////////////////////////////////////////////////////////////////////////
// �������������� �������
//////////////////////////////////////////////////////////////////////////

// ������� ��������� ��������� T_CURVEDATA
// ������� � ���������� ��������,
// ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
long EXPORT KRTAPI GetCurveData (

   KRTHANDLE    handle,     // ����� ��������� �������

   long         turnkind,   // ������� �����
                            // ��� 0
                            // ������ - ������� � ��������� ���������
                            // ���������� - ������� � ������������ ���������
                            // ��� 1
                            // ���������� - ���������� �������� �� ����� ������� � ������ ��������
                            // ��� 2
                            // ���������� - ���������� �������� �� ����� ������� � ����� ��������
                            // ��� 3
                            // ���������� - ������� 3D ������� �� ������� �������� �� ��� 0

   long      start,         // ������ ��������

   long      length,        // ����� ��������

   T_TURNDATA  *turninf    // ��������� �� ��������� T_TURNDATA, �������
                           // ���������� ��������� ������� � ���������� ��������
);

// ������� �������������� ��������� ���������� �������� ���� ��������,
// ���������� ������������� ��������, ������� � ������ ��������.
// � ������������� �� ����� matchMode, ��������� �� ��� ���� ���������
// ������������ �������������� ��������� ��� ���������� ��������.
// � ���������� � ������� ������ ������� GetNextMatching �������� ���������
// �������� ������� ���������� �������� ������� � ������ ����������� ��������������
long EXPORT KRTAPI InitMatching (

   KRTHANDLE handleMaster, // ����� �������� �������
   long startMaster,       // ������ ������� ���������� �� ������� ������
   long lengthMaster,      // ����� ������� ���������� �� ������� ������
   KRTHANDLE handleSlave,  // ����� �������� �������
   long startSlave,        // ������ ������� ���������� �� ������� ������
   long lengthSlave,       // ����� ������� ���������� �� ������� ������
   long controlSize,       // ������ �������� ��� ����������� �����������
                           // ���������� � �������� ��������
   long matchMode          // ������� �����, �������� ����� ���������� �������
                           // ����� �� �������� MATCH_MODE_*
);

// ������� �������� ���� vogx, vogy, vogz ��������� T_NODEGROUP
// ������������ ������� ����� ���� �������� ������� � ������ ����������� �������
// ��������������.
// ���� vogext1, vogext2, vogext3 ��������������� ���������
// ����������� ������ (�� ����� � ������ ���������)
long EXPORT KRTAPI GetNextMatching (

   T_NODEGROUP *node       // ��������� �� ��������� ������� ����� ���������
                           // ���������������� ������������ ������� ���������
                           // ������������ handleSlave ��� ������ InitMatching
);

// ������� ��������� ������ outString ��������� ��������� ������ ������������
// ��� ������ � �������� ��������. ���������� ����� ������ ��������� �� ������.
long EXPORT KRTAPI krotError (char * outString);

// ������� ���� � ��������, ��� ���������� primFile ����� ��������� ������������� ������.
// ���� �������, �� ������� ��������� ����� ������������� ������ � �������� indxFolder.
// ����� ����� ���������� ���� �� ��������� ����� � trc-���� trcFile,
// � �����, ������������ � ����� vogTrc.h
// � �������� ������ �������� ������� informUser, �������� ������������ � ���� ������.
long EXPORT KRTAPI krotCreateVogIndex (
 const char * primFile, 
 const char * indxFolder,           
 const char * trcFile, 
 long (KRTAPI *informUser) (short percentDone, const char *msg)
);

// ������� ��������� ������ outString ��������� ��������� ������ ������������
// ��� ������ � �������� ��������. ���������� ����� ������ ��������� �� ������.
long EXPORT KRTAPI vogError (char * outString);
