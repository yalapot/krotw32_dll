#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <krot128.h>

short main (int argc, char *argv[]) {
FILE *in;
T_KROT_HEAD head;
T_ITEM item;
T_WELD weld, insWeld;
T_STOP stop;
T_ITEMSTOP *st;
short flag, offs, first_weld, nostop, endReason, odoNum;
long part = 0L, lcount = 0L, pdist = 0L, ptime = 0L, dd = 0L, dt = 0L;
long alltime = 0L, alldist = 0L;
long km, metr, hour, min;
char *label;
int stopCount = 0;
unsigned long sec;
unsigned char *bstr;

printf("Krot record scanner. (C) Vitaly Bogomolov 1996,1997\n");
printf("Release %s %s\n", __TIME__, __DATE__);

if (argc < 2)
{
	printf("Использование : scan128 file.krt [-s]\n");
	printf("-s отключает выдачу информации об остановках");
	return 1;
}
in = fopen(argv[1], "rb");
if (in == NULL)
{
	printf ("Файл не найден: %s", argv[1]);
	return 1;
}

nostop = ((argc == 3) && (!strcmpi("-S", argv[2]))) ? 1 : 0;

fread(&head, sizeof(T_KROT_HEAD), 1, in);
if (head.sign != KROT_SIGN)
{
	printf ("Неверный заголовок файла: %s", argv[1]);
	return 1;
}

endReason = R_UNKNOWN;
printf("\n");

printf ("Дата синхронизации:    \t%d.%02d.%d\t%d:%02d:%02d\n",
	head.sinh_day,
	head.sinh_month,
	head.sinh_year,
	head.sinh_hour,
	head.sinh_minutes,
	head.sinh_second
);
printf ("Дата первого включения:\t%d.%02d.%d\t%d:%02d:%02d\n",
	head.day,
	head.month,
	head.year,
	head.hour,
	head.minutes,
	head.second
);

printf("\n");

flag = 0;
offs = 0;
alltime = 0L;
first_weld = 1;
odoNum = -1;

fread(&item, sizeof(T_ITEM), 1, in);
while (!feof(in)) {
	switch (item.sign) {

	case D_WELD :
		endReason = R_UNKNOWN;
		fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
		fread(&weld, sizeof(T_WELD), 1, in);

		if (weld.odonum != odoNum)
		{
			odoNum = weld.odonum;
			printf("Одометр: %d дистанция %ld\n", odoNum, weld.dist);
		}

		if (flag == 1)
		{
			flag = 0;
			printf(" кол-во: %ld\n", lcount);
		}
		dd = weld.dist - pdist;
		dt = weld.time - ptime;
		offs = 0;

		if ((dd != 256) && (first_weld == 0))
		{
			hour = weld.time / (100L * 60L * 60L);
			min = (weld.time - hour * (100L * 60L * 60L)) / (100L * 60L);
			printf(
				"\nПлохой шов\tтаймер %ld:%02ld мин (%ld тиков)\tдистанция %ld см\n\tдлина сегмента %ld см\tвремя прохождения сегмента %ld тиков\n\tсмещение в файле: %lX\n",
				hour,
				min,
				weld.time,
				weld.dist,
				dd,
				dt,
				ftell(in) - sizeof(T_WELD)
				);
			if (dd == 512) /* простая потеря шва */
			{
				insWeld.sign = 0x50;
				insWeld.orient = weld.orient;
				insWeld.wdist = 0;
				insWeld.odonum = weld.odonum;
				insWeld.dist = weld.dist - 256;
				insWeld.time = weld.time - dt / 2;
				bstr = (unsigned char *) &insWeld;
				/* дать рекомендации */
				printf(
	"\t%02X %02X %02X %02X - %02X %02X %02X %02X - %02X %02X %02X %02X\n",

					bstr[0],
					bstr[1],
					bstr[2],
					bstr[3],

					bstr[4],
					bstr[5],
					bstr[6],
					bstr[7],

					bstr[8],
					bstr[9],
					bstr[10],
					bstr[11]
				);
			}
			printf ("\n");
		}
		pdist = weld.dist;
		ptime = weld.time;
		alltime = weld.time;
		first_weld = 0;
		break;

	case D_POWERFAIL :
	case D_DISKFULL :
	case D_BARDOWN :
	case D_POWERON :
		fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
		fread(&stop, sizeof(T_STOP), 1, in);
		if (flag == 1)
		{
			flag = 0;
			printf(" кол-во: %ld\n", lcount);
		}
		switch (stop.sign) {
			case D_POWERFAIL :
				endReason = R_POWERFAIL;
				label = "Отключение питания";
				break;
			case D_DISKFULL :
				endReason = R_DISKFULL;
				label = "Переполнение диска";
				break;
			case D_BARDOWN :
				endReason = R_BARDOWN;
				label = "Сброс давления";
				break;
			case D_POWERON :
				endReason = R_UNKNOWN;
				label = "Включение питания";
				break;
		}

		if (first_weld == 1)
			stop.dist++;

		km = stop.dist / (1000L * 100L);
		metr = (stop.dist - km * (1000L * 100L)) / 100L;
		hour = stop.time / (100L * 60L * 60L);
		min = (stop.time - hour * (100L * 60L * 60L)) / (100L * 60L);
		printf("\n%s дистанция %ld.%03ld км (%ld см) время %ld:%02ld мин (%ld тиков)\n",
			label,
			km,
			metr,
			stop.dist,
			hour,
			min,
			stop.time
			);
		alltime = stop.time;
		break;

	case D_STOP :
		endReason = R_UNKNOWN;
		if (flag == 1)
		{
			flag = 0;
			printf(" кол-во: %ld\n", lcount);
		}
		stopCount++;
		st = (T_ITEMSTOP *) &item;
		sec = ((unsigned long) st->sec) * 2L;

		if (first_weld == 1)
			st->dist++;

		offs = st->dist;
		km = (offs + pdist) / (1000L * 100L);
		metr = ((offs + pdist) - km * (1000L * 100L)) / 100L;
		if (!nostop) {
		printf("\nОстановка дистанция %ld.%03ld км (%ld см)\n",
			km,
			metr,
			pdist + offs
			);
		printf("Время остановки: %u часов %u минут %u секунд\n",
			(unsigned short) (sec / (60L * 60L)),
			(unsigned short) ((sec / 60L) % 60L),
			(unsigned short) (sec % 60L)
			);
		}
		break;
	case D_DFKT01 :
	case D_DFKT02 :
	case D_DFKT03 :
	case D_DFKT04 :
	case D_DFKT05 :
	case D_DFKT06 :
	case D_DFKT07 :
	case D_DFKT08 :
	case D_DFKT09 :
	case D_DFKT10 :
	case D_DFKT11 :
	case D_DFKT12 :
	case D_DFKT13 :
	case D_DFKT14 :
	case D_DFKT15 :
	case D_DFKT16 :
		endReason = R_UNKNOWN;
		if (flag == 1)
		{
			flag = 0;
			printf(" кол-во: %ld\n", lcount);
		}
		offs = item.dist;
		break;
	default:
		endReason = R_UNKNOWN;
		if (flag == 0)
		{
			flag = 1;
			part++;
			lcount = 0L;
			printf("\nНеизвестные элементы по смещению в файле %lX", ftell(in) - sizeof(T_ITEM));
		}
		lcount++;
		break;
   }
	fread(&item, sizeof(T_ITEM), 1, in);
}

if (flag == 1)
{
	flag = 0;
	printf(" кол-во: %ld\n", lcount);
}

alldist = (pdist + offs > stop.dist) ? pdist + offs : stop.dist;
km = alldist / (1000L * 100L);
metr = (alldist - km * (1000L * 100L)) / 100L;
printf("\n\nОбщая длина прогона %ld.%03ld км (%ld см)", km, metr, alldist);

hour = alltime / (100L * 60L * 60L);
min = (alltime - hour * (100L * 60L * 60L)) / (100L * 60L);
printf("\nОбщее время прогона %ld:%02ld мин (%ld тиков)", hour, min, alltime);

printf("\nКоличество остановок при прогоне: %d", stopCount);
printf("\nНеизвестные элементы в записи встречались в %ld местах", part);

printf("\n\nЗапись завершена по ");
switch (endReason) {
	case R_UNKNOWN   :
		printf("неизвестной причине");
		break;
	case R_BARDOWN   :
		printf("сбросу давления");
		break;
	case R_POWERFAIL :
		printf("отказу электропитания");
		break;
	case R_DISKFULL  :
		printf("переполнению диска");
		break;
	default :
		printf("*** ERROR !!! ***");
		break;
}

return 0;

}