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
	printf("�ᯮ�짮����� : scan128 file.krt [-s]\n");
	printf("-s �⪫�砥� �뤠�� ���ଠ樨 �� ��⠭�����");
	return 1;
}
in = fopen(argv[1], "rb");
if (in == NULL)
{
	printf ("���� �� ������: %s", argv[1]);
	return 1;
}

nostop = ((argc == 3) && (!strcmpi("-S", argv[2]))) ? 1 : 0;

fread(&head, sizeof(T_KROT_HEAD), 1, in);
if (head.sign != KROT_SIGN)
{
	printf ("������ ��������� 䠩��: %s", argv[1]);
	return 1;
}

endReason = R_UNKNOWN;
printf("\n");

printf ("��� ᨭ�஭���樨:    \t%d.%02d.%d\t%d:%02d:%02d\n",
	head.sinh_day,
	head.sinh_month,
	head.sinh_year,
	head.sinh_hour,
	head.sinh_minutes,
	head.sinh_second
);
printf ("��� ��ࢮ�� ����祭��:\t%d.%02d.%d\t%d:%02d:%02d\n",
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
			printf("�������: %d ���⠭�� %ld\n", odoNum, weld.dist);
		}

		if (flag == 1)
		{
			flag = 0;
			printf(" ���-��: %ld\n", lcount);
		}
		dd = weld.dist - pdist;
		dt = weld.time - ptime;
		offs = 0;

		if ((dd != 256) && (first_weld == 0))
		{
			hour = weld.time / (100L * 60L * 60L);
			min = (weld.time - hour * (100L * 60L * 60L)) / (100L * 60L);
			printf(
				"\n���宩 订\t⠩��� %ld:%02ld ��� (%ld ⨪��)\t���⠭�� %ld �\n\t����� ᥣ���� %ld �\t�६� ��宦����� ᥣ���� %ld ⨪��\n\tᬥ饭�� � 䠩��: %lX\n",
				hour,
				min,
				weld.time,
				weld.dist,
				dd,
				dt,
				ftell(in) - sizeof(T_WELD)
				);
			if (dd == 512) /* ����� ����� 袠 */
			{
				insWeld.sign = 0x50;
				insWeld.orient = weld.orient;
				insWeld.wdist = 0;
				insWeld.odonum = weld.odonum;
				insWeld.dist = weld.dist - 256;
				insWeld.time = weld.time - dt / 2;
				bstr = (unsigned char *) &insWeld;
				/* ���� ४������樨 */
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
			printf(" ���-��: %ld\n", lcount);
		}
		switch (stop.sign) {
			case D_POWERFAIL :
				endReason = R_POWERFAIL;
				label = "�⪫�祭�� ��⠭��";
				break;
			case D_DISKFULL :
				endReason = R_DISKFULL;
				label = "��९������� ��᪠";
				break;
			case D_BARDOWN :
				endReason = R_BARDOWN;
				label = "���� ��������";
				break;
			case D_POWERON :
				endReason = R_UNKNOWN;
				label = "����祭�� ��⠭��";
				break;
		}

		if (first_weld == 1)
			stop.dist++;

		km = stop.dist / (1000L * 100L);
		metr = (stop.dist - km * (1000L * 100L)) / 100L;
		hour = stop.time / (100L * 60L * 60L);
		min = (stop.time - hour * (100L * 60L * 60L)) / (100L * 60L);
		printf("\n%s ���⠭�� %ld.%03ld �� (%ld �) �६� %ld:%02ld ��� (%ld ⨪��)\n",
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
			printf(" ���-��: %ld\n", lcount);
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
		printf("\n��⠭���� ���⠭�� %ld.%03ld �� (%ld �)\n",
			km,
			metr,
			pdist + offs
			);
		printf("�६� ��⠭����: %u �ᮢ %u ����� %u ᥪ㭤\n",
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
			printf(" ���-��: %ld\n", lcount);
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
			printf("\n��������� �������� �� ᬥ饭�� � 䠩�� %lX", ftell(in) - sizeof(T_ITEM));
		}
		lcount++;
		break;
   }
	fread(&item, sizeof(T_ITEM), 1, in);
}

if (flag == 1)
{
	flag = 0;
	printf(" ���-��: %ld\n", lcount);
}

alldist = (pdist + offs > stop.dist) ? pdist + offs : stop.dist;
km = alldist / (1000L * 100L);
metr = (alldist - km * (1000L * 100L)) / 100L;
printf("\n\n���� ����� �ண��� %ld.%03ld �� (%ld �)", km, metr, alldist);

hour = alltime / (100L * 60L * 60L);
min = (alltime - hour * (100L * 60L * 60L)) / (100L * 60L);
printf("\n��饥 �६� �ண��� %ld:%02ld ��� (%ld ⨪��)", hour, min, alltime);

printf("\n������⢮ ��⠭���� �� �ண���: %d", stopCount);
printf("\n��������� �������� � ����� ����砫��� � %ld �����", part);

printf("\n\n������ �����襭� �� ");
switch (endReason) {
	case R_UNKNOWN   :
		printf("�������⭮� ��稭�");
		break;
	case R_BARDOWN   :
		printf("���� ��������");
		break;
	case R_POWERFAIL :
		printf("�⪠�� �����ய�⠭��");
		break;
	case R_DISKFULL  :
		printf("��९������� ��᪠");
		break;
	default :
		printf("*** ERROR !!! ***");
		break;
}

return 0;

}