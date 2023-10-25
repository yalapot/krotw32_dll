#pragma inline

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <time.h>
#include <mem.h>

#include <krot128.h>
#include <num2word.h>

extern unsigned char SensArray[];
extern short getSens(void);

void CheckSequense(short mode);

short main (void) {
short mode;

	mode = InitBort();
	while (mode != M_DOS) {
		CheckSequense(mode);
		switch (mode) {
			case M_SINHRO :
				Say("синхронизация");
				Sinhronize();
				break;
			case M_REPORT :
				Say("отчёт");
				VoiceReport(RECORD_NAME);
				break;
			case M_TEST :
				Say("диагностика");
				mode = Diags();
				break;
			case M_READ :
				Say("чтение");
				ReadReady();
				break;
			case M_WORK :
				Say("работа");
				return 0;
		}
		mode = WaitModeChange(mode);
	}
	// переключатель в неопределенном положении
	Say("меня вынули из блока");
	fprintf(stdout, "Have a nice DOS");
	return 1;
}

void ReadReady(void) {
	Lamp(DIOD_OK | DIOD_READY | DIOD_READ);
	return;
}

void Say (const char *msg) {
FILE *f;

	f = fopen("_say.bat", "wt");
	fprintf(f, "@echo off\n");
	fprintf(f, "- ");
	fprintf(f, msg);
	fprintf(f, "\n");
	fclose(f);
	system("_say.bat");
	unlink("_say.bat");
	return;
}

void Lamp(unsigned char val) {

	asm {
	mov dx, DIOD_PORT
	mov al, val
	xor al, 11111111b
	out dx, al
	}

	return;
}

byte byteBCD(byte val) {
	return ((val & 0xF0) >> 4) * 10 + (val & 0xF);
}

void Sinhronize(void) {
int i = 0, period = 0, cancel = 0;
unsigned char wait=1;
T_SINHTIME sTime;
FILE *s;
unsigned char val[2] = {DIOD_OK | DIOD_READY, DIOD_OK};
int index = 0;
union REGS regs;

char *disk_error = "ошибка диска синхронизация не проведена";
char *sinh_cancel = "синхронизация не проведена";
char *sinh_ok = "блок синхронизирован";

	Lamp(val[index]);
	sound(SINHRO_TONE);
	while (wait) {
		asm {
			mov dx, STATUS_PORT
			in al, dx
			and al, SINHRO_IMPULS
		}
      	wait = _AL;

		i++;
		if (i >= SINHRO_SWITCH_PERIOD)
		{
			i = 0;
			period++;
			if (period > SINHRO_WAIT_PERIOD)
			{
				wait = 0;
				cancel = 1;
			}
			index = index ^ 1;
			Lamp(val[index]);
			if (index == 0)
				sound(SINHRO_TONE);
			else
				nosound();
		}

	}

	// время синхронизации
	regs.h.ah = 2;
   	int86(0x1a, &regs, &regs);
	sTime.hour		= byteBCD(regs.h.ch);
	sTime.minutes	= byteBCD(regs.h.cl);
	sTime.second	= byteBCD(regs.h.dh);
	sTime.hsecond	= 0;

	// дата синхронизации
	regs.h.ah = 4;
	int86(0x1a, &regs, &regs);
	sTime.year		= (short) byteBCD(regs.h.ch) * 100 + (short) byteBCD(regs.h.cl);
	sTime.month		= byteBCD(regs.h.dh);
	sTime.day		= byteBCD(regs.h.dl);

	nosound();
	Lamp(DIOD_OK);

	if (cancel)
	{
		Lamp(DIOD_OK | DIOD_CANCEL);
		Say(sinh_cancel);
		return;
	}

	s = fopen(SINHRO_FILE, "wb");
	if (s == NULL)
	{
		Lamp(DIOD_OK | DIOD_CANCEL);
		Say(disk_error);
		return;
	}

	i = fwrite(&sTime, sizeof(T_SINHTIME), 1, s);
	if (i != 1)
	{
		Lamp(DIOD_OK | DIOD_CANCEL);
		Say(disk_error);
		return;
	}

	fclose(s);
	unlink(RECORD_NAME);
	unlink("voice.bat");

	Lamp(DIOD_OK | DIOD_READY);
	Say(sinh_ok);
	return;
}

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
	Say("реальная");
	return M_WORK;
}

