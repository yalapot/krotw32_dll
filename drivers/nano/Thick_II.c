
#define thick_II_FILE_NAME "thick_II.idx"

char thick_II_file_path[1024];

FILE *thick_II_file_data;

short *thick_II_data = NULL;

long file_len;

int open_for_write_file_thick_II_data(char *data_path)
{
    strcpy(thick_II_file_path, data_path);
    strcat(thick_II_file_path, thick_II_FILE_NAME);

    thick_II_file_data = fopen(thick_II_file_path, "wb");
    if ( thick_II_file_data == NULL) {
        return 0;
    };

    return 1;
}

int write_file_thick_II_data(short data)
{
    if (thick_II_file_data != NULL)
    {
        return fwrite(&data, 1, sizeof(data), thick_II_file_data);
    }

    return 0;
}

void close_for_write_file_thick_II_data()
{
    if (thick_II_file_data != NULL)
    {
        fclose(thick_II_file_data);
        thick_II_file_data = NULL;
    }
}

int read_file_thick_II_data(char *data_path)
{
    long res_read = 0;

    strcpy(thick_II_file_path, data_path);
    strcat(thick_II_file_path, thick_II_FILE_NAME);

    thick_II_file_data = fopen(thick_II_file_path, "rb");
    if ( thick_II_file_data == NULL) {
        return 0;
    };

    // файл присутствует
    // посчитаем его длинну
    fseek(thick_II_file_data, 0, SEEK_END);
    file_len = ftell(thick_II_file_data);

    thick_II_data = malloc(file_len);

    fseek(thick_II_file_data, 0, SEEK_SET);

    res_read = fread(thick_II_data, 1, file_len, thick_II_file_data);

    fclose(thick_II_file_data);

    return 1;
}; // int init_file_thick_II_data()
