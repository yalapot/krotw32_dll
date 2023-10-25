
#include <direct.h>
#include <stdlib.h>
#include <stdio.h>
#include <driver.h>

#pragma warning(disable : 4996) // for VC 8.00


//char drvError[1024];

#include "raw_data_tools.c"

#include "krot_trc.c"

#include "xml_tools.c"

/* функция регистрации записи */
long KRTAPI krtDrvRegister (
 const char * xmlFile,
 const char * trcFile
 ) 
{

   long data_path_len;
   char data_path[_MAX_PATH]; // путь до файлов с данными

   FILE * data_file;
   char file_name[1024];

   FILE *idx_file_data;
   char idx_file_name[1024];

   long file_counter;

   T_IDX_HEADER idx_head;
   T_IDX_TRC idx_rec;

//   long first_length = -1;

   char key_name[1024];
   char key_value[1024];

   long num_file_in_trace;

   long first_file_index = 0;
   long persent_value;

   long timer_value;

   long odometer_value;
   long pred_odometer_value = 0;
   long odometer_step;

   long d_trace_mm;
   long trace_len_mm;
   long block_len_mm;

   long search_file_counter;

   long i;

   long Diameter;

   char location_trace[1024];

   Т_sens_define Odometer;
   Т_sens_define Timer;

   long other_sens_counter = 0;
   Т_sens_define others_sens[16];

   long senslines_counter = 0;
   Т_sensline_define senslines_param[8];

   long FullRecordSize;
   long num_all_sens;

   long break_flag = 0;

   long record_data_counter;
   char * record_data;
   long result;

   long pred_persent_value = 0;

   char palette_file_name[1024];

   FILE * xml_file;
   char xml_file_name[1024];
   long xml_file_len;
   char * xml_file_buf;

// -------------------------------------------------------------------------------
   { // работа с xml файлом

       // вычитываем данные из xml файла
       sprintf(xml_file_name, xmlFile);
//       sprintf(xml_file_name, "record_define.xml");

       xml_file_len = 0;

       xml_file = fopen(xml_file_name, "rb");
       if (xml_file != NULL)
       {
          fseek(xml_file, 0, SEEK_END);
          xml_file_len = ftell(xml_file);
          fseek(xml_file, 0, SEEK_SET);
          xml_file_buf = malloc(xml_file_len + 1);
          fread(xml_file_buf, 1, xml_file_len, xml_file);
          fclose(xml_file);
       } else {
          sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", (char *) xml_file_name);
          MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
          return KRT_ERR;
       }

       { // Парсинг xml файла
           long cur_xml_pos = 0;
           long cur_xml_pos_save;
           char * substr;

           // проверим: не utf-8 кодировка?
           UTF_8_flag = 0;
           substr = strstr( &(xml_file_buf[cur_xml_pos]), "utf-8");
           if ( substr == NULL) {
               fseek(xml_file, 0, SEEK_SET);
           } else {
               UTF_8_flag = 1;
           }

           substr = strstr( &(xml_file_buf[cur_xml_pos]), "<INSPECTION_DATA");
           if ( substr == NULL) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", (char *) xml_file_name);
               MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
               return KRT_ERR;
           }
           cur_xml_pos = substr - xml_file_buf + 1;

           // парсим название трассы
           result =  parse_str_property(&(xml_file_buf[cur_xml_pos]), "LOCATION", location_trace, &cur_xml_pos);
           if ( result == KRT_ERR) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", (char *) xml_file_name);
               MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
               return KRT_ERR;
           }
           cur_xml_pos = substr - xml_file_buf + 1;

           // парсинг Диаметра
           result = parse_int_data_property(&(xml_file_buf[cur_xml_pos]), "DIAM", &Diameter, &cur_xml_pos);
           if ( result == KRT_ERR) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", (char *) xml_file_name);
               MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
               return KRT_ERR;
           }

           substr = strstr( &(xml_file_buf[cur_xml_pos]), "<DATARECORD");
           if ( substr == NULL) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", xml_file_name);
               MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
               return KRT_ERR;
           }
           cur_xml_pos = substr - xml_file_buf + 1;

           // парсинг Одометра
           result = parse_sens_property(&(xml_file_buf[cur_xml_pos]), "<ODOMETER", &Odometer, &cur_xml_pos);
           if ( result == KRT_ERR) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", xml_file_name);
               MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
               return KRT_ERR;
           }

           // парсинг Таймера
           result = parse_sens_property(&(xml_file_buf[cur_xml_pos]), "<TIMER", &Timer, &cur_xml_pos);
           if ( result == KRT_ERR) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", xml_file_name);
               MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
               return KRT_ERR;
           }

           // парсинг и подсчет количества остальных датчиков
           substr = strstr( &(xml_file_buf[cur_xml_pos]), "<SERVICEDATA");
           if ( substr == NULL) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", xml_file_name);
               MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
               return KRT_ERR;
           }
           cur_xml_pos = substr - xml_file_buf + 1;

           cur_xml_pos_save = cur_xml_pos;

           other_sens_counter = 0;
           do {
               result = parse_sens_property( &(xml_file_buf[cur_xml_pos]), "<SENSOR", &(others_sens[other_sens_counter]), &cur_xml_pos );
               if (result == KRT_ERR)
               {
                    cur_xml_pos = cur_xml_pos_save;
                    break;
               } else {
                    other_sens_counter++;
               }

           } while (result == KRT_OK);

           // парсинг и подсчет количества поясов дефектоскопических датчиков 
           senslines_counter = 0;
           do {

               result = parse_senslines_property( &(xml_file_buf[cur_xml_pos]), "<RAWDATA", &(senslines_param[senslines_counter]), &cur_xml_pos );
               if (result == KRT_ERR)
               {
                   break;
               }
               else
               {
                    senslines_counter++;
               }

           } while (result == KRT_OK);
       } // Закончили парсинг xml файла

       free (xml_file_buf);
   } // работа с xml файлом закончена

   // выделим путь до файлов с данными из полного пути до первого файла
   strcpy(data_path, xmlFile);

   data_path_len=strlen(data_path);

   while ((data_path_len>0) && (data_path[data_path_len-1]!='\\')) {
     data_path[data_path_len - 1] = 0;
     data_path_len--;
   };
   // посчитали длинну строки пути до первого файла (без имени)

  // запишем данные в trc-файл 

  // запишем в trc-файл путь на рабочий каталог
  WritePrivateProfileString(DRIVER_DATA, PATH_DATA_KEY, "", trcFile);

  // запишем в trc-файл диаметер трубы
  sprintf(key_name, "%s", PIPE_DIAMETER_KEY);
  sprintf(key_value, "%ld", Diameter);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

  WritePrivateProfileString("Trace", "Diametr", key_value, trcFile);
  WritePrivateProfileString("Driver", "diamDflt", key_value, trcFile);

  // запишем названия трассы
  WritePrivateProfileString("Trace", "Name", location_trace, trcFile);

  // запишем в trc-файл параметры одометра
  WritePrivateProfileString(DRIVER_DATA, ODOMETER_NAME_KEY, Odometer.name, trcFile);

  WritePrivateProfileString(DRIVER_DATA, ODOMETER_TITLE_KEY, Odometer.title, trcFile);

  sprintf(key_name, "%s", ODOMETER_SIZE_KEY);
  sprintf(key_value, "%ld", Odometer.size);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

  sprintf(key_name, "%s", ODOMETER_INT_TYPE_KEY);
  sprintf(key_value, "%ld", Odometer.int_type);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);


  // запишем в trc-файл параметры таймера
  WritePrivateProfileString(DRIVER_DATA, TIMER_NAME_KEY, Timer.name, trcFile);

  WritePrivateProfileString(DRIVER_DATA, TIMER_TITLE_KEY, Timer.title, trcFile);

  sprintf(key_name, "%s", TIMER_SIZE_KEY);
  sprintf(key_value, "%ld", Timer.size);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

  sprintf(key_name, "%s", TIMER_INT_TYPE_KEY);
  sprintf(key_value, "%ld", Timer.int_type);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

  // запишем в trc-файл параметры сервисных датчикав
  sprintf(key_name, "%s", NUM_ADD_SENSORS_KEY);
  sprintf(key_value, "%ld", other_sens_counter);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

  for ( i = 0; i < other_sens_counter; i++)
  {
      sprintf(key_name, "%s%ld", ADD_SENSOR_NAME_KEY, i);
      WritePrivateProfileString(DRIVER_DATA, key_name, others_sens[ i ].name, trcFile);

      sprintf(key_name, "%s%ld", ADD_SENSOR_TITLE_KEY, i);
      WritePrivateProfileString(DRIVER_DATA, key_name, others_sens[ i ].title, trcFile);

      sprintf(key_name, "%s%ld", ADD_SENSOR_SIZE_KEY, i);
      sprintf(key_value, "%ld", others_sens[ i ].size);
      WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

      sprintf(key_name, "%s%ld", ADD_SENSOR_INT_TYPE_KEY, i);
      sprintf(key_value, "%ld", others_sens[ i ].int_type);
      WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);
  }

  // запишем в trc-файл параметры поясов магнитных датчикав
  sprintf(key_name, "%s", NUM_LINES_SENSORS_KEY);
  sprintf(key_value, "%ld", senslines_counter);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

  for ( i = 0; i < senslines_counter; i++)
  {
      sprintf(key_name, "%s%ld", LINES_SENSORS_NUM_SENS_KEY, i);
      sprintf(key_value, "%ld", senslines_param[ i ].sens_num);
      WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

      sprintf(key_name, "%s%ld", LINES_SENSORS_NAME_KEY, i);
      WritePrivateProfileString(DRIVER_DATA, key_name, senslines_param[ i ].name, trcFile);

      sprintf(key_name, "%s%ld", LINES_SENSORS_TITLE_KEY, i);
      WritePrivateProfileString(DRIVER_DATA, key_name, senslines_param[ i ].title, trcFile);

      sprintf(key_name, "%s%ld", LINES_SENSORS_SIZE_KEY, i);
      sprintf(key_value, "%ld", senslines_param[ i ].size);
      WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

      sprintf(key_name, "%s%ld", LINES_SENSORS_INT_TYPE_KEY, i);
      sprintf(key_value, "%ld", senslines_param[ i ].int_type);
      WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

      sprintf(key_name, "%s%ld", LINES_SENSORS_PALETTE_KEY, i);
      sprintf(key_value, "%s", senslines_param[ i ].palette_name);
      WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

      sprintf(palette_file_name, "%s%s.kpl", data_path, senslines_param[ i ].palette_name);
         
      parse_palette( palette_file_name, senslines_param[ i ].palette_name, xml_file_name);

      sprintf(key_name, "ctlCoroz%ldPalPalFile", i);
      sprintf(key_value, "%s", palette_file_name);
      WritePrivateProfileString("UserSettings", key_name, key_value, trcFile);
  }

  // Посчитаем FullRecordSize и, заодно, shift_in_record
  FullRecordSize = 0;
  Odometer.shift_in_record = FullRecordSize;
  FullRecordSize += Odometer.size;

  Timer.shift_in_record = FullRecordSize;
  FullRecordSize += Timer.size;

  for ( i = 0; i < other_sens_counter; i++)
  {
     others_sens[ i ].shift_in_record = FullRecordSize;
     FullRecordSize += others_sens[ i ].size;
  }

  num_all_sens = 0;
  for ( i = 0; i < senslines_counter; i++)
  {
     senslines_param[ i ].shift_in_record = FullRecordSize;
     FullRecordSize += senslines_param[ i ].size * senslines_param[ i ].sens_num;
     num_all_sens += senslines_param[ i ].sens_num;
  }

  sprintf(key_name, "%s", FULL_RECORD_SIZE_KEY);
  sprintf(key_value, "%ld", FullRecordSize);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value, trcFile);

