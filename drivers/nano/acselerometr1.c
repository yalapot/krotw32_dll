
#define acselerometr1_FILE_NAME "acselerometr1.idx"

#define acselerometr1_TYPE_VALUE short //long  // это для #одометры вместо акселерометров

#define acselerometr1_MAX_VALUE 1024 //20000000 // это для #одометры вместо акселерометров
#define acselerometr1_MIN_VALUE 0    //-20000000 // это для #одометры вместо акселерометров

char acselerometr1_file_path[1024];

FILE *acselerometr1_file_data;

acselerometr1_TYPE_VALUE *acselerometr1_data = NULL;

long file_len;

int open_for_write_file_acselerometr1_data(char *data_path)
{
    strcpy(acselerometr1_file_path, data_path);
    strcat(acselerometr1_file_path, acselerometr1_FILE_NAME);

    acselerometr1_file_data = fopen(acselerometr1_file_path, "wb");
    if ( acselerometr1_file_data == NULL) {
        return 0;
    };

    return 1;
}

int write_file_acselerometr1_data(acselerometr1_TYPE_VALUE data)
{
    if (acselerometr1_file_data != NULL)
    {
        return fwrite(&data, 1, sizeof(data), acselerometr1_file_data);
    }

    return 0;
}

void close_for_write_file_acselerometr1_data()
{
    if (acselerometr1_file_data != NULL)
    {
        fclose(acselerometr1_file_data);
        acselerometr1_file_data = NULL;
    }
}

int read_file_acselerometr1_data(char *data_path)
{
    long res_read = 0;

    strcpy(acselerometr1_file_path, data_path);
    strcat(acselerometr1_file_path, acselerometr1_FILE_NAME);

    acselerometr1_file_data = fopen(acselerometr1_file_path, "rb");
    if ( acselerometr1_file_data == NULL) {
        return 0;
    };

    // файл присутствует
    // посчитаем его длинну
    fseek(acselerometr1_file_data, 0, SEEK_END);
    file_len = ftell(acselerometr1_file_data);

    acselerometr1_data = malloc(file_len);

    fseek(acselerometr1_file_data, 0, SEEK_SET);

    res_read = fread(acselerometr1_data, 1, file_len, acselerometr1_file_data);

    fclose(acselerometr1_file_data);

//    {
//    char tmp[1024];
//    sprintf(tmp, "%ld", res_read);
//    MessageBox(NULL, tmp,"read_file_acselerometr1_data", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//    }

    return 1;
}; // int init_file_acselerometr1_data()

