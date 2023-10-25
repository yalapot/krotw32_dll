#pragma inline
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>

#include <krot128.h>

short InitBort(void) {
short mode;

	asm {
	// инициализируем чтение регистров аппаратуры
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

	// мигнем всеми лампочками светодиодов
	mov dx, DIOD_PORT
	mov al, 0x0 // зажигаем все лампочки
	out dx, al
	nop ;	nop ;	nop
	mov al, 0xFF // гасим все лампочки
	out dx, al
	nop ;	nop ;	nop

	// зажигаем лампочку исправности
	mov dx, DIOD_PORT
	mov al, DIOD_OK
	xor al, 0xFF // горящая лампочка - 0
	out dx, al
	nop ;	nop ;	nop

	// проверяем положение переключателей
	mov dx, STATUS_PORT
	in al, dx
	nop ;	nop ;	nop
	and al, MODE_MASK // выделяем биты переключателя
	xor al, MODE_MASK // включаем значащий бит

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
	// зажигаем лампочку чтения
	mov dx, DIOD_PORT
	mov al, DIOD_READ
	or al, DIOD_OK // сохраняем горящей лампочку исправности
	xor al, 0xFF // горящая лампочка - 0
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
	// зажигаем лампочку работы
	mov dx, DIOD_PORT
	mov al, DIOD_WORK
	or al, DIOD_OK // сохраняем горящей лампочку исправности
	xor al, 0xFF // горящая лампочка - 0
	out dx, al
	}
	mode = M_WORK;

End:
	;
	asm {
	// проверяем наличие давления
	mov dx, STATUS_PORT
	in al, dx
	nop ;	nop ;	nop
	and al, REAL_BAR
	// если есть давление то игнорируем положение переключателей
	// и уходим на запись трассы
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