//--------------------------------------------------------------------------------

  for (first_file_index = 0; first_file_index < 4096; first_file_index++)
  {
      sprintf(file_name, "%sraw%05ld.dat", data_path, first_file_index);
      data_file = fopen(file_name, "rb");
      if (data_file != NULL)
      {
         fclose(data_file);
         break;
      }
  } // for (first_file_index = 0; first_file_index < 4096; first_file_index++)

  // запишем в trc-файл индекс первого файла
  sprintf(key_value, "%ld", first_file_index);
  WritePrivateProfileString(DRIVER_DATA, FIRST_FILE_INDEX_KEY, key_value,trcFile);

  // вычислим шаг одометра
//  odometer_value = 0;
//  pred_odometer_value = 0;
//  sprintf(file_name, "%sraw%05ld.dat", data_path, first_file_index);
//  data_file = fopen(file_name, "rb");
//  fread( &pred_odometer_value, 1, Odometer.size, data_file);
//  fseek( data_file, FullRecordSize, SEEK_SET);
//  fread( &odometer_value, 1, Odometer.size, data_file);
//  fclose(data_file);
//  odometer_step = odometer_value - pred_odometer_value;

  odometer_step = Odometer.step;
  sprintf(key_value, "%ld", odometer_step);
  WritePrivateProfileString(DRIVER_DATA, TRACE_STEP_KEY, key_value,trcFile);
  // вычислили шаг одометра

  // пересчитаем файлы трассы чтобы считать % регистрации
  num_file_in_trace = 0;
  for (search_file_counter = first_file_index; search_file_counter < 4096; search_file_counter++)
  {
      sprintf(file_name, "%sraw%05ld.dat", data_path, search_file_counter);
      data_file = fopen(file_name, "rb");
      if (data_file != NULL)
      {
         fclose(data_file);
         num_file_in_trace ++;
      } else {
         break;
      }
  } // (file_counter*100)/ num_file_in_trace
  // пересчитали файлы трассы чтобы считать % регистрации

  // подготовим заголовок файла индексов
  idx_head.num_idx_in_table = 0;
  idx_head.trace_len        = 0;
  idx_head.trace_time       = 0;

  idx_head.first_file_index = first_file_index;
  idx_head.num_add_sens        = other_sens_counter;
  idx_head.num_magn_sens_group = senslines_counter;
  idx_head.full_record_size = FullRecordSize;
  memcpy( &(idx_head.odometer_define), &Odometer, sizeof(Odometer) );
  memcpy( &(idx_head.timer_define), &Timer, sizeof(Timer) );

  idx_head.num_add_sens = other_sens_counter;
  for ( i = 0; i < other_sens_counter; i++)
  {
      memcpy( &(idx_head.others_sens_define[ i ]), &(others_sens[ i ]), sizeof(others_sens[ i ]) );
  }

  idx_head.num_magn_sens_group = senslines_counter;
  for ( i = 0; i < senslines_counter; i++)
  {
      memcpy( &(idx_head.senslines_define[ i ]), &(senslines_param[ i ]), sizeof(senslines_param[ i ]) );
  }

  idx_head.num_all_sens = num_all_sens;
  // подготовили заголовок файла индексов

  sprintf(idx_file_name, "%strace.idx", data_path);

  idx_file_data = fopen(idx_file_name, "wb");
  if (idx_file_data==NULL) {
      sprintf(drvError, "Ошибка открытия файла %s. \n", idx_file_name);
      MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
      return KRT_ERR;
  };

  // начинаем индексировать файлы данных
  sprintf(file_name, "%sraw%05ld.dat", data_path, first_file_index);
  file_counter=first_file_index;


  // !!!!!! заполняем путь на лог файл на случай использования  Reg_Log(register_log_info);
  sprintf(register_log_file_name, "%sReg_Log.txt", data_path);

  trace_len_mm = 0;

  timer_value = 0;
  while ( (data_file = fopen(file_name, "rb")) != NULL) {

      sprintf(register_log_file_name, "%sReg_Log.txt", data_path);
      sprintf(register_log_info, "%s\n", file_name);
      Reg_Log(register_log_info);

      persent_value = (file_counter-first_file_index) * 100 / num_file_in_trace;
      if (persent_value <  0) persent_value =  0;
      if (persent_value > 99) persent_value = 99;

      if (pred_persent_value != persent_value)
      {
         printf("\r%02ld %% ", persent_value);
         pred_persent_value = persent_value;
      };

      break_flag = 0;
      record_data = malloc(FullRecordSize);

      do {
           idx_rec.beg_trace         = idx_head.trace_len;
           idx_rec.shift_in_file     = ftell(data_file);
           idx_rec.file_num          = (short) file_counter;
           idx_rec.pred_odometer_value = pred_odometer_value;

           // Тут станем принудительно разбивать на блоки по RECORDS_IN_BLOCK записей
           block_len_mm = 0;
           for (record_data_counter = 0; record_data_counter < RECORDS_IN_BLOCK; record_data_counter++)
           {
               result = fread(record_data, 1, FullRecordSize, data_file);

               if (result < FullRecordSize)
               {
                   break_flag = 1;
                   break;
               }

               memcpy( &odometer_value, &(record_data[0]), Odometer.size);
               memcpy( &timer_value, &(record_data[4]), Timer.size);

               d_trace_mm = odometer_value - pred_odometer_value;
               pred_odometer_value = odometer_value;

               if (d_trace_mm <= 0) d_trace_mm = odometer_step;

               block_len_mm += d_trace_mm;
               trace_len_mm += d_trace_mm;

/*
   { // &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
      char tmp_str[1024];

      if ( d_trace_mm != odometer_step)
      {
          sprintf(tmp_str,"%ld, %ld\n", odometer_value, d_trace_mm);
          Reg_Log(tmp_str);

//            MessageBox(NULL, tmp_str, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
      }
   } // &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
*/
           } // for (i = 0; i < RECORDS_IN_BLOCK; i++)
           // прочитали и разархивировали данные

           if (record_data_counter == 0)
           {
               break_flag = 1;
               break;
           }
           idx_head.trace_len  = trace_len_mm / odometer_step;
           idx_head.trace_time = timer_value;

           idx_rec.num_test_in_block = (short) record_data_counter;
           idx_rec.real_len          = block_len_mm / odometer_step; // idx_rec.num_test_in_block;

           // Запишем индексы архивных блоков
           fwrite( &idx_rec, 1, sizeof(idx_rec), idx_file_data);
           // Записали индексы архивных блоков

           idx_head.num_idx_in_table++;

      } while (break_flag == 0);

      free(record_data);
      fclose(data_file);

      file_counter++;
      sprintf(file_name, "%sraw%05ld.dat", data_path, file_counter);

  };//  while (data_file = fopen(file_name, "rb"))

  if ( fwrite( &idx_head, 1, sizeof(idx_head), idx_file_data) != sizeof(idx_head))
  {
      sprintf(drvError, "Ошибка записи файла %s. \n", idx_file_name);
      MessageBox(NULL, drvError, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
      return KRT_ERR;
  };

  fclose(idx_file_data);

  // запишем в trc-файл длинну трассы в измерениях
  sprintf(key_name, "%s", TRACE_LEN_KEY);
  sprintf(key_value, "%ld", idx_head.trace_len);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value,trcFile);

  return KRT_OK;
}; /* krtDrvRegister */


