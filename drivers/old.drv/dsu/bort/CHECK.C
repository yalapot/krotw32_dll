#pragma inline
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>

#include <krot128.h>

short InitBort(void) {
short mode;

	asm {
	// ���樠�����㥬 �⥭�� ॣ���஢ ���������
	mov dx, INIT1_PORT
	mov al, INIT1_VALUE
	out dx, al
	nop ;	nop ;	nop

	mov dx, INIT2_PORT
	mov al, INIT2_VALUE
	out dx, al
	nop ;	nop ;	nop

	mov dx, INIT4_PORT
	mov al, INIT4_VALUE
	out dx, al
	nop ;	nop ;	nop

	// ������ �ᥬ� �����窠�� ᢥ⮤�����
	mov dx, DIOD_PORT
	mov al, 0x0 // �������� �� �����窨
	out dx, al
	nop ;	nop ;	nop
	mov al, 0xFF // ��ᨬ �� �����窨
	out dx, al
	nop ;	nop ;	nop

	// �������� ������� ��ࠢ����
	mov dx, DIOD_PORT
	mov al, DIOD_OK
	xor al, 0xFF // ������ �����窠 - 0
	out dx, al
	nop ;	nop ;	nop

	// �஢��塞 ��������� ��४���⥫��
	mov dx, STATUS_PORT
	in al, dx
	nop ;	nop ;	nop
	and al, MODE_MASK // �뤥�塞 ���� ��४���⥫�
	xor al, MODE_MASK // ����砥� ����騩 ���

	test al, MODE_SINHRO
	jnz SinhroRun

	test al, MODE_WORK
	jnz WorkRun

	test al, MODE_READ
	jnz ReadRun

	test al, MODE_REPORT
	jnz ReportRun

	test al, MODE_TEST
	jnz TestRun

	}
	return M_DOS;

TestRun:
	;
	mode = M_TEST;
	goto End;
SinhroRun:
	;
	mode = M_SINHRO;
	goto End;
ReadRun:
	;
	asm {
	// �������� ������� �⥭��
	mov dx, DIOD_PORT
	mov al, DIOD_READ
	or al, DIOD_OK // ��࠭塞 ����饩 ������� ��ࠢ����
	xor al, 0xFF // ������ �����窠 - 0
	out dx, al
	}
	mode = M_READ;
	goto End;
ReportRun:
	;
	mode = M_REPORT;
	goto End;
WorkRun:
	;
	asm {
	// �������� ������� ࠡ���
	mov dx, DIOD_PORT
	mov al, DIOD_WORK
	or al, DIOD_OK // ��࠭塞 ����饩 ������� ��ࠢ����
	xor al, 0xFF // ������ �����窠 - 0
	out dx, al
	}
	mode = M_WORK;

End:
	;
	asm {
	// �஢��塞 ����稥 ��������
	mov dx, STATUS_PORT
	in al, dx
	nop ;	nop ;	nop
	and al, REAL_BAR
	// �᫨ ���� �������� � ������㥬 ��������� ��४���⥫��
	// � �室�� �� ������ �����
	jnz RealWorkRun
	}

	return mode;

RealWorkRun:
	;
	return M_WORK;
}

short main (void) {

	switch (InitBort()) {

	case M_READ:
	case M_DOS:
		sound(300);
		delay(1000);
		nosound();
		return 1;

	default:
		return 0;
	}
}