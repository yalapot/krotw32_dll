#include <stdio.h>
#include <krtapi.h>

#define Delete_sens_data_KEY         "Delete_sens_data"
#define invert_sens_data_KEY         "invert_sens_data"
#define Zerro_sens_data_KEY          "Zerro_sens_data"

#define SENSE_DELETE_FLAG 0xFFFF

long Get_long_key( char * key_name, char * section_name, long dflt_value, char * trcFile)
{
   char key_value[1024];
   char dflt_str[1024];

   sprintf(dflt_str, "%ld", dflt_value);

   GetPrivateProfileString(section_name, key_name, dflt_str, key_value, sizeof(key_value), trcFile);

   return atol(key_value);
}

double Get_double_key( char * key_name, char * section_name, double dflt_value, char * trcFile)
{
   char key_value[1024];
   char dflt_str[1024];

   sprintf(dflt_str, "%f", dflt_value);

   GetPrivateProfileString(section_name, key_name, dflt_str, key_value, sizeof(key_value), trcFile);

   return atof(key_value);
}


long Create_str_key_not_rewrite( char * key_name, char * section_name, char * key_value, char * trcFile)
{
    char new_key_value[1024];

    // на всякий случай перечитаем значение, если есть то оставляем как есть
    if (GetPrivateProfileString(section_name, key_name, "", new_key_value, sizeof(new_key_value), trcFile)==0)
    {
       sprintf(new_key_value, "%s", key_value);
    }; 
    WritePrivateProfileString(section_name, key_name, new_key_value, trcFile);

    return KRT_OK;
}

long Create_long_key_not_rewrite( char * key_name, char * section_name, long key_value, char * trcFile)
{
    char new_key_value[1024];

    // на всякий случай перечитаем значение, если есть то оставляем как есть
    if (GetPrivateProfileString(section_name, key_name, "", new_key_value, sizeof(new_key_value), trcFile)==0)
    {
       sprintf(new_key_value, "%ld", key_value);
    }; 
    WritePrivateProfileString(section_name, key_name, new_key_value, trcFile);

    return atol(new_key_value);
}

double Create_double_key_not_rewrite( char * key_name, char * section_name, double key_value, char * trcFile)
{
    char new_key_value[1024];

    // на всякий случай перечитаем значение, если есть то оставляем как есть
    if (GetPrivateProfileString(section_name, key_name, "", new_key_value, sizeof(new_key_value), trcFile)==0)
    {
       sprintf(new_key_value, "%f", key_value);
    }; 
    WritePrivateProfileString(section_name, key_name, new_key_value, trcFile);

    return atof(new_key_value);
}

long read_delete_sens_table(long full_sens_num, long Delete_sens_data[],
                            long real_number_sensor_in_group[],
                            long linesense_size[], long group_num,
                            char * traceFile )
{

   long i;

   char key_name[1024];
   char key_value[1024];

   char tmp_str[1024];

   char seps[]   = " ,\t\n";
   char sub_seps[]   = " -\t\n";
   char *token;
   char *sub_token;
   long low_range, high_range, next_token; 

   long curr_delete;
   long new_group_beg_sens;
   long cur_group;


     // читаем из trc-файла таблицу удаления датчиков из записи
     for (i=0; i < full_sens_num; i++)
     {
        Delete_sens_data[i] = 0;
     };

     for (i=0; i < group_num; i++)
     {
        real_number_sensor_in_group[i] = linesense_size[i];
     };

     sprintf(key_name, Delete_sens_data_KEY);
     if (GetPrivateProfileString(DRIVER_DATA, key_name, "", key_value, sizeof(key_value), traceFile)!=0)
     {
        strcpy(tmp_str, key_value);
        token = strtok(key_value, seps );
        next_token=1;
        while (token!=NULL) {
           sub_token = strtok(token, sub_seps );
           if (sub_token==NULL) {
               low_range=0;
            } else {
               low_range=atoi(sub_token);
            };
           sub_token = strtok(NULL, seps );
           if (sub_token==NULL) {
               high_range=low_range;
            } else {
               high_range=atoi(sub_token);
            };
           if (high_range>=low_range) {
               for (i=low_range; i<=high_range; i++) {
                  Delete_sens_data[i]=1;
               };
            };
           strcpy(key_value, tmp_str);
           token = strtok(key_value, seps );
           for (i=0; i<next_token; i++) {
              token = strtok(NULL, seps);
            };
           next_token++;
         };

        cur_group=0;
        curr_delete=0;
        new_group_beg_sens = linesense_size[cur_group];

        for (i=0; i < full_sens_num; i++) {
           if (i==new_group_beg_sens) {
              cur_group++;
              curr_delete=0;
              new_group_beg_sens += linesense_size[cur_group];
           };
           if (Delete_sens_data[i]==1) {
              curr_delete++;
              real_number_sensor_in_group[cur_group]--;
              Delete_sens_data[i] = SENSE_DELETE_FLAG;
           } else {
              Delete_sens_data[i] += curr_delete;
           };
        };
     };
     // прочитали таблицу  удаления датчиков из записи

     return KRT_OK;

}; // long read_delete_sens_table

