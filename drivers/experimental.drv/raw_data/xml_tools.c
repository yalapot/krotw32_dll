// --------------------------------------------------------------

typedef struct {
   long level_num;
   long value;
   unsigned long rgb;
} T_PALETTE_LEVEL;


long UTF_8_flag = 0;

int parse_hex(const char* s, unsigned long* h){
    const char*  p;
    unsigned int n;
    if((*s != '0') || ((*(s + 1) & 0xDF) != 'X'))
        return 0;
    
    for(n = 0, p = s + 2; *p; ++p){
        if(*p >= '0' && *p <= '9')
            n = (n << 4) | (unsigned int)(*p - '0');
        else if(*p >= 'A' && *p <= 'F')
            n = (n << 4) | (unsigned int)(*p - 'A' + 10);
        else
            break;
    }
 
    //проверка на переполнение
    if(((int)(p - s) - 2) > (int)(sizeof(n) << 1))
        return 0;
 
    *h = n;
    return (p != s + 2) ? (int)(p - s) : 0;
}


long parse_str_property(char * src_data, char * property_name, char * property_str, long *pos_in_file)
{
    long cur_xml_pos = 0;
    char * substr;

    long begin_substr;
    long end_substr;
    long len_substr;
    long i;
    long new_str_len;

    substr = strstr( &(src_data[cur_xml_pos]), property_name);
    if ( substr == NULL) return KRT_ERR;
    cur_xml_pos = substr - src_data + strlen(property_name);

    substr = strstr( &(src_data[cur_xml_pos]), "\"");
    if ( substr == NULL) return KRT_ERR;
    cur_xml_pos = substr - src_data + 1;

    begin_substr = cur_xml_pos;

    substr = strstr( &(src_data[cur_xml_pos]), "\"");
    if ( substr == NULL) return KRT_ERR;
    cur_xml_pos = substr - src_data + 1;

    end_substr = cur_xml_pos - 1;

    len_substr = end_substr - begin_substr;

    *pos_in_file += end_substr;

    if (UTF_8_flag != 0)
    {
        // UTF-8 кодировка
        unsigned char* cur_char;

        new_str_len = 0;
        for ( i = 0; i < len_substr; i++)
        {
            cur_char = (unsigned char*) &(src_data[begin_substr + i]);

            if (*cur_char < 128)
            {
                property_str[new_str_len] = src_data[begin_substr + i];
                new_str_len++;
                continue;
            }

            if (*cur_char == 0xd0)
            {   i++;
                property_str[new_str_len] = src_data[begin_substr + i] + 48;
                new_str_len++;
                continue;
            }

            if (*cur_char == 0xd1)
            {   i++;
                property_str[new_str_len] = src_data[begin_substr + i] + 112;
                new_str_len++;
                continue;
            }

            if (*cur_char == 0xef)
            {   i+=3;
                continue;
            }
        }
        property_str[new_str_len] = 0;
    } else {
        // ANSI кодировка
        memcpy( property_str, &(src_data[begin_substr]), len_substr);
        property_str[len_substr] = 0;
    }

    return KRT_OK;
} // long parse_str_property(

long parse_data_type_property(char * src_data, char * property_name, long *data_size, long *int_type, long *pos_in_file)
{
   long cur_xml_pos = 0;
   char * substr;

   long begin_substr;
   long end_substr;
   long len_substr;
   char data_type_property[16];

    substr = strstr( &(src_data[cur_xml_pos]), property_name);
    if ( substr == NULL) return KRT_ERR;
    cur_xml_pos = substr - src_data + strlen(property_name);

    substr = strstr( &(src_data[cur_xml_pos]), "\"");
    if ( substr == NULL) return KRT_ERR;
    cur_xml_pos = substr - src_data + 1;

    begin_substr = cur_xml_pos;

    substr = strstr( &(src_data[cur_xml_pos]), "\"");
    if ( substr == NULL) return KRT_ERR;
    cur_xml_pos = substr - src_data + 1;

    end_substr = cur_xml_pos - 1;

    len_substr = end_substr - begin_substr;
    memcpy( data_type_property, &(src_data[begin_substr]), len_substr);
    data_type_property[len_substr] = 0;

    *pos_in_file += end_substr;

    if (strcmp(data_type_property, "DOUBLE") == 0)
    {
        *data_size = 8;
        *int_type = 0;
        return KRT_OK;
    };

    if (strcmp(data_type_property, "INT8") == 0)
    {
        *data_size = 1;
        *int_type = 1;
        return KRT_OK;
    };
       
    if (strcmp(data_type_property, "UINT8") == 0)
    {
        *data_size = 1;
        *int_type = 2;
        return KRT_OK;
    };
       
    if (strcmp(data_type_property, "INT16") == 0)
    {
        *data_size = 2;
        *int_type = 1;
        return KRT_OK;
    };

    if (strcmp(data_type_property, "UINT16") == 0)
    {
        *data_size = 2;
        *int_type = 2;
        return KRT_OK;
    };
       
    if (strcmp(data_type_property, "INT32") == 0)
    {
        *data_size = 4;
        *int_type = 1;
        return KRT_OK;
    };
       
    if (strcmp(data_type_property, "UINT32") == 0)
    {
        *data_size = 4;
        *int_type = 2;
        return KRT_OK;
    };
       
    return KRT_ERR;
} // long parse_data_type_property( 

