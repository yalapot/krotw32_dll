// ���� �������� �������� � ������� ������ � ��������. 
// ������� ������ vbapi.h, krtapi.h, windows.h


// ��������� ��� ������ ������� �� kpl �����
typedef struct {
 VB_PAL       head;             // ���������
 VB_PAL_ITEM *Item;             // ������ ���������
 long         maxItemNum;       // ������ ������ Item (���-�� ��������� VB_PAL_ITEM)
 long         changed;          // ���� ���������� ������
} T_PAL_CORE;

// ��������� �������� ���� ����������� �������
typedef struct {
 long         X;                // ������ ���� ��������� ������� � �������� �� X
 long         Y;                // ������ ���� ��������� ������� � �������� �� Y
 long         maxX;             // ������ ������ dataVect (���-�� ��������)
 void        *dataVect;         // ����� ������� ������� ��� ������� ������� ����
 HBITMAP      bmp;              // ������ �������
} T_PAL_WIN;

// ��������� �������� ��������� �������� ������ �� ���������� ������ �� �������� ���������
typedef struct {
 VB_PAL_ITEM  min;              // ����� �������
 VB_PAL_ITEM  max;              // ������ �������
} T_PAL_DIAP;

// ��������� �������� ������� �������
typedef struct {
 T_PAL_CORE   core;             // ������ �������
 T_PAL_WIN    pic;              // ���� ��������� �������
 T_PAL_DIAP   border;           // ������� � ������ ������� � ����� ������������ ��������
 T_PAL_DIAP  *color;            // ��������� �� ������ ���������� ������ � ���������� �������
 long         usrMin;           // ������ ������� �����, ������������� �������������
 long         usrMax;           // ������� ������� �����, ������������� �������������
} T_PAL;


// ���������� ���������� ������������ �������� � ��������
extern long bytesPerPixel;      // ���-�� ���� �� ������ � ����������� �� �����������
extern long bitsPerPixel;       // ���-�� ��� �� ������ � ����������� �� �����������

// ���������� ������� ������������ �������� � ��������
extern INLINE void putPixel(void *buff, long index, long val, T_PAL *pal);
extern void palClose(T_PAL *pal);
extern short palInit(T_PAL *pal);