int file_exist(char * file_name)
{ // проверим есть ли файл 
    FILE * file;

    file = fopen(file_name, "rt");
    if (file == NULL)
    {   
        return 1;
    };
    fclose(file);
    return 0;
};

long write_trc_blank(char * file_name)
{
    FILE * file;

    file = fopen(file_name, "wt");

    fprintf(file, "[Files]\n");
    fprintf(file, "Database=raw_data.mdb\n");
    fprintf(file, "WordReport=C:\\Program Files (x86)\\Krot for Win32\\rus.dot\n");
    fprintf(file, "[Trace]\n");
    fprintf(file, "Name=Новая запись\n");
    fprintf(file, "Driver=raw_data\n");
    fprintf(file, "Diametr=1020\n");
    fprintf(file, "DisableMdbEdit=0\n");
    fprintf(file, "OdoDiametr=10186\n");
    fprintf(file, "OdoDiametr1=10186\n");
    fprintf(file, "OdoDiametr2=10186\n");
    fprintf(file, "PigL0=0\n");
    fprintf(file, "PigL1=0\n");
    fprintf(file, "PigL3=0\n");
    fprintf(file, "ExpGraphColor=255\n");
    fprintf(file, "newObjEdit=0\n");
    fprintf(file, "CurveLength=100\n");
    fprintf(file, "[Driver]\n");
    fprintf(file, "Description=просмотр RawData\n");
    fprintf(file, "Path=raw_data_drv.dll\n");
    fprintf(file, "diamDflt=1020\n");
    fprintf(file, "primeExt=xml\n");
    fprintf(file, "Pallete=C:\\Program Files (x86)\\Krot for Win32\\pallete\\std03.kpl\n");
    fprintf(file, "dfltScaleX=0\n");
    fprintf(file, "dfltScaleY=1\n");
    fprintf(file, "ScaleX=-16;-8;-4;-2;0;2;4;8;16\n");
    fprintf(file, "ScaleY=-4;-2;0;2;4\n");
    fprintf(file, "WallThick=10\n");
    fprintf(file, "SpeedVector=200\n");
    fprintf(file, "OdoKoefDflt=1\n");
    fprintf(file, "ProfilZero=65\n");
    fprintf(file, "ProfilPigLength=925\n");
    fprintf(file, "IsProfil=0\n");
    fprintf(file, "OdoAngle=0\n");
    fprintf(file, "MagnetID=\n");
    fprintf(file, "[MagnetSystem]\n");
    fprintf(file, "MagnDesc=Магнитная система по умолчанию (волшебные прямые)\n");
    fprintf(file, "Tesla1=1\n");
    fprintf(file, "Tesla2=0\n");
    fprintf(file, "DefektWidthACP=0\n");
    fprintf(file, "DefektWidthMode=0\n");
    fprintf(file, "DfktLowPrcnt=10\n");
    fprintf(file, "CurveNum=2\n");
    fprintf(file, "DiamNum=0\n");
    fprintf(file, "SlitNum=2\n");

    fprintf(file, "[UserSettings]\n");
    fprintf(file, "ctlCoroz0PalPalFile=\\\\NTS\\ag_programs\\Krot32\\pallete\\std03.kpl\n");
    fprintf(file, "ctlCoroz0PalPalMin=0\n");
    fprintf(file, "ctlCoroz0PalPalMax=200\n");

    fprintf(file, "ctlCoroz1PalPalFile=\\\\NTS\\ag_programs\\Krot32\\pallete\\std03.kpl\n");
    fprintf(file, "ctlCoroz1PalPalMin=0\n");
    fprintf(file, "ctlCoroz1PalPalMax=200\n");

    fprintf(file, "ctlCoroz2PalPalFile=\\\\NTS\\ag_programs\\Krot32\\pallete\\std03.kpl\n");
    fprintf(file, "ctlCoroz2PalPalMin=0\n");
    fprintf(file, "ctlCoroz2PalPalMax=200\n");

    fprintf(file, "ctlCoroz3PalPalFile=\\\\NTS\\ag_programs\\Krot32\\pallete\\std03.kpl\n");
    fprintf(file, "ctlCoroz3PalPalMin=0\n");
    fprintf(file, "ctlCoroz3PalPalMax=200\n");

    fclose(file);
    return 0;
}