long read_invert_sens_table(long full_sens_num, long invert_sens_data[],
                            char * traceFile )
{
   long i;

   char tmp_str[1024];

   char key_name[1024];
   char str_cur_sens_value[1024];

   char seps[]       = " ,\t\n";
   char sub_seps[]   = " -\t\n";
   char *token;
   char *sub_token;

   long low_range, high_range, next_token; 


     // читаем из trc-файла таблицу инвертирования сигналов датчиков
     for (i = 0; i <= full_sens_num; i++) {
        invert_sens_data[i]=0;
     };

     sprintf(key_name, invert_sens_data_KEY);
     if (GetPrivateProfileString(DRIVER_DATA, key_name, "",
             str_cur_sens_value, sizeof(str_cur_sens_value), traceFile) != 0)
     {
        strcpy(tmp_str, str_cur_sens_value);
        token = strtok(str_cur_sens_value, seps );
        next_token=1;
        while (token!=NULL) {
           sub_token = strtok(token, sub_seps );
           if (sub_token==NULL) {
               low_range=0;
           } else {
               low_range=atoi(sub_token);
           };
           sub_token = strtok(NULL, seps );
           if (sub_token==NULL) {
               high_range=low_range;
           } else {
               high_range=atoi(sub_token);
           };
           if (high_range>=low_range) {
               for (i=low_range; i<=high_range; i++) {
                  invert_sens_data[i]=1;
               };
           };
           strcpy(str_cur_sens_value, tmp_str);
           token = strtok(str_cur_sens_value, seps );
           for (i=0; i<next_token; i++) {
              token = strtok(NULL, seps);
           };
           next_token++;
        };
     };
     // прочитали таблицу инвертирования сигнало датчиков

     return KRT_OK;

}; // long read_invert_sens_table

long read_zerro_sens_table(long full_sens_num, long Zerro_sens_data[],
                            char * traceFile )
{

   long i;

   char tmp_str[1024];

   char key_name[1024];
   char str_cur_sens_value[1024];

   char seps[]       = " ,\t\n";
   char sub_seps[]   = " -\t\n";
   char *token;
   char *sub_token;

   long low_range, high_range, next_token; 


     // читаем из trc-файла таблицу инвертирования сигналов датчиков
     for (i = 0; i <= full_sens_num; i++) {
        Zerro_sens_data[i]=0;
     };

     sprintf(key_name, Zerro_sens_data_KEY);
     if (GetPrivateProfileString(DRIVER_DATA, key_name, "",
             str_cur_sens_value, sizeof(str_cur_sens_value), traceFile) != 0)
     {
        strcpy(tmp_str, str_cur_sens_value);
        token = strtok(str_cur_sens_value, seps );
        next_token=1;
        while (token!=NULL) {
           sub_token = strtok(token, sub_seps );
           if (sub_token==NULL) {
               low_range=0;
           } else {
               low_range=atoi(sub_token);
           };
           sub_token = strtok(NULL, seps );
           if (sub_token==NULL) {
               high_range=low_range;
           } else {
               high_range=atoi(sub_token);
           };
           if (high_range>=low_range) {
               for (i=low_range; i<=high_range; i++) {
                  Zerro_sens_data[i]=1;
               };
           };
           strcpy(str_cur_sens_value, tmp_str);
           token = strtok(str_cur_sens_value, seps );
           for (i=0; i<next_token; i++) {
              token = strtok(NULL, seps);
           };
           next_token++;
        };
     };
     // прочитали таблицу инвертирования сигнало датчиков

     return KRT_OK;

}; // long read_zerro_sens_table

