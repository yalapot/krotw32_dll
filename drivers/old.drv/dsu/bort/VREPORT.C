#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <krot128.h>
#include <num2word.h>

#define MAXSPEED	600

static char * MonthName[] = {
  "",
  "йанваря",
  "февраля",
  "марта",
  "апреля",
  "мая",
  "июня",
  "июля",
  "августа",
  "сентября",
  "октября",
  "ноября",
  "декабря"
};

void VoiceReport(char *tr_file) {
	FILE *in, *out;
	T_KROT_HEAD head;
	T_ITEM item;
	T_WELD weld;
	T_STOP stop;
	T_SUMMARY trace;
	short stopFlag=0, speedFlag=0, os_index=0, st_index=0;
	long all_time, start_time, end_time, stop_begin=0L, speed, delta_time;
	short reccount = 0;
	short first_weld = 1;
	short i;
	div_t x;

  static char buf1[256];
  static char buf2[256];

  in = fopen(tr_file, "rb");
  if (in == NULL)
   {
    fprintf(stdout, "\nFile not found: %s", tr_file);
	Say("запись трассы отсутствует");
	Lamp(DIOD_OK | DIOD_CANCEL);
    return;
   }

  out = fopen("voice.bat", "rt");
  if (out != NULL)
  {
  	fclose(out);
	Say("Докладываю");
  	system("voice.bat");
  	Say("доклад закончен");
  	/* unlink("voice.bat"); */
  	Lamp(DIOD_OK | DIOD_READY);
  	return;
  }

  Say("Анализирую результаты прогона");
  Say("Падаждите");

	end_time = -1L;
	fread(&item, sizeof(T_ITEM), 1, in);
	do {
	  switch (item.sign) {

		case 0x53 :
			fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
			fread(&head, sizeof(T_KROT_HEAD), 1, in);

			reccount++;
			first_weld = 1;
			speedFlag = 0;
			stopFlag = 0;
			os_index = 0;
			st_index = 0;
			memset(&trace, 0, sizeof(T_SUMMARY));

			trace.serialNo = head.serialNo;

			trace.d_year = head.year;
			trace.d_month = head.month;
			trace.d_day = head.day;
			trace.d_hour = head.hour;
			trace.d_minutes = head.minutes;
			trace.d_second = head.second;

			trace.s_year = head.sinh_year;
			trace.s_month = head.sinh_month;
			trace.s_day = head.sinh_day;
			trace.s_hour = head.sinh_hour;
			trace.s_minutes = head.sinh_minutes;
			trace.s_second = head.sinh_second;

			trace.stop_reson = R_UNKNOWN;

			break;

		case D_WELD :
			fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
			fread(&weld, sizeof(T_WELD), 1, in);
			if (first_weld == 1)
			{
				first_weld = 0;
				start_time = weld.time;
				end_time = weld.time;
				trace.dist = weld.dist;
			}
			else
			{
				delta_time = weld.time - end_time;
				if (delta_time == 0L)
					speed = OUT_SPEED;
				else
					speed = (weld.dist - trace.dist) / delta_time * TIC_PER_SECOND;

				end_time = weld.time;
				trace.dist = weld.dist;
				if (speed > MAXSPEED)
				{
					if (speedFlag == 0)
					{
						trace.overspeed[os_index].speed = (short) speed;
						trace.overspeed[os_index].dist = weld.dist;
						speedFlag = 1;
						os_index++;
					}
					else
					{
						if (trace.overspeed[os_index - 1].speed < speed)
							trace.overspeed[os_index - 1].speed = (short) speed;
					}
				}
				else
				{
					speedFlag = 0;
				}
			}
			if (stopFlag == 1)
			{
				if (stop_begin == -1L)
					trace.stop[st_index - 1].minutes = 0;
				else
					trace.stop[st_index - 1].minutes = (short) ((end_time - stop_begin) / (TIC_PER_SECOND * 60L));
				stopFlag = 0;
			}
			trace.stop_reson = R_UNKNOWN;
			break;

		case D_STOP :
			if (stopFlag == 0)
			{
				trace.stop[st_index].dist = trace.dist;
				stop_begin = end_time;
				st_index++;
				stopFlag = 1;
			}
			break;

		case D_BARDOWN :
			fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
			fread(&stop, sizeof(T_STOP), 1, in);
			trace.stop_reson = R_BARDOWN;
			break;
		case D_POWERFAIL :
			fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
			fread(&stop, sizeof(T_STOP), 1, in);
			trace.stop_reson = R_POWERFAIL;
			break;
		case D_DISKFULL :
			fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
			fread(&stop, sizeof(T_STOP), 1, in);
			trace.stop_reson = R_DISKFULL;
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
			trace.stop_reson = R_UNKNOWN;
			break;
		default:
			trace.unknown_item++;
			break;
	   }
	   fread(&item, sizeof(T_ITEM), 1, in);
	} while (!feof(in));

	if (start_time > end_time)
		all_time = (TIC_PER_SECOND * 60L * 60L * 24L) - start_time + end_time;
		else
		all_time = end_time - start_time;

	all_time = all_time / (TIC_PER_SECOND * 60L); /* время в минутах */
	x = div((short) all_time, 60);
	trace.wt_hour = x.quot;
	trace.wt_minutes = x.rem;

	if (reccount == 0)
	 return;

  out = fopen("voice.bat", "wt");
  if (out == NULL)
   {
    fprintf(stdout, "\nCan't open voice.bat");
	Say("ошибка при создании отчета");
	Lamp(DIOD_OK | DIOD_CANCEL);
    return;
   }

fprintf(out, "@echo off\n");
if (reccount > 1)
{
	transns(reccount, buf1, FEMALE, IMENIT, SUSCH);
	buildnn(reccount, "запис", "ь", "и", "ей", buf2);
	fprintf(out, "- В файле данных обнаружено %s %s\n", buf1, buf2);
	fprintf(out, "- Прослушайте информацию о последней записи\n");
}

transns(trace.serialNo, buf1, MALE, IMENIT, SUSCH);
//fprintf(out, "- Запись сделана снарядом серийный номер %s\n", buf1);

transns(trace.s_day, buf1, MALE, RODIT, PRIL);
transns(trace.s_year, buf2, MALE, RODIT, PRIL);
fprintf(out, "- Дата синхронизации %s %s %s года ",
  buf1,
  MonthName[trace.s_month],
  buf2
  );
transns(trace.s_hour, buf1, MALE, IMENIT, SUSCH);
buildnn(trace.s_hour, "час", "", "а", "ов", buf2);
fprintf(out, " %s%s", buf1, buf2);
transns(trace.s_minutes, buf1, FEMALE, IMENIT, SUSCH);
buildnn(trace.s_minutes, "минут", "а", "ы", "", buf2);
fprintf(out, " %s%s\n", buf1, buf2);

transns(trace.d_day, buf1, MALE, RODIT, PRIL);
transns(trace.d_year, buf2, MALE, RODIT, PRIL);
fprintf(out, "- Дата начала записи %s %s %s года ",
  buf1,
  MonthName[trace.d_month],
  buf2
  );
transns(trace.d_hour, buf1, MALE, IMENIT, SUSCH);
buildnn(trace.d_hour, "час", "", "а", "ов", buf2);
fprintf(out, " %s%s", buf1, buf2);
transns(trace.d_minutes, buf1, FEMALE, IMENIT, SUSCH);
buildnn(trace.d_minutes, "минут", "а", "ы", "", buf2);
fprintf(out, " %s%s\n", buf1, buf2);

transns(trace.dist / 100L, buf1, MALE, IMENIT, SUSCH);
buildnn((short) (trace.dist / 100L), "метр", "", "а", "ов", buf2);
fprintf(out, "- Записано %s%s трассы\n", buf1, buf2);

fprintf(out, "- Время в пути");
if (trace.wt_hour > 0)
{
  transns(trace.wt_hour, buf1, MALE, IMENIT, SUSCH);
  buildnn(trace.wt_hour, "час", "", "а", "ов", buf2);
  fprintf(out, " %s%s", buf1, buf2);
}
transns(trace.wt_minutes + 1, buf1, FEMALE, IMENIT, SUSCH);
buildnn(trace.wt_minutes + 1, "минут", "а", "ы", "", buf2);
fprintf(out, " %s%s\n", buf1, buf2);

i = 0;
if (os_index != 0)
 i = i | 1;
if (st_index != 0)
 i = i | 2;
switch (i) {
	case 0:
		fprintf(out, "- Превышений скорости и остановок в пути не было\n");
		break;
	case 2:
		transns(st_index, buf1, FEMALE, IMENIT, SUSCH);
		buildnn(st_index, "останов", "ка", "ки", "ок", buf2);
		fprintf(out, "- Был%s %s%s в пути. Превышений скорости не было\n",
			((st_index==1) ? "а" : "о"), buf1, buf2);
		break;
	case 1:
		transns(os_index, buf1, MALE, IMENIT, SUSCH);
		buildnn(os_index, "превышени", "е", "я", "й", buf2);
		fprintf(out, "- Было %s%s скорости. Остановок в пути не было\n", buf1, buf2);
		break;
	case 3:
		transns(st_index, buf1, FEMALE, IMENIT, SUSCH);
		buildnn(st_index, "останов", "ка", "ки", "ок", buf2);
		fprintf(out, "- Был%s %s%s в пути и ",
			((st_index==1) ? "а" : "о"), buf1, buf2);
		transns(os_index, buf1, MALE, IMENIT, SUSCH);
		buildnn(os_index, "превышени", "е", "я", "й", buf2);
		fprintf(out, "%s%s скорости\n", buf1, buf2);
		break;
};

for (i = 0; i < st_index; i++) {
	transns(i+1, buf1, FEMALE, IMENIT, PRIL);
	fprintf(out, "- %s остановка\n", (st_index==1) ? "" : buf1);
	transns(trace.stop[i].dist / 100, buf1, MALE, IMENIT, SUSCH);
	buildnn((short) (trace.stop[i].dist / 100L), "метр", "", "а", "ов", buf2);
	fprintf(out, "- Была на отметке %s%s\n", buf1, buf2);
	transns(trace.stop[i].minutes+1, buf1, FEMALE, IMENIT, SUSCH);
	buildnn(trace.stop[i].minutes+1, "минут", "а", "ы", "", buf2);
	fprintf(out, "- Время остановки %s%s\n", buf1, buf2);

}

for (i = 0; i < os_index; i++) {
	transns(i+1, buf1, GERM, IMENIT, PRIL);
	fprintf(out, "- %s превышение скорости\n", (os_index==1) ? "" : buf1);
	transns(trace.overspeed[i].dist / 100, buf1, MALE, IMENIT, SUSCH);
	buildnn((short) (trace.overspeed[i].dist / 100L), "метр", "", "а", "ов", buf2);
	fprintf(out, "- Было на отметке %s%s\n", buf1, buf2);
	speed = (long) trace.overspeed[i].speed / 100L;

	if (speed == (OUT_SPEED / 100L))
	{
		sprintf(buf1, "охуеное количество ");
		sprintf(buf2, "метров");
	}
	else
	{
		transns(speed, buf1, MALE, IMENIT, SUSCH);
		buildnn((short) speed, "метр", "", "а", "ов", buf2);
	}

	fprintf(out, "- Максимальная скорость составляла %s%s в секунду\n", buf1, buf2);

}

fprintf(out, "- Запись завершена ");
switch (trace.stop_reson){
	case R_UNKNOWN:
		fprintf(out, "по неизвестной причине\n");
		break;
	case R_BARDOWN:
		fprintf(out, "по сбросу давления в трубопроводе\n");
		break;
	case R_POWERFAIL:
		fprintf(out, "из за выработки ресурса аккамуляторов\n");
		break;
	case R_DISKFULL:
		fprintf(out, "из за недостатка места на жестком диске\n");
		break;
};

  fclose(in);
  fclose(out);

  Say("Анализ закончен");
  Say("Докладываю");
  system("voice.bat");
  /* unlink("voice.bat"); */
  Say("доклад закончен");
  Lamp(DIOD_OK | DIOD_READY);

  return;
}