int main(int argc, char *argv[])
{
//    FILE * trc_file;
    char tmp_str[1024];
    long tmp_str_len;

    char trc_file_name[1024];
    char xml_file_name[1024];

    WIN32_FIND_DATA FindFileData;
    HANDLE hFind = INVALID_HANDLE_VALUE;
    char mask_file_str[MAX_PATH] = {0};

    char data_path[1024];
    long data_path_len;

    (void) argc;

    printf("argv[0] = %s\n", argv[0]);

    // выделим путь до файлов с данными из полного пути запущеной программы
    strcpy(data_path, argv[0]);

    data_path_len=strlen(data_path);

    while ((data_path_len>0) && (data_path[data_path_len-1]!='\\')) {
      data_path[data_path_len - 1] = 0;
      data_path_len--;
    };
    // посчитали длинну строки пути до первого файла (без имени)

    sprintf (mask_file_str, "%s*.xml", data_path);

    printf ( "mask_file_str = %s\n", mask_file_str);

    hFind=FindFirstFile(mask_file_str, &FindFileData);

    if (hFind != INVALID_HANDLE_VALUE)
    {
         //while (FindNextFile(hFind,&FindFileData)!=0);
         FindClose(hFind);
    } else {
         printf ("Не найден xml-файл\n");
         return 1;
    }

    sprintf(xml_file_name, "%s%s", data_path, FindFileData.cFileName);

    printf ("%s\n", xml_file_name);

    // сгенерим имя trc-файла взяв за основу название каталога с данными
    strcpy(tmp_str, data_path);
    // посчитаем сколько символов в имени каталога
    tmp_str_len=strlen(tmp_str);
    tmp_str_len--;
    tmp_str[tmp_str_len] = 0;

    while ((tmp_str_len>0) && (tmp_str[tmp_str_len-1]!='\\')) {
      tmp_str[tmp_str_len - 1] = 0;
      tmp_str_len--;
    };

    strncpy(tmp_str, & data_path[tmp_str_len], data_path_len - tmp_str_len-1);
    tmp_str_len = data_path_len - tmp_str_len-1;
    tmp_str[tmp_str_len] = 0;

    sprintf(trc_file_name, "%s%s.trc", data_path, tmp_str);

    printf("%s\n", trc_file_name);

    write_trc_blank(trc_file_name);

    krtDrvRegister (xml_file_name, trc_file_name);


   {
      char tmp_str[1024];

      sprintf(tmp_str,"Registration complete \n");
      MessageBox(NULL, tmp_str, "raw_data_reg", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
   }

    return 0;
}
