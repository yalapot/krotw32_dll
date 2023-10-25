
#include "xml_tools.c"

/* функция регистрации записи */
long KRTAPI krtDrvRegister (
 const char * xmlFile,
 const char * trcFile,
 char **errText,
 long (KRTAPI *userBreak) (short percentDone)
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
   long pred_odometer_value;
   long odometer_step;

   long search_file_counter;

   long i;

   char location_trace[1024];

   long Diameter;

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

   (void) errText;

// -------------------------------------------------------------------------------
   { // работа с xml файлом
       long result;

       FILE * xml_file;
       char xml_file_name[1024];
       long xml_file_len;
       char * xml_file_buf;

       // вычитываем данные из xml файла
       sprintf(xml_file_name, xmlFile);
//       sprintf(xml_file_name, "record_define.xml");

       xml_file_len = 0;
       xml_file_buf = malloc(xml_file_len + 1);
       xml_file_buf[0] = 0;

       xml_file = fopen(xml_file_name, "rb");
       if (xml_file != NULL)
       {
          fseek(xml_file, 0, SEEK_END);
          xml_file_len = ftell(xml_file);
          fseek(xml_file, 0, SEEK_SET);
          xml_file_buf = malloc(xml_file_len + 1);
          fread(xml_file_buf, 1, xml_file_len, xml_file);
          fclose(xml_file);
       }

       { // Парсинг xml файла
           long cur_xml_pos = 0;
           long cur_xml_pos_save;

           char * substr;

           substr = strstr( &(xml_file_buf[cur_xml_pos]), "<INSPECTION_DATA");
           if ( substr == NULL) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", (char *) xml_file_name);
               return KRT_ERR;
           }
           cur_xml_pos = substr - xml_file_buf + 1;

           // парсим название трассы
           result =  parse_str_property(&(xml_file_buf[cur_xml_pos]), "LOCATION", location_trace, &cur_xml_pos);
           if ( result == KRT_ERR) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", (char *) xml_file_name);
               return KRT_ERR;
           }
           cur_xml_pos = substr - xml_file_buf + 1;

           // парсинг Диаметра
           result = parse_int_data_property(&(xml_file_buf[cur_xml_pos]), "DIAM", &Diameter, &cur_xml_pos);
           if ( result == KRT_ERR) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", (char *) xml_file_name);
               return KRT_ERR;
           }

           substr = strstr( &(xml_file_buf[cur_xml_pos]), "<DATARECORD");
           if ( substr == NULL) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", xml_file_name);
               return KRT_ERR;
           }
           cur_xml_pos = substr - xml_file_buf + 1;

           // парсинг Одометра
           result = parse_sens_property(&(xml_file_buf[cur_xml_pos]), "<ODOMETER", &Odometer, &cur_xml_pos);
           if ( result == KRT_ERR) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", xml_file_name);
               return KRT_ERR;
           }

           // парсинг Таймера
           result = parse_sens_property(&(xml_file_buf[cur_xml_pos]), "<TIMER", &Timer, &cur_xml_pos);
           if ( result == KRT_ERR) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", xml_file_name);
               return KRT_ERR;
           }

           // парсинг и подсчет количества остальных датчиков
           substr = strstr( &(xml_file_buf[cur_xml_pos]), "<SERVICEDATA");
           if ( substr == NULL) {
               sprintf (drvError, "Ошибка парсинга %s (krtDrvRegister)", xml_file_name);
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
               if (result == KRT_ERR) break;
               else
               {
                    senslines_counter++;
               }

           } while (result == KRT_OK);
       } // Закончили парсинг xml файла
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
  WritePrivateProfileString(DRIVER_DATA, PATH_DATA_KEY, data_path, trcFile);

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
  odometer_value = 0;
  pred_odometer_value = 0;
  sprintf(file_name, "%sraw%05ld.dat", data_path, first_file_index);
  data_file = fopen(file_name, "rb");
  fread( &pred_odometer_value, 1, Odometer.size, data_file);
  fseek( data_file, FullRecordSize, SEEK_SET);
  fread( &odometer_value, 1, Odometer.size, data_file);
  fclose(data_file);

  odometer_step = odometer_value - pred_odometer_value;
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
      return KRT_ERR;
  };

  // начинаем индексировать файлы данных
  sprintf(file_name, "%sraw%05ld.dat", data_path, first_file_index);
  file_counter=first_file_index;

  timer_value = 0;
  while ( (data_file = fopen(file_name, "rb")) != NULL) {

      sprintf(register_log_file_name, "%sReg_Log.txt", data_path);
      sprintf(register_log_info, "%s\n", file_name);
      Reg_Log(register_log_info);

      persent_value = (file_counter-first_file_index) * 100 / num_file_in_trace;
      if (persent_value <  0) persent_value =  0;
      if (persent_value > 99) persent_value = 99;

      // проверка не пытается ли пользователь прервать нас принудительно и 
      // заодно передадим процент проделанной работы
      if (userBreak((short) persent_value ) ) {
         sprintf (drvError, "Отменено пользователем (krtDrvRegister)");

         fclose(data_file);
         data_file=NULL;

         fclose(idx_file_data);
         idx_file_data=NULL;

         return KRT_ERR;
      };

      break_flag = 0;
      record_data = malloc(FullRecordSize);

      do {
           idx_rec.beg_trace         = idx_head.trace_len;
           idx_rec.shift_in_file     = ftell(data_file);
           idx_rec.file_num          = (short) file_counter;

           // Тут станем принудительно разбивать на блоки по RECORDS_IN_BLOCK записей
           for (record_data_counter = 0; record_data_counter < RECORDS_IN_BLOCK; record_data_counter++)
           {
               result = fread(record_data, 1, FullRecordSize, data_file);

               if (result < FullRecordSize)
               {
                   break_flag = 1;
                   break;
               }

               memcpy( &timer_value, &(record_data[4]), 4);
           } // for (i = 0; i < RECORDS_IN_BLOCK; i++)
           // прочитали и разархивировали данные

           if (record_data_counter == 0)
           {
               break_flag = 1;
               break;
           }

           idx_head.trace_len += record_data_counter;
           idx_head.trace_time = timer_value;

           idx_rec.num_test_in_block = (short) record_data_counter;
           idx_rec.real_len          = idx_rec.num_test_in_block;

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
      return KRT_ERR;
  };

  fclose(idx_file_data);

  // запишем в trc-файл длинну трассы в измерениях
  sprintf(key_name, "%s", TRACE_LEN_KEY);
  sprintf(key_value, "%ld", idx_head.trace_len);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value,trcFile);

  return KRT_OK;
}; /* krtDrvRegister */