long parse_int_data_property(char * src_data, char * property_name, long *int_data, long *pos_in_file)
{
   long cur_xml_pos = 0;
   char * substr;

   long begin_substr;
   long end_substr;
   long len_substr;
   char int_data_str[16];

    substr = strstr( &(src_data[cur_xml_pos]), property_name);
    if ( substr == NULL) return KRT_ERR;
    cur_xml_pos = substr - src_data + strlen(property_name);

    substr = strstr( &(src_data[cur_xml_pos]), "\"");
    if ( substr == NULL) return KRT_ERR;
    cur_xml_pos = substr - src_data + 1;

    begin_substr = cur_xml_pos;

    substr = strstr( &(src_data[cur_xml_pos]), "\"");
    if ( substr == NULL) return KRT_ERR;
    cur_xml_pos = substr - src_data + 1;

    end_substr = cur_xml_pos - 1;

    len_substr = end_substr - begin_substr;
    memcpy( int_data_str, &(src_data[begin_substr]), len_substr);
    int_data_str[len_substr] = 0;

    *int_data = atoi(int_data_str);

    *pos_in_file += end_substr;

    return KRT_OK;
} // long parse_int_data_property(


long parse_sens_property(char * src_data, char * sens_name, “_sens_define * sens_data, long *pos_in_file)
{
    long result;
    long cur_xml_pos = 0;
    char * substr;

    long cur_xml_pos_save;

    substr = strstr( &(src_data[cur_xml_pos]), sens_name);
    if ( substr == NULL) {
        return KRT_ERR;
    }
    cur_xml_pos = substr - src_data + strlen(sens_name);

    result = parse_str_property ( &(src_data[cur_xml_pos]), "NAME", sens_data->name, &cur_xml_pos);
    if ( result == KRT_ERR) {
        return KRT_ERR;
    }

    // парсим title
    result = parse_str_property ( &(src_data[cur_xml_pos]), "TITLE", sens_data->title, &cur_xml_pos);
    if ( result == KRT_ERR) {
        return KRT_ERR;
    }

    // парсим size
    result = parse_data_type_property(&(src_data[cur_xml_pos]), "SIZE", &(sens_data->size), &(sens_data->int_type), &cur_xml_pos);
    if ( result == KRT_ERR) {
        return KRT_ERR;
    }

    cur_xml_pos_save = cur_xml_pos;
    // парсим step
    result = parse_int_data_property(&(src_data[cur_xml_pos]), "STEP", &(sens_data->step), &cur_xml_pos);
    if ( result == KRT_ERR) {
        sens_data->step = 5;
        cur_xml_pos = cur_xml_pos_save;
    }

    *pos_in_file += cur_xml_pos;

    return KRT_OK;
} // long parse_sens_property(


