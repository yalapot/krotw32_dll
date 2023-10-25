
#define acselerometr2_FILE_NAME "acselerometr2.idx"

#define acselerometr2_TYPE_VALUE short //long  // это для #одометры вместо акселерометров

#define acselerometr2_MAX_VALUE 1024 //20000000 // это для #одометры вместо акселерометров
#define acselerometr2_MIN_VALUE 0    //-20000000 // это для #одометры вместо акселерометров


char acselerometr2_file_path[1024];

FILE *acselerometr2_file_data;

acselerometr2_TYPE_VALUE *acselerometr2_data = NULL;

long file_len;

int open_for_write_file_acselerometr2_data(char *data_path)
{
    strcpy(acselerometr2_file_path, data_path);
    strcat(acselerometr2_file_path, acselerometr2_FILE_NAME);

    acselerometr2_file_data = fopen(acselerometr2_file_path, "wb");
    if ( acselerometr2_file_data == NULL) {
        return 0;
    };

    return 1;
}

int write_file_acselerometr2_data(acselerometr2_TYPE_VALUE data)
{
    if (acselerometr2_file_data != NULL)
    {
        return fwrite(&data, 1, sizeof(data), acselerometr2_file_data);
    }

    return 0;
}

void close_for_write_file_acselerometr2_data()
{
    if (acselerometr2_file_data != NULL)
    {
        fclose(acselerometr2_file_data);
        acselerometr2_file_data = NULL;
    }
}

int read_file_acselerometr2_data(char *data_path)
{
    long res_read = 0;

    strcpy(acselerometr2_file_path, data_path);
    strcat(acselerometr2_file_path, acselerometr2_FILE_NAME);

    acselerometr2_file_data = fopen(acselerometr2_file_path, "rb");
    if ( acselerometr2_file_data == NULL) {
        return 0;
    };

    // файл присутствует
    // посчитаем его длинну
    fseek(acselerometr2_file_data, 0, SEEK_END);
    file_len = ftell(acselerometr2_file_data);

    acselerometr2_data = malloc(file_len);

    fseek(acselerometr2_file_data, 0, SEEK_SET);

    res_read = fread(acselerometr2_data, 1, file_len, acselerometr2_file_data);

    fclose(acselerometr2_file_data);

//    {
//    char tmp[1024];
//    sprintf(tmp, "%ld", res_read);
//    MessageBox(NULL, tmp,"read_file_acselerometr2_data", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//    }

    return 1;
}; // int init_file_acselerometr2_data()