short IsModeChanged (short oldmode) {
short mode;

	asm {
		// сначала проверяем отключение имитатора давления
		mov dx, CONTROL_PORT
		mov al, ODOMETR_1CM	// этим запросом не надо переключать одометр
		or al, BAR_REQUEST_ON
		out dx, al
		nop ;	nop ;	nop

		mov al, ODOMETR_1CM
		or al, BAR_REQUEST_OFF
		out dx, al
		nop ;	nop ;	nop

		mov dx, STATUS_PORT
		in al, dx
		nop ;	nop ;	nop
		and al, BAR_PRESENT
		jz CheckSwitch
	}
	delay(1000); // задержка 1 сек
	asm {
		mov dx, DIOD_PORT
		mov al, 0xFF //DIOD_ALLDARK
		out dx, al
		jmp short $+2
	}

OFF_LOOP:
	asm {
		// еще раз проверяем есть ли давление в трубе
		mov dx, CONTROL_PORT
		mov al, ODOMETR_1CM	// этим запросом не надо переключать одометр
		or al, BAR_REQUEST_ON
		out dx, al
		nop ;	nop ;	nop

		mov al, ODOMETR_1CM
		or al, BAR_REQUEST_OFF
		out dx, al
		nop ;	nop ;	nop

		mov dx, STATUS_PORT
		in al, dx
		nop ;	nop ;	nop
		and al, BAR_PRESENT
		jz CheckSwitch

		// выключаем бортовую аппаратуру
		mov al, 1
		mov dx, CONTROL_PORT
		out dx, al
		nop ;	nop ;	nop
		jmp OFF_LOOP
	}

CheckSwitch:
	;

	asm {
		mov dx, STATUS_PORT
		in al, dx
		nop ;	nop ;	nop
		and al, MODE_MASK
		xor al, MODE_MASK

		test al, MODE_SINHRO
		jnz SinhroRun

		test al, MODE_WORK
		jnz WorkRun

		test al, MODE_READ
		jnz ReadRun

		test al, MODE_REPORT
		jnz ReportRun
	}

	TestRun:
		;
		mode = M_TEST;
		goto EndSel;

	SinhroRun:
		;
		mode = M_SINHRO;
		goto EndSel;

	WorkRun:
		;
		Lamp(DIOD_OK | DIOD_WORK);
		mode = M_WORK;
		goto EndSel;

	ReadRun:
		;
		Lamp(DIOD_OK | DIOD_READY | DIOD_READ);
		mode = M_READ;
		goto EndSel;

	ReportRun:
		;
		mode = M_REPORT;
		goto EndSel;

	EndSel:
		;
	return (mode == oldmode) ? 0 : 1;
}

short WaitModeChange(short oldmode) {

	while (!IsModeChanged(oldmode)) ;

	Lamp(DIOD_OK);
	delay(1000); // задержка 1 секунда
	Say("режим");
	return InitBort();
}

volatile long oCount;

void interrupt IntrOdometr(void) {

	asm {
	// здесь сброс аппаратного прерывания
	mov al, 0x20 	// non-specific eoi в ведущий контроллер
	out 0x20, al
	nop ;	nop ;	nop
	mov al, 0x20 // non-specific eoi в ведомый контроллер
	out 0xA0, al
	nop ;	nop ;	nop
	}
	oCount++;
}

short getOrient (void) {
	asm {
	mov dx, ORIENTATION_PORT
	in al, dx // читаем ориентацию снаряда
	shr al, 1 // преобразуем в номер верхнего датчика

	add al, 0x40 // перевернутый датчик ориентации
	and al, 0x7F

	}
	return _AL;
}