long parse_senslines_property(char* src_data, char* senslines_name, “_sensline_define* senslines_data, long* pos_in_file)
{
    long result;
    long cur_xml_pos = 0;
    char * substr;

    substr = strstr( &(src_data[cur_xml_pos]), senslines_name);
    if ( substr == NULL) {
        return KRT_ERR;
    }
    cur_xml_pos = substr - src_data + strlen(senslines_name);

    result = parse_str_property ( &(src_data[cur_xml_pos]), "NAME", senslines_data->name, &cur_xml_pos);
    if ( result == KRT_ERR) {
        strcpy(senslines_data->name, "default");
    }

    // парсим title
    result = parse_str_property ( &(src_data[cur_xml_pos]), "TITLE", senslines_data->title, &cur_xml_pos);
    if ( result == KRT_ERR) {
        strcpy(senslines_data->title, "default");
    }

    // парсим size
    result = parse_data_type_property(&(src_data[cur_xml_pos]), "SIZE", &(senslines_data->size), &(senslines_data->int_type), &cur_xml_pos);
    if ( result == KRT_ERR) {
        return KRT_ERR;
    }

    // парсим sens_num
    result = parse_int_data_property(&(src_data[cur_xml_pos]), "QUANTITY", &(senslines_data->sens_num), &cur_xml_pos);
    if ( result == KRT_ERR) {
        return KRT_ERR;
    }

    // парсим palette
    result = parse_str_property ( &(src_data[cur_xml_pos]), "PALETTE", senslines_data->palette_name, &cur_xml_pos);
    if ( result == KRT_ERR) {
        strcpy(senslines_data->palette_name, "default");
    }

    *pos_in_file += cur_xml_pos;

    return KRT_OK;
} // parse_senslines_property(

//---------------------------------------------------------------

long write_palette_blank(char * file_name)
{
    FILE * file;

    file = fopen(file_name, "wt");

    fprintf(file, "[Palette]         \n");
    fprintf(file, "Version=1         \n");
    fprintf(file, "EntryNum=7        \n");
    fprintf(file, "BorderMin=0      \n");
    fprintf(file, "BorderMax=199     \n");
    fprintf(file, "[Items]           \n");
//    fprintf(file, "ItemMin=0:0       \n");
//    fprintf(file, "ItemMax=199:13823 \n");
//    fprintf(file, "Item1=88:11579568 \n");
//    fprintf(file, "Item2=89:12632256 \n");
//    fprintf(file, "Item3=110:15863040\n");
//    fprintf(file, "Item4=128:587520  \n");
//    fprintf(file, "Item5=137:65384   \n");
//    fprintf(file, "Item6=151:62975   \n");
//    fprintf(file, "Item7=154:59135   \n");

    fclose(file);

    return KRT_OK;
}

long parse_next_palette_level(char* src_data, T_PALETTE_LEVEL* palette_level, long* pos_in_file)
{
    char digit_str[1024];
    char tmt_digit_chars[16];
    long digit_len;
    long hex_len;

    long result;
    long cur_xml_pos = 0;
    char * substr;

    substr = strstr( &(src_data[cur_xml_pos]), "<LEVEL");
    if ( substr == NULL)
    {
        return KRT_ERR;
    }
    cur_xml_pos = substr - src_data + strlen("<LEVEL");

    digit_len=0;
    while ( isdigit(src_data[cur_xml_pos]) )
    {
        digit_str[digit_len] = src_data[cur_xml_pos];
        digit_len ++;
        cur_xml_pos++;
    }

    digit_str[digit_len] = 0;
    palette_level->level_num = atoi(digit_str);

    // парсим value
    result = parse_int_data_property(&(src_data[cur_xml_pos]), "VALUE", &(palette_level->value), &cur_xml_pos);
    if ( result == KRT_ERR) {
        return KRT_ERR;
    }

    // парсим RGB
    digit_len = 0;
    digit_str[digit_len] = '0';
    digit_len++;
    digit_str[digit_len] = 'x';
    digit_len++;
    result = parse_str_property ( &(src_data[cur_xml_pos]), "RGB", &(digit_str[digit_len]), &cur_xml_pos);
    if ( result == KRT_ERR) {
        return KRT_ERR;
    }

    // переставим красный и синий
    tmt_digit_chars[0] = digit_str[0+2];
    tmt_digit_chars[1] = digit_str[1+2];
    digit_str[0+2] = digit_str[4+2];
    digit_str[1+2] = digit_str[5+2];
    digit_str[4+2] = tmt_digit_chars[0];
    digit_str[5+2] = tmt_digit_chars[1];

    palette_level->rgb =0;
    hex_len = parse_hex(digit_str, &(palette_level->rgb) );

    *pos_in_file += cur_xml_pos;

    return KRT_OK;

} // parse_next_palette_level(char* src_data, T_PALETTE_LEVEL* palette_level)