void CheckSensors(void) {
short orient;
char str[256];
char buf1[256];
char buf2[256];
short i, j, lasta, h;

	setmem(SensArray, KROT128_SENSNUM, 0);
	if (getSens() == 0)
		return;

	Lamp(DIOD_OK);
	orient = getOrient();

	j = 1;
	while (j > 0) {
		j = 0;
		for (i = 0; i<5000; i++)
			j += getSens();
	}

	for (i=0; i < (KROT128_SENSNUM / 4); i++) { // цикл по ластам
		lasta = 0;
		for (j=0; j<4; j++)  // цикл по датчикам ласты
			if (SensArray[i*4+j] > 0) lasta++;

		switch (lasta) {
			case 4: // все датчики ласты сработали
				transns(i+1, buf1, MALE, IMENIT, SUSCH);
				sprintf(str, "ласта %s", buf1);

				/////////////
				printf (str); printf ("\n");
				/////////////

				Say(str);

				h = ((i*4+2) - orient) / 10;
				h = (h < 0) ? (12 + h) : h;
				transns(h, buf1, MALE, IMENIT, SUSCH);
  				buildnn(h, "час", "", "а", "ов", buf2);
				sprintf(str, "%s %s", buf1, buf2);

				/////////////
				printf (str); printf ("\n");
				/////////////

				Say(str);
				printf("верхний датчик %d\n", orient);
				//delay(2000);

				break;

			case 0: // ни один датчик ласты не сработал (ее не трогали)
				break;

			default: // не все датчики ласты сработали
				transns(i+1, buf1, MALE, IMENIT, SUSCH);
				sprintf(str, "ласта %s", buf1);

				/////////////
				printf (str); printf ("\n");
				/////////////

				Say(str);

				h = ((i*4+2) - orient) / 10;
				h = (h < 0) ? (12 + h) : h;
				transns(h, buf1, MALE, IMENIT, SUSCH);
  				buildnn(h, "час", "", "а", "ов", buf2);
				sprintf(str, "%s %s", buf1, buf2);

				/////////////
				printf (str); printf ("\n");
				/////////////

				Say(str);

				transns(4 - lasta, buf1, MALE, IMENIT, SUSCH);
  				buildnn(4 - lasta, "датчик", "", "а", "ов", buf2);
				sprintf(str, "не работает %s %s", buf1, buf2);

				/////////////
				printf (str); printf ("\n");
				/////////////

				Say(str);

				/////////////
				printf("верхний датчик %d\n", orient);
				/////////////
				//delay(2000);

				break;

		}
	}

	Lamp(DIOD_OK | DIOD_READY);
	return;
}

void CheckOdometr(void) {
long count = 0L, CPoCount;
char str[256];
char buf1[256];
char buf2[256];

	disable();
	CPoCount = oCount;
	enable();

	if (CPoCount == 0L)
		return;

	Lamp(DIOD_OK);

	while (1) {
		delay(1000);
		disable();
		CPoCount = oCount;
		enable();
		if (count == CPoCount)
			break;
		else
			count = CPoCount;
	}

	transns(count, buf1, MALE, IMENIT, SUSCH);
	buildnn((int) count, "сантиметр", "", "а", "ов", buf2);
	sprintf(str, "путь %s %s", buf1, buf2);
	Say(str);

	disable();
	oCount = 0L;
	enable();

	Lamp(DIOD_OK | DIOD_READY);
	return;
}

short Diags(void) {
void interrupt (*oldfunc)(void);
unsigned char oldmask;

	oCount = 0L;

	disable();
	oldfunc  = _dos_getvect(ODOMETR_INTERRUPT);
	_dos_setvect(ODOMETR_INTERRUPT,IntrOdometr);
	enable();

	asm {
	cli
	// сохраняем старые маски прерываний
	in al, 0xA1 // для 2 контроллера
	nop ; nop ; nop ; nop
	}
	oldmask = _AL;
	_AL = oldmask;
	asm {
	// разрешаем int73h
	and al, IRQ_MASK
	out 0xA1, al
	nop ; nop ; nop ; nop
	sti
	}

	Lamp(DIOD_OK | DIOD_READY);

	while (!IsModeChanged(M_TEST)) {
		CheckOdometr();
		CheckSensors();
	}

	Lamp(DIOD_OK);
	// восстанавливаем старые маски прерываний
	_AL = oldmask;
	asm {
	cli
	out 0xA1, al
	nop ; nop ; nop ; nop
	sti
	}

	disable();
	_dos_setvect(ODOMETR_INTERRUPT,oldfunc);
	enable();

	return M_DOS;
}

char *cpr_word[] =
{
"\22\124\132\125\35\37\121\122\24\126\337\136\124\121\125\337\36\122\137\37\20\133\137\337\36\133\132\124\137\124\127",
"\134\132\37\137\36\127\122\337\120\137\135\132\124\337\135\137\124\132\122\35\127\122\121\135\127\30",
"\136\121\134\121\123\121\124\121\135\337\135\127\35\137\124\127\126\337\135\124\137\133\127\123\127\37\121\135\127\30",
NULL
};

void SayCopyright(void) {
short i, j;
char *item;

	for (i=0; cpr_word[i]; i++) {
		item = cpr_word[i];
		for (j=0; item[j]; j++) {
			item[j] = item[j] ^ 0xFF;
		}
		Say(cpr_word[i]);
		for (j=0; item[j]; j++) {
			item[j] = item[j] ^ 0xFF;
		}
	}
	return;
}

#define  SEQ_LEN	6

void CheckSequense(short mode) {
static short step=0;
static short secMode[SEQ_LEN] = {M_TEST, M_TEST, M_SINHRO, M_READ, M_READ, M_TEST};

	if (mode == secMode[step])
		step++;
	else
		step = 0;

	if (step == SEQ_LEN)
		SayCopyright();

	return;
}