long parse_palette( char* palette_file_name, char* palette_name, char* xml_file_name)
{
    long result;

    FILE * xml_file;
    long xml_file_len;
    char * xml_file_buf;

    long cur_xml_pos = 0;

    char * substr;

    char serched_palette_name[1024];
    long serched_palette_flag;

    long palette_level_counter = 0;
    T_PALETTE_LEVEL palette_level[256];
    long num_levels_in_palette;
    T_PALETTE_LEVEL tmp_palette_level;
    long max_palette_value;

    char key_name[1024];
    char key_value[1024];


    // вычитываем данные из xml файла
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
        return KRT_ERR;
    }

    // ѕарсинг xml файла
    substr = strstr( &(xml_file_buf[cur_xml_pos]), "<PALETTESLIST");
    if ( substr == NULL)
    {
        free(xml_file_buf);
        return KRT_ERR;
    }
    cur_xml_pos = substr - xml_file_buf + 1;

    substr = strstr( &(xml_file_buf[cur_xml_pos]), "<PALETTE");
    if ( substr == NULL)
    {
        free(xml_file_buf);
        return KRT_ERR;
    }
    cur_xml_pos = substr - xml_file_buf + 1;

    // ищем палитру с нужным именем
    serched_palette_flag = 0;
    while (cur_xml_pos < xml_file_len)
    {
        result = parse_str_property ( &(xml_file_buf[cur_xml_pos]), "NAME", serched_palette_name, &cur_xml_pos);

        if  ( strcmp(serched_palette_name, palette_name) == 0 )
        {
            //палитра с нужным именем найдена
            serched_palette_flag = 1;
            break;
        }
    }

    if (serched_palette_flag == 0)
    {
        free(xml_file_buf);
        return KRT_ERR;
    }

    // чтение параметров уровней палитры
    palette_level_counter = 0;
    do { 
        result = parse_next_palette_level(&(xml_file_buf[cur_xml_pos]), &(palette_level[palette_level_counter]), &cur_xml_pos);
        if (result == KRT_ERR) break;

        palette_level_counter++;

    } while ( result != KRT_ERR);

    if (result == KRT_ERR && palette_level_counter == 0 )
    {
        free(xml_file_buf);
        return KRT_ERR;
    }
    num_levels_in_palette = palette_level_counter;
    // прочитали параметры уровней палитры

    free(xml_file_buf);

    // смасштабтруем уровни палитры в 200 градаций
    max_palette_value = 0;
    for (palette_level_counter = 0; palette_level_counter < num_levels_in_palette; palette_level_counter++)
    {
        if (max_palette_value < palette_level[palette_level_counter].value)
               max_palette_value = palette_level[palette_level_counter].value;
    }

    for (palette_level_counter = 0; palette_level_counter < num_levels_in_palette; palette_level_counter++)
    {
        palette_level[palette_level_counter].value = 
            palette_level[palette_level_counter].value * 199 / max_palette_value;
    }

    // возможно сортировку проверить еще, пропуски в нумерации уровней ?
//    for (palette_level_counter = 0; palette_level_counter < num_levels_in_palette; palette_level_counter++)
//    {
//        tmp_palette_level.level_num = palette_level[palette_level_counter].level_num;
//        tmp_palette_level.value;
//    }


    // запишем параметры палитры в файл
    write_palette_blank(palette_file_name);

    // запишем в kpl-файл
    sprintf(key_name, "%s", "EntryNum");
    sprintf(key_value, "%ld", num_levels_in_palette - 2);
    WritePrivateProfileString("Palette", key_name, key_value, palette_file_name);

    sprintf(key_name, "%s", "ItemMin");
    sprintf(key_value, "%ld:%ld", palette_level[0].value, palette_level[0].rgb);
    WritePrivateProfileString("Items", key_name, key_value, palette_file_name);

    sprintf(key_name, "%s", "ItemMax");
    sprintf(key_value, "%ld:%ld", palette_level[num_levels_in_palette - 1].value, palette_level[num_levels_in_palette - 1].rgb);
    WritePrivateProfileString("Items", key_name, key_value, palette_file_name);

    for (palette_level_counter = 1; palette_level_counter < num_levels_in_palette - 1; palette_level_counter++)
    {
        sprintf(key_name, "Item%ld", palette_level[palette_level_counter].level_num);
        sprintf(key_value, "%ld:%ld", palette_level[palette_level_counter].value, palette_level[palette_level_counter].rgb);
        WritePrivateProfileString("Items", key_name, key_value, palette_file_name);
    }

    return 0;

} // long parse_palette( char* palette_file_name, char* palette_name, char* xml_file_name)

//   {
//      char tmp_str[1024];
//
//      sprintf(tmp_str,"(krtDrvRegister) begin xml\n");
//      MessageBox(NULL, tmp_str, "ѕредупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//   }

